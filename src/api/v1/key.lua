-- laprassl
validation = require("laprassl.validation")
-- luaossl
pkey = require("openssl.pkey")

local func = {}

function func.create_key(self, params)
  local response = {}

  local valid = validation:validate(params, {
    { "keytype", exists = true, type = String, one_of = { "ec", "rsa" } }
  })

  if not valid then
    if "ec" == params.keytype then
      key = pkey.new{ type = "EC", curve = "secp384r1" }
    elseif "rsa" == params.keytype then
      valid = validation:validate(params, {
        { "keysize", exists = true, type = Number, one_of = { 1024, 2048, 4096 } }
      })

      if not valid then
        key = pkey.new{ type = "RSA", bits = params.keysize }
      else
        response = { code = 400, ret = { msg = "Missing keysize parameter" } }
      end
    end

    if not response.code then
      response = { code = 200, ret = { key = key:toPEM("private") } }
    end
  else
    response = { code = 400, ret = { msg = valid.type } }
  end

  return { status = response.code, json = response.ret }
end

local key = {
  post = {
    { context = "", callable = func.create_key }
  }
}

return key
