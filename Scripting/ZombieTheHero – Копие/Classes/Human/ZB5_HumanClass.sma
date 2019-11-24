#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define MAX_CLASS 10
#define FLAG_ADMIN ADMIN_CHAT
#define FLAG_VIP ADMIN_LEVEL_B
#define TASK_SKILL_DO 1152018

enum TOTAL_FORWARDS
{
FW_SELECT_ITEM = 0,
FW_SKILL_RESET,
FW_RESTOCK,
FW_REMOVE,
FW_SKILL
}
enum _:Classes
{	
ClassName,	
CLASS,	
SOZO,	
HERO
}
enum _:Levels
{	
COUNTDOWN_LEVEL,
RESET_TIME_LEVEL,
POWER_LEVEL,
COUNTDOWN_TIME,
RESET_TIME,
CAN_SKILL,
DO_SKILL,
LEVEL
}
enum _:Options
{
CAN_JUMP,
DO_JUMP,
NUM_JUMP
}
enum _:CLASSEN
{
ADMIN,
VIP
}
enum _:Items
{
EXTRA_EXP,	
RESTOCK,
EXP_X2,	
ONCE
}

static szName[32], Temp_String_CAN[64]

new g_IsZombie, g_IsAlive, g_IsConnected
new g_ForwardResult, g_Forwards[TOTAL_FORWARDS]
new Array:Class_Name, Array:Class_Desc, Array:Class_UnlockCost
new g_wpn_i, g_class_primary[10], g_class_count, g_scaned

new g_had[33][Options], g_had2[33][Classes], g_item[33][Items], g_level[33][Levels], g_user[33][CLASSEN]
new Float:g_user_speed[33], g_sozo, g_RespawnHud, g_skill_hud, g_MaxPlayers
new g_can_respawn, bool:g_joined[33], g_pcvar_team, g_pcvar_class

public plugin_init() 
{
Register_SafetyFunc()	

RegisterHam(Ham_TakeDamage, "player", "fw_takedamage")
register_forward(FM_CmdStart, "fw_CmdStart")	

register_message(get_user_msgid("ShowMenu"), "message_show_menu")
register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu")

set_msg_block(get_user_msgid("HudTextArgs"), BLOCK_SET) 

register_clcmd("drop", "cmd_drop")
register_clcmd("say /cam","camera")	

g_pcvar_team = register_cvar("ajc_team", "5")
g_pcvar_class = register_cvar("ajc_class", "5")	

g_Forwards[FW_SELECT_ITEM] = CreateMultiForward("zb5_class_selected_post", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_RESTOCK] = CreateMultiForward("zp_fw_restock_ammo", ET_IGNORE, FP_CELL)
g_Forwards[FW_REMOVE] = CreateMultiForward("zb5_class_remove_post", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_SKILL] = CreateMultiForward("zb5_humanskill", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_SKILL_RESET] = CreateMultiForward("zb5_humanskill_reset", ET_IGNORE, FP_CELL)

g_RespawnHud = zp_get_synchud_id(SYNCHUD_NOTICE)
g_skill_hud = zp_get_synchud_id(SYNCHUD_HUMAN_SKILL)

g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_native("zp_core_is_admin", "native_admin", 1)	
register_native("zp_core_is_vip", "native_vip", 1)

register_native("zp_core_is_hero", "native_hero", 1)	
register_native("zp_set_user_hero", "native_set_hero", 1)

register_native("zb5_main_menu", "Main_Menu", 1)		
register_native("zb5_class_menu", "do_open_menu_hclass", 1)	
register_native("zb5_menu_camera", "camera", 1)	

register_native("zb5_register_class", "native_register_hclass", 1)
register_native("zb5_remove_class", "ResetAllClass", 1)
register_native("zb5_had_class", "native_class", 1)	

register_native("zb5_set_hspeed", "native_set_speed", 1)
register_native("zb5_reset_hspeed", "AddSpeed", 1)

register_native("zb5_restock_ammo", "Restock_Ammo", 1)
register_native("zb5_buy_item_exp", "native_buyexp", 1)

register_native("zb5_item_exp", "native_item_exp", 1)

register_native("zb5_skill_human", "native_skill_human", 1)
register_native("zb5_get_restock", "native_restock", 1)
register_native("zb5_get_buyexp", "native_item_exp", 1)
register_native("zb5_get_upgrade", "native_upgrade", 1)
}
public plugin_precache()
{	
Class_Name = ArrayCreate(64, 1)
Class_Desc = ArrayCreate(64, 1)
Class_UnlockCost = ArrayCreate(1, 1)

//PrecacheModel("sprites/ZB5/EffectKiller/damage500.spr")
PrecacheModel("models/player/ZB5_Humans1/ZB5_Humans1.mdl")
PrecacheModel("sprites/ZB5/zb_hero.spr")
PrecacheSound("ZB5/zsrespawn.wav")	
PrecacheSound("ZB5/10000dmg.wav")

g_sozo = zb5_register_class("Sozo", "Thunder Squad", 0)		
}
public plugin_cfg()
{
if(!g_scaned)
{
g_scaned = 1

for(new i = 0; i < g_wpn_i; i++)
{
g_class_primary[g_class_count] = i
g_class_count++
}
log_amx("Human Class Count: %i", g_class_count)	
}	
}
public zb5_class_selected_post(id, class)
{
if(class == g_sozo)
{	
Get_Class(id)
}
}
public Get_Class(id)
{		
ResetAllClass(id)	
g_had2[id][SOZO] = true	

fm_set_user_health(id, 1000)
fm_set_user_armor(id, 0)
fm_set_user_gravity(id, 0.9)
zb5_set_hspeed(id, 1.0)

cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 1 - 1)
get_weapon_grenade_he(id, 1)
}
public GiveHuman(id)
{
g_had2[id][HERO] = false

if(g_had2[id][CLASS])
{	
ResetAllClass(id)
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_had2[id][ClassName])	
} else {
Get_Class(id)
do_open_menu_hclass(id)
}
if(!g_had2[id][SOZO])
{
g_level[id][COUNTDOWN_TIME] = 0	
g_level[id][RESET_TIME] = 0

g_level[id][CAN_SKILL] = true
g_level[id][DO_SKILL] = false
}
AddSpeed(id)
Restock_Ammo(id)

