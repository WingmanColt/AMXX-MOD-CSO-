#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_core>

#define TASK_FBURN5 15123151
#define ID_FBURN5 (taskid - TASK_FBURN5)
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_NAPALM = 2222
new g_trailSpr, g_exp1Spr, g_firegibs, g_burning_duration2[33], g_flameSpr, g_exp2Spr, g_burnvision[33] 
public plugin_init()
{	
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")		
register_forward(FM_SetModel, "fw_SetModel")
}

public plugin_precache()
{

g_flameSpr = PrecacheModel("sprites/ZPlague/flame_burn01.spr")	
g_trailSpr = PrecacheModel("sprites/laserbeam.spr")
g_exp1Spr = PrecacheModel("sprites/ZPlague/explosion_1.spr")
g_exp2Spr = PrecacheModel("sprites/ZPlague/explosion_2.spr")	
g_firegibs = PrecacheModel("sprites/ZPlague/fire_explosion_gib.spr")
}
public plugin_natives()
{
register_native("zp_burnvision", "vision", 1)
}
public zp_fw_core_cure_post(id, attacker)
{
cs_set_player_view_model(id, CSW_HEGRENADE, "models/ZPlague/Grenades/v_flare.mdl")
cs_set_player_weap_model(id, CSW_HEGRENADE, "models/p_hegrenade.mdl")
if (task_exists(id+TASK_FBURN5))
remove_task(id+TASK_FBURN5)
}
public vision(id) return g_burnvision[id];
public zp_fw_core_infect(id, attacker)
{
cs_reset_player_view_model(id, CSW_HEGRENADE)
}
public zp_fw_core_spawn_post(id)
{
if(!is_user_alive(id))
return;	
if (task_exists(id+TASK_FBURN5))
remove_task(id+TASK_FBURN5)	
}
// Forward Set Model
public fw_SetModel(entity, const model[])
{
if(!pev_valid(entity))
return;

if (strlen(model) < 8)
return;

// Narrow down our matches a bit
if (model[7] != 'w' || model[8] != '_')
return;

// Get damage time of grenade
static Float:dmgtime
pev(entity, pev_dmgtime, dmgtime)

// Grenade not yet thrown
if (dmgtime == 0.0)
return;

// Grenade's owner is zombie?
if (zp_core_is_zombie(pev(entity, pev_owner)))
return;

// HE Grenade
if (model[9] == 'h' && model[10] == 'e')
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(entity) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(200) // r
write_byte(100) // g
write_byte(0) // b
write_byte(100) // brightness
message_end()
set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)
}
}
// Ham Grenade Think Forward
public fw_ThinkGrenade(entity)
{
// Invalid entity
if (!pev_valid(entity)) 
return HAM_IGNORED;

// Get damage time of grenade
static Float:dmgtime
pev(entity, pev_dmgtime, dmgtime)

// Check if it's time to go off
if (dmgtime > get_gametime())
return HAM_IGNORED;

// Not a napalm grenade
if (pev(entity, PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
return HAM_IGNORED;

fire_explode(entity);
return HAM_SUPERCEDE;
}

public fire_explode(ent)
{
if (!pev_valid(ent)) 
return;

static Float:origin[3]
pev(ent, pev_origin, origin)
static Float:originF[3]
pev(ent, pev_origin, originF)

engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]) // z axis
write_short(g_exp1Spr)
write_byte(70) // Scale
write_byte(35) // Frame
write_byte(TE_EXPLFLAG_NOSOUND)
message_end();	

engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]) // z axis
write_short(g_exp2Spr)
write_byte(60) // Scale
write_byte(13) // Frame
write_byte(TE_EXPLFLAG_NOSOUND)
message_end();	

engfunc(EngFunc_MessageBegin, MSG_BROADCAST ,SVC_TEMPENTITY, originF, 0)
write_byte(TE_SPRITETRAIL) // TE ID
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]+70) // z axis
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]) // z axis
write_short(g_firegibs) // Sprite Index
write_byte(80) // Count
write_byte(10) // Life
write_byte(3) // Scale
write_byte(50) // Velocity Along Vector
write_byte(10) // Rendomness of Velocity
message_end();

