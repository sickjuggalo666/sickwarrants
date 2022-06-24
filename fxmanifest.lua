fx_version 'bodacious'
games { 'rdr3', 'gta5' }

mod 'sickwarrants'
version '2.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua',
}

exports {
    'WarrantMenu'
}