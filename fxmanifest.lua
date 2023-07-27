fx_version 'bodacious'
game 'gta5'

author 'Stabs'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/target.lua',
    'client/client.lua'
}

server_script 'server/server.lua'


files {
    'stream/*.ydr',
    'stream/*.ytd',
}
data_file 'DLC_ITYP_REQUEST' 'stream/stretcher.ytyp'

-- file 'stream/prop_ld_binbag_01.ydr'