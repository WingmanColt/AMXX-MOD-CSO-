#include <amxmodx>
#include <ZombieMod5>

new g_had_class[33], g_class, g_IsAlive
public plugin_init()
{
Register_SafetyFunc()

g_class = zb5_register_class("SAF", "\yTerrorist Fiction Team", LEVEL_SAF)
}
public plugin_precache()
{	
PrecacheModel("sprites/ZB5/armor_head.spr")
PrecacheSound("ZB5/td_heal.wav")	
}
public zp_fw_level_post(id)
{
switch(zb5_get_user_level(id))	
{
case 4..7:Get_Class(id)	
}
}
public zb5_class_selected_post(id, class)
{
if(class == g_class)
Get_Class(id)
}
public Get_Class(id)
{	
zb5_remove_class(id)
g_had_class[id] = true	

fm_set_user_health(id, 1000)
fm_set_user_armor(id, 0)
fm_set_user_gravity(id, 1.0)
zb5_set_hspeed(id, 1.0)


get_weapon_grenade_he(id, 2)
cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 3 - 1)
}
public zb5_humanskill(id, SkillButton)
{	
if(!is_player(id))
return

switch(SkillButton)
{
case SKILL_E:Do_Skill(id)
}
}
public Do_Skill(id)
{	
static Armor, Radius
switch(zb5_skill_human(id, SKILL_PLEVEL))
{
case 1:
{
Armor = 30
Radius = 110
}
case 2:
{
Armor = 40
Radius = 130
}
case 3:
{
Armor = 50
Radius = 150
}
case 4:
{
Armor = 60
Radius = 170
}
case 5:
{
Armor = 70
Radius = 170
}
default:
{
Armor = 20
Radius = 100
}
}

fm_set_user_armor(id, get_user_armor(id) + Armor)
zb5_AddTofull_Icon(id, 220.0, 0.8, 3.0, "sprites/ZB5/armor_head.spr", 20)

if(!zb5_get_user_nvg(id))
Make_ScreenFade(id, 1.0, 50, 200, 50, 50, FADE_IN)

PlaySound(id, "ZB5/td_heal.wav")

static Float:Origin[3], i
pev(id, pev_origin, Origin)  

i = -1
while ((i = engfunc(EngFunc_FindEntityInSphere, i, Origin, float(Radius))) != 0)
{	
if(!is_alive(i))
continue
if(i == id)
continue

fm_set_user_armor(i, get_user_armor(i) + Armor)
zb5_AddTofull_Icon(i, 220.0, 0.8, 3.0, "sprites/ZB5/armor_head.spr", 20)
PlaySound(i, "ZB5/td_heal.wav")

if(!zb5_get_user_nvg(i))
Make_ScreenFade(i, 1.0, 50, 200, 50, 50, FADE_IN)
}	
}


/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
public zb5_class_remove_post(id)g_had_class[id] = false

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
g_had_class[id] = false;	
UnSet_BitVar(g_IsAlive, id)
}

Safety_Disconnected(id)
{
g_had_class[id] = false;	
UnSet_BitVar(g_IsAlive, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
UnSet_BitVar(g_IsAlive, id)

if(g_had_class[id])	
Get_Class(id)
}
public zp_fw_core_cure_post(id)
{	
Set_BitVar(g_IsAlive, id)

if(g_had_class[id])	
Get_Class(id)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

UnSet_BitVar(g_IsAlive, id)
g_had_class[id] = false
}
public is_player(id)
{
if(!(1 <= id <= 32))
return 0
if(!is_user_connected(id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0
if(!g_had_class[id])
return 0

return 1
}
public is_alive(id)
{
if(!(1 <= id <= 32))
return 0
if(!is_user_connected(id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/


