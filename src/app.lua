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
  status = { status = "OK" }

  return { status = 200, json = status }
end)

app:post("/v1/x509/cert", json_params(function(self)
  val = validate(self.params, {
    { "key", exists = true, type = String },
    { "profile", exists = true, type = String },
    { "cn", exists = true }
  })

  response = { out = config.data }

  if val == nil then
    return { status = 200, json = response }
  else
    return { status = 400, json = response }
  end
end))

return app