engfunc(EngFunc_MessageBegin, MSG_PVS,SVC_TEMPENTITY, originF)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, originF[0]) // x
engfunc(EngFunc_WriteCoord, originF[1]) // y
engfunc(EngFunc_WriteCoord, originF[2]) // z
write_byte(30) // radius	
write_byte(250) // r
write_byte(100) // g
write_byte(10) // b
write_byte(5) //life
write_byte(10) //decay rate
message_end()

Exp(ent)
emit_sound(ent, CHAN_AUTO, "ZPlague/_exp1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

new attacker = pev(ent, pev_owner)
if (!is_user_connected(attacker) || !is_user_alive(attacker))
{
engfunc(EngFunc_RemoveEntity, ent)
return;
}
new victim = -1
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 300.0)) != 0)
{
if (!is_user_alive(victim) || !zp_core_is_zombie(victim))
continue;

create_burn(victim)
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, victim)
write_short((3<<12)*4)           
write_short((3<<12)*10) 
write_short((3<<12)*10) 

message_end()	
emit_sound(victim, CHAN_AUTO, "ZPlague/flame.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}
engfunc(EngFunc_RemoveEntity, ent)
}
public Exp(Ent)
{
if(!pev_valid(Ent))
return	
static Float:Origin[3],Float:VictimOrigin[3]
static Float:flVelocity[3]
pev(Ent, pev_origin, Origin)  
for(new i = 1; i < get_maxplayers(); i++)
{
if(!is_user_alive(i))
continue	
pev(i, pev_origin, VictimOrigin)
new Float:flDistance = get_distance_f(Origin, VictimOrigin)   
if(flDistance <= 300.0)
{
static Float:flNewSpeed
flNewSpeed = 700 * (1.0 - (flDistance / 300.0))
get_speed_vector(Origin, VictimOrigin, flNewSpeed, flVelocity)
set_pev(i, pev_velocity,flVelocity)
}
}
}
create_burn(player)
{
if(!is_user_alive(player))
return;		
if(!task_exists(player + TASK_FBURN5))
{
g_burning_duration2[player] += 15 * 5
}
set_task(0.2, "Burn2", player + TASK_FBURN5, _, _, "b")	
}
public Burn2(taskid)
{
static origin[3], flags, health
get_user_origin(ID_FBURN5, origin)
flags = pev(ID_FBURN5, pev_flags)

if ((flags & FL_INWATER) || g_burning_duration2[ID_FBURN5] < 1 || !is_user_alive(ID_FBURN5))
{
g_burnvision[ID_FBURN5] = false	
remove_task(taskid)
return
}
health = pev(ID_FBURN5, pev_health)
if (health - 5 > 0)
fm_set_user_health(ID_FBURN5, health - 5)
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_SPRITE) // TE id
write_coord(origin[0]+random_num(-5, 5)) // x
write_coord(origin[1]+random_num(-5, 5)) // y
write_coord(origin[2]+random_num(-10, 10)) // z
write_short(g_flameSpr) // sprite
write_byte(random_num(5,10)) // scale
write_byte(150) // brightness
message_end()	

message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]+10) // z
write_byte(13) // radius	
write_byte(100) // r
write_byte(30) // g
write_byte(0) // b
write_byte(1) //life
write_byte(1) //decay rate
message_end()

g_burnvision[ID_FBURN5] = true
if ((flags & FL_ONGROUND) > 0.0)
{
static Float:velocity[3]
pev(ID_FBURN5, pev_velocity, velocity)
xs_vec_mul_scalar(velocity, 0.5, velocity)
set_pev(ID_FBURN5, pev_velocity, velocity)
}
g_burning_duration2[ID_FBURN5]--
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
new_velocity[0] = origin2[0] - origin1[0]
new_velocity[1] = origin2[1] - origin1[1]
new_velocity[2] = origin2[2] - origin1[2]
static Float:num; num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
new_velocity[0] *= num
new_velocity[1] *= num
new_velocity[2] *= num

return 1;
}
