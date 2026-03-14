fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
games {"rdr3"}

shared_scripts {
    'config.lua',
}

client_scripts {
    'c/c.lua',
}

server_scripts {
    'server/s.lua',
}

dependencies {
    'vorp_core',
    'vorp_inventory',
    'oxmysql',
}
