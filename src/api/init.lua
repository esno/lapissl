-- lapis
local lapis = require("lapis")
local json_params = require("lapis.application").json_params

-- api
local api = {
  version = {
    v1 = require("api.v1.init")
  },
  app = lapis.Application()
}

function api.init(self)
  for version, blueprint in pairs(api.version) do
    for endpoint, definition in pairs(blueprint) do
      if definition.get then
        for _, ctx in pairs(definition.get) do
          if ctx.context then
            api.app:get(
              "/" .. version .. "/" .. endpoint .. ctx.context,
              json_params(function(self) return ctx:callable(self.params) end)
            )
          end
        end
      end
      if definition.post then
        for _, ctx in pairs(definition.post) do
          if ctx.context then
            api.app:post(
              "/" .. version .. "/" .. endpoint .. ctx.context,
              json_params(function(self) return ctx:callable(self.params) end)
            )
          end
        end
      end
    end
  end
end

return api
