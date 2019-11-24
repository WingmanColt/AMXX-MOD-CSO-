#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <ZombieMod5>
#include <fvault>

#define TASK_FADE 5566
#define MAXDATA 64

enum _:TOTAL_FORWARDS 
{
FW_USER_REGISTER = 0,
FW_USER_LOGGED
}

new const g_vault_name[] = "RegisterSystem";
new const g_vault_name2[] = "ZB5LevelSystem_NICK";

static szData[MAXDATA], szName[32], szMenu[128]
new g_Forwards[TOTAL_FORWARDS], g_ForwardResult

new g_logged[33], g_registered[33], g_menu[33]
new g_attempts[33], g_unlock[33], g_deleted_account[33]
new g_password[33], g_password_again[33], g_joined[33]

new g_Hud

public plugin_init() 
{
register_clcmd("chooseteam", "message_team")
register_clcmd("jointeam", "message_team")
register_clcmd("joinclass", "message_team")

register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")

register_clcmd("ENTER_YOUR_PASSWORD","cmd_password")
register_clcmd("ENTER_YOUR_PASSWORD_AGAIN","cmd_password_again")
register_clcmd("ENTER_YOUR_PASSWORD_CURRENT","cmd_password_current")

register_clcmd("say", "commands")
register_clcmd("say_team", "commands")

register_dictionary("registration_system.txt")

g_Forwards[FW_USER_REGISTER] = CreateMultiForward("reg_user_register", ET_IGNORE, FP_CELL)
g_Forwards[FW_USER_LOGGED] = CreateMultiForward("reg_user_logged", ET_IGNORE, FP_CELL)
g_Hud = zp_get_synchud_id(SYNCHUD_HUMAN_HUD)
}

public plugin_natives() 
{
register_native("reg_open_menu", "menu_account", 1)		
register_native("reg_is_user_logged", "native_is_user_logged", 1)
register_native("reg_is_user_registered", "native_is_user_registered", 1)
}
/// CONNECTION ///
public client_putinserver(id) 
{
/*if(is_user_bot(id))
{
g_registered[id] = true
g_logged[id] = true
return 
} else {
*/
get_user_name(id, szName, charsmax(szName))	
if(fvault_get_data(g_vault_name, szName, szData, charsmax(szData)))
g_registered[id] = true
else
g_registered[id] = false
	
g_menu[id] = false
g_unlock[id] = true
menu_cancel(id)
	
set_task(0.3, "menu_account", id)
set_task(5.0, "Fading", id+TASK_FADE, _,_,"b")
//}
}
public client_disconnected(id) 
{
g_logged[id] = false
g_unlock[id] = false
g_menu[id] = false
}
public zp_fw_core_spawn_post(id)Reset(id)
public zp_fw_core_cure_post(id)Reset(id)
public zp_fw_core_infect_post(id)
{
if(zp_core_is_zombie(id))	
Reset(id)
}

Reset(id)
{
if(!g_logged[id] && !is_user_bot(id))
{
g_menu[id] = false	
user_silentkill(id)
}	
}
//// END CONNECTION ////

public reg_user_logged(id)
{	
get_user_name(id, szName, charsmax(szName))
set_dhudmessage(0, 100, 0, -1.0, 0.180, 0, 10.0, 10.0) // 0.125
show_dhudmessage(id, "^n^nSuccessful Login^nID: %s ^nPASS: %s!", szName, g_password[id])

client_print_color2(0, "^4|System| ^3Hello ^4%s^3, Successfuly logged !", szName)
}
public Fading(id) 
{
id -= TASK_FADE
	
if (!is_user_connected(id))
{
remove_task(id+TASK_FADE)	
return	
}
if(!g_logged[id]) 
{
//Make_ScreenFade(id, 1.0, 0, 0, 0, 255, FADE_STAYOUT)
static Temp_String[256]
formatex(Temp_String, sizeof(Temp_String), !g_registered[id] ? "Welcome to CSO Zombie Mod 3 +FREE VIP^n^n You should ^"Register^" or ^"Join as Guest^"^n Choose from menu to Continue (if you can't see menu click ^"M^") !^n^n Visit: www.CMS-BG.eu" : "Welcome to CMS-BG.eu | Zombie: The Hero +FREE VIP^n^n You should ^"Login^" to your account to play! Choose from menu ^"Login^" and write your Password to continue.^n^n Visit: www.CMS-BG.eu")

set_hudmessage(200, 145, 0, -1.0, 0.150, 0, 5.0, 5.0)		
ShowSyncHudMsg(id, g_Hud, "%s", Temp_String)

if(!g_menu[id])		
{
menu_account(id)
g_menu[id] = true	
}
}
}
public message_team(id) 
{
if(!g_logged[id]) 
{
menu_account(id)
return PLUGIN_HANDLED
}

if(g_logged[id])
{	
if(is_user_alive(id))
{	
if(!zp_core_is_zombie(id))	
zb5_main_menu(id)
else zb5_menu_items(id) 
}else zb5_main_menu(id)
}else reg_open_menu(id)
return PLUGIN_HANDLED
}