if(!has_user_any_weapon(id))
engclient_cmd(id, "weapon_knife")
}
public AddSpeed(id)
{
if(!Get_BitVar(g_IsAlive, id))
return

cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, g_user_speed[id])	
}

public Reset_All(id)
{
remove_task(id+TASK_SKILL_DO)

//arrayset(g_had[id], false, sizeof(g_had[]))		
arrayset(g_had2[id], false, sizeof(g_had2[]))
arrayset(g_level[id], false, sizeof(g_level[]))	
}
random_class(id)
{
static wpn_id

ResetAllClass(id)

wpn_id = g_class_primary[random_num(0, g_class_count)]
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, wpn_id)	
}
public ResetAllClass(id)
{
for(new i = 0; i < g_wpn_i; i++)
ExecuteForward(g_Forwards[FW_REMOVE], g_ForwardResult, id, i)	
ExecuteForward(g_Forwards[FW_SKILL_RESET], g_ForwardResult, id)

g_level[id][COUNTDOWN_TIME] = 0	
g_level[id][RESET_TIME] = 0

g_level[id][CAN_SKILL] = true
g_level[id][DO_SKILL] = false
remove_task(id+TASK_SKILL_DO)	
}
public RuningTime_Player(id)
{	
if(!zp_GameStart())
return			
if(!is_player(id))
return
if(g_had2[id][SOZO])
return

HUD_SKILL(id)
}
public HUD_SKILL(id)
{
//// SKILLS /////
if(g_level[id][RESET_TIME] > 0) 
g_level[id][RESET_TIME]--

if(g_level[id][COUNTDOWN_TIME] > 0)
{ 
g_level[id][COUNTDOWN_TIME]--

if(!g_level[id][COUNTDOWN_TIME]) 
g_level[id][CAN_SKILL] = true
}
////////////////////////

if(g_level[id][CAN_SKILL])	
formatex(Temp_String_CAN, sizeof(Temp_String_CAN), "^n[Press E] - Do Ability (Ready)")
else if(g_level[id][DO_SKILL])		
formatex(Temp_String_CAN, sizeof(Temp_String_CAN), "^n[Press E] - Ability (Reset: %i)", g_level[id][RESET_TIME])
else formatex(Temp_String_CAN, sizeof(Temp_String_CAN), "^n[Press E] - Ability (Countdown: %i)", g_level[id][COUNTDOWN_TIME])

set_hudmessage(150, 150, 150, -1.0, 0.10, 0, 1.0, 1.0)
ShowSyncHudMsg(id,g_skill_hud, "%s^n^nUpgrade Level: %i", Temp_String_CAN, g_level[id][LEVEL])	
}
// MENUS
public do_open_menu_hclass(id)
{
if(!is_player(id))
return PLUGIN_HANDLED 

static menu, MyLevel, Temp_String[128], Temp_String2[128], Temp_String3[10], Temp_String4[128]

MyLevel = zb5_get_user_level(id)
menu = menu_create("\rZombie: \yZ-Noid", "weapon_menu_handle")

for(new i = 0; i < g_wpn_i; i++)
{
if(MyLevel >= ArrayGetCell(Class_UnlockCost, i))
{					
ArrayGetString(Class_Name, i, Temp_String, sizeof(Temp_String))
ArrayGetString(Class_Desc, i, Temp_String4, sizeof(Temp_String4))
num_to_str(i, Temp_String3, sizeof(Temp_String3))
formatex(Temp_String2, sizeof(Temp_String2), "%s %s", Temp_String, Temp_String4)
menu_additem(menu, Temp_String2, Temp_String3)	
}
}

//menu_additem(menu, "\rEXIT", "0")
menu_setprop(menu,MPROP_PERPAGE, 0)   
menu_display(id, menu, 0)	
return PLUGIN_HANDLED
}

