#include <amxmodx>  
#include <cstrike>
#include <hamsandwich>  
#include <fun>    
#include <fakemeta>
#include <zp50_core>
#include <ZP_Shop>

#define VIP ADMIN_IMMUNITY
#define NO_MONEY "You don`t have enough ammopacks!"
#define set_Money zp_ammopacks_set
#define get_Money zp_ammopacks_get
#define PRIMARY_ONLY 1
#define SECONDARY_ONLY 2
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
enum _:Primary_Shop
{	
sg550,
g3sg1,
m249
}
new g_had_weapon[33], menu, menu2
new g_Shop[33][Primary_Shop];
public plugin_natives()
{
register_native("zp_weapons_menu", "primary_wpn", 1)
}
public client_disconnect(id)g_had_weapon[id] = false
public zp_fw_core_infect_post(id)g_had_weapon[id] = false
public zp_fw_core_cure_post(id)
{
if(!is_user_alive(id))
return; 		
if(zp_class_sniper_get(id) || zp_class_survivor_get(id))
return;			
g_had_weapon[id] = false	
primary_wpn(id)  	
}
public primary_wpn(id)   
{   	
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(zp_core_is_zombie(id))
return PLUGIN_HANDLED

if(zp_class_sniper_get(id) || zp_class_survivor_get(id))
return PLUGIN_HANDLED	

if(g_had_weapon[id])
return PLUGIN_HANDLED	

menu_cancel(id)
new buffer[512]
menu = menu_create("\r[NS2] \yPrimary Weapons", "primary_weapon")  
formatex(buffer, charsmax(buffer), "M4A1 Carbine")
menu_additem(menu, buffer, "1")
formatex(buffer, charsmax(buffer), "AK-47 Kalashnikov")
menu_additem(menu, buffer, "2")
formatex(buffer, charsmax(buffer), "SG552 Scope Gun")
menu_additem(menu, buffer, "3")
formatex(buffer, charsmax(buffer), "M3 Super Pump");
menu_additem(menu, buffer, "4")
formatex(buffer, charsmax(buffer), "XM1014 Automatic");
menu_additem(menu, buffer, "5")
if(g_Shop[id][m249] == 1)
{ 
formatex(buffer, charsmax(buffer), "M249 Machine Gun")
menu_additem(menu, buffer, "6")
} 
else if(get_Money(id) >= 7)
{
formatex(buffer, charsmax(buffer), "M249 Machine Gun \r(Locked) \y30 AP");
menu_additem(menu, buffer, "6")
}
else if(get_Money(id) <= 7)
{ 
formatex(buffer, charsmax(buffer), "M249 Machine Gun \r(Locked) \d30 AP");
menu_additem(menu, buffer, "6")
}
if(g_Shop[id][sg550] == 1)
{ 
formatex(buffer, charsmax(buffer), "SG550 Auto-Sniper Gun")
menu_additem(menu, buffer, "7")
} 
else if(get_Money(id) >= 10)
{
formatex(buffer, charsmax(buffer), "SG550 Auto-Sniper Gun \r(Locked) \y40 AP");
menu_additem(menu, buffer, "7")
}
else if(get_Money(id) <= 10)
{ 
formatex(buffer, charsmax(buffer), "SG550 Auto-Sniper Gun \r(Locked) \d40 AP");
menu_additem(menu, buffer, "7")
}
if(g_Shop[id][g3sg1] == 1)
{ 
formatex(buffer, charsmax(buffer), "G3SG1 Auto-Sniper Gun")
menu_additem(menu, buffer, "8")
} 
else if(get_Money(id) >= 15)
{
formatex(buffer, charsmax(buffer), "G3SG1 Auto-Sniper Gun \r(Locked) \y45 AP");
menu_additem(menu, buffer, "8")
}
else if(get_Money(id) <= 15)
{ 
formatex(buffer, charsmax(buffer), "G3SG1 Auto-Sniper Gun \r(Locked) \d45 AP");
menu_additem(menu, buffer, "8")
}
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED   
}   

