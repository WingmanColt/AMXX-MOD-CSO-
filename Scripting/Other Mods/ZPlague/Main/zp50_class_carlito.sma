#include <amxmodx>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_player_models_api>
#include <cs_maxspeed_api>
#include <ZP_Shop>
#include <zp50_core>

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

new g_MaxPlayers, g_IsCarlito
public plugin_init()
{
register_clcmd("drop", "clcmd_drop")
RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_carlito_get", "native_class_carlito_get")
register_native("zp_class_carlito_set", "native_class_carlito_set")
register_native("zp_class_carlito_get_count", "native_class_carlito_get_count")
}

public client_disconnect(id)
{
if (flag_get(g_IsCarlito, id))
{
remove_weapon_flamegun(id)
}
}
public fw_ClientDisconnect_Post(id)
{
flag_unset(g_IsCarlito, id)
}
public clcmd_drop(id)
{
if (flag_get(g_IsCarlito, id))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_IsCarlito, id))
{
flag_unset(g_IsCarlito, id)
remove_weapon_flamegun(id)
}
}

public zp_fw_core_infect(id, attacker)
{
if (flag_get(g_IsCarlito, id))
{
flag_unset(g_IsCarlito, id)
remove_weapon_flamegun(id)
}
}
public zp_fw_core_cure_post(id, attacker)
{
if (!flag_get(g_IsCarlito, id))
return;

set_user_health(id, 2500)
set_user_gravity(id, 0.6)
cs_set_player_maxspeed_auto(id, 1.10)
cs_set_player_model(id, "ZP_Carlito")
give_weapon_flamegun(id)	
}
public fw_TouchWeapon(weapon, id)
{
if (is_user_alive(id) && flag_get(g_IsCarlito, id))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}
public native_class_carlito_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_IsCarlito, id);
}

public native_class_carlito_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_IsCarlito, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a sniper (%d)", id)
return false;
}

flag_set(g_IsCarlito, id)
zp_core_force_cure(id)
return true;
}

public native_class_carlito_get_count(plugin_id, num_params)
{
return GetcarlitoCount();
}
GetcarlitoCount()
{
new icarlito, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_IsCarlito, id))
icarlito++
}

return icarlito;
}