public weapon_menu_handle(id, menu, item)
{
if(!is_player(id))
return PLUGIN_HANDLED 

if (item == MENU_EXIT)   
{   	
menu_destroy(menu)   
return PLUGIN_HANDLED   
}    	
new data[6], access, callback
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)

new wpn_id = str_to_num(data)

g_had2[id][CLASS] = true
g_had2[id][ClassName] = wpn_id

if(Get_BitVar(g_IsAlive, id))
{
if(!zp_GameStart() && !zp_GameEnd())
{
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_had[id][ClassName])	
zb5_weapons_menu(id)	
}
}

return PLUGIN_HANDLED   
}

// CLASS

public fw_takedamage(victim, inflictor, attacker, Float:damage, dmgtype)
{
if(!is_player(attacker))
return HAM_IGNORED
if(!Get_BitVar(g_IsZombie, victim))
return HAM_IGNORED

static Float:g_fHaveDamage[33]
g_fHaveDamage[attacker] += damage;

if (g_fHaveDamage[attacker] >= 10000.0)
{
g_level[attacker][LEVEL]++
native_upgrade(attacker)
g_fHaveDamage[attacker] = 0.0;
}

return HAM_HANDLED
}
public native_upgrade(attacker)
{
if(!is_player(attacker))
return 
	
if (g_level[attacker][LEVEL] < 16)
{
g_level[attacker][LEVEL]++
PlaySound(attacker, "ZB5/td_heal.wav")

set_dhudmessage(200, 145, 0, -1.0, 0.0, 0, 4.0, 1.0)
show_dhudmessage(attacker, "^nYou upgraded yourself to level = %i!", g_level[attacker][LEVEL])

switch(random_num(1,3))
{	
case 1:
{	
if(g_level[attacker][COUNTDOWN_LEVEL] < 6)
{
g_level[attacker][COUNTDOWN_LEVEL]++	

if(!zb5_get_user_nvg(attacker))
Make_ScreenFade(attacker, 0.5, 240, 190, 140, 60, FADE_IN)
}
}
case 2:
{	
if(g_level[attacker][RESET_TIME_LEVEL] < 6)
{
g_level[attacker][RESET_TIME_LEVEL]++	

if(!zb5_get_user_nvg(attacker))
Make_ScreenFade(attacker, 0.5, 240, 190, 140, 60, FADE_IN)
}
}
case 3:
{	
if(g_level[attacker][POWER_LEVEL] < 6)
{
g_level[attacker][POWER_LEVEL]++

if(!zb5_get_user_nvg(attacker))
Make_ScreenFade(attacker, 0.5, 150, 10, 10, 70, FADE_IN)
}
}
}
}	
}