public primary_weapon(id, menu, item)   
{   
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(zp_core_is_zombie(id))
return PLUGIN_HANDLED

if(zp_class_sniper_get(id) || zp_class_survivor_get(id))
return PLUGIN_HANDLED	
	
if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback);
drop_weapons(id, PRIMARY_ONLY)
new key = str_to_num(data)   
switch(key)   
{   
case 1:   
{   
give_item(id, "weapon_m4a1")
cs_set_user_bpammo (id, CSW_M4A1, 90)
g_had_weapon[id] = true
secondary_wpn(id)  
return PLUGIN_HANDLED   
}   
case 2:   
{   
give_item(id, "weapon_ak47")
cs_set_user_bpammo (id, CSW_AK47, 90) 
g_had_weapon[id] = true
secondary_wpn(id)  
return PLUGIN_HANDLED   
}   
case 3:   
{   
give_item(id, "weapon_sg552")
cs_set_user_bpammo (id, CSW_SG552, 90)
g_had_weapon[id] = true
secondary_wpn(id)  
return PLUGIN_HANDLED 
}
case 4:   
{   
give_item(id, "weapon_m3")
cs_set_user_bpammo (id, CSW_M3, 32)
g_had_weapon[id] = true	
secondary_wpn(id)  
return PLUGIN_HANDLED 
}
case 5:   
{   
give_item(id, "weapon_xm1014")
cs_set_user_bpammo (id, CSW_XM1014, 32)
g_had_weapon[id] = true
secondary_wpn(id)  
return PLUGIN_HANDLED 
}
case 6:   
{   
if(g_Shop[id][m249] == 1)
{ 
give_item(id, "weapon_m249")
cs_set_user_bpammo (id, CSW_M249, 200)
g_had_weapon[id] = true
secondary_wpn(id)  
return PLUGIN_HANDLED 
}
else if(get_Money(id) >= 30)
{     
g_Shop[id][m249] = 1;
give_item(id, "weapon_m249")
cs_set_user_bpammo (id, CSW_M249, 200)
g_had_weapon[id] = true
secondary_wpn(id)  
set_Money(id, get_Money(id) - 30) 			
client_cmd(id, "spk events/enemy_died.wav")
return PLUGIN_HANDLED 
}
else if(get_Money(id) <= 30)
{ 
client_cmd(id, "spk events/friend_died.wav")
client_print(id, print_center, NO_MONEY)
primary_wpn(id)
return PLUGIN_HANDLED				
}
}
case 7:   
{   
if(g_Shop[id][sg550] == 1)
{ 
give_item(id, "weapon_sg550")
cs_set_user_bpammo (id, CSW_SG550, 90)
g_had_weapon[id] = true
secondary_wpn(id)  
return PLUGIN_HANDLED 
}
else if(get_Money(id) >= 40)
{     
g_Shop[id][sg550] = 1;
give_item(id, "weapon_sg550")
cs_set_user_bpammo (id, CSW_SG550, 90)
g_had_weapon[id] = true
secondary_wpn(id)  
set_Money(id, get_Money(id) - 40) 			
client_cmd(id, "spk events/enemy_died.wav")
return PLUGIN_HANDLED 
}
else if(get_Money(id) <= 40)
{ 
client_cmd(id, "spk events/friend_died.wav")
client_print(id, print_center, NO_MONEY)
primary_wpn(id)
return PLUGIN_HANDLED				
}
}
case 8:   
{   
if(g_Shop[id][g3sg1] == 1)
{ 
give_item(id, "weapon_g3sg1")
cs_set_user_bpammo (id, CSW_G3SG1, 90)
g_had_weapon[id] = true
secondary_wpn(id)  
return PLUGIN_HANDLED 
}
else if(get_Money(id) >= 45)
{     
g_Shop[id][g3sg1] = 1;
give_item(id, "weapon_g3sg1")
cs_set_user_bpammo (id, CSW_G3SG1, 90)
g_had_weapon[id] = true
secondary_wpn(id)  
set_Money(id, get_Money(id) - 45) 			
client_cmd(id, "spk events/enemy_died.wav")
return PLUGIN_HANDLED 
}
else if(get_Money(id) <= 45)
{ 
client_cmd(id, "spk events/friend_died.wav")
client_print(id, print_center, NO_MONEY)
primary_wpn(id)
return PLUGIN_HANDLED				
}
}
}   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   

