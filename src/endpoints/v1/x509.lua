local laprassl = require('laprassl.generic')
local laprasslKey = require('laprassl.x509key')
local laprasslCrt = require('laprassl.x509crt')
local config = require('config')

local x509 = {}

x509.post = {
  { context = '/key', call = laprasslKey.post },
  { context = '/crt', call = laprasslCrt.post }
}

return x509
