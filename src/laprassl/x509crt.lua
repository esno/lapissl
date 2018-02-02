local laprassl = require('laprassl.generic')
local laprasslProfile = require('laprassl.profile')
local luna = require('luna.helper')
local sqlite3 = require('lsqlite3')
local config = require('config')
local x509name = require("openssl.x509.name")
local x509csr = require("openssl.x509.csr")
local x509ext = require("openssl.x509.extension")
local x509 = require("openssl.x509")
local pkey = require("openssl.pkey")
local db = sqlite3.open(config.sqlite)
local lrandom = require('random')

local x509crt = {}

local _persistCrt = function(crt, key, token, signer)
  local serial = tostring(crt:getSerial())
  local _, notafter = crt:getLifetime()
  local stmt = db:prepare('INSERT INTO x509 (serial, notafter, crt, key, token) VALUES (?, ?, ?, ?, ?)')
  stmt:bind_values(serial, notafter, tostring(crt), key, token or '')
  if stmt:step() == sqlite3.DONE then
    if signer then
      local update = db:prepare('UPDATE x509 SET signer = ? WHERE serial = ?')
      update:bind_values(signer, serial)
      update:step()
      update:finalize()
    end
    stmt:finalize()
    return true
  end
  stmt:finalize()
  return false
end

local _mkSerial = function()
  local stmt = db:prepare('SELECT serial FROM x509')
  local serial = nil
  local ret = stmt:step()
  if ret == sqlite3.DONE or ret == sqlite3.ROW then
    local serials = {}
    for r in stmt:nrows() do
      table.insert(serials, r.serial)
    end
    local r = lrandom.new(os.time())
    repeat
      serial = r(1, 65535)
      for k, v in pairs(serials) do
        if serial == v then
          serial = nil
          break
        end
      end
    until serial ~= nil
  end
  stmt:finalize()
  return serial
end

local _getSigner = function(signer)
  local stmt = db:prepare('SELECT * FROM x509 WHERE id = ?')
  stmt:bind_values(signer)
  local signer = nil
  if stmt:step() == sqlite3.DONE then
    signer = stmt:nrows()
  end
  stmt:finalize()
  return signer
end

local _mkCsr = function(params, profile)
  local sobj = x509name.new()
  for k, v in pairs(profile) do
    if k == 'c' then sobj:add('C', v) end
    if k == 'st' then sobj:add('ST', v) end
    if k == 'l' then sobj:add('L', v) end
    if k == 'o' then sobj:add('O', v) end
    if k == 'ou' then sobj:add('OU', v) end
    if k == 'emailaddress' then sobj:add('emailAddress', v) end
  end
  if params.cn then
    sobj:add('CN', params.cn)
  end

  local csr = x509csr.new()
  local key = pkey.new(params.key)

  csr:setPublicKey(key)
  csr:setVersion(3)
  csr:setSubject(sobj)
  csr:sign(key)

  return csr
end

