#include <amxmodx>
#include <ZombieMod5>

new g_had_class[33], g_class, g_IsAlive
public plugin_init()
{
Register_SafetyFunc()	
RegisterHam(Ham_TakeDamage, "player", "fw_takedamage")

g_class = zb5_register_class("Jim", "\yRed Lizard^n", LEVEL_JIM)
}
public plugin_precache()
{
PrecacheModel("sprites/ZB5/head.spr")		
} 
public zp_fw_level_post(id)
{
switch(zb5_get_user_level(id))	
{
case 59..61:Get_Class(id)	
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
fm_set_user_gravity(id, 0.8)
zb5_set_hspeed(id, 1.2)

get_weapon_grenade_he(id, 4)
get_weapon_grenade_flash(id, 1)
get_weapon_grenade_smoke(id, 3)

cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 6 - 1)
}

// HUMAN SKILLS //
public fw_takedamage(victim, inflictor, attacker, Float:damage, dmgtype)
{
if(!is_player(attacker))
return HAM_IGNORED;

if(!zb5_skill_human(attacker, SKILL_DO))
return HAM_IGNORED

static Float:Damage
switch(zb5_skill_human(attacker, SKILL_PLEVEL))
{
case 1: Damage = 1.0
case 2: Damage = 1.5
case 3: Damage = 2.0
case 4: Damage = 2.5
case 5: Damage = 3.0
default: Damage = 0.5
}	

SetHamParamFloat(4, damage * Damage)
return HAM_HANDLED
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
set_weapons_headshot(id, 1)
PlaySound(id, "ZB5/td_item_get.wav")

if(!zb5_get_user_nvg(id))
Make_ScreenFade(id, float(zb5_skill_human(id, SKILL_RTIME)), 243, 207, 149, 60, FADE_IN)

zb5_AddTofull_Icon(id, 220.0, 1.0, float(zb5_skill_human(id, SKILL_RTIME)), "sprites/ZB5/head.spr", 1)
}
public zb5_humanskill_reset(id)
{
if(!is_player(id))
return

set_weapons_headshot(id, 0)
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
if(!Get_BitVar(g_IsAlive, id))
return 0
if(!g_had_class[id])
return 0

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/


