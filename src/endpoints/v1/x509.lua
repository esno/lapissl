local laprassl = require('laprassl.generic')
local laprasslKey = require('laprassl.x509key')
local config = require('config')

local x509 = {}

x509.post = {
  { context = '/key', call = laprasslKey.post }
}

return x509
