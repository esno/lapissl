-- lua
local io = require("io")

-- configuration
local config = {}
local fh = io.open("/etc/laprassl/config.lua", "r")

if fh then
  fh:close()
  config = dofile("/etc/laprassl/config.lua")
else
  config = {
    data = "./data",
    profiles = {
      rootca = {
        authkey = "rootca",
        basic_constraints = {
          ca = true,
          pathlen = 0
        },
        key_usage = {
          "keyCertSign",
          "cRLSign"
        },
        expiry = "50y"
      },
      subca = {
        authkey = "subca",
        basic_constraints = {
          ca = true,
          pathlen = 0
        },
        key_usage = {
          "keyCertSign",
          "cRLSign"
        },
        expiry = "25y",
        issuer = "rootca"
      },
      server = {
        authkey = "server",
        basic_constraints = {
          ca = false,
          pathlen = 0
        },
        key_usage = {
          "digitalSignature",
          "keyEncipherment"
        },
        extended_key_usage = {
          "serverAuth"
        },
        expiry = "2y",
        issuer = "subca"
      }
    },
    bootstrap = {
      rootca = {
        subject = {
          CN = "rootca"
        },
        profile = "rootca"
      },
      subca = {
        subject = {
          CN = "subca"
        },
        profile = "subca"
      },
      server = {
        subject = {
          CN = "server"
        },
        profile = "server"
      }
    }
  }
end

return config
