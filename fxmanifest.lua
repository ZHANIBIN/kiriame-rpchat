fx_version 'cerulean'
game 'gta5'

author '桐雨绫华'
description '一个基于文本的角色扮演聊天插件。是的，就这么简单'
version '1.0.0'
lua54 'yes'

client_script {
    'client/**',
    'client/nametag.lua'
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/**',
    'config.lua',
}

files {
    "style.css"
}

shared_script {
    "shared/**",
    '@ox_lib/init.lua',
}

chat_theme 'kiriame_rpchat' {
    styleSheet = 'style.css'
}