// ADMIN / VIP JUMP
public fw_CmdStart(id, uc_handle, seed)
{
static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)

if(!Get_BitVar(g_IsAlive, id))
{			
if (!g_item[id][ONCE])
{
if(CurButton & IN_USE && !(pev(id, pev_oldbuttons) & IN_USE))
{
CurButton &= ~IN_USE
set_uc(uc_handle, UC_Buttons, CurButton)

BuyRespawn(id)	
}
}
}

if(is_player(id) && zp_GameStart())
{
if((CurButton & IN_USE) && g_level[id][CAN_SKILL] && !g_level[id][DO_SKILL])
{
CurButton &= ~IN_USE
set_uc(uc_handle, UC_Buttons, CurButton)

Get_RTime(id)

ExecuteForward(g_Forwards[FW_SKILL], g_ForwardResult, id, SKILL_E)

g_level[id][DO_SKILL] = true
g_level[id][CAN_SKILL] = false

remove_task(id+TASK_SKILL_DO)
set_task(float(g_level[id][RESET_TIME]), "Reset_Skill", id+TASK_SKILL_DO)	
}	
}

if(is_player(id) && g_had[id][CAN_JUMP]) 
{
static OldButton, flags	
OldButton = pev(id, pev_oldbuttons)
flags = pev(id, pev_flags)

if((CurButton & IN_JUMP) && !(flags & FL_ONGROUND) && !(OldButton & IN_JUMP))
{
if(g_had[id][NUM_JUMP] < 1)
{
g_had[id][DO_JUMP] = true
g_had[id][NUM_JUMP]++
}
}
if(g_had[id][DO_JUMP])
{
static Float:velocity[3]	
entity_get_vector(id,EV_VEC_velocity,velocity)
velocity[2] = 268.328157
entity_set_vector(id,EV_VEC_velocity,velocity)
g_had[id][DO_JUMP] = false
}
if((CurButton & IN_JUMP) && (flags & FL_ONGROUND))
{
g_had[id][NUM_JUMP] = 0
}
}
}
public Reset_Skill(id)
{
id -= TASK_SKILL_DO

if(!is_player(id))
{
remove_task(id+TASK_SKILL_DO)	
return
}

Get_CTime(id)	
g_level[id][DO_SKILL] = false

ExecuteForward(g_Forwards[FW_SKILL_RESET], g_ForwardResult, id)
}
// HERO / HEROINE SYSTEM
public zp_fw_game_start()
{
if(zbs_is_scenario() == 1) return	
static Player; Player =  Get_TotalInPlayer(1);

if(Player < 5)
return	

static PlayerList[32], PlayerNum; PlayerNum = 0
static id; get_players(PlayerList, PlayerNum, "a")

for(new i = 1; i < 2; i++)
{
id = PlayerList[random(PlayerNum)]

if (!is_user_alive(id))
continue

if (!zp_core_is_zombie(id))
Set_PlayerHero(id, random_num(1, 2))		
}

}
public zp_fw_game_end()  
{
g_can_respawn = false
	
for(new id = 1; id < g_MaxPlayers; id++)
{	
if(!Get_BitVar(g_IsConnected, id))
continue	

g_item[id][EXTRA_EXP] = false
g_item[id][RESTOCK] = false

if(Get_BitVar(g_IsAlive, id) && zp_core_is_hero(id))
{	
user_silentkill(id)
}
}
}

public Set_PlayerHero(id, hero)
{
g_had2[id][HERO] = true
g_user_speed[id] = 1.1

fm_set_user_health(id, 1000)
fm_set_user_armor(id, 100)

cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 10 - 1)

get_weapon_shotgun(id, 5)
get_weapon_pistol(id, 1)

get_weapon_grenade_he(id, 3)
get_weapon_grenade_flash(id, 1)
get_weapon_grenade_smoke(id, 3)

get_user_name(id, szName, charsmax(szName))
client_print(0, print_center, "%s has been selected as a Heroine!", szName)

