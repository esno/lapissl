-- laprassl
validation = require("laprassl.validation")
laprassl_x509 = require("laprassl.x509")

local func = {}

function func.create_csr(self, params)
  local x509csr = laprassl_x509
  local response = {}

  local invalid = validation:validate(params, {
    { "cn", exists = true, type = String },
    { "key", exists = true, type = String }
  })

  if not invalid then
    local subject = {}
    subject.C = params.c or nil
    subject.ST = params.st or nil
    subject.L = params.l or nil
    subject.O = params.o or nil
    subject.OU = params.ou or nil
    subject.emailAddress = params.email or nil
    subject.CN = params.cn or nil

    local csr = x509csr:create_csr(subject, params.key)

    response = {
      code = 201,
      ret = {
        csr = tostring(csr)
      }
    }
  else
    response = { code = 400, ret = { msg = "Missing cn or key parameter" } }
  end

  return { status = response.code, json = response.ret }
end

local x509 = {
  post = {
    { context = "/csr", callable = func.create_csr }
  }
}

return x509
