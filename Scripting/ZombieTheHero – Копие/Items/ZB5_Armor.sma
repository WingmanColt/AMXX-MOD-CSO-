#include <amxmodx>
#include <cstrike>
#include <ZombieMod5>

const OFFSET_PAINSHOCK = 108 
const DMG_HEGRENADE = (1<<24)

public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{		
if(!zp_GameAvailable() || zp_GameEnd() || !zp_GameStart())
return HAM_IGNORED;
	
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;
	
if (damage_type & DMG_HEGRENADE)
return HAM_IGNORED;

static Float:armor
pev(victim, pev_armorvalue, armor)

if(!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{
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
if(zp_core_is_zombie(attacker) && !zp_core_is_zombie(victim))
{
if (armor > 0.0)
{
if (armor - damage > 0.0)
set_pev(victim, pev_armorvalue, armor - damage)
else
cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
set_pdata_float(victim, OFFSET_PAINSHOCK, 0.5)
return HAM_SUPERCEDE;
}
	
if ((inflictor == attacker) && zp_core_is_last_human(victim))
{
if (armor > 0.0)
{
if (armor - damage > 0.0)
set_pev(victim, pev_armorvalue, armor - damage)
else
cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
set_pdata_float(victim, OFFSET_PAINSHOCK, 0.5)
return HAM_SUPERCEDE;
}else{
ExecuteHamB(Ham_Killed, victim, attacker, 0)
return HAM_HANDLED;
}
}
}

return HAM_IGNORED;
}
