#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <zp50_colorchat>
#include <zp50_gamemodes>

#define flag_get(%1,%2)	(%1 & (1 << (%2 & 31)))
#define flag_set(%1,%2)	%1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
#define TASK_FBURN5 11515
#define ID_FBURN5 (taskid - TASK_FBURN5)
new g_IncendiaryBullets, g_burning_duration2[33], g_flameSpr
public plugin_init()
{
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled");
RegisterHam(Ham_TakeDamage, "player", "fw_PlayerTakeDamage");
}
public plugin_precache()
{
g_flameSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/flame_burn01.spr")
}
public plugin_natives()
{
register_native("give_item_fireclip", "BuyItemBullets", 1)
register_native("zp_remove_fire_aura", "remove_fire_aura", 1)
}
public remove_fire_aura(id)
{
if (task_exists(id+TASK_FBURN5))
remove_task(id+TASK_FBURN5)		
}
public client_disconnect(id)
{
flag_unset(g_IncendiaryBullets, id);
if (task_exists(id+TASK_FBURN5))
remove_task(id+TASK_FBURN5)
}
public BuyItemBullets(id)
{
if(!is_user_alive(id))
return;

if(!flag_get(g_IncendiaryBullets, id))
{	
new money = zp_ammopacks_get(id) 		
if (money >= 10)
{		
zp_ammopacks_set(id, money - 10)	
flag_set(g_IncendiaryBullets, id);
}else{
zp_colored_print(id, "^x01Not enough AmmoPacks!")
}
}else{
zp_colored_print(id, "^x01You Already Have This Item!")
}
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if(!is_user_alive(victim))
return;
	
flag_unset(g_IncendiaryBullets, victim);
if (task_exists(victim+TASK_FBURN5))
remove_task(victim+TASK_FBURN5)
}

public fw_PlayerTakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if(victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if(flag_get(g_IncendiaryBullets, attacker) && get_user_weapon(attacker) != CSW_KNIFE)
{
if(zp_class_nemesis_get(victim) || zp_class_assassin_get(victim))
return HAM_IGNORED;	
	
if((task_exists(TASK_FBURN5+victim)) || !task_exists(TASK_FBURN5+victim))
{
create_burn(victim);
}
}

return HAM_IGNORED;
}

public zp_fw_core_spawn_post(id)
{
if(!is_user_alive(id))
return;	
flag_unset(g_IncendiaryBullets, id);
if (task_exists(id+TASK_FBURN5))
remove_task(id+TASK_FBURN5)	
}

public zp_fw_core_cure_post(id, attacker)
{
if(!is_user_alive(id))
return;	
flag_unset(g_IncendiaryBullets, id);
remove_task(id+TASK_FBURN5)	
}
create_burn(player)
{
if(!is_user_alive(player))
return;		
if(!task_exists(player + TASK_FBURN5))
{
g_burning_duration2[player] += 7 * 5
}
set_task(1.5, "Burn2", player + TASK_FBURN5, _, _, "b")	
}
public Burn2(taskid)
{
static origin[3], flags, health
get_user_origin(ID_FBURN5, origin)
flags = pev(ID_FBURN5, pev_flags)

if ((flags & FL_INWATER) || g_burning_duration2[ID_FBURN5] < 1 || !is_user_alive(ID_FBURN5))
{
remove_task(taskid)
return
}
health = pev(ID_FBURN5, pev_health)
if (health - 50 > 0)
fm_set_user_health(ID_FBURN5, health - 50)
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_SPRITE) // TE id
write_coord(origin[0]+random_num(-5, 5)) // x
write_coord(origin[1]+random_num(-5, 5)) // y
write_coord(origin[2]+random_num(-10, 10)) // z
write_short(g_flameSpr) // sprite
write_byte(random_num(8, 14)) // scale
write_byte(200) // brightness
message_end()	
if ((flags & FL_ONGROUND) > 0.0)
{
static Float:velocity[3]
pev(ID_FBURN5, pev_velocity, velocity)
xs_vec_mul_scalar(velocity, 0.5, velocity)
set_pev(ID_FBURN5, pev_velocity, velocity)
}
g_burning_duration2[ID_FBURN5]--
}
