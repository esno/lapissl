local config = require("lapis.config")

config.endpoints = './endpoints'

config('development', {
  port = 8080,
  session_name = 'laprassl',
  secret = '0wVQjMtpJTgfbrgqWg0wPK6NpfOH2v13',
})

return config
