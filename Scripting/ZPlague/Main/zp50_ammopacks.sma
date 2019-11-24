#include <amxmodx>
#include <fakemeta>
#include <zp50_core>

#define AMMO ADMIN_LEVEL_C
#define is_user_valid(%1) (1 <= %1 <= g_MaxPlayers)
#define TASK_HIDEMONEY 100
#define ID_HIDEMONEY (taskid - TASK_HIDEMONEY)
const PDATA_SAFE = 2
const OFFSET_CSMONEY = 115
const HIDE_MONEY_BIT = (1<<5)
new g_MaxPlayers
new g_MsgHideWeapon, g_MsgCrosshair
new g_AmmoPacks[32+1]
public plugin_init()
{
g_MaxPlayers = get_maxplayers()
g_MsgHideWeapon = get_user_msgid("HideWeapon")
g_MsgCrosshair = get_user_msgid("Crosshair")
register_event("ResetHUD", "event_reset_hud", "be")
register_message(get_user_msgid("Money"), "message_money")
}

public plugin_natives()
{
register_library("zp50_core")
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

public client_putinserver(id)
{
if(get_user_flags(id) & AMMO)
{
g_AmmoPacks[id] += 200
}else{
g_AmmoPacks[id] += 0
}
}

public client_disconnect(id)
{
remove_task(id+TASK_HIDEMONEY)
}

public event_reset_hud(id)
{
set_task(0.1, "task_hide_money", id+TASK_HIDEMONEY)
}
public task_hide_money(taskid)
{
message_begin(MSG_ONE, g_MsgHideWeapon, _, ID_HIDEMONEY)
write_byte(HIDE_MONEY_BIT) // what to hide bitsum
message_end()

message_begin(MSG_ONE, g_MsgCrosshair, _, ID_HIDEMONEY)
write_byte(0) // toggle
message_end()
}

public message_money(msg_id, msg_dest, msg_entity)
{
fm_cs_set_user_money(msg_entity, 0)
return PLUGIN_HANDLED;
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
// Prevent server crash if entity's private data not initalized
if (pev_valid(id) != PDATA_SAFE)
return;

set_pdata_int(id, OFFSET_CSMONEY, value)
}
