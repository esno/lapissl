pkey = require("openssl.pkey")

local key = {}

function key.mkKey(self, keyType, keySize)
  if 'ec' == keyType then
    newKey = pkey.new{ type = "EC", curve = "secp384r1" }
  elseif "rsa" == keyType then
    newKey = pkey.new{ type = "RSA", bits = keySize }
  end

  return newKey
end

return key
