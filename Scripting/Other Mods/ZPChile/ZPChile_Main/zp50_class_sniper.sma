#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <cs_weap_models_api>
#include <zp50_core>

#define TASK_AURA 100
#define ID_AURA (taskid - TASK_AURA)

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

new g_MaxPlayers, g_IsSniper, g_exp
public plugin_init()
{
register_clcmd("drop", "clcmd_drop")
RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
g_MaxPlayers = get_maxplayers()
}
public plugin_precache()
{
g_exp =  engfunc(EngFunc_PrecacheModel, "sprites/ZPChile/plasmabomb.spr")
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_sniper_get", "native_class_sniper_get")
register_native("zp_class_sniper_set", "native_class_sniper_set")
register_native("zp_class_sniper_get_count", "native_class_sniper_get_count")
}
public client_disconnect(id)
{
if (flag_get(g_IsSniper, id))
{
remove_task(id+TASK_AURA)
}
}

public fw_ClientDisconnect_Post(id)
{
// Reset flags AFTER disconnect (to allow checking if the player was sniper before disconnecting)
flag_unset(g_IsSniper, id)
}

public clcmd_drop(id)
{
// Should sniper stick to his weapon?
if (flag_get(g_IsSniper, id))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}

// Ham Weapon Touch Forward
public fw_TouchWeapon(weapon, id)
{
// Should sniper stick to his weapon?
if (is_user_alive(id) && flag_get(g_IsSniper, id))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (flag_get(g_IsSniper, victim))
{
remove_task(victim+TASK_AURA)
}

// When killed by a Sniper victim explodes
if (flag_get(g_IsSniper, attacker))
{
static Float:Origin[3], TE_FLAG
pev(victim, pev_origin, Origin)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND
TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(g_exp)
write_byte(7)
write_byte(10)
write_byte(TE_FLAG)
message_end()	
}
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (flag_get(g_IsSniper, attacker) && zp_core_is_zombie(victim))
{
if (inflictor == attacker)
{
if(get_user_weapon(attacker) == CSW_AWP)ExecuteHamB(Ham_Killed, victim, attacker, 0)
return HAM_HANDLED;
}
}

return HAM_IGNORED;
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_IsSniper, id))
{
remove_task(id+TASK_AURA)
flag_unset(g_IsSniper, id)
}
}

public zp_fw_core_infect(id, attacker)
{
if (flag_get(g_IsSniper, id))
{
set_user_rendering(id)
remove_task(id+TASK_AURA)
flag_unset(g_IsSniper, id)
}
}


public zp_fw_core_cure_post(id, attacker)
{
// Apply sniper attributes?
if (!flag_get(g_IsSniper, id))
return;

set_user_health(id, 500)
set_user_gravity(id, 0.8)
give_item(id, "weapon_awp")
new iWep2 = give_item(id, "weapon_awp")
if(iWep2 > 0)
{
cs_set_weapon_ammo(iWep2, 30)		
}
cs_set_player_maxspeed_auto(id, 1.00)
cs_set_player_model(id, "ZPC_Player01")
set_task(0.1, "sniper_aura", id+TASK_AURA, _, _, "b")
}
public native_class_sniper_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_IsSniper, id);
}

public native_class_sniper_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_IsSniper, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a sniper (%d)", id)
return false;
}

flag_set(g_IsSniper, id)
zp_core_force_cure(id)
return true;
}

public native_class_sniper_get_count(plugin_id, num_params)
{
return GetsniperCount();
}
public sniper_aura(taskid)
{
static origin[3]
get_user_origin(ID_AURA, origin)
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(15) // radius
write_byte(150) // r
write_byte(150) // g
write_byte(0) // b
write_byte(2) // life
write_byte(0) // decay rate
message_end()
}
GetsniperCount()
{
new isnipers, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_IsSniper, id))
isnipers++
}

return isnipers;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
