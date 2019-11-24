#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_core>


#define TASK_AURA 21252355
#define ID_AURA (taskid - TASK_AURA)
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_NAPALM = 57847
public plugin_init()
{	
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")		
register_forward(FM_SetModel, "fw_SetModel")
}
public zp_fw_core_cure_post(id, attacker)
{
cs_set_player_view_model(id, CSW_FLASHBANG, "models/ZPChile/Grenades/v_explosive.mdl")
cs_set_player_weap_model(id, CSW_FLASHBANG, "models/p_hegrenade.mdl")
}
public zp_fw_core_infect(id, attacker)
{
cs_reset_player_view_model(id, CSW_FLASHBANG)
}
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

static attacker; attacker = pev(entity, pev_owner)

// Grenade's owner is zombie?
if (!is_user_alive(attacker) || zp_core_is_zombie(attacker))
return;

if (model[9] == 'f' && model[10] == 'l')
{
set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)
engfunc(EngFunc_SetModel, entity, "models/ZPChile/Items/human_bomb.mdl")
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

set_task(1.0, "explode", entity+TASK_AURA, _, _, "b")
return HAM_SUPERCEDE;
}

public explode(taskid)
{
if (!pev_valid(ID_AURA)) 
return;

static Float:origin[3]
pev(ID_AURA, pev_origin, origin)

new victim = -1
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 300.0)) != 0)
{
if (is_user_alive(victim) && zp_core_is_zombie(victim))
{
static Float:origin[3]
pev(ID_AURA, pev_origin, origin)

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, origin[0]) // x
engfunc(EngFunc_WriteCoord, origin[1]) // y
engfunc(EngFunc_WriteCoord, origin[2]) // z
write_byte(13) // radius
write_byte(200) // r
write_byte(0) // g
write_byte(0) // b
write_byte(5) //life
write_byte(8) //decay rate
message_end()
emit_sound(ID_AURA, CHAN_AUTO, "ZPChile/beep1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}
}
}
