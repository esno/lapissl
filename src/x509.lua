-- openssl
local openssl = require("openssl")

local x509 = {}

function x509.gen_csr(self, subject, private_key)
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

  local e_parse = function(self)
    e = {}
    for ekey, evalue in pairs({ extensions }) do
      for k, v in pairs(evalue) do
        if k == "ca" and v == true then
          new = {
            critical = true,
            object = "cA",
            value = "TRUE"
          }
          table.insert(e, new)
        elseif k == "pathlen" then
          new = {
            critical = false,
            object = "pathLenConstraint",
            value = v
          }
          table.insert(e, new)
        end
      end
    end

    return e
  end

  local sobj = openssl.x509.name.new(s_parse())
  --local eobj = openssl.x509.extension.new_extension(e_parse())

  local csr = openssl.x509.req.new(
    sobj,
    --eobj,
    --nil,
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
