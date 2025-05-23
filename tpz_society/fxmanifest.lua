fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Nosmakos'
description 'TPZ-CORE - Society'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 'config.lua', 'locales.lua' }
client_scripts { 'client/*.lua' }
server_scripts { 'server/*.lua' }

files { 'html/**/*' }

dependencies {
    'tpz_core',
    'tpz_characters',
    'tpz_inventory',
    'tpz_inputs',
    'tpz_notify',
    'tpz_menu_base',
}

lua54 'yes'
