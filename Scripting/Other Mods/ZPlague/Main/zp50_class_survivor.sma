#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <zp50_core>
#include <ZP_Shop>

#define TASK_AURA 5252
#define ID_AURA (taskid - TASK_AURA)
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373
new g_MaxPlayers,g_IsSurvivor

public plugin_init()
{
register_clcmd("drop", "clcmd_drop")
RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_survivor_get", "native_class_survivor_get")
register_native("zp_class_survivor_set", "native_class_survivor_set")
register_native("zp_class_survivor_get_count", "native_class_survivor_get_count")
}

public client_disconnect(id)
{
if (flag_get(g_IsSurvivor, id))
{
remove_task(id+TASK_AURA)
remove_weapon_m134ex(id)
remove_weapon_m134ex_2(id)
}
}

public fw_ClientDisconnect_Post(id)
{
flag_unset(g_IsSurvivor, id)
}

public clcmd_drop(id)
{
if (flag_get(g_IsSurvivor, id))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (flag_get(g_IsSurvivor, victim))
{
remove_task(victim+TASK_AURA)
remove_weapon_m134ex(victim)
remove_weapon_m134ex_2(victim)
}
}
public fw_TouchWeapon(weapon, id)
{
if (is_user_alive(id) && flag_get(g_IsSurvivor, id))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}

public zp_fw_core_spawn_post(id)
{
if (flag_get(g_IsSurvivor, id))
{
remove_task(id+TASK_AURA)
remove_weapon_m134ex(id)
remove_weapon_m134ex_2(id)
flag_unset(g_IsSurvivor, id)
}
}

public zp_fw_core_infect(id, attacker)
{
if (flag_get(g_IsSurvivor, id))
{
remove_task(id+TASK_AURA)
remove_weapon_m134ex(id)
remove_weapon_m134ex_2(id)
flag_unset(g_IsSurvivor, id)
}
}

public zp_fw_core_cure_post(id, attacker)
{
if (!flag_get(g_IsSurvivor, id))
return;

set_user_health(id, 2000)
set_user_gravity(id, 0.7)
cs_set_player_maxspeed_auto(id, 1.10)
cs_set_player_model(id, "ZP_Crysis01")
give_weapon_m134ex(id)
set_task(0.1, "survivor_aura", id+TASK_AURA, _, _, "b")
}

public native_class_survivor_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_IsSurvivor, id);
}

public native_class_survivor_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_IsSurvivor, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a survivor (%d)", id)
return false;
}

flag_set(g_IsSurvivor, id)
zp_core_force_cure(id)
return true;
}

public native_class_survivor_get_count(plugin_id, num_params)
{
return GetSurvivorCount();
}

GetSurvivorCount()
{
new iSurvivors, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_IsSurvivor, id))
iSurvivors++
}

return iSurvivors;
}
public survivor_aura(taskid)
{
// Get player's origin
static origin[3]
get_user_origin(ID_AURA, origin)

// Colored Aura
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(14) // radius
write_byte(0) // r
write_byte(100) // g
write_byte(100) // b
write_byte(1) // life
write_byte(0) // decay rate
message_end()
}
