#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <zp50_core>

#define TASK_FLASHLIGHT 100
#define TASK_CHARGE 200
#define ID_FLASHLIGHT (taskid - TASK_FLASHLIGHT)
#define ID_CHARGE (taskid - TASK_CHARGE)

const PDATA_SAFE = 2
const OFFSET_FLASHLIGHT_BATTERIES = 244
const IMPULSE_FLASHLIGHT = 100
#define MAXPLAYERS 32
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
new g_MsgFlashlight, g_MsgFlashBat
new g_FlashlightActive, g_FlashlightCharge[MAXPLAYERS+1]
new Float:g_FlashlightLastTime[MAXPLAYERS+1]
public plugin_init()
{
register_forward(FM_CmdStart, "fw_CmdStart")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
g_MsgFlashlight = get_user_msgid("Flashlight")
g_MsgFlashBat = get_user_msgid("FlashBat")
register_message(g_MsgFlashBat, "message_flashbat")
}
public fw_CmdStart(id, handle)
{
// Not alive
if (!is_user_alive(id))
return;

// Check if it's a flashlight impulse
if (get_uc(handle, UC_Impulse) != IMPULSE_FLASHLIGHT)
return;

// Flashlight is being turned off
if (pev(id, pev_effects) & EF_DIMLIGHT)
return;

if (zp_core_is_zombie(id))
{
set_uc(handle, UC_Impulse, 0)
}
if (is_user_alive(id) && !zp_core_is_zombie(id))
{
set_uc(handle, UC_Impulse, 0)
if (g_FlashlightCharge[id] > 2 && get_gametime() - g_FlashlightLastTime[id] > 1.2)
{
// Prevent calling flashlight too quickly (bugfix)
g_FlashlightLastTime[id] = get_gametime()
if (flag_get(g_FlashlightActive, id))
{
remove_task(id+TASK_FLASHLIGHT)
flag_unset(g_FlashlightActive, id)
}
else
{
set_task(0.1, "custom_flashlight_task", id+TASK_FLASHLIGHT, _, _, "b")
flag_set(g_FlashlightActive, id)
}
remove_task(id+TASK_CHARGE)
set_task(1.0, "flashlight_charge_task", id+TASK_CHARGE, _, _, "b")
emit_sound(id, CHAN_ITEM,"items/flashlight1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
message_begin(MSG_ONE, g_MsgFlashlight, _, id)
write_byte(flag_get_boolean(g_FlashlightActive, id)) // toggle
write_byte(g_FlashlightCharge[id]) // batteries
message_end()
}
}
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
flag_unset(g_FlashlightActive, victim)
remove_task(victim+TASK_FLASHLIGHT)
remove_task(victim+TASK_CHARGE)
}

public client_disconnect(id)
{
flag_unset(g_FlashlightActive, id)
remove_task(id+TASK_FLASHLIGHT)
remove_task(id+TASK_CHARGE)
}

// Flashlight batteries messages
public message_flashbat(msg_id, msg_dest, msg_entity)
{
if (is_user_connected(msg_entity) && zp_core_is_zombie(msg_entity))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}

public zp_fw_core_infect(id, attacker)turn_off_flashlight(id)
public zp_fw_core_cure(id, attacker)
{
turn_off_flashlight(id)	
if(is_user_bot(id))
{
set_task(0.1, "custom_flashlight_task", id+TASK_FLASHLIGHT, _, _, "b")
flag_set(g_FlashlightActive, id)		
}
}
turn_off_flashlight(id)
{
g_FlashlightCharge[id] = 100
if (pev(id, pev_effects) & EF_DIMLIGHT)
{
set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT)
}
else
{
set_pev(id, pev_impulse, 0)
message_begin(MSG_ONE, g_MsgFlashlight, _, id)
write_byte(0) // toggle
write_byte(100) // batteries
message_end()
}
flag_unset(g_FlashlightActive, id)
remove_task(id+TASK_CHARGE)
remove_task(id+TASK_FLASHLIGHT)
}
public custom_flashlight_task(taskid)
{
if(!is_user_alive(ID_FLASHLIGHT) && zp_core_is_zombie(ID_FLASHLIGHT))
return;	
static Float:origin[3], Float:destorigin[3]
pev(ID_FLASHLIGHT, pev_origin, origin)
fm_get_aim_origin(ID_FLASHLIGHT, destorigin)

// Max distance check
if (get_distance_f(origin, destorigin) > 1000)
return;
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, destorigin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, destorigin[0]) // x
engfunc(EngFunc_WriteCoord, destorigin[1]) // y
engfunc(EngFunc_WriteCoord, destorigin[2]) // z
write_byte(16) // radius
write_byte(50) // r
write_byte(130) // g
write_byte(50) // b
write_byte(2) // life
write_byte(2) // decay rate
message_end()
}

// Flashlight Charge Task
public flashlight_charge_task(taskid)
{
// Drain or charge?
if (flag_get(g_FlashlightActive, ID_CHARGE))
g_FlashlightCharge[ID_CHARGE] = max(g_FlashlightCharge[ID_CHARGE] - 1, 0)
else
g_FlashlightCharge[ID_CHARGE] = min(g_FlashlightCharge[ID_CHARGE] + 5, 100)

// Batteries fully charged
if (g_FlashlightCharge[ID_CHARGE] == 100)
{
// Update flashlight batteries on HUD
message_begin(MSG_ONE, g_MsgFlashBat, _, ID_CHARGE)
write_byte(100) // batteries
message_end()

// Task not needed anymore
remove_task(taskid)
return;
}

if (g_FlashlightCharge[ID_CHARGE] == 0)
{
flag_unset(g_FlashlightActive, ID_CHARGE)
remove_task(ID_CHARGE+TASK_FLASHLIGHT)
emit_sound(ID_CHARGE, CHAN_ITEM,"items/flashlight1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
message_begin(MSG_ONE, g_MsgFlashlight, _, ID_CHARGE)
write_byte(0) // toggle
write_byte(0) // batteries
message_end()

return;
}
message_begin(MSG_ONE_UNRELIABLE, g_MsgFlashBat, _, ID_CHARGE)
write_byte(g_FlashlightCharge[ID_CHARGE]) // batteries
message_end()
}

stock fm_cs_set_flash_batteries(id, value)
{
if (pev_valid(id) != PDATA_SAFE)
return;

set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERIES, value)
}
stock fm_get_aim_origin(id, Float:origin[3])
{
static Float:origin1F[3], Float:origin2F[3]
pev(id, pev_origin, origin1F)
pev(id, pev_view_ofs, origin2F)
xs_vec_add(origin1F, origin2F, origin1F)

pev(id, pev_v_angle, origin2F);
engfunc(EngFunc_MakeVectors, origin2F)
global_get(glb_v_forward, origin2F)
xs_vec_mul_scalar(origin2F, 9999.0, origin2F)
xs_vec_add(origin1F, origin2F, origin2F)

engfunc(EngFunc_TraceLine, origin1F, origin2F, 0, id, 0)
get_tr2(0, TR_vecEndPos, origin)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
