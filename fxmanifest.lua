fx_version 'bodacious'
games { 'rdr3', 'gta5' }
lua54 'yes'

mod 'sickwarrants'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
    
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

exports {
    'WarrantMenu'
}
