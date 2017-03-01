-- laprassl
validation = require("laprassl.validation")
-- luaossl
pkey = require("openssl.pkey")

local func = {}

function func.create_key(self, params)
  local response = {}

  local invalid = validation:validate(params, {
    { "keytype", exists = true, type = String, one_of = { "ec", "rsa" } }
  })

  if not invalid then
    if "ec" == params.keytype then
      key = pkey.new{ type = "EC", curve = "secp384r1" }
      response = { code = 201, ret = { key = key:toPEM("private") } }
    elseif "rsa" == params.keytype then
      invalid = validation:validate(params, {
        { "keysize", exists = true, type = Number, one_of = { 1024, 2048, 4096 } }
      })

      if not invalid then
        key = pkey.new{ type = "RSA", bits = params.keysize }
        response = { code = 201, ret = { key = key:toPEM("private") } }
      else
        response = { code = 400, ret = { msg = "Missing keysize parameter" } }
      end
    end
  else
    response = { code = 400, ret = { msg = "Missing keytype parameter" } }
  end

  return { status = response.code, json = response.ret }
end

local key = {
  post = {
    { context = "", callable = func.create_key }
  }
}

return key
