-- configuration
config = {
  data = "./data",
  profiles = {
    rootca = {
      auth_key = "rootca",
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
      auth_key = "subca",
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
    }
  }
}

return config
