local sqlite3 = require('lsqlite3')
local config = require('config')
local db = sqlite3.open(config.sqlite)

local laprasslProfile = {}

function laprasslProfile.mkProfile(self, values)
  local query = 'INSERT INTO profiles'
  local rows = {}
  local pattern = {}
  local i = 0

  for k, v in pairs(values) do
    rows[i] = k
    table.insert(pattern, '?')
    i = i + 1
  end

  query = query .. ' (' table.concat(rows, ', ') .. ')' ..
    ' VALUES (' .. table.concat(pattern, ', ') .. ')'

  local stmt = db:prepare(query)

  while i >= 0 do
    i = i - 1
    stmt:bind(i, values[rows[i]])
  end

  local ret = stmt:step()
  stmt:finalize()
  db:close()

  if ret == sqlite3.DONE then
    return true
  end
  return nil
end

return laprasslProfile
