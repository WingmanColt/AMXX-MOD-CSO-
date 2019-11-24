#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_gamemodes>
#include <ZP_Shop>

#define TASK_NIGHTVISION 100
#define ID_NIGHTVISION (taskid - TASK_NIGHTVISION)

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
new g_had_nightvision[33], g_NightVisionActive, g_MsgNVGToggle, g_GameModeBiohazardID
public plugin_init()
{
g_MsgNVGToggle = get_user_msgid("NVGToggle")
register_message(g_MsgNVGToggle, "message_nvgtoggle")
register_clcmd("nightvision", "clcmd_nightvision_toggle")
}
public plugin_cfg()
{
g_GameModeBiohazardID = zp_gamemodes_get_id("Biohazard Mode")
}
public Get_Nightvision(id)
{
g_had_nightvision[id] = true
clcmd_nightvision_toggle(id)
}
public zp_fw_core_cure(id, attacker)
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
message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NIGHTVISION)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
if(is_user_alive(ID_NIGHTVISION))
{
if (zp_core_is_zombie(ID_NIGHTVISION))
{
if(zp_class_assassin_get(ID_NIGHTVISION))
{	
write_byte(50) // radius	
write_byte(10) 
write_byte(10) 
write_byte(0) 
}
else if(zp_class_nemesis_get(ID_NIGHTVISION))	
{
write_byte(50) // radius	
write_byte(5) 
write_byte(0) 
write_byte(0) 
}
else if(zp_class_clown_get(ID_NIGHTVISION))	
{
write_byte(50) // radius	
write_byte(0) 
write_byte(1) 
write_byte(1) 
}
else
{
if(zp_gamemodes_get_current() != g_GameModeBiohazardID)
{	
if(zp_burnvision(ID_NIGHTVISION))
{	
write_byte(100) // radius	
write_byte(50) 
write_byte(8)
write_byte(0) 		
}
else if(zp_frostvision(ID_NIGHTVISION))
{	
write_byte(100) // radius	
write_byte(0) 		
write_byte(50)
write_byte(140)
}
if(!zp_darkness())
{
if(!zp_burnvision(ID_NIGHTVISION) && !zp_frostvision(ID_NIGHTVISION))
{
write_byte(80) // radius			
write_byte(15) 
write_byte(15) 
write_byte(15) 
}
}else{
if(!zp_burnvision(ID_NIGHTVISION) && !zp_frostvision(ID_NIGHTVISION))
{
write_byte(70) // radius			
write_byte(12) 
write_byte(0) 
write_byte(0) 
}	
}
}else{	
if(zp_burnvision(ID_NIGHTVISION))
{	
write_byte(100) // radius	
write_byte(50) 
write_byte(8) 
write_byte(0) 		
}
else if(zp_frostvision(ID_NIGHTVISION))
{	
write_byte(100) // radius	
write_byte(0) 		
write_byte(50)
write_byte(140)
}
if(!zp_burnvision(ID_NIGHTVISION) && !zp_frostvision(ID_NIGHTVISION))
{
write_byte(50) // radius			
write_byte(5) 
write_byte(10) 
write_byte(0) 
}	
}
}
}else{
write_byte(80) // radius			
write_byte(10) 
write_byte(10) 
write_byte(10) 
}
}else{
write_byte(80) // radius			
write_byte(10) 
write_byte(10) 
write_byte(10) 
}
write_byte(2) // life
write_byte(0) // decay rate
message_end()
}

EnableNightVision(id)
{
if(!g_had_nightvision[id])
return	
flag_set(g_NightVisionActive, id)
if(zp_darkness())set_fov(id, 120)
set_task(0.1, "custom_nightvision_task", id+TASK_NIGHTVISION, _, _, "b")
}

DisableNightVision(id)
{
flag_unset(g_NightVisionActive, id)
if(zp_darkness())set_fov(id)
remove_task(id+TASK_NIGHTVISION)
}
stock cs_set_user_nvg_active(id, active)
{
message_begin(MSG_ONE, g_MsgNVGToggle, _, id)
write_byte(active) // toggle
message_end()
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
