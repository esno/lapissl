-- lapis
local lapis = require("lapis")
local validate = require("lapis.validate").validate
local json_params = require("lapis.application").json_params

local app = lapis.Application()

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

app:get("/v1/status", function(self)
  local status = { status = "OK" }

  return { status = 200, json = status }
end)

app:post("/v1/x509/cert", json_params(function(self)
  local response = {}
  response.code = 200

  local val = validate(self.params, {
    { "key", exists = true, type = String },
    { "profile", exists = true, type = String },
    { "cn", exists = true }
  })

  local profile = config.profiles[self.params.profile]

  if val == nil then
    if profile ~= nil then
      response.json = { out = config.profiles[self.params.profile].expiry }
    else
      response.code = 400
      response.json = { out = "error: profile not defined" }
    end

    return { status = response.code, json = response.json }
  else
    return { status = 400, json = { out = "error: bad request" } }
  end
end))

return app
