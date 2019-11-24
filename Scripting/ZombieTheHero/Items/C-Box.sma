#include <amxmodx>
#include <cstrike>
#include <ZombieMod5>

#define TASK_COUNT 63532

new const sound[][] =
{		
"ZB5/C-Box/congratulation1.wav",
"ZB5/C-Box/congratulation2.wav",	
"ZB5/C-Box/congratulation3.wav"
}

new g_quantity[33], g_time[33], ef_sprite[3]
public plugin_precache() 
{
for(new i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])	
	
ef_sprite[0] = PrecacheModel("sprites/ZB5/result1.spr")
ef_sprite[1] = PrecacheModel("sprites/ZB5/result2.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/result3.spr")
}

public plugin_natives()
{	
register_native("zb5_cbox", "native_cbox", 1)
register_native("zb5_give_cbox", "native_give_cbox", 1)
register_native("zb5_cbox_menu", "show_cbox", 1)
register_native("zb5_cbox_time", "time_cbox", 1)
}

public native_cbox(id) return g_quantity[id];
public time_cbox(id) return g_time[id];
public native_give_cbox(id, amount) g_quantity[id] += amount

//public client_connect(id)reset_vars(id)
//public client_disconnected(id)reset_vars(id)

public reset_vars(id)
{
if(task_exists(id+TASK_COUNT))
remove_task(id+TASK_COUNT)

g_time[id] = 0		
g_quantity[id] = 0
}
public show_cbox(id)
{
if(!is_user_alive(id) || zp_core_is_hero(id))
return PLUGIN_HANDLED;
if(zp_core_is_zombie(id))
return PLUGIN_HANDLED;

static item[64], item2[64], menu

menu = menu_create("\y[Zombie: The Hero] \yC\wo\rd\de \yB\ro\wx \yD\re\dc\wo\yd\de\wr", "cbox")

if(cs_get_user_money(id) >= 5000)	
format(item, charsmax(item), "\yBuy Code Decoder \w(\r5000$\w)")
else
format(item, charsmax(item), "\dBuy Code Decoder (\r5000$\d)")
	
if(g_quantity[id] > 0 && g_time[id] <= 0)	
format(item2, charsmax(item2), "\yOpen Code Decoder \r[%i Quantity]", g_quantity[id])
else if(g_time[id] >= 0 || g_quantity[id] <= 0)
format(item2, charsmax(item2), "\dOpen Code Decoder \r[%i Time Wait]", g_time[id])
	
menu_additem(menu, item, "1", 0)
menu_additem(menu, item2, "2", 0)
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED;
}  
public cbox(id, menu, item)   
{
if(!is_user_alive(id) || zp_core_is_hero(id))
return PLUGIN_HANDLED;
if(zp_core_is_zombie(id))
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
case 1:
{
if(cs_get_user_money(id) >= 5000)	
{	
g_quantity[id]++
show_cbox(id)
cs_set_user_money(id, cs_get_user_money(id) - 5000)
zp_colored_print(id, "You have %i Code Decoders. Use it press M4 !", g_quantity[id])	
}else {
zp_colored_print(id, "You don't have enough money. You need 5000$", g_quantity[id])		
}
}
case 2:
{
if(g_quantity[id] > 0 && g_time[id] <= 0)
{	
switch(random_num(1,3))
{
case 1:
{
Small(id)
g_time[id] = 30
}
case 2:
{
Normal(id)
g_time[id] = 70
}
case 3:
{
Super(id)
g_time[id] = 140
}
}
--g_quantity[id];
}
}
}

menu_destroy(menu)   
return PLUGIN_HANDLED   
}

