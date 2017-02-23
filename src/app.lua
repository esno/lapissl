local lapis = require("lapis")
local app = lapis.Application()

app:get("/v1/status", function(self)
  self.status = { status = "OK" }

  return { status = 200, json = self.status }
end)

return app