public ClientUserInfoChanged(id) 
{ 
static szOldName[32]
pev(id, pev_netname, szOldName, charsmax(szOldName))

if(szOldName[0]) {

static const name[] = "name"
static szNewName[32]
get_user_info(id, name, szNewName, charsmax(szNewName))

if(!equal(szOldName, szNewName)) {

set_user_info(id, name, szOldName)
return FMRES_HANDLED
}
}
return FMRES_IGNORED
}

public menu_account(id) 
{	
if(!is_user_connected(id))
return PLUGIN_HANDLED  
	
get_user_name(id, szName, charsmax(szName))

formatex(szMenu, 127, "\r|ACC| \yAccount Settings^n^n \rID: \y%s^n\dLevel: %i - EXP: %i", szName, zb5_get_user_level(id), zb5_get_user_exp(id))

static Menu; Menu = menu_create(szMenu, "handler_menu_account")

if(!g_registered[id])
{	
formatex(szMenu, 63, "%s%L", g_registered[id] ? "\d":"\r", LANG_PLAYER, "MENU_ACCOUNT_01")
menu_additem(Menu, szMenu, "1", 0)
	
} else {
formatex(szMenu, 63, "%s%L", g_logged[id] ? "\d" : g_registered[id] ? "\y" : "\d", LANG_PLAYER, "MENU_ACCOUNT_00")
menu_additem(Menu, szMenu, "1", 0)


formatex(szMenu, 63, "%s%L", g_logged[id] ? "\w" : "\d", LANG_PLAYER, "MENU_ACCOUNT_02")
menu_additem(Menu, szMenu, "2", 0)

formatex(szMenu, 63, "%s%L^n", g_logged[id] ? "\w" :  "\d", LANG_PLAYER, "MENU_ACCOUNT_03")
menu_additem(Menu, szMenu, "3", 0)

}

if(!g_logged[id])
menu_setprop(Menu,MPROP_PERPAGE, 0)   
else menu_setprop(Menu, MPROP_EXIT, 0)
menu_display(id, Menu, 0)
return PLUGIN_HANDLED  
}

public handler_menu_account(id, menu, item) 
{
if(!is_user_connected(id))
return PLUGIN_CONTINUE

switch(item) 
{
case 0: g_registered[id] ? login(id) : register(id)
case 1: change(id)	
case 2: delete_account(id) 
}

return PLUGIN_HANDLED
}

public login(id) 
{
if(g_logged[id]) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_A")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_A")
}
else if(!g_registered[id]) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_B")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_B")
}
else {

client_cmd(id,"messagemode ENTER_YOUR_PASSWORD")
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_C")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_C")
g_unlock[id] = false
}
return PLUGIN_HANDLED
}

public register(id) 
{
if(g_registered[id]) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_A")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_A")
}
else {

client_cmd(id,"messagemode ENTER_YOUR_PASSWORD")
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_B")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_B")
g_unlock[id] = false
}
return PLUGIN_HANDLED
}

public change(id) 
{
if(!g_logged[id]) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_A")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_A")
}
else {

client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_CURRENT")
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_B")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_B")
g_unlock[id] = false
}
return PLUGIN_HANDLED
}

public delete_account(id) 
{
if(!g_logged[id]) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_A")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_A")
}
else {

client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_CURRENT")
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "^n^n%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_B")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_B")
g_unlock[id] = false
g_deleted_account[id] = true
}
return PLUGIN_HANDLED
}

