local sqlite3 = require('lsqlite3')
local config = require('config')
local db = sqlite3.open(config.sqlite)

db:exec[[
  CREATE TABLE IF NOT EXISTS version (id INTEGER PRIMARY KEY)
]]

local migrations = {
  [1] = function()
    db:exec[[
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name,
        x509subject INTEGER,
        x509basicconstraints INTEGER,
        x509keyusage INTEGER,
        expiry INTEGER
      )
    ]]

    db:exec[[
      CREATE TABLE x509subject (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cn, c, st, l, o, ou
      )
    ]]

    db:exec[[
      CREATE TABLE x509basicconstraints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ca BOOLEAN DEFAULT 0,
        pathlenconstraints INTEGER
      )
    ]]

    db:exec[[
      CREATE TABLE x509keyusage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        digitalSignature BOOLEAN DEFAULT 0,
        nonRepudiation BOOLEAN DEFAULT 0,
        keyEncipherment BOOLEAN DEFAULT 0,
        dataEncipherment BOOLEAN DEFAULT 0,
        keyAgreement BOOLEAN DEFAULT 0,
        keyCertSign BOOLEAN DEFAULT 0,
        cRLSign BOOLEAN DEFAULT 0,
        encipherOnly BOOLEAN DEFAULT 0,
        decipherOnly BOOLEAN DEFAULT 0
      )
    ]]

    db:exec[[
      CREATE TABLE x509 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name,
        serial INTEGER,
        notbefore INTEGER,
        notafter INTEGER,
        crt,
        key,
        revoked BOOLEAN DEFAULT 0
      )
    ]]
  end
}

for k, v in ipairs(migrations) do
  local stmt = db:prepare[[
    SELECT * FROM version WHERE id = :id
  ]]
  stmt:bind_names{ id = k }
  stmt:step()
  if db:errcode() > sqlite3.OK then
    print('[' .. k .. '] migrating')
    v()
    stmt:reset()
    if db:errcode() > sqlite3.OK then
      print(' -> failed. cleanup database!')
      os.exit(1)
    end
    db:exec('INSERT INTO version VALUES (' .. k .. ')')
  end
  stmt:finalize()
end
db:close()
