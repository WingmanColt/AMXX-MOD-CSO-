#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_gamemodes>

new g_GameModeBiohazardID
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", 1)
}
public plugin_cfg()
{
g_GameModeBiohazardID = zp_gamemodes_get_id("Biohazard Mode")
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{	
SetHamParamFloat(4, damage * 0.75)
return HAM_HANDLED;
}

return HAM_IGNORED;
}
public Player_TakeDamage(victim, inflictor, attacker)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;
if(zp_gamemodes_get_current() != g_GameModeBiohazardID)	
return HAM_IGNORED;
if (zp_core_is_zombie(victim))
{
set_pdata_float(victim, 108, 5.0, 5)
}
return HAM_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
