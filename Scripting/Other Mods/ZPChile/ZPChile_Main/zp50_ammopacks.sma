#include <amxmodx>
#include <fakemeta>
#include <zp50_core>

#define MAXPLAYERS 32
#define is_user_valid(%1) (1 <= %1 <= g_MaxPlayers)
new g_MaxPlayers
new g_AmmoPacks[MAXPLAYERS+1]
public plugin_init()
{
g_MaxPlayers = get_maxplayers()
}

public plugin_natives()
{
register_library("zp50_ammopacks")
register_native("zp_ammopacks_get", "native_ammopacks_get")
register_native("zp_ammopacks_set", "native_ammopacks_set")
}

public native_ammopacks_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_valid(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return g_AmmoPacks[id];
}

public native_ammopacks_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_valid(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

new amount = get_param(2)

g_AmmoPacks[id] = amount
return true;
}
