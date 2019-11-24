#include <amxmodx>
#include <ZombieMod5>

#define TASK_CHECK 1242016
#define MAX_WEAPON 100

enum TOTAL_FORWARDS
{
FW_SELECT_ITEM = 0,
FW_REMOVE
}

enum _:Weapons
{	
PistolName,
ShotgunName,
SubName,
RifleName,
SniperName,
MachineName,
DestroyerName,
KnifeName
}
enum _:LastWeapons
{	
PRIMARY,	
SECONDARY,
MELEE
}
enum _:Options
{
Selected_Knife,
Selected_Pistol,
Selected_Primary
}

static Array:Weapon_Name, Array:Weapon_Desc, Array:Weapon_Type, Array:Weapon_UnlockCost, Array:Weapon_VIP

new g_IsZombie, g_IsAlive, g_IsConnected, g_Cvar_Enable, g_Cvar_Enable2
new g_had[33][Options], g_wpn[33][Weapons], g_wpn_i, g_ForwardResult, g_Forwards[TOTAL_FORWARDS]
new g_wpn_primary[MAX_WEAPON], g_wpn_count, g_scaned

new g_last[33][LastWeapons], bool:g_last_enabled[33], bool:g_menu_show[33]

public plugin_init() 
{	
Register_SafetyFunc()	
		
g_Forwards[FW_SELECT_ITEM] = CreateMultiForward("zb5_weapon_selected_post", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_REMOVE] = CreateMultiForward("zb5_weapon_remove_post", ET_IGNORE, FP_CELL, FP_CELL)

g_Cvar_Enable = 1
g_Cvar_Enable2 = 1

}
public plugin_natives()
{
register_native("zb5_weapons_primary", "native_wpn", 1)	
register_native("zb5_weapons_secondary", "native_wpn2", 1)
register_native("zb5_weapons_menu", "choose_wpn", 1)	
register_native("zb5_register_weapon", "native_register_weapon", 1)
}
public plugin_precache()
{	
Weapon_Name = ArrayCreate(64, 1)
Weapon_Desc = ArrayCreate(64, 1)
Weapon_Type = ArrayCreate(1, 1)
Weapon_VIP = ArrayCreate(1, 1)
Weapon_UnlockCost = ArrayCreate(1, 1)
}
public plugin_cfg()
{
if(!g_scaned)
{
g_scaned = 1

for(new i = 0; i < g_wpn_i; i++)
{
if(get_weapon_type(i) == WPN_SHOTGUNS || get_weapon_type(i) == WPN_MACHINES || get_weapon_type(i) == WPN_SNIPERS || get_weapon_type(i) == WPN_DESTROYERS || get_weapon_type(i) == WPN_SUBS || get_weapon_type(i) == WPN_RIFLES)
{
g_wpn_primary[g_wpn_count] = i
g_wpn_count++
}
}
log_amx("Primary Count: %i", g_wpn_count)	
}	
}

public ResetSelect(id, select)
{
if(select)	
arrayset(_:g_had[id], false, sizeof(g_had[]));
else 
{
remove_task(id+TASK_CHECK)
arrayset(_:g_wpn[id], false, sizeof(g_wpn[]));
arrayset(_:g_had[id], false, sizeof(g_had[]));	
}
}
public Check(id)
{
if(!is_player(id))
return 

if(!zp_GameAvailable())
return 

if(g_last_enabled[id])
GetLastChoosed(id)
else {
if(!g_menu_show[id])	
choose_wpn(id)
}
}
/*public random_weapon(id)
{
if(has_user_any_weapon(id))
return	

static  wpn_id
wpn_id = g_wpn_primary[random_num(0, g_wpn_count)]	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, wpn_id)	
}*/
public choose_wpn(id)  
{   		
/*if(!is_player(id))
{	
menu_destroy(menu)   	
return PLUGIN_HANDLED 
}*/

if(g_menu_show[id])
g_menu_show[id] = false

static buffer[70]
static menu; menu = menu_create("\r.:: \yChoose \r::.", "choose_weapon")  

formatex(buffer, charsmax(buffer), "\yWeapons Menu")
menu_additem(menu, buffer, "1")	

formatex(buffer, charsmax(buffer), g_last_enabled[id] ? "Get Last Weapons \y[ON]" : "\dGet Last Weapons \r[OFF]")
menu_additem(menu, buffer, "2")	

formatex(buffer, charsmax(buffer), "\rDon't show this menu on new round !")
menu_additem(menu, buffer, "3")	

//menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
menu_display(id, menu, 0)	
return PLUGIN_HANDLED  
} 

