fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'rugoba94'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua', 
    'config.lua'
}

server_scripts {
    'server/main.lua',  
    'config.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/app.js'
}
