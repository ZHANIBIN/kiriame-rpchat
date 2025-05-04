fx_version 'cerulean'
game 'gta5'

author 'Kiriame'
description 'RP Chat System'
version '1.0.0'
lua54 'yes'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/api_interface.lua',
    'server/function.lua',
    'server/radio.lua',
    'server/statscheck.lua',
    'server/main.lua',
    '@oxmysql/lib/MySQL.lua'
}

files {
    "style.css"
}

chat_theme 'kiriame_rpchat' {
    styleSheet = 'style.css'
}

server_exports {
    'GetAPIInterface',
    'OverrideAPI'
}
