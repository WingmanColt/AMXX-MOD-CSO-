#include <amxmodx>
#include <hamsandwich>
#include <zp50_gamemodes>
#include <zp50_core>

#define MAXPLAYERS 32
new Float:g_DamageDealtToZombies[MAXPLAYERS+1]
new Float:g_DamageDealtToHumans[MAXPLAYERS+1]
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
}
public zp_fw_core_infect_post(id, attacker)
{
if (is_user_connected(attacker) && attacker != id && 1 > 0)
zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + 1)
}
public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return;
if (zp_core_is_zombie(attacker) && !zp_core_is_zombie(victim))
{
if (1.0 > 0)
{
g_DamageDealtToHumans[attacker] += damage
new how_many_rewards = floatround(g_DamageDealtToHumans[attacker] / 250, floatround_floor)
if (how_many_rewards > 0)
{
zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + (1 * how_many_rewards))
g_DamageDealtToHumans[attacker] -= 250 * how_many_rewards
}
}
}
else if (!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{
if (1.0 > 0)
{
g_DamageDealtToZombies[attacker] += damage
new how_many_rewards = floatround(g_DamageDealtToZombies[attacker] / 550, floatround_floor)
if (how_many_rewards > 0)
{
zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + (1 * how_many_rewards))
g_DamageDealtToZombies[attacker] -= 550 * how_many_rewards
}
}
}
}
public client_disconnect(id)
{
g_DamageDealtToZombies[id] = 0.0
g_DamageDealtToHumans[id] = 0.0
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
