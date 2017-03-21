-- luua
local io = require("io")
local math = require("math")
-- luaossl
local openssl_x509 = require("openssl.x509")
local openssl_x509_csr = require("openssl.x509.csr")
local openssl_x509_extension = require("openssl.x509.extension")
local openssl_x509_name = require("openssl.x509.name")
local openssl_pkey = require("openssl.pkey")

local x509 = {}

function x509.create_crt(self, csr, profile)
  local req = openssl_x509_csr.new(csr)
  local crt = openssl_x509.new()

  crt:setPublicKey(req:getPublicKey())
  crt:setVersion(req:getVersion())

  local _conv_time = function(time)
    local unit = string.sub(time, -1)
    local range = tonumber(string.sub(time, 0, string.len(time) - 1))
    local ret = 0

    if unit == "y" then
      ret = range * 365 * 24 * 60 * 60
    end

    if unit == "d" then
      ret = range * 24 * 60 * 60
    end

    return ret
  end

  local issued, expires = crt:getLifetime()
  crt:setLifetime(issued, _conv_time(profile.expiry) + expires)

  if profile.basic_constraints then
    if profile.basic_constraints.ca == true then
      crt:setBasicConstraints{ CA = true }
    else
      crt:setBasicConstraints{ CA = false }
    end

    if crt:getBasicConstraints("CA") == true then
      local current = crt:getBasicConstraints("CA")
      crt:setBasicConstraints{ CA = current, pathLen = profile.basic_constraints.pathlen or 0 }
    end
  else
    crt:setBasicConstraints{ CA = false }
  end

  usage = "critical"
  for kkey, kvalue in pairs(profile.key_usage) do
    usage = usage .. "," .. kvalue
  end

  if usage ~= "critical" then
    crt:addExtension(openssl_x509_extension.new("keyUsage", usage))
  end

  if profile.extended_key_usage then
    usage = "critical"
    for kkey, kvalue in pairs(profile.extended_key_usage) do
      usage = usage .. "," .. kvalue
    end

    if usage ~= "critical" then
      crt:addExtension(openssl_x509_extension.new("extendedKeyUsage", usage))
    end
  end

  crt:setSerial(math.random(1, 65535))
  crt:setSubject(req:getSubject())
  crt:setBasicConstraintsCritical(true)
  crt:setKeyIdentifier("subjectKeyIdentifier")

  return crt
end

function x509.sign_crt(self, crt, key, ca)
  if type(key) == "string" then pkey = openssl_pkey.new(key) else pkey = key end
  if type(crt) == "string" then subject = openssl_x509.new(crt) else subject = crt end
  if type(ca) == "string" then issuer = openssl_x509.new(ca) else issuer = ca end

  if ca or issuer then
    subject:setIssuer(issuer:getSubject())
    subject:setKeyIdentifier("authorityKeyIdentifier", issuer)
  else
    subject:setIssuer(subject:getSubject())
    subject:setKeyIdentifier("authorityKeyIdentifier")
  end

  subject:sign(pkey)

  return subject
end

function x509.create_csr(self, subject, key)
  local sobj = openssl_x509_name.new()

  for skey, svalue in pairs(subject) do
    if type(svalue) == "string" then
      sobj:add(skey, svalue)
    else
      for k, v in pairs(svalue) do
        sobj:add(skey, v)
      end
    end
  end

  local csr = openssl_x509_csr.new()
  local pkey = openssl_pkey.new(key)

  csr:setPublicKey(pkey)
  csr:setVersion(3)
  csr:setSubject(sobj)
  csr:sign(pkey)

  return csr
end

function x509.tocrt(self, crt)
  return openssl_x509.new(crt)
end

return x509
