#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
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
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
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
public client_disconnect(id)
{
if (flag_get(g_Isassassin, id))
{
set_user_rendering(id)
set_fov(id)
}
}

public fw_ClientDisconnect_Post(id)
{
// Reset flags AFTER disconnect (to allow checking if the player was assassin before disconnecting)
flag_unset(g_Isassassin, id)
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
// Non-player damage or self damage
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

// assassin attacking human
if (flag_get(g_Isassassin, attacker) && !zp_core_is_zombie(victim))
{
if (inflictor == attacker)
{
// Set assassin damage
ExecuteHamB(Ham_Killed, victim, attacker, 0)
return HAM_HANDLED;
}
}

return HAM_IGNORED;
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (flag_get(g_Isassassin, victim))
{
SetHamParamInteger(3, 2)
}
}

public zp_fw_grenade_frost_pre(id)
{
// Prevent frost for assassin
if (flag_get(g_Isassassin, id))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_Isassassin, id))
{
set_user_rendering(id)
set_fov(id)
flag_unset(g_Isassassin, id)
}
}

public zp_fw_core_cure(id, attacker)
{
if (flag_get(g_Isassassin, id))
{
set_user_rendering(id)
set_fov(id)
flag_unset(g_Isassassin, id)
}
}

public zp_fw_core_infect_post(id, attacker)
{
if (!flag_get(g_Isassassin, id))
return;
set_user_health(id, 1000)
set_user_gravity(id, 0.4)
cs_set_player_maxspeed_auto(id, 1.75)
cs_set_player_model(id, "ZPC_Assassin")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZPChile/Claws/v_knife_assassin.mdl")	
set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 40)
set_fov(id, 130)
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
stock set_fov(id, num = 95)
{
if(!is_user_connected(id))
return

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SetFOV"), {0,0,0}, id)
write_byte(num)
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