/*
switch(hero)
{	
case 1:
{	
cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 10 - 1)

get_weapon_shotgun(id, 5)
get_weapon_pistol(id, 1)

get_weapon_grenade_he(id, 3)
get_weapon_grenade_flash(id, 1)
get_weapon_grenade_smoke(id, 3)

get_user_name(id, szName, charsmax(szName))
client_print(0, print_center, "%s has been selected as a Heroine!", szName)
}
case 2:
{
cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 11 - 1)

get_weapon_rifle(id, 3)
get_weapon_pistol(id, 1)

get_weapon_grenade_he(id, 4)
get_weapon_grenade_flash(id, 2)
get_weapon_grenade_smoke(id, 3)

get_user_name(id, szName, charsmax(szName))
client_print(0, print_center, "%s has been selected as a Hero!", szName)	
}
}*/

fm_set_user_rendering(id, kRenderFxGlowShell, 150, 200, 45, kRenderNormal, 0)
//zb5_AddTofull_pIcon(id, 220, 0.2, 30.0, "sprites/ZB5/zb_hero.spr")
}
public cmd_drop(id)
{
if(g_had2[id][HERO])
return PLUGIN_HANDLED

return PLUGIN_CONTINUE
}
// END HERO SYSTEM

// MAIN MENU
public Main_Menu(id)
{
if(!Get_BitVar(g_IsConnected, id))
return PLUGIN_HANDLED;

if(!reg_is_user_logged(id))
return PLUGIN_HANDLED 

static buffer[256], menu
menu = menu_create("\yZ-Noid \w/ \rVersion: 1.0", "Main_Menu2") 

if(Get_BitVar(g_IsAlive, id))	
{
formatex(buffer, charsmax(buffer), "Weapons Menu")
menu_additem(menu, buffer, "1")

formatex(buffer, charsmax(buffer), "Choose Human Class^n")
menu_additem(menu, buffer, "2")

formatex(buffer, charsmax(buffer), "Human \rItems \wMenu")
menu_additem(menu, buffer, "3")

formatex(buffer, charsmax(buffer), "\rC\yo\wd\de \yB\ro\dx \dD\ye\rc\wo\yd\de\wr^n")
menu_additem(menu, buffer, "4")

formatex(buffer, charsmax(buffer), "\yDaily Missions \r(NEW)^n^n")
menu_additem(menu, buffer, "5")

formatex(buffer, charsmax(buffer), "\yAccount Settings")
menu_additem(menu, buffer, "6")

if(g_user[id][ADMIN] || g_user[id][VIP])
{
formatex(buffer, charsmax(buffer), "\rServer \yControl Panel")
menu_additem(menu, buffer, "7")
}
}
else	
{
formatex(buffer, charsmax(buffer), "\yBattle Revive \w- \r5000$")
menu_additem(menu, buffer, "1")

formatex(buffer, charsmax(buffer), "\yDaily Missions \r(NEW)^n")
menu_additem(menu, buffer, "2")

formatex(buffer, charsmax(buffer), "\yAccount Settings")
menu_additem(menu, buffer, "3")

if(g_user[id][ADMIN] || g_user[id][VIP])
{
formatex(buffer, charsmax(buffer), "\rServer \yControl Panel")
menu_additem(menu, buffer, "4")
}
}

menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED
} 
public Main_Menu2(id, menu, item)   
{
if(!Get_BitVar(g_IsConnected, id))
return PLUGIN_HANDLED;

if(!reg_is_user_logged(id))
return PLUGIN_HANDLED 

if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback) 
new key = str_to_num(data)   

switch(key)   
{  
case 1:
{
if(Get_BitVar(g_IsAlive, id))	
zb5_weapons_menu(id)
else BuyRespawn(id)
}
case 2:
{
if(Get_BitVar(g_IsAlive, id))	
do_open_menu_hclass(id)  
else zb5_menu_quest(id)
}
case 3:
{
if(Get_BitVar(g_IsAlive, id))		
zb5_menu_items(id) 
else reg_open_menu(id) 
}
case 4:
{
if(Get_BitVar(g_IsAlive, id))		
zb5_cbox_menu(id) 
else Control_Menu(id)  
}
case 5:zb5_menu_quest(id)  
case 6:reg_open_menu(id)  
case 7:
{
if(g_user[id][ADMIN] || g_user[id][VIP])
Control_Menu(id)  
}
}  
menu_destroy(menu)   
return PLUGIN_HANDLED   
}  

