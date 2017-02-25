-- openssl
local openssl = require("openssl")

local x509 = {}

function x509.gen_cert(self, csr, private_key, issuer)
  crt = openssl.x509.new(csr)
  crt:sign(
    private_key,
    crt,
    "sha512WithhRSAEncryption"
  )

  return crt:export("pem")
end

function x509.gen_csr(self, subject, extensions, private_key)
  local s_parse = function(self)
    s = {}
    for skey, svalue in pairs(subject) do
      if type(svalue) == "string" then
        table.insert(s, { [skey] = svalue })
      else
        for k, v in pairs(svalue) do
          table.insert(s, { [skey] = v })
        end
      end
    end

    return s
  end

  local sobj = openssl.x509.name.new(s_parse())
  local csr = openssl.x509.req.new(
    sobj,
    openssl.pkey.read(
      private_key,
      true
    ),
    "sha512WithRSAEncryption"
  )

  return csr:export("pem")
end

function x509.gen_ec_key(self)
  local private_key = openssl.pkey.new("ec", "secp384r1")
  return private_key:export()
end

function x509.gen_rsa_key(self, key_size)
  local private_key = openssl.pkey.new("rsa", key_size)
  return private_key:export()
end

return x509
