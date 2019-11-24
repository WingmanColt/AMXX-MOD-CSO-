#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <cs_weap_restrict_api>
#include <cs_weap_models_api>
#include <zp50_core>

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
new g_IsClown, g_MaxPlayers
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", 1)
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_clown_get", "native_class_clown_get")
register_native("zp_class_clown_set", "native_class_clown_set")
register_native("zp_class_clown_get_count", "native_class_clown_get_count")
}
public client_disconnect(id)
{
if (flag_get(g_IsClown, id))
{
fm_set_rendering(id)
}
}

public fw_ClientDisconnect_Post(id)
{
flag_unset(g_IsClown, id)
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (flag_get(g_IsClown, attacker) && !zp_core_is_zombie(victim))
{
if (inflictor == attacker)
{
if(zp_class_survivor_get(victim) && zp_class_carlito_get(victim))
{
SetHamParamFloat(4, damage * 4.0)
}else{
ExecuteHamB(Ham_Killed, victim, attacker, 0)
}
return HAM_HANDLED;
}
}
return HAM_IGNORED;
}
public Player_TakeDamage(victim, inflictor, attacker)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;
	
if (flag_get(g_IsClown, victim) && !zp_core_is_zombie(victim))
{
set_pdata_float(victim, 108, 4.0, 5)
}
return HAM_HANDLED;
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (flag_get(g_IsClown, attacker))
{
new origin[3]
get_user_origin(victim, origin)

message_begin(MSG_PVS, SVC_TEMPENTITY, origin, 0)
write_byte(TE_LAVASPLASH)
write_coord(origin[0])
write_coord(origin[1])
write_coord(origin[2] - 26)
message_end()
}
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_IsClown, id))
{
fm_set_rendering(id)
flag_unset(g_IsClown, id)
}
}

public zp_fw_core_cure(id, attacker)
{
if (flag_get(g_IsClown, id))
{
fm_set_rendering(id)
flag_unset(g_IsClown, id)
}
cs_reset_player_view_model(id, CSW_KNIFE)
cs_reset_player_weap_model(id, CSW_KNIFE)
cs_set_player_weap_restrict(id, false)
}

public zp_fw_core_infect_post(id, attacker)
{
if (!flag_get(g_IsClown, id))
return;

set_user_health(id, 50000)
set_user_gravity(id, 0.6)
cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, 1.20)
cs_set_player_model(id, "ZP_Clown")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZPlague/Claws/v_knife_clown.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
fm_set_rendering(id, kRenderFxGlowShell, random_num(50,100), random_num(50,100), 10, kRenderNormal, 0)
}
public native_class_clown_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_IsClown, id);
}

public native_class_clown_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_IsClown, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a nemesis (%d)", id)
return false;
}

flag_set(g_IsClown, id)
zp_core_force_infect(id)
return true;
}

public native_class_clown_get_count(plugin_id, num_params)
{
return GetClownCount();
}
GetClownCount()
{
new iClown, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_IsClown, id))
iClown++
}

return iClown;
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
new Float:RenderColor[3];
RenderColor[0] = float(r);
RenderColor[1] = float(g);
RenderColor[2] = float(b);

set_pev(entity, pev_renderfx, fx);
set_pev(entity, pev_rendercolor, RenderColor);
set_pev(entity, pev_rendermode, render);
set_pev(entity, pev_renderamt, float(amount));

return 1
}