public Control_Menu(id)
{
if(!Get_BitVar(g_IsConnected, id))
return PLUGIN_HANDLED;

static buffer[512]
new menu = menu_create("", "Control_Menu2") 

formatex(buffer, charsmax(buffer), "AMXX Menu")
menu_additem(menu, buffer, "1")	

if(is_user_alive(id))
formatex(buffer, charsmax(buffer), "Change team to Spectator")
else
formatex(buffer, charsmax(buffer), "Change team to Player")
menu_additem(menu, buffer, "2")

formatex(buffer, charsmax(buffer), "Restart Round")
menu_additem(menu, buffer, "3")

formatex(buffer, charsmax(buffer), "Restart Server")
menu_additem(menu, buffer, "4")
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED   
} 
public Control_Menu2(id, menu, item)   
{
if(!Get_BitVar(g_IsConnected, id))
return PLUGIN_HANDLED;

if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback) 
new key = str_to_num(data)   

switch(key)   
{  
case 1:client_cmd(id, "amxmodmenu")
case 2:
{
if(Get_BitVar(g_IsAlive, id))
{	
user_kill(id)
cs_set_user_team(id,CS_TEAM_SPECTATOR)
}else cs_set_user_team(id,CS_TEAM_CT)
}
case 3:server_cmd("sv_restartround 1");				
case 4:server_cmd("restart")		 	
}   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}  

public camera(id)
{
if(!is_player(id))
return PLUGIN_HANDLED;

new menu = menu_create("", "cameramenu") 
menu_additem(menu, "3rd Person", "1", 0);
menu_additem(menu, "Top Down", "2", 0);
menu_additem(menu, "Up left", "3", 0);
menu_additem(menu, "1st Person", "4", 0);
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED   
} 
public cameramenu(id, menu, item)   
{
if(!is_player(id))
return PLUGIN_HANDLED;

if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback) 
new key = str_to_num(data)   
switch(key)   
{  
case 1:set_view(id,CAMERA_3RDPERSON)
case 2:set_view(id,CAMERA_TOPDOWN)
case 3:set_view(id,CAMERA_UPLEFT) 
case 4:set_view(id,CAMERA_NONE)   
}   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}  
// MAIN MENU END

/////////////////////// AUTOJOIN /////////////////////////
public message_show_menu(msgid, dest, id) 
{
if (!should_autojoin(id))
return PLUGIN_CONTINUE

static team_select[] = "#Team_Select"
static menu_text_code[sizeof team_select]
get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)

if (!equal(menu_text_code, team_select))
return PLUGIN_CONTINUE

set_force_team_join_task(id, msgid)

if(!g_had[id][CLASS])
do_open_menu_hclass(id) 

return PLUGIN_HANDLED
}

public message_vgui_menu(msgid, dest, id) 
{
if (get_msg_arg_int(1) != 2 || !should_autojoin(id))
return PLUGIN_CONTINUE

set_force_team_join_task(id, msgid)

if(!g_had[id][CLASS])
do_open_menu_hclass(id) 

return PLUGIN_HANDLED
}

bool:should_autojoin(id) 
{
return (get_pcvar_num(g_pcvar_team) && !get_user_team(id) && !task_exists(id))
}
set_force_team_join_task(id, menu_msgid) 
{
static param_menu_msgid[2]
param_menu_msgid[0] = menu_msgid
set_task(0.5, "task_force_team_join", id, param_menu_msgid, sizeof param_menu_msgid)
}

public task_force_team_join(menu_msgid[], id) 
{
if (get_user_team(id))
return

static team[2], class[2]
get_pcvar_string(g_pcvar_team, team, sizeof team - 1)
get_pcvar_string(g_pcvar_class, class, sizeof class - 1)
force_team_join(id, menu_msgid[0], team, class)

set_task(2.0, "respawn", id)
}

stock force_team_join(id, menu_msgid, /* const */ team[] = "5", /* const */ class[] = "0") {
static jointeam[] = "jointeam"
if (class[0] == '0') {
engclient_cmd(id, jointeam, team)
return
}

static msg_block, joinclass[] = "joinclass"
msg_block = get_msg_block(menu_msgid)
set_msg_block(menu_msgid, BLOCK_SET)
engclient_cmd(id, jointeam, team)
engclient_cmd(id, joinclass, class)
set_msg_block(menu_msgid, msg_block)
}
// END AUTOJOIN

