fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

games {"rdr3"}

shared_scripts {
    'config.lua',
    'locale.lua',
    'locales/en.lua',
}

client_scripts {
    'client/warmenu.lua',
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}
