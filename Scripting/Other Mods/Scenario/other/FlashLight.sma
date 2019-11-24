#include <amxmodx> 
#include <fakemeta> 

new g_bitPlayerFlashlight, g_iMaxPlayers 
#define MarkPlayerFlashLight(%0)    g_bitPlayerFlashlight |= 1<<(%0&31) 
#define ClearPlayerFlashLight(%0)    g_bitPlayerFlashlight &= ~(1<<(%0&31)) 
#define HasPlayerFlashLightOn(%0)    (g_bitPlayerFlashlight & 1<<(%0&31)) 

public plugin_init() 
{ 
register_forward(FM_PlayerPreThink, "PlayerPreThink") 
register_event("Flashlight", "Event_Flashlight", "b") 
g_iMaxPlayers = get_maxplayers() 
} 

public Event_Flashlight(id) 
{ 
if (read_data(1)) 
MarkPlayerFlashLight(id) 
else 
ClearPlayerFlashLight(id) 
} 

public PlayerPreThink(id) 
{ 
static aim, dummy 
aim = 0 
get_user_aiming(id, aim, dummy) 

if (!HasPlayerFlashLightOn(id) 
|| aim < 1 || aim > g_iMaxPlayers 
|| HasPlayerFlashLightOn(aim)) 
return; 

static origin[3]; get_user_origin(id, origin, 3) 

message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id) 
write_byte(TE_DLIGHT) // TE id 
write_coord(origin[0]) // x 
write_coord(origin[1]) // y 
write_coord(origin[2]) // z 
write_byte(random_num(9, 11)) // radius 
write_byte(57) // r 
write_byte(57) // g 
write_byte(57) // b 
write_byte(1) // life 
write_byte(0) // decay rate 
message_end() 
}  