#include <amxmodx>
#include <cstrike>
#include <ZombieMod5>

enum Items
{
Jump,
Sheild,	
Booster,
Boosted,
Stronglife,
FlameBullets,
Nightvision,
DoubleGrenade,
BoughtGrenade,
BoughtGrenade2,
RespawnNoTime
}

new g_had[33][Items], g_IsZombie, g_IsAlive, g_IsConnected
public plugin_init()
{	
Register_SafetyFunc()	
	
register_forward(FM_CmdStart, "fw_CmdStart")	
RegisterHam(Ham_TakeDamage, "player", "fw_takedamage")
}
public plugin_natives()
{
register_native("zb5_give_NightVision", "native_nightvision", 1)		
register_native("zb5_had_DamageBooster", "native_p30", 1)
register_native("zb5_give_DamageBooster", "native_give_p30", 1)
register_native("zb5_give_Sheild", "native_sheild", 1)
register_native("zb5_had_DoubleGrenade", "native_Spec", 1)
register_native("zb5_had_ZombieRespawn", "native_zombierespawn", 1)
register_native("zb5_had_StrongLife", "native_StrongLife", 1)
register_native("zb5_menu_items", "native_items_menu", 1)
}
Reset_All(id, set)
{
if(set)
{	
g_had[id][Boosted] = false
g_had[id][Booster] = false
g_had[id][Jump] = false
g_had[id][Sheild] = false
g_had[id][Stronglife] = false
g_had[id][DoubleGrenade] = false
g_had[id][RespawnNoTime] = false
}

g_had[id][Nightvision] = false
g_had[id][FlameBullets] = false
g_had[id][BoughtGrenade] = false
g_had[id][BoughtGrenade2] = false
g_had[id][Sheild] = false
}
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)	

if((CurButton & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))
{
CurButton &= ~IN_JUMP
set_uc(uc_handle, UC_Buttons, CurButton)

if(g_had[id][Jump])
{
static flags; flags = pev(id, pev_flags)
static waterlvl; waterlvl = pev(id, pev_waterlevel)
	
if (!(flags & FL_ONGROUND))
return FMRES_IGNORED

if (flags & FL_WATERJUMP)
return FMRES_IGNORED

if (waterlvl > 1)
return FMRES_IGNORED
	
static Float:fVelocity[3]
pev(id, pev_velocity, fVelocity)

fVelocity[2] += 314.0

set_pev(id, pev_velocity, fVelocity)
set_pev(id, pev_gaitsequence, 6)
}
}
return FMRES_HANDLED
}
// DAMAGE BOOSTER
public set_damageboost(id)
{
if(!g_had[id][Booster]) 
return;

g_had[id][Boosted] = true
}
public set_decoder_damageboost(id)
{
g_had[id][Booster] = true
g_had[id][Boosted] = true
}

