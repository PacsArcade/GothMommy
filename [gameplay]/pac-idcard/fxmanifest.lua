author 'PacsArcade'
description 'Goth Mommy RP - ID Card System (pac-idcard v1)'
version '1.0.0'
lua54 'yes'
fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts {
    "framework/*.lua",
    "config.lua",
}

client_scripts {
    'c/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    's/*.lua',
}

ui_page 'ui/index.html'

files {
    'ui/**/*',
}

escrow_ignore {
    '**/*'
}
