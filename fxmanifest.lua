lua54 'yes'
fx_version 'cerulean'
game 'gta5'
author "KamuiKody"

shared_script 'config.lua'

client_script 'client.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-input',
    'qb-menu'
}