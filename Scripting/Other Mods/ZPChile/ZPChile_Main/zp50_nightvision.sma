#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <ZPC_Options>
#include <zp50_core>

#define TASK_NIGHTVISION 100
#define ID_NIGHTVISION (taskid - TASK_NIGHTVISION)
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
new g_had_nightvision[33], g_NightVisionActive, g_MsgNVGToggle
public plugin_init()
{
g_MsgNVGToggle = get_user_msgid("NVGToggle")
register_message(g_MsgNVGToggle, "message_nvgtoggle")
register_clcmd("nightvision", "clcmd_nightvision_toggle")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
}
public plugin_natives()
{
register_native("give_item_nightvision", "Get_Nightvision", 1)
}
public Get_Nightvision(id)
{
g_had_nightvision[id] = true
clcmd_nightvision_toggle(id)
}
public zp_fw_core_cure_post(id, attacker)
{
DisableNightVision(id)	
g_had_nightvision[id] = false
}
public zp_fw_core_infect_post(id, attacker)
{
if (zp_core_is_zombie(id))
{
g_had_nightvision[id] = true	
clcmd_nightvision_toggle(id)
}
}
public clcmd_nightvision_toggle(id)
{
if (flag_get(g_NightVisionActive, id))
DisableNightVision(id)
else
EnableNightVision(id)
return PLUGIN_HANDLED;
}
public fw_PlayerKilled_Post(victim, attacker, shouldgib)spectator_nightvision(victim)
public client_putinserver(id)
{
set_task(0.1, "spectator_nightvision", id)
}
public spectator_nightvision(id)
{
if (!is_user_connected(id) || is_user_alive(id))
return;

g_had_nightvision[id] = true

if (!flag_get(g_NightVisionActive, id))
clcmd_nightvision_toggle(id)
else if (flag_get(g_NightVisionActive, id))
DisableNightVision(id)
}

public client_disconnect(id)
{
g_had_nightvision[id] = false	
flag_unset(g_NightVisionActive, id)
remove_task(id+TASK_NIGHTVISION)
}
public message_nvgtoggle(msg_id, msg_dest, msg_entity)
{
return PLUGIN_HANDLED;
}
public custom_nightvision_task(taskid)
{
static origin[3]
get_user_origin(ID_NIGHTVISION, origin)

new rgb[3]
if (!is_user_alive(ID_NIGHTVISION))
{
rgb[0] = 0 
rgb[1] = 10 
rgb[2] = 0
}else{	
if (zp_core_is_zombie(ID_NIGHTVISION))
{
if(zp_class_assassin_get(ID_NIGHTVISION))
{
rgb[0] = 0 
rgb[1] = 15 
rgb[2] = 15
}
else if(zp_class_nemesis_get(ID_NIGHTVISION))
{	
rgb[0] = 10 
rgb[1] = 0 
rgb[2] = 15
}
else
{
if(!zp_zombie_inburn(ID_NIGHTVISION))	
{
rgb[0] = 0 
rgb[1] = 10
rgb[2] = 0
}else{
rgb[0] = 10 
rgb[1] = 5
rgb[2] = 0	
}
if(!zp_zombie_infrost(ID_NIGHTVISION))	
{
rgb[0] = 0 
rgb[1] = 10 
rgb[2] = 0
}else{
rgb[0] = 0 
rgb[1] = 50
rgb[2] = 100	
}
}
}
else
{
rgb[0] = 0 
rgb[1] = 10 
rgb[2] = 0	
}
}

message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NIGHTVISION)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(70) // radius
write_byte(rgb[0]) 
write_byte(rgb[1]) 
write_byte(rgb[2]) 
write_byte(2) // life
write_byte(0) // decay rate
message_end()
}

EnableNightVision(id)
{
if(!g_had_nightvision[id])
return	
flag_set(g_NightVisionActive, id)
set_task(0.1, "custom_nightvision_task", id+TASK_NIGHTVISION, _, _, "b")
}

DisableNightVision(id)
{
flag_unset(g_NightVisionActive, id)
remove_task(id+TASK_NIGHTVISION)
}
stock cs_set_user_nvg_active(id, active)
{
message_begin(MSG_ONE, g_MsgNVGToggle, _, id)
write_byte(active) // toggle
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
