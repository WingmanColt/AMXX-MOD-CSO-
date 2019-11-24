#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <cs_weap_restrict_api>
#include <cs_weap_models_api>
#include <zp50_core>

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
new g_MaxPlayers,g_Isassassin
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)	
g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_assassin_get", "native_class_assassin_get")
register_native("zp_class_assassin_set", "native_class_assassin_set")
register_native("zp_class_assassin_get_count", "native_class_assassin_get_count")
}
public fw_ClientDisconnect_Post(id)flag_unset(g_Isassassin, id)
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (flag_get(g_Isassassin, attacker) && !zp_core_is_zombie(victim))
{
if (inflictor == attacker)
{
ExecuteHamB(Ham_Killed, victim, attacker, 0)
return HAM_HANDLED;
}
}

return HAM_IGNORED;
}
public zp_fw_grenade_frost_pre(id)
{
if (flag_get(g_Isassassin, id))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_Isassassin, id))
{
flag_unset(g_Isassassin, id)
}
}

public zp_fw_core_cure(id, attacker)
{
if (flag_get(g_Isassassin, id))
{
flag_unset(g_Isassassin, id)
}
cs_reset_player_view_model(id, CSW_KNIFE)
cs_reset_player_weap_model(id, CSW_KNIFE)
cs_set_player_weap_restrict(id, false)
}

public zp_fw_core_infect_post(id, attacker)
{
if (!flag_get(g_Isassassin, id))
return;

set_user_rendering(id)
set_user_health(id, 1500)
set_user_gravity(id, 0.5)
cs_set_player_maxspeed_auto(id, 1.50)
cs_set_player_model(id, "ZP_HeadCrab")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZPlague/Claws/v_knife_assassin.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")	
}

public native_class_assassin_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_Isassassin, id);
}

public native_class_assassin_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_Isassassin, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a assassin (%d)", id)
return false;
}

flag_set(g_Isassassin, id)
zp_core_force_infect(id)
return true;
}
public native_class_assassin_get_count(plugin_id, num_params)
{
return GetassassinCount();
}
GetassassinCount()
{
new iassassin, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_Isassassin, id))
iassassin++
}

return iassassin;
}