public choose_weapon(id, menu, item)   
{   	
if(!is_player(id))   	
return PLUGIN_HANDLED 

if(item == MENU_EXIT)
{
menu_destroy(menu)
return PLUGIN_HANDLED 
}

static data[30], iName[64]    
static access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback)   
static key; key = str_to_num(data)  

switch(key)   
{ 		 	
case 1:   
{
choose_wpn_category(id)  
return PLUGIN_HANDLED   
} 	 	
case 2:   
{   
if(g_last_enabled[id])
{
g_last_enabled[id] = false
choose_wpn(id) 
}
else 
{
g_last_enabled[id] = true
choose_wpn(id)  
}

return PLUGIN_HANDLED   
}  	
case 3:   
{   
if(!g_menu_show[id])
g_menu_show[id] = true

return PLUGIN_HANDLED   
}     		
}   
menu_destroy(menu)   
return PLUGIN_HANDLED  
} 



public choose_wpn_category(id)  
{   		
static buffer[70]	
static menu; menu = menu_create("\r.:: \yChoose your WPN \r::.", "choose_weapon_category")  
 
if(!is_player(id))
{
menu_destroy(menu)   	
return PLUGIN_HANDLED 
}

formatex(buffer, charsmax(buffer), g_had[id][Selected_Pistol] ? "\dPistols^n" : "Pistols^n")
menu_additem(menu, buffer, "1")	

formatex(buffer, charsmax(buffer), g_had[id][Selected_Primary] ? "\dWarfame ShotGun" : "Warfame ShotGun")
menu_additem(menu, buffer, "2")	

formatex(buffer, charsmax(buffer), g_had[id][Selected_Primary] ? "\dH&K SubGuns" : "H&K SubGuns")
menu_additem(menu, buffer, "3")	

formatex(buffer, charsmax(buffer), g_had[id][Selected_Primary] ? "\dAssault Rifles" : "Assault Rifles")
menu_additem(menu, buffer, "4")	

formatex(buffer, charsmax(buffer), g_had[id][Selected_Primary] ? "\dSniper Rifles^n" : "Sniper Rifles^n")
menu_additem(menu, buffer, "5")	

formatex(buffer, charsmax(buffer), g_had[id][Selected_Primary] ? "\dDestroyer Machines" : "Destroyer Machines")
menu_additem(menu, buffer, "6")	

formatex(buffer, charsmax(buffer), g_had[id][Selected_Primary] ? "\dBeast Weapons^n" : "\rBeast \yWeapons^n")
menu_additem(menu, buffer, "7")

formatex(buffer, charsmax(buffer), g_had[id][Selected_Knife] ? "\dSelect Melee^n" : "\ySelect Knife^n")
menu_additem(menu, buffer, "8")


formatex(buffer, charsmax(buffer),"\yVisit: \rwww.CMS-BG.eu")
menu_additem(menu, buffer, "9")
formatex(buffer, charsmax(buffer), "Exit")
menu_additem(menu, buffer, "0")

menu_setprop(menu,MPROP_PERPAGE, 0)   
menu_display(id, menu, 0)
return PLUGIN_HANDLED  
} 

public choose_weapon_category(id, menu, item)   
{   	
if(!is_player(id))
{
menu_destroy(menu)   	
return PLUGIN_HANDLED 
}

static data[30], iName[64]    
static access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback)   
static key; key = str_to_num(data)  

