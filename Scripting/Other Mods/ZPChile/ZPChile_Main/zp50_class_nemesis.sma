#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <cs_weap_models_api>
#include <zp50_core>

#define TASK_AURA 5252
#define ID_AURA (taskid - TASK_AURA)
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_MaxPlayers,g_IsNemesis
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_nemesis_get", "native_class_nemesis_get")
register_native("zp_class_nemesis_set", "native_class_nemesis_set")
register_native("zp_class_nemesis_get_count", "native_class_nemesis_get_count")
}
public client_disconnect(id)
{
if (flag_get(g_IsNemesis, id))
{
remove_task(id+TASK_AURA)
}
}

public fw_ClientDisconnect_Post(id)
{
flag_unset(g_IsNemesis, id)
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;
if (flag_get(g_IsNemesis, attacker) && !zp_core_is_zombie(victim))
{
if (inflictor == attacker)
{
SetHamParamFloat(4, damage * 500.0)
return HAM_HANDLED;
}
}

return HAM_IGNORED;
}
public zp_fw_grenade_frost_pre(id)
{
// Prevent frost for Nemesis
if (flag_get(g_IsNemesis, id))
return PLUGIN_HANDLED;
return PLUGIN_CONTINUE;
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_IsNemesis, id))
{
remove_task(id+TASK_AURA)
flag_unset(g_IsNemesis, id)
}
}

public zp_fw_core_cure(id, attacker)
{
if (flag_get(g_IsNemesis, id))
{
remove_task(id+TASK_AURA)
flag_unset(g_IsNemesis, id)
}
}

public zp_fw_core_infect_post(id, attacker)
{
// Apply Nemesis attributes?
if (!flag_get(g_IsNemesis, id))
return;

set_user_health(id, 50000)
set_user_gravity(id, 0.6)
cs_set_player_maxspeed_auto(id, 1.15)
cs_set_player_model(id, "ZPC_Nemesis")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZPChile/Claws/v_knife_nemesis.mdl")
set_task(0.1, "aura", id+TASK_AURA, _, _, "b")
}

public native_class_nemesis_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_IsNemesis, id);
}

public native_class_nemesis_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_IsNemesis, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a nemesis (%d)", id)
return false;
}

flag_set(g_IsNemesis, id)
zp_core_force_infect(id)
return true;
}

public native_class_nemesis_get_count(plugin_id, num_params)
{
return GetNemesisCount();
}
public aura(taskid)
{
static origin[3]
get_user_origin(ID_AURA, origin)

// Colored Aura
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(15) // radius
write_byte(100) // r
write_byte(0) // g
write_byte(150) // b
write_byte(2) // life
write_byte(0) // decay rate
message_end()
}

GetNemesisCount()
{
new iNemesis, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_IsNemesis, id))
iNemesis++
}

return iNemesis;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