public cmd_password(id) 
{
if(g_unlock[id]) 
return PLUGIN_HANDLED

get_user_name(id, szName, charsmax(szName))
fvault_get_data(g_vault_name, szName, szData, charsmax(szData))

read_args(g_password[id], 50)
remove_quotes(g_password[id])
trim(g_password[id])

g_unlock[id] = true

if(!characters(g_password[id], strlen(g_password[id]))) {

set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 5.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "CMD_PASSWORD_00")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_00")
menu_account(id)
}
else if(strlen(g_password[id]) < 3) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 3.0, 5.0)
show_hudmessage(id, "^n^nYour password must contain at least 3 characters.")
}
else if(strlen(g_password[id]) > 11) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 3.0, 5.0)
show_hudmessage(id, "^n^n^nYour password must contain at most 10 characters.")
}
else if(equal(g_password[id], szName[id])) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 3.0, 5.0)
show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_03")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_03")
}
else if(g_logged[id]) 
{
if(!equal(szData, g_password[id])) 
{
client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_AGAIN")
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 3.0, 5.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "CMD_PASSWORD_04")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_04")
g_unlock[id] = false
} else {
menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 3.0, 5.0)
show_hudmessage(id, "^n^n%L", LANG_PLAYER, "CMD_PASSWORD_05")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_05")
}
}
else if(!g_registered[id]) 
{
client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_AGAIN")
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 3.0, 5.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "CMD_PASSWORD_06")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_06")
g_unlock[id] = false
} else {
if(equal(szData, g_password[id])) 
{
remove_task(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 3.0, 5.0)
show_hudmessage(id, "^n%L", LANG_PLAYER, "CMD_PASSWORD_07")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_07")			

g_logged[id] = true
g_attempts[id] = 0

ExecuteForward(g_Forwards[FW_USER_LOGGED], g_ForwardResult, id)
Make_ScreenFade(id, 0.1, 0, 0, 0, 0, FADE_OUT)

remove_task(id+TASK_FADE)
client_cmd(id, "stopsound")

if(zp_GameStart() && !g_joined[id])
{	
zp_core_respawn_as_zombie(id, zp_core_is_zombie(id) ? true : false)
cs_set_user_team(id, zp_core_is_zombie(id) ? CS_TEAM_T : CS_TEAM_CT)
ExecuteHamB(Ham_CS_RoundRespawn, id)	
g_joined[id] = true
}

if(!zp_GameStart())
{	
zp_core_respawn_as_zombie(id, false)
cs_set_user_team(id, CS_TEAM_CT)
ExecuteHamB(Ham_CS_RoundRespawn, id)	
}
}else wrong_password(id)
}
return PLUGIN_HANDLED
}

public cmd_password_again(id) 
{
if(g_unlock[id]) 
return PLUGIN_HANDLED

read_args(g_password_again[id], 50)
remove_quotes(g_password_again[id])
trim(g_password_again[id])

g_unlock[id] = true

if(!equal(g_password[id], g_password_again[id])) {

menu_account(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_00")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_00")	
}
else if(!g_registered[id]) {

menu_end_register(id)
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_01")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_01")	
}
else {

menu_change_password(id)
set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_02")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_02")	
}
return PLUGIN_HANDLED
}

public cmd_password_current(id) 
{
if(g_unlock[id]) 
return PLUGIN_HANDLED

get_user_name(id, szName, charsmax(szName))
fvault_get_data(g_vault_name, szName, szData, charsmax(szData))

read_args(g_password[id], 50)
remove_quotes(g_password[id])
trim(g_password[id])

g_unlock[id] = true

if(equal(szData, g_password[id])) 
{
if(g_deleted_account[id]) 
{
menu_delete_account(id)
g_unlock[id] = false
g_deleted_account[id] = false
}
else 
{
client_cmd(id,"messagemode ENTER_YOUR_PASSWORD")
set_hudmessage(0, 255, 0, -1.0, 0.0, 0, 1.0, 3.0)
show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_CURRENT_00")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_CURRENT_00")	
g_unlock[id] = false
}
}
else wrong_password(id)
return PLUGIN_HANDLED
}

