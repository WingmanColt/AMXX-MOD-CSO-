#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_core>

#define TASK_FROST_REMOVE 151210
#define ID_FROST_REMOVE (taskid - TASK_FROST_REMOVE)
#define MAXPLAYERS 32
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

#define TASK_ID 2787
#define TASK_ID2 41241
#define TASK_ID3 52352
#define ID_TASK_REMOVE (taskid - TASK_REMOVE)
const TASK_REMOVE = 15151
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_FROST = 3333
const UNIT_SECOND = (1<<12)
const BREAK_GLASS = 0x01
const FFADE_IN = 0x0000
const FFADE_STAYOUT = 0x0004
enum _:TOTAL_FORWARDS
{
FW_USER_FREEZE_PRE = 0,
FW_USER_UNFROZEN
}
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame
new Float:iAngles[33][3]; 
new g_Forwards[TOTAL_FORWARDS]
new g_ForwardResult
new Float:g_FrozenGravity[MAXPLAYERS+1],g_FrozenRenderingFx[MAXPLAYERS+1]
new g_FrozenRenderingRender[MAXPLAYERS+1],Float:g_FrozenRenderingColor[MAXPLAYERS+1][3]
new Float:g_FrozenRenderingAmount[MAXPLAYERS+1],g_IsFrozen, g_gibSpr
new g_trailSpr, g_glassSpr, g_frostexpSpr,g_MsgScreenFade
public plugin_init()
{
register_logevent("logevent_round_end", 2, "1=Round_End")	
RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeed_Post", 1)
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
register_forward(FM_SetModel, "fw_SetModel")
g_Forwards[FW_USER_FREEZE_PRE] = CreateMultiForward("zp_fw_grenade_frost_pre", ET_CONTINUE, FP_CELL)
g_Forwards[FW_USER_UNFROZEN] = CreateMultiForward("zp_fw_grenade_frost_unfreeze", ET_IGNORE, FP_CELL)
g_MsgScreenFade = get_user_msgid("ScreenFade")
}
public plugin_precache()
{
g_frostexpSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/frost_ex2.spr")	
g_trailSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/frost_trail.spr")
g_gibSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/frost_shatter.spr")
g_glassSpr = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl")
}
public plugin_natives()
{
register_library("zp50_grenade_frost")
register_native("zp_grenade_frost_get", "native_grenade_frost_get")
register_native("zp_grenade_frost_set", "native_grenade_frost_set")
}

public native_grenade_frost_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

return flag_get_boolean(g_IsFrozen, id);
}

public native_grenade_frost_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

new set = get_param(2)

// Unfreeze
if (!set)
{
// Not frozen
if (!flag_get(g_IsFrozen, id))
return true;

// Remove freeze right away and stop the task
remove_freeze(id+TASK_FROST_REMOVE)
remove_task(id+TASK_FROST_REMOVE)
return true;
}

return set_freeze(id);
}

public zp_fw_core_cure_post(id, attacker)
{
cs_set_player_view_model(id, CSW_FLASHBANG, "models/ZPlague/Grenades/v_frost.mdl")
if (flag_get(g_IsFrozen, id))
{
ApplyFrozenRendering(id)
remove_freeze(id+TASK_FROST_REMOVE)
remove_task(id+TASK_FROST_REMOVE)
}
}

public zp_fw_core_infect(id)cs_reset_player_view_model(id, CSW_FLASHBANG)
public zp_fw_core_infect_post(id, attacker)
{
if (flag_get(g_IsFrozen, id))
{
ApplyFrozenRendering(id)
}
}

public client_disconnect(id)
{
flag_unset(g_IsFrozen, id)
remove_task(id+TASK_FROST_REMOVE)
}
public logevent_round_end(id)
{
if(task_exists(id+TASK_REMOVE)) remove_task(id+TASK_REMOVE)	
remove_task(id+TASK_FROST_REMOVE)	
}
public fw_ResetMaxSpeed_Post(id)
{
// Dead or not frozen
if (!is_user_alive(id) || !flag_get(g_IsFrozen, id))
return;

// Prevent from moving
set_user_maxspeed(id, 1.0)
}

// Ham Trace Attack Forward
public fw_TraceAttack(victim, attacker)
{
// Non-player damage or self damage
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

// Block damage while frozen, as it makes killing zombies too easy
if (flag_get(g_IsFrozen, victim))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}

// Ham Take Damage Forward (needed to block explosion damage too)
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
// Non-player damage or self damage
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

