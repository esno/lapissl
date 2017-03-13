#!/usr/bin/env lua

local config = require("config")
local laprassl_x509 = require("laprassl.x509")
local openssl_pkey = require("openssl.pkey")
local laprassl = require("api.v1.x509")

function writeFiles(subject, file)
  local subj = subject:all()
  for _, v in pairs(subj) do
    if v.sn == "CN" then name = v.blob end
  end
  if file.crt and name then
    local fh = io.open(config.data .. "/" .. name .. ".crt.pem", "w")
    fh:write(file.crt)
    fh:close()
  end
  if file.key and name then
    local fh = io.open(config.data .. "/" .. name .. ".key.pem", "w")
    fh:write(file.key)
    fh:close()
  end
end

local keyRootCa = openssl_pkey.new{ type = "EC", curve = "secp384r1" }
local csr = laprassl_x509:create_csr(config.bootstrap.rootca.subject, keyRootCa:toPEM("private"))
local rootCa = laprassl_x509:sign_crt(
  laprassl_x509:create_crt(tostring(csr), config.profiles[config.bootstrap.rootca.profile]),
  keyRootCa
)

local keySubCa = openssl_pkey.new{ type = "EC", curve = "secp384r1" }
local csr = laprassl_x509:create_csr(config.bootstrap.subca.subject, keySubCa:toPEM("private"))
local subCa = laprassl_x509:sign_crt(
  laprassl_x509:create_crt(tostring(csr), config.profiles[config.bootstrap.subca.profile]),
  keyRootCa,
  ca
)

writeFiles(rootCa:getSubject(), { crt = tostring(rootCa), key = keyRootCa:toPEM("private") })
writeFiles(subCa:getSubject(), { crt = tostring(subCa), key = keySubCa:toPEM("private") })