switch(key)   
{ 	
case 0:   
{   
menu_cancel(id);  
return PLUGIN_HANDLED   
}  		 	
case 1:   
{   
do_open_menu_weapon(id, WPN_PISTOLS, 0)	
return PLUGIN_HANDLED   
}  	
case 2:   
{   
do_open_menu_weapon(id, WPN_SHOTGUNS, 0)
return PLUGIN_HANDLED   
}     
case 3:   
{
do_open_menu_weapon(id, WPN_SUBS, 0)
return PLUGIN_HANDLED   
} 
case 4:   
{
do_open_menu_weapon(id, WPN_RIFLES, 0)
return PLUGIN_HANDLED   
}  
case 5:   
{
do_open_menu_weapon(id, WPN_SNIPERS, 0)
return PLUGIN_HANDLED   
}  
case 6:   
{
do_open_menu_weapon(id, WPN_MACHINES, 0)
return PLUGIN_HANDLED   
} 
case 7:   
{
do_open_menu_weapon(id, WPN_DESTROYERS, 0)
return PLUGIN_HANDLED   
}  
case 8:   
{   
do_open_menu_weapon(id, WPN_KNIVES, 0)
return PLUGIN_HANDLED   
}  
case 9:   
{   
choose_wpn(id)  
return PLUGIN_HANDLED   
}  		
}   
menu_destroy(menu)   
return PLUGIN_HANDLED  
} 
public equip(id)do_open_menu_weapon(id, WPN_SETS, 0)
public do_open_menu_weapon(id, type, page)
{
if(!is_player(id))
return  PLUGIN_HANDLED 

static menu, Temp_String[128], Temp_String2[128], Temp_String3[30], Temp_String4[128], i
static MyLevel; MyLevel = zb5_get_user_level(id)

switch(type)
{
case WPN_PISTOLS:menu = menu_create("Choose Secondary", "weapon_menu_handle")	
case WPN_SHOTGUNS:menu = menu_create("Choose Primary", "weapon_menu_handle")
case WPN_SUBS:menu = menu_create("Choose Primary", "weapon_menu_handle")
case WPN_RIFLES:menu = menu_create("Choose Primary", "weapon_menu_handle")
case WPN_SNIPERS:menu = menu_create("Choose Primary", "weapon_menu_handle")
case WPN_MACHINES:menu = menu_create("Choose Primary", "weapon_menu_handle")
case WPN_DESTROYERS:menu = menu_create("Choose Primary", "weapon_menu_handle")
case WPN_KNIVES:menu = menu_create("Choose Melee", "weapon_menu_handle")
}

for(i = 0; i < g_wpn_i; i++)
{	
if(get_weapon_type(i) == type)
{	
if(MyLevel >= ArrayGetCell(Weapon_UnlockCost, i))
{		
if(get_weapon_vip(i) == 1)
{
if(!zp_core_is_vip(id) && !zp_core_is_admin(id))
{	
ArrayGetString(Weapon_Name, i, Temp_String, sizeof(Temp_String))
ArrayGetString(Weapon_Desc, i, Temp_String4, sizeof(Temp_String4))
num_to_str(i, Temp_String3, sizeof(Temp_String3))
formatex(Temp_String2, sizeof(Temp_String2), "%s %s \r(VIP)", Temp_String , Temp_String4)
menu_additem(menu, Temp_String2, Temp_String3)
}else {				
ArrayGetString(Weapon_Name, i, Temp_String, sizeof(Temp_String))
ArrayGetString(Weapon_Desc, i, Temp_String4, sizeof(Temp_String4))
num_to_str(i, Temp_String3, sizeof(Temp_String3))
formatex(Temp_String2, sizeof(Temp_String2), "%s %s", Temp_String, Temp_String4)
menu_additem(menu, Temp_String2, Temp_String3)
}
} else {				
ArrayGetString(Weapon_Name, i, Temp_String, sizeof(Temp_String))
ArrayGetString(Weapon_Desc, i, Temp_String4, sizeof(Temp_String4))
num_to_str(i, Temp_String3, sizeof(Temp_String3))
formatex(Temp_String2, sizeof(Temp_String2), "%s %s", Temp_String, Temp_String4)
menu_additem(menu, Temp_String2, Temp_String3)	
}
} 
}
}



menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
menu_display(id, menu, page)	
return PLUGIN_HANDLED
}

public weapon_menu_handle(id, menu, item)
{
if(!is_player(id))
return PLUGIN_HANDLED 

new data[10], szName[64], access, callback
menu_item_getinfo(menu, item, access, data,charsmax(data), szName, charsmax(szName), callback)

new wpn_id = str_to_num(data)

if (item == MENU_EXIT)   
{   	
menu_destroy(menu)		
return PLUGIN_HANDLED   
}  

if(get_weapon_vip(wpn_id) ==  1)
{
if(!zp_core_is_vip(id) && !zp_core_is_admin(id))
zp_colored_print(id, "^1[ERROR] ^3You're not a ^4VIP Member^3 to unlock this weapon !")	
else 
{
small_handle(id, wpn_id)  
choose_wpn_category(id)  	
}
}
else
{	
small_handle(id, wpn_id)
choose_wpn_category(id)  
}		

return PLUGIN_CONTINUE
}

