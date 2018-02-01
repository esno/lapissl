## profiles

profiles are sets of rules which will be applied to requested certificates
like subject attributes or key usage.
Profiles can only be created with the admin api token which is set in `config.lua`

    -- config.lua
    [...]
    config.admin = '<admin-api-token>'
