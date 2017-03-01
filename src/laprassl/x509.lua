-- luaossl
openssl_x509_csr = require("openssl.x509.csr")
openssl_x509_name = require("openssl.x509.name")
openssl_pkey = require("openssl.pkey")

local x509 = {}

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

return x509