// RESPAWN 
public BuyRespawn(id)
{
if(zp_GameEnd())
return	

if(!Get_BitVar(g_IsConnected, id))
return;

if (!g_item[id][ONCE])
{	
new money = cs_get_user_money(id) 	
if (money >= 5000)
{			
cs_set_user_money(id, money - 5000)		
get_user_name(id, szName, 31)
ClearSyncHud(id, g_RespawnHud)
set_hudmessage(200, 130, 0, 0.02, 0.35, 1, 4.0, 4.0)
ShowSyncHudMsg(0, g_RespawnHud, "%s  used battle revive item...", szName)	
PlaySound(id, "ZB5/zsrespawn.wav")
zb5_zombie_PermDeath(id) 
zp_core_respawn_as_zombie(id, false)
ExecuteHamB(Ham_CS_RoundRespawn, id)
cs_set_user_team(id,CS_TEAM_CT)
g_item[id][ONCE] = true
}else zp_colored_print(id, "^x03 You have no money to Revieve !")	
}

}
public respawn(id)
{
if(!Get_BitVar(g_IsConnected, id))
return;
if(!g_can_respawn)
return;
if(g_joined[id])
return;

get_user_name(id, szName, 31)
ClearSyncHud(id, g_RespawnHud)
set_hudmessage(200, 130, 0, 0.02, 0.35, 1, 2.0, 2.0)
ShowSyncHudMsg(0, g_RespawnHud, "%s  respawned by server...", szName)	
fm_set_user_armor(id, 100)
PlaySound(id, "ZB5/zsrespawn.wav")
zp_core_respawn_as_zombie(id, false)
ExecuteHamB(Ham_CS_RoundRespawn, id)	
cs_set_user_team(id,CS_TEAM_CT)
g_joined[id] = true
}
/// END RESPAWN

// NATIVES
public native_class(id)return g_had2[id][CLASS];
public native_admin(id)return g_user[id][ADMIN];
public native_vip(id)return g_user[id][VIP];
public native_hero(id)return g_had2[id][HERO];
public native_set_hero(id, hero)Set_PlayerHero(id, hero)
public native_set_speed(id, Float:speed) g_user_speed[id] = speed
public native_get_power(id)return g_level[id][POWER_LEVEL];
public native_get_level(id)return g_level[id][LEVEL];
public native_item_exp(id)return g_item[id][EXP_X2];

public native_skill_human(id, INFO)
{
switch(INFO)
{
case SKILL_LEVEL: return g_level[id][LEVEL];		
case SKILL_PLEVEL: return g_level[id][POWER_LEVEL];
case SKILL_CAN: return g_level[id][CAN_SKILL];		
case SKILL_DO: return g_level[id][DO_SKILL];		
case SKILL_CTIME:return g_level[id][COUNTDOWN_TIME]
case SKILL_RTIME:return g_level[id][RESET_TIME];
}
return 0;
}
public native_buyexp(id)
{
new money = cs_get_user_money(id) 	

if (!g_item[id][EXTRA_EXP])
{
if (money >= 5000)
{				
cs_set_user_money(id, money - 5000)
g_item[id][EXP_X2] = true
g_item[id][EXTRA_EXP] = true
}else zp_colored_print(id, "^x03 You have no money to boost your EXP !")	
}else zp_colored_print(id, "^x03 You used that item for this map!")
}
public native_restock(id)
{
new money = cs_get_user_money(id)  	
if (!g_item[id][RESTOCK])
{
if (money >= 4000)
{			
cs_set_user_money(id, money - 4000)	
Restock_Ammo(id)
g_item[id][RESTOCK] = true	
}else zp_colored_print(id, "^x03 You have no money to Restock Ammo!")	
}else zp_colored_print(id, "^x03 You used that item for this round!")	
}
public Restock_Ammo(id)
{	
cs_set_user_bpammo(id, CSW_AK47, 200)
cs_set_user_bpammo(id, CSW_M4A1, 200)	
cs_set_user_bpammo(id, CSW_DEAGLE, 90)
ExecuteForward(g_Forwards[FW_RESTOCK], g_ForwardResult, id)
}
public native_register_hclass(const Name[], const Desc[], unlock_cost)
{
param_convert(1)
param_convert(2)

ArrayPushString(Class_Name, Name)
ArrayPushString(Class_Desc, Desc)
ArrayPushCell(Class_UnlockCost, unlock_cost)

g_wpn_i++
return (g_wpn_i - 1)
}

