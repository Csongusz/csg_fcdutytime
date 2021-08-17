fx_version 'cerulean'
game 'gta5'

author 'Csongusz'
description 'Frakció duty idő számláló szkript. 0.1-es verziója'
version '0.1'

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    "client.lua"
}
server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    "server.lua",
    "@mysql-async/lib/MySQL.lua"
}

dependency 'es_extended'
