local luna = require('luna.helper')
local pkey = require("openssl.pkey")

local x509key = {}

local _mkRSAKey = function(keysize)
  local key = pkey.new{ type = 'RSA', bits = keysize }
  return key:toPEM('private') or nil
end

local _mkECKey = function()
  local key = pkey.new{ type = 'EC', curve = 'secp384r1' }
  return key:toPEM('private') or nil
end

function x509key.post(self)
  local params = self.params
  local headers = self.req.headers
  local input = luna:validate({
    keytype = 'string'
  }, params)
  if not input then
    if params.keytype == 'rsa' then
      input = luna:validate({
        keysize = 'number'
      }, params)
      if not input then
        local key = _mkRSAKey(params.keysize)
        if key then
          return {
            status = 201,
            json = {
              status = 201,
              reason = 'Created',
              key = key
            }
          }
        end
        return {
          status = 500,
          json = {
            status = 500,
            reason = 'cannot create key'
          }
        }
      end
      return {
        status = 400,
        json = {
          status = 400,
          reason = 'Missing keysize parameter'
        }
      }
    else
      local key = _mkECKey()
      if key then
        return {
          status = 201,
          json = {
            status = 201,
            reason = 'Created',
            key = key
          }
        }
      end
      return {
        status = 500,
        json = {
          status = 500,
          reason = 'cannot create key'
        }
      }
    end
  end
  return {
    status = 400,
    json = {
      status = 400,
      reason = 'Missing keytype parameter'
    }
  }
end

return x509key
