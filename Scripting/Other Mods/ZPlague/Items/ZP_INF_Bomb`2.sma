#include <amxmodx>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_colorchat>
#include <zp50_gamemodes>
#include <zp50_core>

new const gas_classname[] = "Gas"
new const bomb_classname[]= "bomb"
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_INFECTION = 41241
new g_had_infection[33], g_InfectionBombCounter
new g_trailSpr, g_exploSpr,g_explo3gibs,g_exploshatter

public plugin_init()
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_Touch, "fw_Touch")
RegisterHam(Ham_Think, "info_target", "fw_Gas_Think")
}
public plugin_precache()
{
g_trailSpr = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
g_exploSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/ef_smoke_poison.spr")
g_explo3gibs = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/infect_shatter2.spr")
g_exploshatter = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/inf_shatter.spr")
}
public plugin_natives()
{
register_native("give_grenade_infect", "Get_Infection", 1)
}
public event_round_start()
{
g_InfectionBombCounter = 0
}
public zp_fw_core_cure(id, attacker)
{
cs_reset_player_view_model(id, CSW_HEGRENADE)
cs_reset_player_weap_model(id, CSW_HEGRENADE)
g_had_infection[id] = false
}
public zp_fw_core_infect_post(id, attacker)
{
g_had_infection[id] = false	
cs_set_player_view_model(id, CSW_HEGRENADE, "models/ZPlague/Grenades/v_zombiebomb.mdl")
cs_set_player_weap_model(id, CSW_HEGRENADE, "models/ZPlague/Grenades/p_zombiebomb.mdl")
}
public Get_Infection(id)
{
if (g_InfectionBombCounter >= 1)
return 
if (user_has_weapon(id, CSW_HEGRENADE))
return 
new money = zp_ammopacks_get(id) 		
if (money >= 20)
{		
zp_ammopacks_set(id, money - 20)		
fm_give_item(id, "weapon_hegrenade")
g_had_infection[id] = true
g_InfectionBombCounter++
}else{
zp_colored_print(id, "^x01Not enough AmmoPacks!")
}
}

public fw_SetModel(ent, const Model[])
{
if(!pev_valid(ent))
return FMRES_IGNORED

static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))
if(equal(Model, "models/w_hegrenade.mdl"))
{
static id; id = pev(ent, pev_owner)

if(g_had_infection[id])
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(10) // r
write_byte(200) // g
write_byte(10) // b
write_byte(100) // brightness
message_end()
engfunc(EngFunc_SetModel, ent, "models/ZPlague/Grenades/w_zombiebomb.mdl")
set_pev(ent, pev_classname, bomb_classname)
return FMRES_SUPERCEDE
}
}
return FMRES_IGNORED	
}
public fw_Touch(ent, touch)
{
if(!pev_valid(ent))
return HAM_IGNORED

static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))
if(equal(Classname, bomb_classname))
{		
static Float:Origin[3]
pev(ent, pev_origin, Origin)  	

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, Origin[0]) // x
engfunc(EngFunc_WriteCoord, Origin[1]) // y
engfunc(EngFunc_WriteCoord, Origin[2]) // z
write_byte(15) // radius
write_byte(80); // r
write_byte(255); // g
write_byte(90); // b
write_byte(216) //life
write_byte(0) //decay rate
message_end()
static Entity_Gas; Entity_Gas = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
engfunc(EngFunc_SetOrigin, Entity_Gas, Origin)
set_pev(Entity_Gas, pev_classname, gas_classname)
set_pev(Entity_Gas, pev_solid, SOLID_NOT)
set_pev(Entity_Gas, pev_movetype, MOVETYPE_NONE)
set_pev(Entity_Gas, pev_takedamage, 0.0)
set_pev(Entity_Gas, pev_deadflag, DEAD_NO)
set_pev(Entity_Gas, pev_nextthink, get_gametime() + 0.01)
set_pev(Entity_Gas,pev_owner,pev(ent,pev_owner))
set_pev(ent,pev_iuser1,1)
if(pev_valid(ent))engfunc(EngFunc_RemoveEntity, ent)
return HAM_SUPERCEDE
}
return HAM_IGNORED
}
public fw_Gas_Think(ent)
{
if(!pev_valid(ent))
return;

static Classname[32];pev(ent, pev_classname, Classname, sizeof(Classname))
if(equal(Classname, gas_classname))
{
static Float:origin[3]
pev(ent, pev_origin, origin)	

new attacker = pev(ent, pev_owner)

if (!is_user_connected(attacker) || !zp_core_is_zombie(attacker))
{
if(pev_valid(ent))
{
static Float:Origin[3]
pev(ent, pev_origin, Origin) 	
engfunc(EngFunc_RemoveEntity, ent)
remove_entity_name(gas_classname)
engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, Origin[0]) // x
engfunc(EngFunc_WriteCoord, Origin[1]) // y
engfunc(EngFunc_WriteCoord, Origin[2]) // z
write_byte(1) // radius
write_byte(0); // r
write_byte(0); // g
write_byte(0); // b
write_byte(1) //life
write_byte(0) //decay rate
message_end()
}
}

new victim = -1

while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 200.0)) != 0)
{
if (!is_user_alive(victim) || zp_core_is_zombie(victim))
continue;

if (zp_core_get_human_count() == 1)
{
ExecuteHamB(Ham_Killed, victim, attacker, 0)
continue;
}
zp_core_infect(victim, attacker)
emit_sound(victim, CHAN_AUTO, "ZPlague/fear_cry.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}
static Float:Origin[3],  ExpFlag; ExpFlag = 0
ExpFlag |= TE_DECALHIGH
ExpFlag |= TE_EXPLFLAG_NOSOUND
ExpFlag |= TE_EXPLFLAG_NOPARTICLES
pev(ent, pev_origin, Origin)  	
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 20.0)
write_short(g_exploSpr)
write_byte(40)	// scale in 0.1's
write_byte(15)	// framerate
write_byte(ExpFlag)// flags
message_end()  

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 20.0)
write_short(g_exploshatter)
write_byte(10)	// scale in 0.1's
write_byte(10)	// framerate
write_byte(ExpFlag)// flags
message_end()  

engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, Origin, 0)
write_byte(TE_SPRITETRAIL) // TE ID
engfunc(EngFunc_WriteCoord, Origin[0]) // x axis
engfunc(EngFunc_WriteCoord, Origin[1]) // y axis
engfunc(EngFunc_WriteCoord, Origin[2]+20.0) // z axis
engfunc(EngFunc_WriteCoord, Origin[0]) // x axis
engfunc(EngFunc_WriteCoord, Origin[1]) // y axis
engfunc(EngFunc_WriteCoord, Origin[2]+25.0) // z axis
write_short(g_explo3gibs) // Sprite Index
write_byte(20) // Count
write_byte(1) // Life
write_byte(5) // Scale
write_byte(60) // Velocity Along Vector
write_byte(15) // Rendomness of Velocity
message_end();	  

set_pev(ent,pev_iuser2,pev(ent,pev_iuser2)+1)
if(pev(ent,pev_iuser2)>10)
{
if(pev_valid(ent))
{	
engfunc(EngFunc_RemoveEntity, ent)
remove_entity_name(gas_classname)
engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, Origin[0]) // x
engfunc(EngFunc_WriteCoord, Origin[1]) // y
engfunc(EngFunc_WriteCoord, Origin[2]) // z
write_byte(1) // radius
write_byte(0); // r
write_byte(0); // g
write_byte(0); // b
write_byte(1) //life
write_byte(0) //decay rate
message_end()
}
}else{ 
set_pev(ent,pev_nextthink,get_gametime()+2.0)
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