public menu_end_register(id)
{
if(!is_user_connected(id))
return
	
get_user_name(id, szName, charsmax(szName))
formatex(szMenu,127, "\w%L^n^n\w%L: \y%s^n\w%L: \y%s", LANG_PLAYER, "MENU_END_REGISTER_TITLE", LANG_PLAYER, "MENU_END_REGISTER_NICK", szName, LANG_PLAYER, "MENU_END_REGISTER_PASSWORD", g_password_again[id])

new Menu = menu_create(szMenu, "handler_menu_end_register")

formatex(szMenu, 63, "\y%L", LANG_PLAYER, "MENU_END_REGISTER_00")
menu_additem(Menu, szMenu, "1", 0)

formatex(szMenu, 63, "\r%L^n", LANG_PLAYER, "MENU_END_REGISTER_01")
menu_additem(Menu, szMenu, "2", 0)

formatex(szMenu, 63, "\w%L", LANG_PLAYER, "MENU_END_REGISTER_02")
menu_additem(Menu, szMenu, "3", 0)

menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
menu_display(id, Menu, 0)
}

public handler_menu_end_register(id, menu, item) 
{
if(!is_user_connected(id))
return PLUGIN_CONTINUE

if(item == MENU_EXIT) {

menu_destroy(menu)
return PLUGIN_HANDLED
}
switch(item) {

case 0: end_register(id)
case 1: register(id)
case 2: menu_account(id)
}
menu_destroy(menu)
return PLUGIN_HANDLED
}

