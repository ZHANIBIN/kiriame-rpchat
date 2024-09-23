fx_version 'cerulean'
game 'gta5'

author 'ZHANIBIN'
description 'Just a chat for gtar.Yes just so simple'
version '1.0.0'
lua54 'yes'

client_script {
    'client/main.lua',
    'client/autosaying.lua',
    'client/radio.lua',


}
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/statscheck.lua',
    'server/autosaying.lua',
    'server/radio.lua',
    'config.lua',
}

files {
    "style.css"
}

shared_script {
    "shared/**",
    '@ox_lib/init.lua',
  }
  
chat_theme 'gtarrpchat' {
    styleSheet = 'style.css'

}
