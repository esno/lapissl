local laprassl = require('laprassl.generic')
local laprasslProfile = require('laprassl.profile')
local luna = require('luna.helper')
local config = require('config')

local profile = {}

function profile.create(self, params)
  local input = luna:validate({
    name = 'string',
    token = 'string',
    expiry = 'string'
  }, params)
  if input and laprassl:isAdmin(luna:getAuthToken()) then
    local values = {
      name = params.name,
      token = params.token,
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
    end
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
  { context = '/profile', call = profile.create }
}

return profile
