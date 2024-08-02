fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'fx'
description 'fxJobCenter'
version '1.3'

ui_page 'html/index.html'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client.lua',
    'config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua',
    'config.lua'
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

files {
    'html/*.*'
}

escrow_ignore {
    'locales/en.lua',
    'html/index.html',
    'html/styles.css',
    'html/index.js',
    'client.lua',
    'config.lua',
    'server.lua',
  }
