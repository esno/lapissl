local config = require("lapis.config")

config.endpoints = './endpoints'
config.sqlite = './laprassl.sqlite3'
config.admin = '89137378-3b35-4a81-918d-8852cb4ce2d1'

config('development', {
  port = 8080,
  session_name = 'laprassl',
  secret = '0wVQjMtpJTgfbrgqWg0wPK6NpfOH2v13',
})

return config
