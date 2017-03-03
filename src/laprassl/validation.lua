-- lapis
local validate = require("lapis.validate")
-- laprassl
config = require("config")

validate.validate_functions.one_of_keys = function(input, items)
  return input and items and items[input] ~= nil, "Missing element " .. input
end

validate.validate_functions.is_authorized = function(input, authkey)
  return input and authkey and authkey == input, "Authentication Key does not match"
end

validate.validate_functions.issuer_exists = function(input)
  local fh = io.open(config.data .. "/" .. input .. ".crt.pem", "r")
  local ret = false
  if fh then
    fh:close()
    fh = io.open(config.data .. "/" .. input .. ".key.pem", "r")
    if fh then
      fh:close()
      ret = true
    end
  end
  return ret, "Issuer does not exist"
end

local validation = {
}

function validation.validate(self, params, checks)
  return validate.validate(params, checks)
end

return validation
