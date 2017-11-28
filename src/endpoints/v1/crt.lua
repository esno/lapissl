local laprasslCrt = require('laprassl.crt')
local laprasslKey = require('laprassl.key')
local validate = require('lapis.validate')

local crt = {}

function crt.mkCa(self, param)
  local args = validate.validate(params, {
    { 'CN', exists = true, type = String }
  })

  if not args then
    local argSubject = {
      C = (self.params.subject or {}).C or nil,
      ST = (self.params.subject or {}).ST or nil,
      L = (self.params.subject or {}).L or nil,
      O = (self.params.subject or {}).O or nil,
      OU = (self.params.subject or {}).OU or nil,
      emailAddress = (self.params.subject or {}).emailAddress or nil,
      CN = self.params.CN
    }
    local argKey = {
      type = (self.params.key or {}).type or nil,
      size = (self.params.size or {}).size or nil
    }

    local newKey = laprasslKey:mkKey(
      (argKey.type or 'ec'),
      (argKey.size or 4096))
    local newCa = laprasslCrt:mkCsr(argSubject, newKey)

    if pubKey then
      return { status = 201, json = {  } }
    end
  end

  return { status = 400, json = { reason = 'Bad Request' } }
end

crt.post = {
  { context = '/ca', call = crt.mkCa }
}

return crt