// END
public ShowMenuHM(id)
{
if(!Get_BitVar(g_IsAlive, id))
return PLUGIN_HANDLED;
	
static buffer[512], menu, money
menu = menu_create("\y[Zombie: Z-Noid] \rItems Menu", "menus")

money = cs_get_user_money(id)

if(!Get_BitVar(g_IsZombie, id))
{

if (money < 2000)	
formatex(buffer, charsmax(buffer), "\dHeavanly Boot - Jump Higher (2000$)")
else
formatex(buffer, charsmax(buffer), !g_had[id][Jump] ? "Heavanly Boot \y- Jump Higher \w(\r2000$\w)" : "\dHeavanly Boot - Jump Higher \y(Unlocked)")
menu_additem(menu, buffer, "1")	
	
if (money < 5000)	
formatex(buffer, charsmax(buffer), "\dx1.3 Damage - Increase Your Damage (5000$)")
else
formatex(buffer, charsmax(buffer), !g_had[id][Booster] ? "x1.3 Damage \y- Increase Your Damage \w(\r5000$\w)" : "\dx1.3 Damage - Increase Your Damage \y(Unlocked)")
	
menu_additem(menu, buffer, "2")

if (money < 1500)	
formatex(buffer, charsmax(buffer), "\dGrenade Specialist - x2 Grenades (1500$)")
else
formatex(buffer, charsmax(buffer), !g_had[id][DoubleGrenade] ? "Grenade Specialist \y- x2 Grenades \w(\r1500$\w)" : "\dGrenade Specialist - x2 Grenades \y(Unlocked)")	
menu_additem(menu, buffer, "3")

if (money < 4000)	
formatex(buffer, charsmax(buffer), "\dStrong Life - More BP Ammo (4000$)")
else
formatex(buffer, charsmax(buffer), !g_had[id][Stronglife] ? "Strong Life \y- More BP Ammo \w(\r4000$\w)" : "\dStrong Life - More BP Ammo \y(Unlocked)")			
menu_additem(menu, buffer, "4")

if (money < 6000)	
formatex(buffer, charsmax(buffer), "\dIncendiary Bullets - Zombies Burn (6000$)")
else
formatex(buffer, charsmax(buffer), !g_had[id][FlameBullets] ?  "Incendiary Bullets \y- Zombies Burn \w(\r6000$\w)" : "\dIncendiary Bullets - Zombies Burn \y(Unlocked)")				
menu_additem(menu, buffer, "5")

formatex(buffer, charsmax(buffer), money < 2500 ? "\dNight Vision - For Dark Maps (2500$)" : "Night Vision \y- For Dark Maps \w(\r2500$\w)")
menu_additem(menu, buffer, "6")

formatex(buffer, charsmax(buffer), money < 4000 ? "\dRestock Ammo - Once a Map (4000$)" : "Restock Ammo \w- \rOnce a Map \w(\r4000$\w)")
menu_additem(menu, buffer, "7")

formatex(buffer, charsmax(buffer), money < 5000 ? "\dEXP x2 Booster - Once a Map (5000$)" : "EXP x2 Booster \w- \rOnce a Map \w(\r5000$\w)")
menu_additem(menu, buffer, "8")

}
else
{
formatex(buffer, charsmax(buffer), money < 3000 ? "\dZombie Grenade - Mega Jump (3000$)" : "Zombie Grenade \y- Mega Jump \w(\r3000$\w)")
menu_additem(menu, buffer, "1")

formatex(buffer, charsmax(buffer), money < 5000 ? "\dConfussion Grenade - Confuse Humans (5000$)": "Confussion Grenade \y- Confuse Humans \w(\r5000$\w)")
menu_additem(menu, buffer, "2")

if (money < 20000)	
formatex(buffer, charsmax(buffer), "\dDamage Sheild - Protect Yourself (20000$)");
else
formatex(buffer, charsmax(buffer), !g_had[id][Sheild] ? "Damage Sheild \y- Protect Yourself \w(\r20000$\w)" : "\dDamage Sheild - Protect Yourself \y(Unlocked)")	
menu_additem(menu, buffer, "3")

if (money < 2500)	
formatex(buffer, charsmax(buffer), "\dImmediate Respawn - No Respawn Delay (2500$)");
else
formatex(buffer, charsmax(buffer), !g_had[id][RespawnNoTime] ? "Immediate Respawn \y- No Respawn Delay \w(\r2500$\w)" : "\dImmediate Respawn - No Respawn Delay \y(Unlocked)")	
menu_additem(menu, buffer, "4")

}
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED;
}

