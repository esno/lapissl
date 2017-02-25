-- lapis
local lapis = require("lapis")
local validate = require("lapis.validate")
local json_params = require("lapis.application").json_params

validate.validate_functions.one_of_elements = function(input, items)
  return input and items and items[input] ~= nil, "Missing element " .. input
end

-- x509
local x509 = require("x509")

-- config
local config = {
  data = "./data",
  profiles = {
    rootca = {
      basic_constraints = {
        critical = true,
        ca = true,
        pathlen = 0
      },
      key_usage = {
        "Certificate Signer",
        "CRL Signer"
      },
      expiry = "50y"
    }
  }
}

-- app
local app = lapis.Application()

app:get("/v1/status", function(self)
  local status = { status = "OK" }

  return { status = 200, json = status }
end)

app:post("/v1/x509/cert", json_params(function(self)
  local response = {}
  response.code = 200

  local val = validate.validate(self.params, {
    { "authkey", exists = true, type = String },
    { "profile", exists = true, type = String, one_of_elements = { config.profiles } },
    { "cn", exists = true, type = String },
    { "keytype", exists = true, type = String, one_of = { "ec", "rsa" } }
  })

  if val == nil then
    local profile = config.profiles[self.params.profile]
    local keytype = self.params.keytype
    local privkey = nil

    if keytype == "ec" then
      privkey = x509:gen_ec_key()
    else
      privkey = x509:gen_rsa_key(4096)
    end

    csr_subject = {}

    csr_subject.C = self.params.c or nil
    csr_subject.ST = self.params.st or nil
    csr_subject.L = self.params.l or nil
    csr_subject.O = self.params.o or nil
    csr_subject.OU = self.params.ou or nil
    csr_subject.emailAddress = self.params.email or nil
    csr_subject.CN = self.params.cn

    csr = x509:gen_csr(csr_subject, privkey)

    response.json = {
      private_key = privkey,
      csr = csr
    }

    return { status = response.code, json = response.json }
  else
    return { status = 400, json = { out = "error: bad request" } }
  end
end))

return app
