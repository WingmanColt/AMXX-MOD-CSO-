#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>

#define VIP ADMIN_LEVEL_F
new Float:lastLongJumpTime[33], bool:longJump[33]

public plugin_init() 
{
register_forward(FM_PlayerPreThink, "EventPlayerPreThink");
RegisterHam(Ham_Spawn, "player", "Spawn_post", 1)
}
public Spawn_post(id)
{
if (get_user_flags(id) & VIP)
{
if(!is_user_alive(id))	
return;
longJump[id] = true;
if(!zp_core_is_zombie(id))
return
longJump[id] = false;		
}
}
public zp_fw_core_infect_post(id)
{
if (get_user_flags(id) & VIP)
{	
if(zp_core_is_zombie(id))
{
longJump[id] = false;		
}
}
}
public client_disconnect(id)
{
longJump[id] = false;
}
public EventRoundStart()
{
arrayset(longJump, false, 33);
}
public EventPlayerPreThink(id)
{
if (!is_user_alive(id))
{
return FMRES_IGNORED;
}

if (allow_LongJump(id))
{
static Float:velocity[3];
velocity_by_aim(id, 500, velocity);

velocity[2] = 400.0;

set_pev(id, pev_velocity, velocity);

lastLongJumpTime[id] = get_gametime();
}

return FMRES_IGNORED;
}

allow_LongJump(id)
{
static buttons;
buttons = pev(id, pev_button);

if (!(buttons & IN_JUMP) || !(buttons & IN_DUCK))
return false;

if (!longJump[id])
return false;

if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
return false;

if (get_gametime() - lastLongJumpTime[id] < 5.0)
return false;

return true;
}

stock fm_get_speed(entity)
{
static Float:velocity[3];
pev(entity, pev_velocity, velocity);

return floatround(vector_length(velocity));
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
