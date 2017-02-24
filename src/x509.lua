-- openssl
local openssl = require("openssl")

local x509 = {}

function x509.gen_csr(self, subject, extension, attribute, private_key)
  local csr = openssl.x509.req.new(
    openssl.x509.name.new(subject),
    openssl.x509.extensions.new:extension(extensions),
    openssl.x509.attr.new_attribute(attributes),
    openssl.pkey.read(
      private_key,
      true
    ),
    "sha256WithRSAEncryption"
  )

  return csr:export("pem", false)
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
