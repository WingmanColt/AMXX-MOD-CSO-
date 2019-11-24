#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_colorchat>
#include <zp50_gamemodes>

const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_ANTIDOTE = 13121
new g_had_antidote[33], g_AntidoteBombCounter, g_enabled[33]
new g_trailSpr, g_exploSpr,g_explo3gibs
public plugin_init()
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
register_forward(FM_SetModel, "fw_SetModel")
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
}

public plugin_precache()
{
g_trailSpr = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
g_exploSpr = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
g_explo3gibs = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/infect_shatter4.spr")
}
public plugin_natives()
{
register_native("give_grenade_antidote", "Get_Dote", 1)
register_native("grenade_antidote", "Antidote", 1)
}
public event_round_start()
{
g_AntidoteBombCounter = 0
}

public Get_Dote(id)
{
if (g_AntidoteBombCounter >= 1)
return 
if (user_has_weapon(id, CSW_SMOKEGRENADE))
return 
new money = zp_ammopacks_get(id) 		
if (money >= 15)
{		
zp_ammopacks_set(id, money - 15)		
give_item(id, "weapon_smokegrenade")
g_had_antidote[id] = true
g_enabled[id] = true
grenade_flare(id, 0)
g_AntidoteBombCounter++
}else{
zp_colored_print(id, " ^x01Not enough AmmoPacks!")
}
}
public Antidote(id, mode)
{
if(mode==0)g_enabled[id] = false
else if(mode==1)g_enabled[id] = true
}
public zp_fw_core_cure(id, attacker)g_had_antidote[id] = false
public zp_fw_core_infect_post(id, attacker)g_had_antidote[id] = false	
public Event_CurWeapon(id)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))
return

if(get_user_weapon(id) == CSW_SMOKEGRENADE)
{
if(g_had_antidote[id])
{
set_pev(id, pev_viewmodel2, "models/ZPlague/Grenades/v_antidote.mdl")
set_pev(id, pev_weaponmodel2, "models/ZPlague/Grenades/p_antidote.mdl")
}		
}
}
public fw_SetModel(ent, const model[])
{
if (!pev_valid(ent))
return;

if (strlen(model) < 8)
return;

// Narrow down our matches a bit
if (model[7] != 'w' || model[8] != '_')
return;

// Get damage time of grenade
static Float:dmgtime
pev(ent, pev_dmgtime, dmgtime)

// Grenade not yet thrown
if (dmgtime == 0.0)
return;

static id; id = pev(ent, pev_owner)

if (!is_user_alive(id))
return;

if (zp_core_is_zombie(id))
return;

// HE Grenade
if (model[9] == 's' && model[10] == 'm')
{
if(g_had_antidote[id])
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(200) // r
write_byte(10) // g
write_byte(100) // b
write_byte(100) // brightness
message_end()
engfunc(EngFunc_SetModel, ent, "models/ZPlague/Grenades/w_antidote.mdl")
set_pev(ent, PEV_NADE_TYPE, NADE_TYPE_ANTIDOTE)
grenade_flare(id, 0)
}
}
}
public fw_ThinkGrenade(entity)
{
if (!pev_valid(entity)) 
return HAM_IGNORED;

static Float:dmgtime
pev(entity, pev_dmgtime, dmgtime)

if (dmgtime > get_gametime())
return HAM_IGNORED;

switch (pev(entity, PEV_NADE_TYPE))
{
case NADE_TYPE_ANTIDOTE: // Infection Bomb
{
antidote_explode(entity)
return HAM_SUPERCEDE;
}
}

return HAM_IGNORED;
}
antidote_explode(ent)
{	
if(!pev_valid(ent))
return;
	
static Float:Origin[3], Float:origin[3]
pev(ent, pev_origin, origin)
pev(ent, pev_origin, Origin)  

engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_BEAMCYLINDER) // TE id
engfunc(EngFunc_WriteCoord, Origin[0]) // x
engfunc(EngFunc_WriteCoord, Origin[1]) // y
engfunc(EngFunc_WriteCoord, Origin[2]) // z
engfunc(EngFunc_WriteCoord, Origin[0]) // x axis
engfunc(EngFunc_WriteCoord, Origin[1]) // y axis
engfunc(EngFunc_WriteCoord, Origin[2]+555.0) // z axis
write_short(g_exploSpr) // sprite
write_byte(0) // startframe
write_byte(0) // framerate
write_byte(4) // life
write_byte(60) // width
write_byte(0) // noise
write_byte(200) // red
write_byte(10) // green
write_byte(100) // blue
write_byte(200) // brightness
write_byte(0) // speed
message_end()

engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, Origin, 0)
write_byte(TE_SPRITETRAIL) // TE ID
engfunc(EngFunc_WriteCoord, Origin[0]) // x axis
engfunc(EngFunc_WriteCoord, Origin[1]) // y axis
engfunc(EngFunc_WriteCoord, Origin[2]+20.0) // z axis
engfunc(EngFunc_WriteCoord, Origin[0]) // x axis
engfunc(EngFunc_WriteCoord, Origin[1]) // y axis
engfunc(EngFunc_WriteCoord, Origin[2]+15.0) // z axis
write_short(g_explo3gibs) // Sprite Index
write_byte(50) // Count
write_byte(1) // Life
write_byte(3) // Scale
write_byte(50) // Velocity Along Vector
write_byte(10) // Rendomness of Velocity
message_end();
emit_sound(ent, CHAN_WEAPON, "ZPlague/antidote_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

new attacker = pev(ent, pev_owner)
if (!is_user_connected(attacker) || !is_user_alive(attacker))
{
engfunc(EngFunc_RemoveEntity, ent)
return;
}
new victim = -1
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 250.0)) != 0)
{
if (!is_user_alive(victim) || !zp_core_is_zombie(victim) || zp_class_nemesis_get(victim) || zp_class_assassin_get(victim) || zp_core_is_last_zombie(victim))
continue;

zp_core_force_cure(victim)
}
g_enabled[attacker] = false
g_had_antidote[attacker] = false
grenade_flare(attacker, 1)
if(pev_valid(ent))engfunc(EngFunc_RemoveEntity, ent)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