public menus(id, menu, item)
{
if(!Get_BitVar(g_IsAlive, id))
return PLUGIN_HANDLED

if (item == MENU_EXIT)
{
menu_destroy(menu)
return PLUGIN_HANDLED
}
static money
money = cs_get_user_money(id)

if(!Get_BitVar(g_IsZombie, id))
{
switch (item)
{	
case 0:
{
if(g_had[id][Jump])
return PLUGIN_HANDLED
	
if (money >=  2000)
{
cs_set_user_money(id, money - 2000)
zp_colored_print(id, "^x03 Now you have higher jump !!")			
g_had[id][Jump] = true	                           
}
}	
case 1:
{
if(g_had[id][Booster])
return PLUGIN_HANDLED

if (money >=  5000)
{			
cs_set_user_money(id, money - 5000)
g_had[id][Booster] = true	
g_had[id][Boosted] = false
set_damageboost(id)
}
}
case 2:
{
if(g_had[id][DoubleGrenade])	
return PLUGIN_HANDLED

if (money >= 1500)
{	
cs_set_user_money(id, money - 1500)
zp_colored_print(id, "^x03 Now you have x2 Grenades !!")
g_had[id][DoubleGrenade] = true			
}
}
case 3:
{
if(g_had[id][Stronglife])	
return PLUGIN_HANDLED

if (money >= 4000)
{	
cs_set_user_money(id, money - 4000)
zp_colored_print(id, "^x03 Now you have more bp ammo pack!!")
g_had[id][Stronglife] = true			
}
}
case 4:
{
if(g_had[id][FlameBullets])
return PLUGIN_HANDLED

if (money >=  6000)
{
cs_set_user_money(id, money - 6000)				
g_had[id][FlameBullets] = true	                          
}
}
case 5:
{
if(g_had[id][Nightvision])
return PLUGIN_HANDLED

if (money >=  2500)
{
cs_set_user_money(id, money - 2500)				
g_had[id][Nightvision] = true	
zb5_set_user_nvg(id, 1, 1, 0, 1)                     
}
}
case 6:
{
zb5_get_restock(id)
}
case 7:
{
zb5_buy_item_exp(id)
}
}
}
else
{
switch(item)
{
case 0:
{	
if(g_had[id][BoughtGrenade])	
return PLUGIN_HANDLED
					
if (money >=  3000)
{	
cs_set_user_money(id, money - 3000)
g_had[id][BoughtGrenade] = true		
get_weapon_grenade_smoke(id, 1)
}
}

case 1:
{
if(g_had[id][BoughtGrenade2])	
return PLUGIN_HANDLED	
					
if (money >=  5000)
{	
cs_set_user_money(id, money - 5000)	
g_had[id][BoughtGrenade2] = true			
get_weapon_grenade_smoke(id, 2)
}
}

case 2:
{	
if(g_had[id][Sheild])	
return PLUGIN_HANDLED
			
if (money >=  20000)
{	
cs_set_user_money(id, money - 20000)		
g_had[id][Sheild] = true
zp_colored_print(id, "^x03 You Have Damage Sheild, You Will Take 50%% Less Damage")
}
}
		
case 3:
{	
if(g_had[id][RespawnNoTime])	
return PLUGIN_HANDLED
			
if (money >=  2500)
{	
cs_set_user_money(id, money - 2500)		
g_had[id][RespawnNoTime] = true
zp_colored_print(id, "^x03 You Have Immediate Respawn, No Delay After Death.")
}
}

}
}
return PLUGIN_HANDLED
}
public fw_takedamage(victim, inflictor, attacker, Float:damage, dmgtype)
{
if(!Get_BitVar(g_IsAlive, attacker) || !Get_BitVar(g_IsZombie, victim))
return HAM_IGNORED

if(g_had[victim][Sheild])SetHamParamFloat(4, damage * 0.2)
if(g_had[attacker][FlameBullets])zb5_make_burn(victim, attacker, 3.0, 0.3, "sprites/ZB5/flame_burn01.spr")

return HAM_HANDLED
}

////////// STOCK/////////////
public native_items_menu(id)ShowMenuHM(id)
public native_nightvision(id)return g_had[id][Nightvision];
public native_p30(id)return g_had[id][Boosted];
public native_sheild(id)return g_had[id][Sheild] = true
public native_zombierespawn(id)return g_had[id][RespawnNoTime];
public native_Spec(id)return g_had[id][DoubleGrenade];
public native_StrongLife(id, mode)return g_had[id][Stronglife];
public native_give_p30(id)
{
g_had[id][Booster] = true	
g_had[id][Boosted] = true
set_damageboost(id)
}
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
Reset_All(id, 0)

Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

Safety_Disconnected(id)
{
Reset_All(id, 0)

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

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

Reset_All(id, 0)
}
public zp_fw_core_cure_post(id)
{	
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id, 0)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id, 0)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)
Reset_All(id, 0)
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(Get_BitVar(g_IsZombie, id))
return 0
if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/