///////// STOCKS ////////
/*public Make_ScenarioIcon(id, status, const icon[])
{
message_begin(MSG_ONE_UNRELIABLE, g_status,{0,0,0},id);
write_byte(1); // status (0=hide, 1=show, 2=flash)
write_string("damage500"); // sprite name
message_end();	

//set_task(3.0, "Remove", id+555)
}
public Remove(id)
{
id -= 555

message_begin(MSG_ONE, g_status,{0,0,0},id);
write_byte(0); // status (0=hide, 1=show, 2=flash)
write_string("kill_none"); // sprite name
message_end();		
}*/

Get_RTime(id)
{
switch(g_level[id][RESET_TIME_LEVEL])
{
case 1:g_level[id][RESET_TIME] = 4
case 2:g_level[id][RESET_TIME] = 5
case 3:g_level[id][RESET_TIME] = 6
case 4:g_level[id][RESET_TIME] = 7
case 5:g_level[id][RESET_TIME] = 8
default:g_level[id][RESET_TIME] = 3
}	
}
Get_CTime(id)
{
switch(g_level[id][COUNTDOWN_LEVEL])
{
case 1:g_level[id][COUNTDOWN_TIME] = 45
case 2:g_level[id][COUNTDOWN_TIME] = 40
case 3:g_level[id][COUNTDOWN_TIME] = 30
case 4:g_level[id][COUNTDOWN_TIME] = 20
case 5:g_level[id][COUNTDOWN_TIME] = 10
default:g_level[id][COUNTDOWN_TIME] = 50
}	
}
stock Get_PlayerCount(Alive, Team)
// Alive: 0 - Dead | 1 - Alive | 2 - Both
// Team: 1 - T | 2 - CT
{
new Flag[4], Flag2[12]
new Players[32], PlayerNum

if(!Alive) formatex(Flag, sizeof(Flag), "%sb", Flag)
else if(Alive == 1) formatex(Flag, sizeof(Flag), "%sa", Flag)

if(Team == 1) 
{
formatex(Flag, sizeof(Flag), "%se", Flag)
formatex(Flag2, sizeof(Flag2), "TERRORIST", Flag)
} else if(Team == 2) 
{
formatex(Flag, sizeof(Flag), "%se", Flag)
formatex(Flag2, sizeof(Flag2), "CT", Flag)
}

get_players(Players, PlayerNum, Flag, Flag2)

return PlayerNum
}

stock Get_TotalInPlayer(Alive)return Get_PlayerCount(Alive, 1) + Get_PlayerCount(Alive, 2)
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_class_remove_post(id)g_had2[id][SOZO] = false
public client_putinserver(id)
{	
Safety_Connected(id)

if(get_user_flags(id) & FLAG_ADMIN)
{
g_user[id][ADMIN] = true	
g_had[id][CAN_JUMP] = true		
}
if(get_user_flags(id) & FLAG_VIP)
{	
g_user[id][VIP] = true	
g_had[id][CAN_JUMP] = true		
} 	 
if(!reg_is_user_logged(id))
reg_open_menu(id)

g_had2[id][CLASS] = false
g_joined[id] = true
}

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Reset_All(id)
	
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)	
}

Safety_Disconnected(id)
{
Reset_All(id)

UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)	
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(!zp_core_is_zombie(id))
{
if(!reg_is_user_logged(id))
reg_open_menu(id)

if(is_user_bot(id))
random_class(id)
else 
GiveHuman(id)	
}else Set_BitVar(g_IsZombie, id)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(!reg_is_user_logged(id))
reg_open_menu(id)

if(is_user_bot(id))
random_class(id)
else GiveHuman(id)
}

public fw_Safety_Killed_Post(id)
{	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if (!g_item[id][ONCE])
{
set_dhudmessage(10, 200, 10, 0.3, 0.70, 0, 15.0, 15.0) // 0.125
show_dhudmessage(id, "^nPress E to respawn as Human (5000$)!")	
}
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)
}
public is_player(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsAlive, id)) 
return 0
if(Get_BitVar(g_IsZombie, id))
return 0
if(!reg_is_user_logged(id))
return 0

return 1
}


/* ===============================
--------- END OF SAFETY  ---------
=================================*/
