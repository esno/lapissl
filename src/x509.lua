-- openssl
local openssl = require("openssl")
local openssl_pkey = require("openssl.pkey")
local openssl_x509 = require("openssl.x509")
local openssl_x509_csr = require("openssl.x509.csr")
local openssl_x509_extension = require("openssl.x509.extension")
local openssl_x509_name = require("openssl.x509.name")

-- math
local math = require("math")

-- module
local x509 = {}

function x509.gen_cert(csr, profile)
  local crt = openssl_x509.new()
  crt:setPublicKey(csr:getPublicKey())
  crt:setVersion(csr:getVersion())

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

  constraints = {}
  if profile.basic_constraints.ca == true then
    crt:setBasicConstraints{ CA = true }
  else
    crt:setBasicConstraints{ CA = false }
  end

  if crt:getBasicConstraints("CA") == true then
    current = crt:getBasicConstraints("CA")
    crt:setBasicConstraints{ CA = current, pathLen = profile.basic_constraints.pathlen or 0 }
  end

  usage = "critical"
  for kkey, kvalue in pairs(profile.key_usage) do
    usage = usage .. "," .. kvalue
  end

  if usage ~= "critical" then
    crt:addExtension(openssl_x509_extension.new("keyUsage", usage))
  end

  crt:setSerial(math.random(1, 65535))
  crt:setSubject(csr:getSubject())
  crt:setBasicConstraintsCritical(true)
  crt:setKeyIdentifier("subjectKeyIdentifier")

  return crt
end

function x509.sign_cert(pkeys, crt, ca)
  if ca then
    crt:setIssuer(ca:getSubject())
    crt:setKeyIdentifier("authorityKeyIdentifier", ca)
  else
    crt:setIssuer(crt:getSubject())
    crt:setKeyIdentifier("authorityKeyIdentifier")
  end

  crt:sign(pkeys)

  return crt
end

function x509.gen_csr(subject, pkeys)
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
  csr:setPublicKey(pkeys)
  csr:setVersion(3)
  csr:setSubject(sobj)
  csr:sign(pkeys)

  return csr
end

function x509.gen_ec_key(self)
  local key = openssl_pkey.new{ type = "EC", curve = "secp384r1" }
  return key
end

function x509.gen_rsa_key(self, key_size)
  local key openssl_pkey.new{ type = "RSA", bits = key_size }
  if not key then
    print("failed generating key " .. tostring(key_size))
  end
  return key
end

function x509.map_cert(crt)
  return openssl_x509.new(crt)
end

function x509.map_csr(csr)
  return openssl_x509_csr.new(csr)
end

function x509.map_key(key)
  return openssl_pkey.new(key)
end

return x509
