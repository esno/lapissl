local laprassl = require('laprassl.generic')
local laprasslProfile = require('laprassl.profile')
local luna = require('luna.helper')
local config = require('config')

local profile = {}

function profile.create(self)
  local params = self.params
  local headers = self.req.headers
  local input = luna:validate({
    name = 'string',
    expiry = 'string'
  }, params)
  if not input and laprassl:isAdmin(luna:getAuthToken(headers)) then
    local values = {
      name = params.name,
      expiry = params.expiry,
      x509 = {}
    }
    if type(params.x509.subject) == 'table' then
      values.x509.subject = {
        C = params.x509.subject.C or nil,
        ST = params.x509.subject.ST or nil,
        L = params.x509.subject.L or nil,
        O = params.x509.subject.O or nil,
        OU = params.x509.subject.OU or nil
      }
    end
    if type(params.x509.basicConstraints) == 'table' then
      values.x509.basicConstraints = {
        cA = params.x509.basicConstraints.cA or nil,
        pathLenConstraints = params.x509.basicConstraints.pathLenConstraints or nil
      }
    end
    if type(params.x509.keyUsage) == 'table' then
      values.x509.keyUsage = {
        digitalSignature = params.x509.keyUsage.digitalSignature or nil,
        nonRepudiation = params.x509.keyUsage.nonRepudation or nil,
        keyEncipherment = params.x509.keyUsage.keyEncipherment or nil,
        dataEncipherment = params.x509.keyUsage.dataEncipherment or nil,
        keyAgreement = params.x509.keyUsage.keyAgreement or nil,
        keyCertSign = params.x509.keyUsage.keyCertSign or nil,
        cRLSign = params.x509.keyUsage.cRLSign or nil,
        encipherOnly = params.x509.keyUsage.encipherOnly or nil,
        decipherOnly = params.x509.keyUsage.decipherOnly or nil,
      }
    end

    if laprasslProfile:mkProfile(values) then
      return {
        status = 201,
        json = {
          status = 201,
          reason = 'Created'
        }
      }
    else
      return {
        status = 500,
        json = {
          status = 500,
          reason = 'database issue'
        }
      }
    end
  else
    return {
      status = 401,
      json = {
        status = 401,
        reason = 'missing or wrong api key'
      }
    }
  end

  return {
    status = 400,
    json = {
      status = 400,
      reason = 'missing parameter(s)'
    }
  }
end

profile.post = {
  { context = '', call = profile.create }
}

return profile
