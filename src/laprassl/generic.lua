local config = require('config')

local laprasslGeneric = {}

function laprasslGeneric.isAdmin(self, token)
  if config.admin == token then
    return true
  end
  return nil
end

return laprasslGeneric
