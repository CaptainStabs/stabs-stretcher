fx_version 'bodacious'
game 'gta5'
lua54 "yes"

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

escrow_ignore {
	"config.lua",
	"client/target.lua",
    "client/commands.lua",
    "stream/stretcher.ydr",
    "stream/stretcher.ytd",
    "stream/stretcher.ytyp"
}

dependencies {
    'qb-core',
    'qb-ambulancejob',
    'qb-target'
}