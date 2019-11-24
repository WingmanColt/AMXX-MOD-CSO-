#include <amxmodx>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_gamemodes>
#include <zp50_core>
#include <ZPC_Options>

const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_FLARE = 4444
const PEV_FLARE_COLOR = pev_punchangle
const PEV_FLARE_DURATION = pev_flSwimTime

new FlareEntModel[] = {"sprites/ZPChile/new_flaresprite.mdl"}
new const FlareEntclassname[] = "FlareEntclassname"

new g_had_flare[33], g_enabled[33], g_trailSpr, g_glowSpr, bool:g_endround
public plugin_init()
{	
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")	
RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "fw_Deploy_Post", 1);		
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
register_forward(FM_SetModel, "fw_SetModel")
//register_think(FlareEntclassname, "FlareThink")
}
public plugin_precache()
{
if(!can_precache())
return;	
PrecacheModel(FlareEntModel)
g_trailSpr = PrecacheModel("sprites/ZPChile/new_fire_trail.spr")
g_glowSpr = PrecacheModel("sprites/animglow01.spr")
}
public plugin_natives()
{
register_native("give_grenade_flare", "Get_Flare", 1)
register_native("grenade_flare", "Flare", 1)
}
public zp_fw_core_infect(id)cs_reset_player_view_model(id, CSW_SMOKEGRENADE)
public event_round_start()g_endround = false
public zp_fw_gamemodes_end()g_endround = true
public Get_Flare(id)
{
if (user_has_weapon(id, CSW_SMOKEGRENADE))
return 
grenade_pipe(id, 0)
g_enabled[id] = true
g_had_flare[id] = true
fm_give_item(id, "weapon_smokegrenade")
}
public Flare(id, mode)
{
if(mode==0)g_enabled[id] = false
else if(mode==1)g_enabled[id] = true
}
public fw_Deploy_Post(ent)
{
if(!pev_valid(ent))
return HAM_IGNORED;

new id = get_pdata_cbase(ent, 41, 4);

if (!is_user_alive(id) || zp_core_is_zombie(id))
return HAM_IGNORED;

if(g_had_flare[id] && g_enabled[id])
{
set_pev(id, pev_viewmodel2, "models/ZPChile/Grenades/v_flare.mdl");
set_pev(id, pev_weaponmodel2, "models/ZPChile/Grenades/v_flare.mdl");
}

return HAM_HANDLED;
}
public fw_SetModel(ent, const Model[])
{
if(!pev_valid(ent))
return FMRES_IGNORED

static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))
if(equal(Model, "models/w_smokegrenade.mdl"))
{
static id; id = pev(ent, pev_owner)
if(!is_user_alive(id))
return FMRES_SUPERCEDE

if(g_had_flare[id] && g_enabled[id])
{			
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(250) // r
write_byte(250) // g
write_byte(250) // b
write_byte(250) // brightness
message_end()

grenade_pipe(id, 1)	
g_had_flare[id] = false
engfunc(EngFunc_SetModel, ent, "models/ZPChile/Items/radar_by_morte.mdl")	
set_pev(ent, PEV_NADE_TYPE, NADE_TYPE_FLARE)
return FMRES_SUPERCEDE
}
}
return FMRES_IGNORED	
}


public fw_ThinkGrenade(entity, touch)
{
if (!pev_valid(entity)) 
return HAM_IGNORED;
static Float:dmgtime
pev(entity, pev_dmgtime, dmgtime)
new Float:current_time = get_gametime()
if (dmgtime > current_time)
return HAM_IGNORED;
switch (pev(entity, PEV_NADE_TYPE))
{
case NADE_TYPE_FLARE: // Flare
{
new duration = pev(entity, PEV_FLARE_DURATION)
if (duration > 0)
{
if (duration == 1)
{
if (pev_valid(entity))engfunc(EngFunc_RemoveEntity, entity)
return HAM_SUPERCEDE;
}
flare_lighting(entity, duration)
set_pev(entity, PEV_FLARE_DURATION, --duration)
set_pev(entity, pev_dmgtime, current_time + 2.0)
}
else if ((pev(entity, pev_flags) & FL_ONGROUND) && fm_get_speed(entity) < 10)
{	
emit_sound(entity, CHAN_WEAPON, "ZPChile/flare_on.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
fm_set_entity_visibility(entity, 0)

set_pev(entity, PEV_FLARE_DURATION, 1 + 100/2)
set_pev(entity, pev_dmgtime, current_time + 0.1)

static Float:originF[3], color[3]
pev(entity, pev_origin, originF)
pev(entity, PEV_FLARE_COLOR, color)
/*
new FlareEnt = create_entity("info_target")

if(!g_endround || pev_valid(FlareEnt)) {
entity_set_string(FlareEnt, EV_SZ_classname, FlareEntclassname);
entity_set_int(FlareEnt, EV_INT_solid, SOLID_NOT);
entity_set_int(FlareEnt, EV_INT_movetype, MOVETYPE_NONE);
entity_set_model(FlareEnt, FlareEntModel);
set_rendering(FlareEnt, kRenderFxNone, color[0], color[1], color[2], kRenderTransAdd, 255)
entity_set_float(FlareEnt, EV_FL_scale, 0.5);
entity_set_float(FlareEnt, EV_FL_nextthink, get_gametime() + 2.0);
entity_set_origin(FlareEnt, originF);
set_pev(FlareEnt, pev_renderfx, 90);
set_task(50 + 0.5, "RemoveFlareEnt",FlareEnt)
set_pev(FlareEnt,pev_rendermode,kRenderTransAdd);
}else if(task_exists(FlareEnt)) remove_task(FlareEnt)*/
}
else
{
set_pev(entity, pev_dmgtime, current_time + 0.5)
}
}
}

return HAM_IGNORED;
}
public RemoveFlareEnt(ent)
{
if (g_endround) return
if(pev_valid(ent)) remove_entity(ent)
}
flare_lighting(entity, duration)
{
if(!pev_valid(entity))
return;
static Float:origin[3], color[3]
pev(entity, pev_origin, origin)
pev(entity, PEV_FLARE_COLOR, color)

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, origin[0]) // x
engfunc(EngFunc_WriteCoord, origin[1]) // y
engfunc(EngFunc_WriteCoord, origin[2]) // z
write_byte(23) // radius	
write_byte(150) // r
write_byte(150) // g
write_byte(150) // b
write_byte(21) //life
write_byte((duration < 2) ? 3 : 0) //decay rate
message_end()

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
write_byte(TE_GLOWSPRITE)
engfunc(EngFunc_WriteCoord, origin[0]) // x
engfunc(EngFunc_WriteCoord, origin[1]) // y
engfunc(EngFunc_WriteCoord, origin[2]+10) // z
write_short(g_glowSpr)
write_byte(20) // life
write_byte(10) // scale
write_byte(200) // brightness
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
