-- api/v1/key
local func = {}

function func.create_key(self)
  return { status = 200, json = "hello world" }
end

local key = {
  get = {
    { context = "", callable = func.create_key }
  }
}

return key
