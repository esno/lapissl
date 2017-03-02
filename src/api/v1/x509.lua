-- laprassl
validation = require("laprassl.validation")
laprassl_x509 = require("laprassl.x509")
config = require("config")

local func = {}

function func.create_crt(elf, params)
  local x509crt = laprassl_x509
  local response = {}

  local invalid = validation:validate(params, {
    { "profile", exists = true, type = String, one_of_keys = { config.profiles } },
    { "csr", exists = true, type = String }
  })

  if not invalid then
    invalid = validation:validate(params, {
      { "authkey", exists = true, type = String, is_authorized = config.profiles[params.profile].authkey }
    })

    if not invalid then
      profile = config.profiles[params.profile]
      crt = x509crt:create_crt(params.csr, profile)

      invalid = validation:validate(params, {
        { "issuer", exists = true, type = String, issuer_exists = true }
      })

      if not invalid then
        local fh = io.open(config.data .. "/" .. params.issuer .. ".crt.pem", "r")
        local ca = {}
        ca.crt = fh:read "*a"
        fh:close()
        fh = io.open(config.data .. "/" .. params.issuer .. ".key.pem", "r")
        ca.key = fh:read "*a"
        fh:close()
        crt = x509crt:sign_crt(crt, ca.key, ca.crt)
        response = { code = 201, ret = { crt = crt } }
      else
        response = { code = 400, ret = { msg = "Missing issuer parameter" } }
      end

      invalid = validation:validate(params, {
        { "key", exists = true, type = String }
      })

      if not invalid then
        crt = x509crt:sign_crt(crt, key, crt)
        response = { code = 201, ret = { crt = crt } }
      else
        response = { code = 400, ret = { msg = "Missing key parameter" } }
      end
    else
      response = { code = 400, ret = { msg = "Missing authkey parameter" } }
    end
  else
    response = { code = 400, ret = { msg = "Missing profile or csr parameter" } }
  end

  return { status = response.code, json = response.ret }
end

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

    response = { code = 201, ret = { csr = tostring(csr) } }
  else
    response = { code = 400, ret = { msg = "Missing cn or key parameter" } }
  end

  return { status = response.code, json = response.ret }
end

local x509 = {
  post = {
    { context = "/crt", callable = func.create_crt },
    { context = "/csr", callable = func.create_csr }
  }
}

return x509
