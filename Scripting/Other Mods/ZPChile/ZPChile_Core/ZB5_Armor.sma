#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <cstrike>
#include <zp50_core>

const OFFSET_PAINSHOCK = 108 
const DMG_HEGRENADE = (1<<24)
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (!is_user_alive(victim) || !is_user_alive(attacker))
return HAM_IGNORED;
	
if (victim == attacker)
return HAM_IGNORED;

if (damage_type & DMG_HEGRENADE)
return HAM_IGNORED;

if(zp_class_sniper_get(victim))
return HAM_IGNORED;
if(zp_class_survivor_get(victim))
return HAM_IGNORED;
if(!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{
static Float:armor
pev(victim, pev_armorvalue, armor)
if (armor > 0.0)
{
if (armor - damage > 0.0)
set_pev(victim, pev_armorvalue, armor - damage)
else
cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
set_pdata_float(victim, OFFSET_PAINSHOCK, 0.5)
return HAM_SUPERCEDE;
}
}else{
static Float:armor
pev(victim, pev_armorvalue, armor)
if (armor > 0.0)
{
if (armor - damage > 0.0)
set_pev(victim, pev_armorvalue, armor - damage)
else
cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
set_pdata_float(victim, OFFSET_PAINSHOCK, 0.5)
return HAM_SUPERCEDE;
}
}

return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