public small_handle(id, wpn_id)
{	
if(!is_player(id))
return 

switch(get_weapon_type(wpn_id))
{
case WPN_KNIVES:
{
g_wpn[id][KnifeName] = wpn_id
g_last[id][MELEE] = wpn_id

if(!g_had[id][Selected_Knife])
{	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][KnifeName])
g_had[id][Selected_Knife] = true
}
}	
case WPN_PISTOLS:
{
g_wpn[id][PistolName] = wpn_id
g_last[id][SECONDARY] = wpn_id

if(!g_had[id][Selected_Pistol])
{
drop_weapons(id, 2)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][PistolName])
g_had[id][Selected_Pistol] = true
}
}
case WPN_SHOTGUNS:
{	
g_wpn[id][ShotgunName] = wpn_id	
g_last[id][PRIMARY] = wpn_id

if(!g_had[id][Selected_Primary])
{
drop_weapons(id, 1)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][ShotgunName])
g_had[id][Selected_Primary] = true
}
}
case WPN_SUBS:
{	
g_wpn[id][SubName] = wpn_id
g_last[id][PRIMARY] = wpn_id

if(!g_had[id][Selected_Primary])
{
drop_weapons(id, 1)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][SubName])
g_had[id][Selected_Primary] = true
}	
}
case WPN_RIFLES:
{	
g_wpn[id][RifleName] = wpn_id	
g_last[id][PRIMARY] = wpn_id

if(!g_had[id][Selected_Primary])
{
drop_weapons(id, 1)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][RifleName])
g_had[id][Selected_Primary] = true
}
}
case WPN_SNIPERS:
{	
g_wpn[id][SniperName] = wpn_id	
g_last[id][PRIMARY] = wpn_id

if(!g_had[id][Selected_Primary])
{
drop_weapons(id, 1)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][SniperName])
g_had[id][Selected_Primary] = true
}
}
case WPN_MACHINES:
{	
g_wpn[id][MachineName] = wpn_id	
g_last[id][PRIMARY] = wpn_id

if(!g_had[id][Selected_Primary])
{
drop_weapons(id, 1)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][MachineName])
g_had[id][Selected_Primary] = true
}
}
case WPN_DESTROYERS:
{	
g_wpn[id][DestroyerName] = wpn_id	
g_last[id][PRIMARY] = wpn_id

if(!g_had[id][Selected_Primary])
{
drop_weapons(id, 1)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_wpn[id][DestroyerName])
g_had[id][Selected_Primary] = true
}
}	

}
}
public get_weapon_type(wpn_id)
{
if(wpn_id > g_wpn_i)
return 1

return ArrayGetCell(Weapon_Type, wpn_id)
}
public get_weapon_vip(wpn_id)
{
if(wpn_id > g_wpn_i)
return 1

return ArrayGetCell(Weapon_VIP, wpn_id)
}
public GetLastChoosed(id)
{
if(!is_player(id))
return 

if(!g_had[id][Selected_Knife])
{	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_last[id][MELEE])
g_had[id][Selected_Knife] = true
}

if(!g_had[id][Selected_Pistol])
{
drop_weapons(id, 2)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_last[id][SECONDARY])
g_had[id][Selected_Pistol] = true
}

if(!g_had[id][Selected_Primary])
{
drop_weapons(id, 1)	
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_last[id][PRIMARY])
g_had[id][Selected_Primary] = true
}

}


////// NATIVES /////
public native_register_weapon(const Name[], const Desc[], weapon_type, unlock_cost, weapon_vip)
{
param_convert(1)
param_convert(2)

ArrayPushString(Weapon_Name, Name)
ArrayPushString(Weapon_Desc, Desc)

ArrayPushCell(Weapon_Type, weapon_type)
ArrayPushCell(Weapon_UnlockCost, unlock_cost)
ArrayPushCell(Weapon_VIP, weapon_vip)

g_wpn_i++
return (g_wpn_i - 1)
}
public native_wpn()return g_Cvar_Enable;
public native_wpn2()return g_Cvar_Enable2;

/* ===============================
------------- SAFETY -------------
=================================*/

public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_last[id][SECONDARY] = 0
g_last[id][PRIMARY] = 0
g_last[id][MELEE] = 0

ResetSelect(id, 0)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_last[id][SECONDARY] = 0
g_last[id][PRIMARY] = 0
g_last[id][MELEE] = 0

ResetSelect(id, 0)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

ResetSelect(id, 1)

/*if(is_user_bot(id))random_weapon(id)
else if(is_player(id))Check(id)	
*/
if(is_player(id))
set_task(3.0, "Check", id)
}
public zp_fw_core_cure_post(id)
{	
UnSet_BitVar(g_IsZombie, id)	
Set_BitVar(g_IsAlive, id)

ResetSelect(id, 1)

/*if(is_user_bot(id))random_weapon(id)
else 
if(is_player(id))*/
set_task(3.0, "Check", id)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

ResetSelect(id, 0)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)
ResetSelect(id, 0)
}

public is_player(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsAlive, id)) 
return 0
if(!reg_is_user_logged(id))
return 0
if(Get_BitVar(g_IsZombie, id))
return 0
if(zp_core_is_hero(id))
return 0

return 1
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
