-- lapis
local lapis = require("lapis")
local validate = require("lapis.validate")
local json_params = require("lapis.application").json_params

validate.validate_functions.one_of_elements = function(input, items)
  return input and items and items[input] ~= nil, "Missing element " .. input
end

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
    { "key", exists = true, type = String },
    { "profile", exists = true, type = String, one_of_elements = { config.profiles } },
    { "cn", exists = true, type = String }
  })

  if val == nil then
    local profile = config.profiles[self.params.profile]
    response.json = { out = config.profiles[profile].expiry }

    return { status = response.code, json = response.json }
  else
    return { status = 400, json = { out = "error: bad request" } }
  end
end))

return app
