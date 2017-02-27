-- lapis
local lapis = require("lapis")
local validate = require("lapis.validate")
local json_params = require("lapis.application").json_params

validate.validate_functions.is_authorized = function(input, authkey)
  return input and authkey and authkey == input, "Authentication Key does not match"
end

validate.validate_functions.one_of_elements = function(input, items)
  return input and items and items[input] ~= nil, "Missing element " .. input
end

-- x509
local x509 = require("x509")

-- lua
local io = require("io")

-- config
local config = require("config")

-- app
local app = lapis.Application()

app:get("/v1/status", function(self)
  local status = { status = "OK" }

  return { status = 200, json = status }
end)

app:post("/v1/x509/crt", json_params(function(self)
  local response = {}
  response.code = 201

  local val = validate.validate(self.params, {
    { "profile", exists = true, type = String, one_of_elements = { config.profiles } },
    { "authkey", exists = true, type = String, is_authorized = config.profiles[self.params.profile].auth_key },
    { "cn", exists = true, type = String },
    { "keytype", exists = true, type = String, one_of = { "ec", "rsa" } }
  })

  if val == nil then
    local profile = config.profiles[self.params.profile]
    local keytype = self.params.keytype
    local pkeys = nil

    if keytype == "ec" then
      pkeys = x509:gen_ec_key()
    else
      pkeys = x509:gen_rsa_key(4096)
    end

    local csr_subject = {}

    csr_subject.C = self.params.c or nil
    csr_subject.ST = self.params.st or nil
    csr_subject.L = self.params.l or nil
    csr_subject.O = self.params.o or nil
    csr_subject.OU = self.params.ou or nil
    csr_subject.emailAddress = self.params.email or nil
    csr_subject.CN = self.params.cn

    local csr = x509.gen_csr(csr_subject, pkeys)
    local crt = x509.gen_cert(csr, profile)

    if profile.issuer then
      local ca = {}
      local fh = io.open(config.data .. "/" .. profile.issuer .. ".crt.pem", "r")
      ca.file = {}
      ca.file.crt = fh:read "*a"
      fh:close()
      fh = io.open(config.data .. "/" .. profile.issuer .. ".key.pem", "r")
      ca.file.key = fh:read "*a"
      fh:close()
      crt = x509.sign_cert(x509.map_key(ca.file.key), crt, x509.map_cert(ca.file.crt))
    else
      crt = x509.sign_cert(pkeys, crt)
    end

    if crt then
      local fhCrt = io.open(config.data .. "/" .. csr_subject.CN .. ".crt.pem", "w")
      fhCrt:write(tostring(crt))
      fhCrt:close()
      if profile.basic_constraints.ca then
        local fhKey = io.open(config.data .. "/" .. csr_subject.CN .. ".key.pem", "w")
        fhKey:write(pkeys:toPEM("private"))
        fhKey:close()
      end
    end

    response.json = {
      key = pkeys:toPEM("private"),
      crt = tostring(crt),
      csr = tostring(csr)
    }

    return { status = response.code, json = response.json }
  else
    return { status = 400, json = { out = "error: bad request" } }
  end
end))

app:post("/v1/x509/csr", json_params(function(self)
  local response = {}
  response.code = 201

  local val = validate.validate(self.params, {
    { "cn", exists = true, type = String },
    { "keytype", exists = true, type = String, one_of = { "ec", "rsa" } }
  })

  if val == nil then
    local keytype = self.params.keytype
    local pkeys = nil

    if keytype == "ec" then
      pkeys = x509:gen_ec_key()
    else
      pkeys = x509:gen_rsa_key(4096)
    end

    local csr_subject = {}

    csr_subject.C = self.params.c or nil
    csr_subject.ST = self.params.st or nil
    csr_subject.L = self.params.l or nil
    csr_subject.O = self.params.o or nil
    csr_subject.OU = self.params.ou or nil
    csr_subject.emailAddress = self.params.email or nil
    csr_subject.CN = self.params.cn

    local csr = x509.gen_csr(csr_subject, pkeys)

    response.json = {
      key = pkeys:toPEM("private"),
      csr = tostring(csr)
    }

    return { status = response.code, json = response.json }
  else
    return { status = 400, json = { out = "error: bad request" } }
  end
end))

app:post("/v1/x509/sign", json_params(function(self)
  local response = {}
  response.code = 201

  local val = validate.validate(self.params, {
    { "profile", exists = true, type = String, one_of_elements = { config.profiles } },
    { "authkey", exists = true, type = String, is_authorized = config.profiles[self.params.profile].auth_key },
    { "csr", exists = true, type = String }
  })

  if val == nil then
    local profile = config.profiles[self.params.profile]
    local pkeys = nil
    local crt = x509.gen_cert(x509.map_csr(self.params.csr), profile)

    if profile.issuer then
      local ca = {}
      local fh = io.open(config.data .. "/" .. profile.issuer .. ".crt.pem", "r")
      ca.file = {}
      ca.file.crt = fh:read "*a"
      fh:close()
      fh = io.open(config.data .. "/" .. profile.issuer .. ".key.pem", "r")
      ca.file.key = fh:read "*a"
      crt = x509.sign_cert(
        x509.map_key(ca.file.key),
        crt,
        x509.map_cert(ca.file.crt)
      )
    else
      x509.sign_cert(pkeys, crt)
    end

    response.json = {
      crt = tostring(crt)
    }

    return { status = response.code, json = response.json }
  else
    return { status = 400, json = { out = "error: bad request" } }
  end
end))

return app
