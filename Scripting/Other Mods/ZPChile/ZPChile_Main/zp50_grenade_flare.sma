#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_core>

const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_FLARE = 234242
new g_trailSpr
public plugin_init()
{
register_forward(FM_SetModel, "fw_SetModel")
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
}
public plugin_precache()
{
g_trailSpr = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
}
public zp_fw_core_cure_post(id){
cs_set_player_view_model(id, CSW_SMOKEGRENADE, "models/ZPChile/Grenades/v_flare.mdl")
remove_task(id)
}
public zp_fw_core_infect(id)cs_reset_player_view_model(id, CSW_SMOKEGRENADE)
public fw_SetModel(ent, const Model[])
{
if(!pev_valid(ent))
return FMRES_IGNORED

static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))
if(equal(Model, "models/w_smokegrenade.mdl"))
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(150) // r
write_byte(150) // g
write_byte(150) // b
write_byte(200) // brightness
message_end()	
engfunc(EngFunc_SetModel, ent, "models/w_flare.mdl")	
set_pev(ent, PEV_NADE_TYPE, NADE_TYPE_FLARE)
return FMRES_SUPERCEDE
}
return FMRES_IGNORED	
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
case NADE_TYPE_FLARE: // Frost Grenade
{
explode(entity)
return HAM_SUPERCEDE;
}
}

return HAM_IGNORED;
}
explode(entity)
{
if(!pev_valid(entity))
return;		
	
emit_sound(entity, CHAN_WEAPON, "ZPChile/flare_on.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
set_pev(entity, pev_effects, EF_DIMLIGHT);	
set_task(60.0, "remove_flare", entity)
}
public remove_flare(entity)
{
if(!pev_valid(entity))
return;
set_pev(entity, pev_flags, FL_KILLME);
engfunc(EngFunc_RemoveEntity, entity)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