local _mkCrt = function(req, profile, signer)
  local crt = x509.new()
  crt:setPublicKey(req.csr:getPublicKey())
  crt:setVersion(req.csr:getVersion())

  local issued, expires = crt:getLifetime()
  crt:setLifetime(issued, (profile.expiry * 24 * 60 * 60) + expires)

  if profile.ca == true then
    crt:setBasicConstraints{ cA = true, pathLen = profile.pathlen or 0 }
  else
    crt:setBasicConstraints{ cA = false }
  end

  local keyUsage = 'critical'
  if profile.digitalSignature == 'true' then keyUsage = keyUsage .. ',digitalSignature' end
  if profile.nonRepudiation == 'true' then keyUsage = keyUsage .. ',nonRepudiation' end
  if profile.keyEncipherment == 'true' then keyUsage = keyUsage .. ',keyEncipherment' end
  if profile.dataEncipherment == 'true' then keyUsage = keyUsage .. ',dataEncipherment' end
  if profile.keyAgreement == 'true' then keyUsage = keyUsage .. ',keyAgreement' end
  if profile.keyCertSign == 'true' then keyUsage = keyUsage .. ',keyCertSign' end
  if profile.cRLSign == 'true' then keyUsage = keyUsage .. ',cRLSign' end
  if profile.encipherOnly == 'true' then keyUsage = keyUsage .. ',encipherOnly' end
  if profile.decipherOnly == 'true' then keyUsage = keyUsage .. ',decipherOnly' end
  if keyUsage ~= 'critical' then
    crt:addExtension(x509ext.new('keyUsage', keyUsage))
  end

  local extKeyUsage = 'critical'
  if profile.serverAuth == 'true' then extKeyUsage = extKeyUsage .. ',serverAuth' end
  if profile.clientAuth == 'true' then extKeyUsage = extKeyUsage .. ',clientAuth' end
  if profile.codeSigning == 'true' then extKeyUsage = extKeyUsage .. ',codeSigning' end
  if profile.emailProtection == 'true' then extKeyUsage = extKeyUsage .. ',emailProtection' end
  if profile.timeStamping == 'true' then extKeyUsage = extKeyUsage .. ',timeStamping' end
  if profile.OCSPSigning == 'true' then extKeyUsage = extKeyUsage .. ',OCSPSigning' end
  if profile.ipsecIKE == 'true' then extKeyUsage = extKeyUsage .. ',ipsecIKE' end
  if profile.msCodeInd == 'true' then extKeyUsage = extKeyUsage .. ',msCodeInd' end
  if profile.msCodeCom == 'true' then extKeyUsage = extKeyUsage .. ',msCodeCom' end
  if profile.msCTLSign == 'true' then extKeyUsage = extKeyUsage .. ',msCTLSign' end
  if profile.msEFS == 'true' then extKeyUsage = extKeyUsage .. ',msEFS' end
  if extKeyUsage ~= 'critical' then
    crt:addExtension(x509ext.new('extendedKeyUsage', extKeyUsage))
  end

  crt:setSerial(_mkSerial())
  crt:setSubject(req.csr:getSubject())
  crt:setBasicConstraintsCritical(true)

  crt:addExtension(x509ext.new('subjectKeyIdentifier', 'hash', { subject = crt }))

  if signer then
    local issuer = x509.new(signer.crt, 'PEM')
    crt:setIssuer(issuer:getSubject())
    crt:addExtension(x509ext.new('authorityKeyIdentifier', 'keyid:always', { issuer = issuer }))
    crt:sign(pkey.new(signer.key))
  else
    crt:setIssuer(crt:getSubject())
    crt:addExtension(x509ext.new('authorityKeyIdentifier', 'keyid:always', { issuer = crt }))
    crt:sign(pkey.new(req.key))
  end

  if not _persistCrt(crt, req.key, req.token, (signer or {}).serial or nil) then
    return nil
  end

  return crt
end

function x509crt.post(self)
  local params = self.params
  local headers = self.req.headers
  local input = luna:validate({
    profile = 'string',
    key = 'string',
    x509 = {
      cn = 'string'
    }
  }, params)
  if not input then
    local profile = laprasslProfile:getProfile(params.profile)
    if profile then
      if profile.ca == "true" and
          laprassl:isAdmin(luna:getAuthToken(headers)) or profile.ca == "false"then
        local signer = nil
        if params.signer then
          signer = _getSigner(params.signer)
          if profile.ca == false and
              laprassl:getAuthToken(headers) ~= signer.token then
            return {
              status = 403,
              json = {
                status = 403,
                reason = 'wrong token'
              }
            }
          else
            if not params.token then
              return {
                status = 400,
                json = {
                  status = 400,
                  reason = 'missing parameter'
                }
              }
            end
          end
        end
        local csr = _mkCsr(params, profile)
        local crt = _mkCrt({ csr = csr, key = params.key, token = params.token or nil }, profile, signer)
        if crt then
          return {
            status = 201,
            json = {
              status = 201,
              reason = 'Created',
              crt = tostring(crt)
            }
          }
        else
          return {
            status = 500,
            json = {
              status = 500,
              reason = 'cannot create certificate'
            }
          }
        end
      end
    else
      return {
        status = 404,
        reason = 'profile not found'
      }
    end
  end
  return {
    status = 400,
    json = {
      status = 400,
      reason = 'missing or wrong parameter'
    }
  }
end

return x509crt
