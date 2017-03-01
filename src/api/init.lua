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
        for k, context in pairs(definition.get) do
          api.app:get(
            "/" .. version .. "/" .. endpoint .. context.context,
            json_params(function(self) return context:callable(self.params) end)
          )
        end
      end
      if definition.post then
        for k, context in pairs(definition.post) do
          api.app:post(
            "/" .. version .. "/" .. endpoint .. context.context,
            json_params(function(self) return context:callable(self.params) end)
          )
        end
      end
    end
  end
end

return api
