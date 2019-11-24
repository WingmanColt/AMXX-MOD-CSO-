#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>


public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
// Non-player damage or self damage
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if(zp_class_nemesis_get(attacker))
return HAM_IGNORED;

if(zp_class_assassin_get(attacker))
return HAM_IGNORED;

if (!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{	
SetHamParamFloat(4, damage * 0.75)
return HAM_HANDLED;
}

return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
