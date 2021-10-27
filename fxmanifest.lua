fx_version 'bodacious'

game 'gta5'

mod 'sickwarrants'
version '1.1.4'

sever_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua',
    'config.lua'
}

client_scipts {
    'client.lua',
    'config.lua'
}

exports {
    'SickWarrantsMenu'
}