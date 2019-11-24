#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_gamemodes>
#include <zp50_core>

const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_FLARE = 4444
const PEV_FLARE_COLOR = pev_punchangle
const PEV_FLARE_DURATION = pev_flSwimTime
new g_had_flare[33], g_enabled[33], g_glowSpr
new g_trailSpr, g_GameModeAssassinID, g_GameModeBiohazardID
public plugin_init()
{
register_forward(FM_SetModel, "fw_SetModel")
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
}
public plugin_precache()
{
g_glowSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/_flare_3.spr")	
g_trailSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/_trail_1.spr")
}
public plugin_cfg()
{
g_GameModeAssassinID = zp_gamemodes_get_id("Assassin Mode")
g_GameModeBiohazardID = zp_gamemodes_get_id("Biohazard Mode")
}
public plugin_natives()
{
register_native("give_grenade_flare", "Get_Flare", 1)
register_native("grenade_flare", "Flare", 1)
}
public zp_fw_core_infect(id)cs_reset_player_view_model(id, CSW_SMOKEGRENADE)
public Get_Flare(id)
{
if (user_has_weapon(id, CSW_SMOKEGRENADE))
return 
grenade_antidote(id, 0)
cs_reset_player_view_model(id, CSW_SMOKEGRENADE)
cs_set_player_view_model(id, CSW_SMOKEGRENADE, "models/ZPlague/Grenades/v_light.mdl")
g_enabled[id] = true
g_had_flare[id] = true
fm_give_item(id, "weapon_smokegrenade")
remove_task(id)
}
public Flare(id, mode)
{
if(mode==0)g_enabled[id] = false
else if(mode==1)g_enabled[id] = true
}
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
static id; id = pev(entity, pev_owner)
if (!is_user_alive(id))
return;
if (zp_core_is_zombie(id))
return;

// Smoke Grenade
if (model[9] == 's' && model[10] == 'm')
{
if(g_had_flare[id] && g_enabled[id])
{
static rgb[3]	
grenade_antidote(id, 0)	
if(zp_gamemodes_get_current() == g_GameModeBiohazardID)
{
rgb[0] = 150 
rgb[1] = 150 
rgb[2] = 150
}
else if(zp_gamemodes_get_current() == g_GameModeAssassinID)
{
switch (random_num(1, 8))
{
case 1: 
{
rgb[0] = 150
rgb[1] = 0
rgb[2] = 0 
}
case 2: 
{
rgb[0] = 0 
rgb[1] = 100 
rgb[2] = 0  
}
case 3: 
{
rgb[0] = 0 
rgb[1] = 30 
rgb[2] = 100
}
case 4: 
{
rgb[0] = 100 
rgb[1] = 100 
rgb[2] = 10
}
case 5: 
{
rgb[0] = 150 
rgb[1] = 50 
rgb[2] = 5
}
case 6: 
{
rgb[0] = 200 
rgb[1] = 20 
rgb[2] = 100
}
case 7: 
{
rgb[0] = 100 
rgb[1] = 20 
rgb[2] = 200
}
case 8: 
{
rgb[0] = 50 
rgb[1] = 3 
rgb[2] = 10
}
default:
{
rgb[0] = 50 
rgb[1] = 0 
rgb[2] = 10	
}
}
}
else if(zp_gamemodes_get_current() != g_GameModeBiohazardID || zp_gamemodes_get_current() != g_GameModeAssassinID)
{
switch (random_num(1, 7))
{
case 1: 
{
rgb[0] = random_num(150,200)
rgb[1] = random_num(150,200) 
rgb[2] = 60 
}
case 2: 
{
rgb[0] = random_num(150,200) 
rgb[1] = 100 
rgb[2] = random_num(150,200)  
}
case 3: 
{
rgb[0] = 100 
rgb[1] = random_num(150,200) 
rgb[2] = random_num(150,200)
}
case 4: 
{
rgb[0] = random_num(150,200) 
rgb[1] = 120
rgb[2] = 120
}
case 5: 
{
rgb[0] = 100 
rgb[1] = random_num(50,200) 
rgb[2] = 100 
}
case 6: 
{
rgb[0] = 100 
rgb[1] = 100
rgb[2] = random_num(50,200) 
}
case 7: 
{
rgb[0] = random_num(50,200) 
rgb[1] = 150 
rgb[2] = 50
}
}
}
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(entity) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(rgb[0]) // r
write_byte(rgb[1]) // g
write_byte(rgb[2]) // b
write_byte(200) // brightness
message_end()
set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FLARE)
set_pev(entity, PEV_FLARE_COLOR, rgb)
}
}
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
emit_sound(entity, CHAN_AUTO, "ZPlague/flareon.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
if(pev_valid(entity))fm_set_entity_visibility(entity, 0)
static id; id = pev(entity, pev_owner)
grenade_antidote(id, 0)	
set_pev(entity, PEV_FLARE_DURATION, 1 + 150/2)
set_pev(entity, pev_dmgtime, current_time + 0.1)
}
else
{
set_pev(entity, pev_dmgtime, current_time + 0.5)
}
}
}

return HAM_IGNORED;
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
if(zp_gamemodes_get_current() == g_GameModeAssassinID || zp_gamemodes_get_current() == g_GameModeBiohazardID)
{
write_byte(12) // radius
}else{
write_byte(28) // radius	
}
write_byte(color[0]) // r
write_byte(color[1]) // g
write_byte(color[2]) // b
write_byte(21) //life
write_byte((duration < 2) ? 3 : 0) //decay rate
message_end()

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
write_byte(TE_GLOWSPRITE)
engfunc(EngFunc_WriteCoord, origin[0]) // x
engfunc(EngFunc_WriteCoord, origin[1]) // y
engfunc(EngFunc_WriteCoord, origin[2]) // z
write_short(g_glowSpr)
write_byte(21) // life
write_byte(13) // scale
write_byte(120) // brightness
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