// Block damage while frozen, as it makes killing zombies too easy
if (flag_get(g_IsFrozen, victim))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (flag_get(g_IsFrozen, victim))
{
remove_freeze(victim+TASK_FROST_REMOVE)
remove_task(victim+TASK_FROST_REMOVE)
}
}

// Forward Player PreThink
public fw_PlayerPreThink(id)
{
if (!is_user_alive(id) || !flag_get(g_IsFrozen, id))
return;

set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
set_pev(id, pev_v_angle , iAngles[id]); 
set_pev(id, pev_fixangle , 1); 
}

// Forward Set Model
public fw_SetModel(entity, const model[])
{
if (!pev_valid(entity)) 
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

// Flashbang
if (model[9] == 'f' && model[10] == 'l')
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(entity) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(0) // r
write_byte(100) // g
write_byte(100) // b
write_byte(200) // brightness
message_end()
set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FROST)
}
}
public fw_ThinkGrenade(entity)
{
// Invalid entity
if (!pev_valid(entity)) return HAM_IGNORED;

// Get damage time of grenade
static Float:dmgtime
pev(entity, pev_dmgtime, dmgtime)

// Check if it's time to go off
if (dmgtime > get_gametime())
return HAM_IGNORED;

// Check if it's one of our custom nades
switch (pev(entity, PEV_NADE_TYPE))
{
case NADE_TYPE_FROST: // Frost Grenade
{
frost_explode(entity)
return HAM_SUPERCEDE;
}
}

return HAM_IGNORED;
}
frost_explode(ent)
{
if(!pev_valid(ent))
return;		

static Float:origin[3]
pev(ent, pev_origin, origin)
static Float:Origin[3]
pev(ent, pev_origin, Origin)  
set_task(0.5,"create_aura", ent+TASK_ID3)
set_task(0.5,"create_snow_fall_sprite", ent+TASK_ID2)
set_task(7.0, "Cleat_Type", ent+TASK_REMOVE)

engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, Origin, 0)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0]) // x axis
engfunc(EngFunc_WriteCoord, Origin[1]) // y axis
engfunc(EngFunc_WriteCoord, Origin[2]+75) // z axis
write_short(g_frostexpSpr)
write_byte(30)
write_byte(20)
write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS|TE_EXPLFLAG_NOPARTICLES)// flags
message_end();

emit_sound(ent, CHAN_WEAPON, "ZPlague/frost_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

// Collisions
new victim = -1

while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 200.0)) != 0)
{
if (!is_user_alive(victim) || !zp_core_is_zombie(victim))
continue;
set_freeze(victim)
}
}
public create_snow_fall_sprite(ent)
{
ent -= TASK_ID2	

if(!pev_valid(ent))
return
	
static Float:originF[3]
pev(ent, pev_origin, originF) 

engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0)
write_byte(TE_SPRITETRAIL) // TE ID
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2] + 40) // z axis
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2] + 40) // z axis
write_short(g_gibSpr) // Sprite Index
write_byte(10) // Count
write_byte(2) // Life
write_byte(4) // Scale
write_byte(30) // Velocity Along Vector
write_byte(10) // Rendomness of Velocity
message_end();

engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]+40) // z axis
write_short(g_frostexpSpr)
write_byte(10)
write_byte(8)
write_byte(TE_DECALHIGH|TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS|TE_EXPLFLAG_NOPARTICLES)// flags
message_end();

set_task(2.0,"create_snow_fall_sprite", ent+TASK_ID2)
}
public create_aura(ent)
{
ent -= TASK_ID3		

if(!pev_valid(ent))
return
// Get origin
static Float:Origin[3]
pev(ent, pev_origin, Origin)  

static Float:origin[3]
pev(ent, pev_origin, origin)

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, Origin[0]) // x
engfunc(EngFunc_WriteCoord, Origin[1]) // y
engfunc(EngFunc_WriteCoord, Origin[2]) // z
write_byte(10) // radius	
write_byte(0); // r
write_byte(150); // g
write_byte(240); // b
write_byte(2) //life
write_byte(0) //decay rate
message_end()

new victim = -1

while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 50.0)) != 0)
{
if (!is_user_alive(victim) || !zp_core_is_zombie(victim))
continue;
set_freeze(victim)
}

