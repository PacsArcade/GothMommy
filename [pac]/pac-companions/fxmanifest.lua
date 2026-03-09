fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

games {"rdr3"}

ConvarFramework = "vorp" -- Set to vorp for Goth Mommy RP

client_scripts {
    'client/warmenu.lua',
    'client/client.lua',
    'config.lua'
}

shared_scripts {
    'config.lua',
    'locale.lua',
    'locales/es.lua',
    'locales/en.lua',
}

-- redem block intentionally excluded (VORP only)

server_scripts {
    'config.lua',
    'server/server.lua',
}
