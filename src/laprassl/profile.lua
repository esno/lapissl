local sqlite3 = require('lsqlite3')
local config = require('config')
local db = sqlite3.open(config.sqlite)

local laprasslProfile = {}

function laprasslProfile.mkProfile(self, values)
  local query = 'INSERT INTO profiles'
  local rows = {}
  local pattern = {}
  local input = {}
  local i = 0

  input.name = values.name or nil
  input.expiry = values.expiry or nil
  input.c = values.x509.subject.C or nil
  input.st = values.x509.subject.ST or nil
  input.l = values.x509.subject.L or nil
  input.o = values.x509.subject.O or nil
  input.ou = values.x509.subject.OU or nil
  input.ca = values.x509.basicConstraints.cA or nil
  input.pathlenconstraints = values.x509.basicConstraints.pathLenConstraints or nil
  input.digitalSignature = values.x509.keyUsage.digitalSiganture or nil
  input.nonRepudiation = values.x509.keyUsage.nonRepudiation or nil
  input.keyEncipherment = values.x509.keyUsage.keyEncipherment or nil
  input.dataEncipherment = values.x509.keyUsage.dataEncipherment or nil
  input.keyAgreement = values.x509.keyUsage.keyAgreement or nil
  input.keyCertSign = values.x509.keyUsage.keyCertSign or nil
  input.cRLSign = values.x509.keyUsage.cRLSign or nil
  input.encipherOnly = values.x509.keyUsage.encipherOnly or nil
  input.decipherOnly = values.x509.keyUsage.decipherOnly or nil

  for k, v in pairs(input) do
    i = i + 1
    rows[i] = k
    table.insert(pattern, '?')
  end

  query = query .. ' (' .. table.concat(rows, ', ') .. ')' ..
    ' VALUES (' .. table.concat(pattern, ', ') .. ')'

  local stmt = db:prepare(query)

  while i > 0 do
    stmt:bind(i, input[rows[i]])
    i = i - 1
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