set_task(0.2,"create_aura", ent+TASK_ID3)
}
set_freeze(victim)
{
if(zp_class_nemesis_get(victim) || zp_class_assassin_get(victim))
return true;

if (flag_get(g_IsFrozen, victim))
return false;

ExecuteForward(g_Forwards[FW_USER_FREEZE_PRE], g_ForwardResult, victim)

message_begin(MSG_ONE, g_MsgScreenFade, _, victim)
write_short(0) // duration
write_short(0) // hold time
write_short(FFADE_STAYOUT) // fade type
write_byte(0) // red
write_byte(30) // green
write_byte(150) // blue
write_byte(150) // alpha
message_end()
emit_sound(victim, CHAN_BODY, "ZPlague/unfrost.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
ApplyFrozenRendering(victim)
ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
set_task(2.0, "remove_freeze", victim+TASK_FROST_REMOVE)
flag_set(g_IsFrozen, victim)
return true;
}

ApplyFrozenRendering(id)
{
new rendering_fx = pev(id, pev_renderfx)
new Float:rendering_color[3]
pev(id, pev_rendercolor, rendering_color)
new rendering_render = pev(id, pev_rendermode)
new Float:rendering_amount
pev(id, pev_renderamt, rendering_amount)

// Already set, no worries...
if (rendering_fx == kRenderFxGlowShell && rendering_color[0] == 0.0 && rendering_color[1] == 100.0
&& rendering_color[2] == 200.0 && rendering_render == kRenderNormal && rendering_amount == 25.0)
return;

// Save player's old rendering	
g_FrozenRenderingFx[id] = pev(id, pev_renderfx)
pev(id, pev_rendercolor, g_FrozenRenderingColor[id])
g_FrozenRenderingRender[id] = pev(id, pev_rendermode)
pev(id, pev_renderamt, g_FrozenRenderingAmount[id])

// Light blue glow while frozen
fm_set_rendering(id, kRenderFxGlowShell, 0, 150, 220, kRenderNormal, 30)
}

// Remove freeze task
public remove_freeze(taskid)
{
flag_unset(g_IsFrozen, ID_FROST_REMOVE)

set_pev(ID_FROST_REMOVE, pev_gravity, g_FrozenGravity[ID_FROST_REMOVE])
ExecuteHamB(Ham_Player_ResetMaxSpeed, ID_FROST_REMOVE)
fm_set_rendering_float(ID_FROST_REMOVE, g_FrozenRenderingFx[ID_FROST_REMOVE], g_FrozenRenderingColor[ID_FROST_REMOVE], g_FrozenRenderingRender[ID_FROST_REMOVE], g_FrozenRenderingAmount[ID_FROST_REMOVE])
message_begin(MSG_ONE, g_MsgScreenFade, _, ID_FROST_REMOVE)
write_short(UNIT_SECOND) // duration
write_short(0) // hold time
write_short(FFADE_IN) // fade type
write_byte(0) // red
write_byte(0) // green
write_byte(0) // blue
write_byte(0) // alpha
message_end()

static origin2[3]
get_user_origin(ID_FROST_REMOVE, origin2)
message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
write_byte(TE_BREAKMODEL) // TE id
write_coord(origin2[0]) // x
write_coord(origin2[1]) // y
write_coord(origin2[2]+24) // z
write_coord(16) // size x
write_coord(16) // size y
write_coord(16) // size z
write_coord(random_num(-50, 50)) // velocity x
write_coord(random_num(-50, 50)) // velocity y
write_coord(25) // velocity z
write_byte(10) // random velocity
write_short(g_glassSpr) // model
write_byte(10) // count
write_byte(25) // life
write_byte(0x01) // flags
message_end()

ExecuteForward(g_Forwards[FW_USER_UNFROZEN], g_ForwardResult, ID_FROST_REMOVE)
}
public Cleat_Type(taskid)
{
new id = ID_TASK_REMOVE
remove_task(id+TASK_REMOVE) //force it to remove task
if(pev_valid(id))
engfunc(EngFunc_RemoveEntity, id) // Get rid of the grenade
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
static Float:color[3]
color[0] = float(r)
color[1] = float(g)
color[2] = float(b)

set_pev(entity, pev_renderfx, fx)
set_pev(entity, pev_rendercolor, color)
set_pev(entity, pev_rendermode, render)
set_pev(entity, pev_renderamt, float(amount))
}
stock fm_set_rendering_float(entity, fx = kRenderFxNone, Float:color[3], render = kRenderNormal, Float:amount = 16.0)
{
set_pev(entity, pev_renderfx, fx)
set_pev(entity, pev_rendercolor, color)
set_pev(entity, pev_rendermode, render)
set_pev(entity, pev_renderamt, amount)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