public end_register(id) 
{
get_user_name(id, szName, charsmax(szName))	
fvault_set_data(g_vault_name, szName, g_password_again[id])

set_hudmessage(0, 0, 255, 0.02, 0.25, 0, 1.0, 3.0)
show_hudmessage(id, "%L", LANG_PLAYER, "MENU_END_REGISTER_CASE_00_A")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_END_REGISTER_CASE_00_A")	
client_print_color2(id, "!g%L !t%L: !y[!g %s !y] !t%L: !y[!g %s !y]", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_END_REGISTER_CASE_00_B_NICK", szName, LANG_PLAYER, "MENU_END_REGISTER_CASE_00_B_PASSOWORD", g_password_again[id])

remove_task(id)

g_registered[id] = true
g_logged[id] = true

fvault_remove_key(g_vault_name2, szName)

ExecuteForward(g_Forwards[FW_USER_REGISTER], g_ForwardResult, id)
}

public menu_change_password(id) 
{
if(!is_user_connected(id))
return
	
get_user_name(id, szName, charsmax(szName))
formatex(szMenu, 127, "\r%L^n^n\y%L: \r[\d%s\r]^n\y%L: \r[\d%s\r]", LANG_PLAYER, "MENU_CHANGE_PASSWORD_TITLE", LANG_PLAYER, "MENU_CHANGE_PASSWORD_NICK", szName, LANG_PLAYER, "MENU_CHANGE_PASSWORD_PASSWORD", g_password_again[id])

new Menu = menu_create(szMenu,"handler_menu_change_password")

formatex(szMenu, 63, "%L", LANG_PLAYER, "MENU_CHANGE_PASSWORD_00")
menu_additem(Menu, szMenu, "1", 0)

formatex(szMenu, 63, "\r%L^n", LANG_PLAYER, "MENU_CHANGE_PASSWORD_01")
menu_additem(Menu, szMenu, "2", 0)

formatex(szMenu, 63, "\y%L", LANG_PLAYER, "MENU_CHANGE_PASSWORD_02")
menu_additem(Menu, szMenu, "3", 0)

menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
menu_display(id, Menu, 0)
}

public handler_menu_change_password(id, menu, item) 
{
if(!is_user_connected(id))
return PLUGIN_CONTINUE
	
if(item == MENU_EXIT) 
{
menu_destroy(menu)
return PLUGIN_HANDLED
}
switch(item) {

case 0: replaced_password(id)
case 1: change(id)
case 2: menu_account(id)
}
menu_destroy(menu)
return PLUGIN_HANDLED
}

public replaced_password(id) 
{
get_user_name(id, szName, charsmax(szName))	
fvault_set_data(g_vault_name, szName, g_password_again[id])

set_hudmessage(0, 0, 255, 0.02, 0.25, 0, 1.0, 3.0)
show_hudmessage(id, "%L", LANG_PLAYER, "MENU_CHANGE_PASSWORD_CASE_00_A")
client_print_color2(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_CHANGE_PASSWORD_CASE_00_A")	
client_print_color2(id, "!g%L !t%L: !y[!g %s !y]", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_CHANGE_PASSWORD_CASE_00_B_PASSWORD", g_password_again[id])

g_attempts[id] = 0
}

public menu_delete_account(id) 
{
if(!is_user_connected(id))
return

formatex(szMenu, 127, "\r%L", LANG_PLAYER, "MENU_DELETED_ACCOUNT_TITLE")

new Menu = menu_create(szMenu,"handler_menu_delete_account")

formatex(szMenu, 63, "%L", LANG_PLAYER, "MENU_DELETED_ACCOUNT_00")
menu_additem(Menu, szMenu, "1", 0)

formatex(szMenu, 63, "\r%L", LANG_PLAYER, "MENU_DELETED_ACCOUNT_01")
menu_additem(Menu, szMenu, "2",0)

menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
menu_display(id, Menu, 0)
}

public handler_menu_delete_account(id, menu, item) 
{
if(!is_user_connected(id))
return PLUGIN_CONTINUE

if(item == MENU_EXIT) 
{
menu_destroy(menu)
return PLUGIN_HANDLED
}
switch(item)
{
case 0: account_deleted(id)
case 1: menu_account(id)
}
menu_destroy(menu)
return PLUGIN_HANDLED
}

public account_deleted(id)
{
get_user_name(id, szName, charsmax(szName))
fvault_remove_key(g_vault_name, szName)
fvault_remove_key(g_vault_name2, szName)

client_print(id, print_console, "----------------------------------------")
client_print(id, print_console, "----- %L -------", LANG_PLAYER, "MENU_DELETED_ACCOUNT_CASE_00")
client_print(id, print_console, "----------------------------------------")	
client_cmd(id, "disconnect")
client_cmd(id, "toggleconsole")	
}

public wrong_password(id) 
{
g_attempts[id]++
if(g_attempts[id] >= 3) {

//server_cmd("amx_banip #%i 5 wrong password", get_user_userid(id), LANG_PLAYER, "WRONG_PASSWORD_00", get_pcvar_num(cvar_bantime))
remove_task(id)
g_attempts[id] = 0
}
else {

menu_account(id)
//set_hudmessage(255, 255, 255, 0.02, 0.25, 0, 1.0, 3.0)
//show_hudmessage(id,"%L [ %d / %d ]", LANG_PLAYER, "WRONG_PASSWORD_01", g_attempts[id], get_pcvar_num(cvar_attempts))
//client_print_color2(id, "!g%L !t%L !y[!g %d !y/!g %d !y]", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "WRONG_PASSWORD_01", g_attempts[id], get_pcvar_num(cvar_attempts))
}
}

public commands(id) 
{
new text[70], arg1[32], arg2[32], arg3[6]
read_args(text, sizeof(text) - 1)
remove_quotes(text)
arg1[0] = '^0'; arg2[0] = '^0'; arg3[0] = '^0'
parse(text, arg1, sizeof(arg1) - 1, arg2, sizeof(arg2) - 1, arg3, sizeof(arg3) - 1)

if(equali(arg1, "/", 1) || equali(arg1, ".", 1)) format(arg1, 31, arg1[1])

if(arg3[0]) return PLUGIN_CONTINUE

if(equali(arg1, "reg") || equali(arg1, "register") || equali(arg1, "login")) {

menu_account(id)
}
return PLUGIN_CONTINUE
}

public native_is_user_logged(id)
{
if(!is_user_connected(id))
return 0

return g_logged[id]
}

public native_is_user_registered(id) 
{
if(!is_user_connected(id))
return 0

return g_registered[id]
}
bool:characters(const symbol[], len) 
{
new const valid_chars[][] = {

"0" ,"1" ,"2" ,"3" ,"4" ,"5" ,"6" ,"7" ,"8" ,"9",
"a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
"k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
"u", "v", "w", "x", "y", "z"
}
static i, a, valids;
valids = 0

for(i = 0; i < len; i++) {

for(a = 0; a < sizeof(valid_chars); a++) {

if(symbol[i] == valid_chars[a][0]) {

valids++
break
}
}
}
if(valids != len)
return false
return true
}

stock client_print_color2(const id, const input[], any:...) 
{
new count = 1, players[32]
static msg[191]
vformat(msg, 190, input, 3)

replace_all(msg, 190, "!g", "^4")
replace_all(msg, 190, "!y", "^1")
replace_all(msg, 190, "!t", "^3")
replace_all(msg, 190, "!team2", "^0")

if (id)
players[0] = id;
else
get_players(players, count, "ch")

for (new i = 0; i < count; i++) {

if (is_user_connected(players[i])) {

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
write_byte(players[i]);
write_string(msg);
message_end();
}
}
}