public Small(id)
{
static szName[32]
get_user_name(id, szName, 31)

switch(random_num(1,6))
{
case 1:
{		
get_weapon_rifle(id, 1)
zp_colored_print(0, "^x01***** [%s] Opened^x04 AK47 Kalashnikov^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 2:
{
get_weapon_rifle(id, 2)
zp_colored_print(0, "^x01***** [%s] Opened^x04 M4A1 Carabine^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 3:
{
get_weapon_grenade_he(id, 1)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Hegrenade^x03 (1 Units)^x01 from C-Box. *****", szName)	
}
case 4:
{
fm_set_user_armor(id, 100)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Armor ^x03 (1 Units)^x01 from C-Box. *****", szName)	
}
case 5:
{
get_weapon_grenade_flash(id, 2)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Frost Nade ^x03(1 Units)^x01 from C-Box. *****", szName)
}
case 6:
{
get_weapon_grenade_he(id, 2)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 M67 FireBomb ^x03(1 Units)^x01 from C-Box. *****", szName)	
}
}
set_task(1.0, "countdown", id+TASK_COUNT)
PlaySound(id, "ZB5/C-Box/congratulation1.wav")
Make_Sprite(id, ef_sprite[0], 1, 1, 32, 2, -15)
}
public Normal(id)
{
static szName[32]
get_user_name(id, szName, 31)

switch(random_num(1,10))
{
case 1:
{
get_weapon_rifle(id, 3)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Double Skull4 ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 2:
{
get_weapon_scope(id, 2)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Balrog5 ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 3:
{
get_weapon_machine(id, 2)	
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 MG3 Rheinmetall ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 4:
{
get_weapon_machine(id, 1)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Balrog7 Machine ^x03(1 Game)^x01 from C-Box. *****", szName)
}

case 5:
{
get_weapon_pistol(id, 3)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Dual Infinity ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 6:
{
get_weapon_scope(id, 4)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Dual Kriss ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 7:
{
get_weapon_subgun(id, 3)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Tempset ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 8:
{
get_weapon_scope(id, 3)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 SF Gun ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 9:
{
get_weapon_scope(id, 7)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 Crow5 ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
case 10:
{
get_weapon_shotgun(id, 1)
zp_colored_print(0, "^x01 ***** [%s] Opened^x04 UTS12 ^x03(1 Game)^x01 from C-Box. *****", szName)	
}
}
set_task(1.0, "countdown", id+TASK_COUNT)
PlaySound(id, "ZB5/C-Box/congratulation2.wav")
Make_Sprite(id, ef_sprite[1], 1, 1, 32, 2, -15)
}
public Super(id)
{
static szName[32]
get_user_name(id, szName, 31)

switch(random_num(1,32))
{
case 1:
{
get_weapon_sniper(id, 1)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Skull5 Behemoth Claw^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 2:
{
get_weapon_sniper(id, 2)
zp_colored_print(0, "^x01***** [%s] Opened^x04 AI AS50 Power +8^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 3:
{
get_weapon_shotgun(id, 4)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Balrog XI Flame Shooter^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 4:
{
get_weapon_flameguns(id, 1)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Dragon Cannon ^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 5:
{
get_weapon_machine(id, 8)
zp_colored_print(0, "^x01***** [%s] Opened^x04 M134 Hero^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 6:
{
get_weapon_machine(id, 4)
zp_colored_print(0, "^x01***** [%s] Opened^x04 SFMG Avalanche^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 7:
{
get_weapon_machine(id, 6)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Crow7 Machine^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 8:
{
get_weapon_subgun(id, 2)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Plasma Gun^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 9:
{
get_weapon_knife(id, 7)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 War Hammer^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 10:
{
get_weapon_knife(id, 3)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Strong Knife^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 11:
{
get_weapon_knife(id, 6)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Thanatos9 Knife^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 12:
{
get_weapon_knife(id, 4)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Skull-9 Knife^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 13:
{
get_weapon_knife(id, 5)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Dragon Sword^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 14:
{
get_weapon_pistol(id, 2)	
zp_colored_print(0,"^x01***** [%s] Opened^x04 Balrog1 Pistol ^x03 (1 Game)^x01 from C-Box. *****", szName)		
}
case 15:
{
get_weapon_grenade_flash(id, 1)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Holy Grenade x2^x03 (1 Units)^x01 from C-Box. *****", szName)		
}
case 16:
{	
get_weapon_rifle(id, 6)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Janus5^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 17:
{
get_weapon_scope(id, 6)	
zp_colored_print(0,"^x01***** [%s] Opened^x04 AK47 Buff^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 18:
{
get_weapon_rifle(id, 4)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Thanatos5^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 19:
{
get_weapon_pistol(id, 6)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Janus1 Launcher^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 20:
{
get_weapon_machine(id, 3)	
zp_colored_print(0,"^x01***** [%s] Opened^x04 Thanatos7^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 21:
{
get_weapon_machine(id, 5)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Skull8^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 22:
{
get_weapon_grenade_he(id, 3)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Plasma Grenade x2^x03 (1 Units)^x01 from C-Box. *****", szName)		
}
case 23:
{
get_weapon_sniper(id, 3)
zp_colored_print(0, "^x01***** [%s] Opened^x04 SL8 Ex^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 24:
{
get_weapon_subgun(id, 4)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Thanatos3^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 25:
{
get_weapon_pistol(id, 4)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Sapientia^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 26:
{
get_weapon_pistol(id, 5)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Thanatos 1^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 27:
{
get_weapon_pistol(id, 7)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Dual Skull2^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 28:
{
get_weapon_machine(id, 7)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Janus7^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 29:
{
get_weapon_shotgun(id, 3)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Magnum Drill^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 30:
{
get_weapon_shotgun(id, 2)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Gatling Volcano^x03 (1 Game)^x01 from C-Box. *****", szName)
}
case 31:
{
get_weapon_chainsaw(id)	
zp_colored_print(0, "^x01***** [%s] Opened^x04 Power Saw^x03 (1 Game)^x01 from C-Box. *****", szName)	
}
case 32:
{
get_weapon_grenade_he(id, 4)
zp_colored_print(0, "^x01***** [%s] Opened^x04 Chain Grenade x2^x03 (1 Units)^x01 from C-Box. *****", szName)		
}
}
set_task(1.0, "countdown", id+TASK_COUNT)
PlaySound(id, "ZB5/C-Box/congratulation3.wav")
Make_Sprite(id, ef_sprite[2], 1, 1, 32, 2, -15)
}
// COUNTDOWN
public countdown(id)
{    		
id -= TASK_COUNT
--g_time[id];

if(g_time[id] >= 1)
{
set_task(1.0, "countdown", id+TASK_COUNT)
}
else if(g_time[id] <= 0)
{
if(task_exists(id+TASK_COUNT))	
remove_task(id+TASK_COUNT)
}
}  