public secondary_wpn(id)  
{   
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(zp_core_is_zombie(id))
return PLUGIN_HANDLED

if(zp_class_sniper_get(id) || zp_class_survivor_get(id))
return PLUGIN_HANDLED
	
menu_cancel(id)
	
new buffer[512]	
menu2 = menu_create("\r[NS2] \ySecondary Weapons", "secondary_weapon")   
formatex(buffer, charsmax(buffer), "USP .45 ACP Tactical")
menu_additem(menu2, buffer, "1")
formatex(buffer, charsmax(buffer), "Desert Eagle .50 AE")
menu_additem(menu2, buffer, "2")
formatex(buffer, charsmax(buffer), "Dual Elite .9mm")
menu_additem(menu2, buffer, "3")
menu_setprop(menu2, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu2, 0)  
return PLUGIN_HANDLED   
} 

public secondary_weapon(id, menu2, item)   
{   
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(zp_core_is_zombie(id))
return PLUGIN_HANDLED

if(zp_class_sniper_get(id) || zp_class_survivor_get(id))
return PLUGIN_HANDLED
	
if (item == MENU_EXIT)   
{   
menu_destroy(menu2)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu2, item, access, data,15, iName, 64, callback)   
drop_weapons(id, SECONDARY_ONLY)
new key = str_to_num(data)   
switch(key)   
{   
case 1:   
{   
give_item(id, "weapon_usp")
cs_set_user_bpammo(id, CSW_USP, 100)
give_item(id, "weapon_hegrenade")
give_item(id, "weapon_flashbang")
give_grenade_flare(id) 
g_had_weapon[id] = true
return PLUGIN_HANDLED   
}   
case 2:   
{   
give_item(id, "weapon_deagle")
cs_set_user_bpammo(id, CSW_DEAGLE, 32)
give_item(id, "weapon_hegrenade")
give_item(id, "weapon_flashbang")
give_grenade_flare(id) 
g_had_weapon[id] = true
return PLUGIN_HANDLED   
}  
case 3:   
{   
give_item(id, "weapon_elite")
cs_set_user_bpammo(id, CSW_ELITE, 200)
give_item(id, "weapon_hegrenade")
give_item(id, "weapon_flashbang")
give_grenade_flare(id) 
g_had_weapon[id] = true
return PLUGIN_HANDLED   
}  				
}  
menu_destroy(menu2)   
return PLUGIN_HANDLED   
} 
drop_weapons(id, dropwhat)
{
// Get user weapons
new weapons[32], num_weapons, index, index2, weaponid, weaponid2
get_user_weapons(id, weapons, num_weapons)

// Loop through them and drop primaries or secondaries
for (index = 0; index < num_weapons; index++)
{
// Prevent re-indexing the array
weaponid = weapons[index]

if ((dropwhat == PRIMARY_ONLY && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
|| (dropwhat == SECONDARY_ONLY && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
{
// Get weapon entity
new wname[32]
get_weaponname(weaponid, wname, charsmax(wname))

// Check if another weapon uses same type of ammo first
for (index2 = 0; index2 < num_weapons; index2++)
{
// Prevent re-indexing the array
weaponid2 = weapons[index2]

// Only check weapons that we are not going to drop
if ((dropwhat == PRIMARY_ONLY && ((1<<weaponid2) & SECONDARY_WEAPONS_BIT_SUM))
|| (dropwhat == SECONDARY_ONLY && ((1<<weaponid2) & PRIMARY_WEAPONS_BIT_SUM)))
{
}
}


// Player drops the weapon
engclient_cmd(id, "drop", wname)
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
