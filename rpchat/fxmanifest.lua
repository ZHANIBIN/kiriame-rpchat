fx_version 'cerulean'
game 'gta5'

author 'An awesome dude'
description 'An awesome, but short, description'
version '1.0.0'
lua54 'yes'

client_script {
    'client/main.lua',
}
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/statscheck.lua',
    'config.lua',
}

files {
    "style.css"
}

shared_scripts {
    '@ox_lib/init.lua',
}
chat_theme 'nb-rpchat' {
    styleSheet = 'style.css'

}
