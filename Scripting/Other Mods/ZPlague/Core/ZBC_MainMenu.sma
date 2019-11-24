#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <zp50_gamemodes>
#include <zp50_ammopacks>
#include <zp50_class_nemesis>
#include <zp50_class_assassin>
#define LIBRARY_ADMIN_MENU "zp50_admin_menu"
#include <zp50_admin_menu>
#include <zp50_colorchat>
#include <ZP_ZombieClasses>
#include <ZP_Shop>

#define ADMIN ADMIN_IMMUNITY
#define VIP ADMIN_RESERVATION
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
const OFFSET_CSMENUCODE = 205
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
new g_had_zombie[33], g_ChooseTeamOverrideActive,g_HudSync, g_GameModeSwarmID, g_GameModeMultiID
public plugin_init()
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")	
register_clcmd("chooseteam", "clcmd_chooseteam")
g_HudSync = CreateHudSyncObj()
}
public plugin_cfg()
{
g_GameModeMultiID = zp_gamemodes_get_id("Multiple Infection Mode")	
g_GameModeSwarmID = zp_gamemodes_get_id("Swarm Mode")
}
public plugin_natives()
{
set_module_filter("module_filter")
set_native_filter("native_filter")
}
public module_filter(const module[])
{
if (equal(module, LIBRARY_ADMIN_MENU))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
if (!trap)
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public event_round_start(id)
{
zp_colored_print(id, " ^x03>>>>> [Zombie: Nanosuit2] By ^x04iNexus^x03<<<<<")
zp_colored_print(id, " ^x03Press^x04 ALT^x03 Nanosuit2 Menu!")
}
public zp_fw_core_cure_post(id)
{
remove_task(id)
g_had_zombie[id] = false	
}
public zp_fw_core_infect_post(id)
{
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return		
if(zp_core_is_zombie(id))
{	
g_had_zombie[id] = false	
if(!is_user_bot(id))set_task(1.0, "ZombieClassMenu", id)	
}
}
public clcmd_chooseteam(id)
{
if (flag_get(g_ChooseTeamOverrideActive, id))
{
show_menu_main(id)
return PLUGIN_HANDLED;
}
flag_set(g_ChooseTeamOverrideActive, id)
return PLUGIN_CONTINUE;
}
public client_putinserver(id)
{
flag_set(g_ChooseTeamOverrideActive, id)
}
show_menu_main(id)
{
menu_cancel(id)	
new menu = menu_create("\yEU-Gaming.Info", "menus") 
if(!zp_core_is_zombie(id))
{	
menu_additem(menu, "\yWeapons Menu", "1", 0);	
menu_additem(menu, "\yExtra \wItems Menu^n", "2", 0);
menu_additem(menu, "\yNanoSuit Menu", "3", 0);
menu_additem(menu, "\rVoteBan \yMenu^n^n", "4", 0);

if(!is_user_alive(id))
{
menu_additem(menu, "\yRespawn as Human \r15 AP^n", "5", 0);	
}
if(get_user_flags(id) & VIP){
menu_additem(menu, "\yCPanel Server \r[ADMINISTRATOR]", "6", 0);
}
}else{
menu_additem(menu, "\rZombie \wItems Menu", "1", 0);
menu_additem(menu, "\rZombie \yClass Menu^n", "2", 0);
menu_additem(menu, "\rVoteBan \yMenu^n^n", "3", 0);
if(!is_user_alive(id))
{
menu_additem(menu, "\yRespawn as Human \r15 AP^n", "4", 0);	
}
if(get_user_flags(id) & VIP){
menu_additem(menu, "\yCPanel Server \r[ADMINISTRATOR]", "5", 0);
}
else if(is_user_alive(id) && !is_user_alive(id)){
menu_additem(menu, "\dCPanel Server [ADMINISTRATOR]", "5", 0);
}
}

menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
} 
public menus(id, menu, item)   
{
if (!is_user_connected(id))
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
if(!zp_core_is_zombie(id))
{ 
switch(key)   
{  	
case 1:zp_weapons_menu(id)		 
case 2:zombie_items(id)
case 3:client_cmd(id, "nanosuit")
case 4:client_cmd(id, "voteban")
case 5:respawn(id)
case 6:CPANEL1(id)  
}   
}else{
switch(key)   
{  	
case 1:zombie_items(id) 
case 2:ZombieClassMenu(id)  
case 3:client_cmd(id, "voteban")	
case 4:respawn(id)
case 5:CPANEL1(id)    
}
}
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
public ZombieClassMenu(id)
{	
if (!is_user_connected(id) || !zp_core_is_zombie(id))
return;	
new current_mode = zp_gamemodes_get_current()
if (current_mode != g_GameModeSwarmID && current_mode != g_GameModeMultiID)
{
if (!is_user_connected(id) || zp_core_is_first_zombie(id))
return;
}else{
if (!is_user_connected(id))
return;
}
menu_cancel(id)		
new menu = menu_create("\y[NS2] \rZombie Classes", "ZombieClass") 
menu_additem(menu, "Hunter Zombie \yLongJump", "1", 0);
menu_additem(menu, "Speeder Zombie \yBlink", "2", 0);
menu_additem(menu, "Jumper Zombie \yJump", "3", 0);
menu_additem(menu, "Light Zombie \yInvisible", "4", 0);
menu_additem(menu, "Fat Zombie \yHealth", "5", 0);
menu_additem(menu, "Swarm Zombie \yKiller", "6", 0);
menu_additem(menu, "HeadCrab Zombie \yClimb", "7", 0);
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
} 
public ZombieClass(id, menu, item)   
{
if (!is_user_connected(id) || !zp_core_is_zombie(id))
return PLUGIN_HANDLED;
new current_mode = zp_gamemodes_get_current()
if (current_mode != g_GameModeSwarmID && current_mode != g_GameModeMultiID)
{
if (!is_user_connected(id) || zp_core_is_first_zombie(id))
return PLUGIN_HANDLED;
}else{
if (!is_user_connected(id))
return PLUGIN_HANDLED;
}
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
if(!g_had_zombie[id])
{	
zp_get_class(id, 1)
g_had_zombie[id] = true
}
}	
case 2:
{
if(!g_had_zombie[id])
{	
zp_get_class(id, 2)
g_had_zombie[id] = true
}
} 
case 3:
{
if(!g_had_zombie[id])
{	
zp_get_class(id, 3)
g_had_zombie[id] = true
}
}
case 4:
{
if(!g_had_zombie[id])
{	
zp_get_class(id, 4)
g_had_zombie[id] = true
}
}
case 5:
{
if(!g_had_zombie[id])
{	
zp_get_class(id, 5)
g_had_zombie[id] = true
}
}
case 6:
{
if(!g_had_zombie[id])
{	
zp_get_class(id, 6)
g_had_zombie[id] = true
}
}
case 7:
{
if(!g_had_zombie[id])
{	
zp_get_class(id, 7)
g_had_zombie[id] = true
}
}
}   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}    
zombie_items(id)
{
menu_cancel(id)		
new menu = menu_create("\y[NS2] \rExtra Items", "zombie") 
if(!zp_core_is_zombie(id))
{
menu_additem(menu, "Explosive Grenade \r3 AP", "1", 0);
menu_additem(menu, "Frost Grenade \r3 AP", "2", 0);
menu_additem(menu, "Flare Grenade \r2 AP", "3", 0);
menu_additem(menu, "Antidote Grenade \r15 AP", "4", 0);
menu_additem(menu, "Unlimited Clip \y(Single Round) \r20 AP", "5", 0);
menu_additem(menu, "Fire Bullets \y(Zombies Will Burnt) \r10 AP", "6", 0);
menu_additem(menu, "Bazooka \rRPG \y(Launcher) \r40 AP", "7", 0);
menu_additem(menu, "Nanosuit \rBooster +50.0% \y(End Of Map) \r30 AP", "8", 0)
}else{
menu_additem(menu, "AntiDote \y(1 Times) \r15 AP", "1", 0);	
menu_additem(menu, "Conc Grenade \y(Shake Screen) \r13 AP", "2", 0);
menu_additem(menu, "Zombie Madness \y(Crazy Appear) \r20 AP", "3", 0);
menu_additem(menu, "Infection Grenade \y(Infection Wave) \r30 AP", "4", 0);
}
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
}  
public zombie(id, menu, item)   
{
if (!is_user_connected(id))
return PLUGIN_HANDLED;

if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback)   
if(!zp_core_is_zombie(id))
{
new key = str_to_num(data)   
switch(key)   
{  
case 1:
{
new money = zp_ammopacks_get(id) 		
if (money >= 3)
{		
zp_ammopacks_set(id, money - 3)	
give_item(id, "weapon_hegrenade")		
}else{
zp_colored_print(id, " ^x01Not enough AmmoPacks!")
}	
}
case 2:
{
new money = zp_ammopacks_get(id) 		
if (money >= 3)
{		
zp_ammopacks_set(id, money - 3)	
give_item(id, "weapon_flashbang")	
}else{
zp_colored_print(id, " ^x01Not enough AmmoPacks!")
}	
}
case 3:
{
new money = zp_ammopacks_get(id) 		
if (money >= 2)
{		
zp_ammopacks_set(id, money - 2)	
give_item(id, "weapon_smokegrenade")	
}else{
zp_colored_print(id, " ^x01Not enough AmmoPacks!")
}	
}
case 4:give_grenade_antidote(id)
case 5:give_item_clip(id)
case 6:give_item_fireclip(id)	
case 7:give_item_jetpack(id)	
case 8:zp_boost_energy(id)
}   
}else{
new key = str_to_num(data)   
switch(key)   
{ 
case 1:give_item_antidote(id)	 
case 2:give_item_conc(id)	
case 3:
{
new money = zp_ammopacks_get(id) 		
if (money >= 15)
{		
zp_ammopacks_set(id, money - 15)		
give_item_madness(id)
}else{
zp_colored_print(id, " ^x01Not enough AmmoPacks!")
}
}
case 4:give_grenade_infect(id)
}
}
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
CPANEL1(id)
{
menu_cancel(id)		
new menu = menu_create("\y[NS2] Admin CPanel", "cpanel") 
if(get_user_flags(id) & ADMIN)
{
menu_additem(menu, "AMXX Menu", "1", 0);
menu_additem(menu, "Shut Down Server", "2", 0);
menu_additem(menu, "Restart Server", "3", 0);
menu_additem(menu, "Restart Round", "4", 0);
menu_additem(menu, "Gamemodes menu", "5", 0);
}
else if(get_user_flags(id) & VIP)
{
menu_additem(menu, "AMXX Menu", "1", 0);
menu_additem(menu, "Restart Round", "2", 0);
menu_additem(menu, "Gamemodes menu", "3", 0);
}
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
} 
public cpanel(id, menu, item)   
{
if (!is_user_connected(id))
return PLUGIN_HANDLED;
if(get_user_flags(id) & VIP)
{
if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback) 
new key = str_to_num(data)   
if(get_user_flags(id) & ADMIN)
{
switch(key)   
{  
case 1:client_cmd(id, "amxmodmenu")			
case 2:server_cmd("quit")		
case 3:server_cmd("restart")		
case 4:server_cmd("sv_restartround 1");
case 5:   
{   	
if (LibraryExists(LIBRARY_ADMIN_MENU, LibType_Library) && is_user_admin(id))
zp_admin_menu_show(id)		
} 	    
}   
}
if(get_user_flags(id) & VIP)
{
switch(key)   
{  
case 1:client_cmd(id, "amxmodmenu")				
case 2:server_cmd("sv_restartround 1");
case 3:   
{   	
if (LibraryExists(LIBRARY_ADMIN_MENU, LibType_Library) && is_user_admin(id))
zp_admin_menu_show(id)		
} 	    
}   
}
}
menu_destroy(menu)   
return PLUGIN_HANDLED   
}     
respawn(id)
{
if(!is_user_alive(id))
{	
new money = zp_ammopacks_get(id) 		
if (money >= 15)
{		
zp_ammopacks_set(id, money - 15)	
cs_set_user_team(id,CS_TEAM_CT)
ExecuteHamB(Ham_CS_RoundRespawn, id)
}
}
if(is_user_alive(id))
{
new szName[32]	
get_user_name(id, szName, 31)
ClearSyncHud(id, g_HudSync)
set_hudmessage(180, 100, 0, 0.02, 0.35, 1, 4.0, 4.0)
ShowSyncHudMsg(id, g_HudSync, "%s  using battle revived item...", szName)	
PlaySound(id, "ZB5/zsrespawn.wav")	
}
}
stock PlaySound(id, const sound[])
{
client_cmd(id, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/
