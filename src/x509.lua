-- openssl
local openssl = require("openssl")
local openssl_pkey = require("openssl.pkey")
local openssl_x509 = require("openssl.x509")
local openssl_x509_csr = require("openssl.x509.csr")
local openssl_x509_name = require("openssl.x509.name")

-- math
local math = require("math")

local x509 = {}

function x509.gen_cert(csr, profile, pkeys)
  local crt = openssl_x509.new()

  constraints = {}
  if profile.basic_constraints.ca == true then
    crt:setBasicConstraints{ CA = true }
    crt:setBasicConstraintsCritical(true)
  else
    crt:setBasicConstraints{ CA = true }
  end

  if profile.basic_constraints.pathlen then
    current = crt:getBasicConstraints("CA")
    crt:setBasicConstraints{ CA = current, pathLen = profile.basic_constraints.pathlen }
  end

  crt:setVersion(csr:getVersion())
  crt:setSerial(math.random(1, 65535))
  crt:setSubject(csr:getSubject())
  crt:setIssuer(crt:getSubject())
  crt:setPublicKey(csr:getPublicKey())
  crt:sign(pkeys)

  return crt
end

function x509.gen_csr(self, subject, pkeys)
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
  csr:setVersion(3)
  csr:setSubject(sobj)
  csr:setPublicKey(pkeys)

  return csr
end

function x509.gen_ec_key()
  local key = openssl_pkey.new{ type = "EC", curve = "secp384r1" }
  return key
end

function x509.gen_rsa_key(key_size)
  local key openssl_pkey.new{ type = "RSA", bits = key_size }
  return key
end

return x509
