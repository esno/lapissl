-- lapis
local validate = require("lapis.validate")

validate.validate_functions.is_authorized = function(input, authkey)
  return input and authkey and authkey == input, "Authentication Key does not match"
end

local validation = {
}

function validation.validate(self, params, checks)
  return validate.validate(params, checks)
end

return validation
