local lapis = require("lapis")
local json = require("json")

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

app:get("/v1/x509/cert", function(self)
  response = { out = config.data }

  return { status = 200, json = response }
end)

return app
