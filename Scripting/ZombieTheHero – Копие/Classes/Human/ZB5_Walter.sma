#include <amxmodx>
#include <ZombieMod5>

new g_had_class[33], g_class, g_IsAlive
public plugin_init()
{
Register_SafetyFunc()	
RegisterHam(Ham_TakeDamage, "player", "fw_takedamage")

g_class = zb5_register_class("Walter", "\yDefense Specialist", LEVEL_WALTER)
}
public plugin_natives()
{
register_native("zb5_had_walter", "Had_Walter", 1)
}
public plugin_precache()
{
PrecacheModel("sprites/ZB5/zbt_invincibility.spr")	
PrecacheSound("ZB5/td_item_get.wav")
} 
public Had_Walter(id)return g_had_class[id];

public zp_fw_level_post(id)
{
switch(zb5_get_user_level(id))	
{
case 50..56:Get_Class(id)	
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

get_weapon_grenade_he(id, 3)
get_weapon_grenade_flash(id, 2)
get_weapon_grenade_smoke(id, 3)

cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 7 - 1)
}

// HUMAN SKILLS //
public fw_takedamage(victim, inflictor, attacker, Float:damage, dmgtype)
{
if(!is_player(attacker))
return HAM_IGNORED;

if(!zb5_skill_human(attacker, SKILL_DO))
return HAM_IGNORED

static KnockBack	
switch(zb5_skill_human(attacker, SKILL_PLEVEL))
{
case 1: KnockBack = 1500
case 2: KnockBack = 2000
case 3: KnockBack = 2500
case 4: KnockBack = 3000
default: KnockBack = 1000
}	

set_weapon_kick(attacker, victim, float(KnockBack))
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
fm_set_user_godmode(id, 1)
PlaySound(id, "ZB5/td_item_get.wav")

if(!zb5_get_user_nvg(id))
Make_ScreenFade(id, float(zb5_skill_human(id, SKILL_RTIME)), 149, 207, 243, 60, FADE_IN)

zb5_AddTofull_Icon(id, 220.0, 1.0, float(zb5_skill_human(id, SKILL_RTIME)), "sprites/ZB5/zbt_invincibility.spr", 12)
}
public zb5_humanskill_reset(id)
{
if(!is_player(id))
return

fm_set_user_godmode(id, 0)
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


