#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>
#include <dhudmessage>

#define SNOW_MAN					"models/player/zbs_host/zbs_host.mdl"
#define SNOW_MAN_HP				10000.0
#define SNOW_MAN_HIT				20
#define SNOW_MAN_CLASS_NAME		"show_man"

#define SNOW_MAN_SOUND_IDLE		"snow_idle.wav"
#define SNOW_MAN_SOUND_DIE		"snow_die.wav"

new spr_blood_drop, spr_blood_spray
new g_NpcDead;
new Float:g_vecSnowManSpawnPos[3];
new g_iRound;

public plugin_init()
{
register_plugin("ShowMans", "0.1", "fl0wer")
register_event("HLTV", "Event_RoundStart", "a", "1=0", "2=0")

register_logevent("Event_NewRoundStarted", 2, "1=Round_Start")
register_logevent("Event_NewRoundEnd", 2, "1=Round_End")

register_clcmd("set", "clcmd_coord_snowman")

register_clcmd("start", "clcmd_show")

RegisterHam(Ham_Think, "info_target", "Entity_Think")
RegisterHam(Ham_TakeDamage, "info_target", "Entity_TakeDamage_Post", 1)
RegisterHam(Ham_Killed, "info_target", "Entity_Killed")
RegisterHam(Ham_TraceAttack, "info_target", "Entity_TraceAttack")
}
public plugin_precache()
{
spr_blood_drop = precache_model("sprites/blood.spr") 
spr_blood_spray = precache_model("sprites/bloodspray.spr")

precache_model(SNOW_MAN)

precache_sound(SNOW_MAN_SOUND_IDLE)
precache_sound(SNOW_MAN_SOUND_DIE)
load_spawn()
}

public clcmd_coord_snowman(id)
{
new Float:vecOrigin[3], szOrigin[39];

pev(id, pev_origin, vecOrigin)
formatex(szOrigin, charsmax(szOrigin), "%f %f %f", vecOrigin[0], vecOrigin[1], vecOrigin[2])

new szFile[32];

get_mapname(szFile, charsmax(szFile))

format(szFile, charsmax(szFile), "maps/%s.snowman", szFile)

write_file(szFile, szOrigin, 0)

return PLUGIN_HANDLED;
}

public Event_RoundStart()
{
g_iRound--;

if(g_iRound < 0)
g_iRound = 4;

static entity;
entity = -1;
while((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", SNOW_MAN_CLASS_NAME)))
{
engfunc(EngFunc_RemoveEntity, entity)
}
}

public Event_NewRoundStarted()
{
if(g_iRound)
set_task(10.0, "clcmd_show")
}

public Event_NewRoundEnd()
{
remove_task()
}

public Entity_Think(ent) 
{ 
if(!is_valid_ent(ent))
return;

static szClassName[32]; 
entity_get_string(ent, EV_SZ_classname, szClassName, charsmax(szClassName)) 

if(!equali(szClassName, SNOW_MAN_CLASS_NAME)) 
return;

if(g_NpcDead) 
return;

entity_set_float(ent, EV_FL_animtime, get_gametime()) 
entity_set_float(ent, EV_FL_framerate, 1.0) 
entity_set_int(ent, EV_INT_sequence, 1)

entity_set_float(ent, EV_FL_nextthink, get_gametime() + random_float(5.0, 10.0))
}

public Entity_TakeDamage_Post(victim, inflicator, attacker, Float:damage, damage_type)
{
if(!is_user_connected(attacker))
return;

new szClassName[32];
entity_get_string(victim, EV_SZ_classname, szClassName, charsmax(szClassName))

if(equal(szClassName, SNOW_MAN_CLASS_NAME)) 
{
emit_sound(victim, CHAN_VOICE, SNOW_MAN_SOUND_IDLE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
cs_set_user_money(attacker, cs_get_user_money(attacker) + SNOW_MAN_HIT)
}
}

public Entity_Killed(victim, attacker, shouldgin)
{
new szClassName[32];
entity_get_string(victim, EV_SZ_classname, szClassName, charsmax(szClassName))

if(!equal(szClassName, SNOW_MAN_CLASS_NAME)) 
return HAM_IGNORED;

entity_set_float(victim, EV_FL_animtime, get_gametime()); 
entity_set_float(victim, EV_FL_framerate, 1.0)
entity_set_int(victim, EV_INT_sequence, 7)

entity_set_int(victim, EV_INT_solid, SOLID_NOT)

emit_sound(victim, CHAN_VOICE, SNOW_MAN_SOUND_DIE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

g_NpcDead = true;

return HAM_SUPERCEDE;
}

public Entity_TraceAttack(ent, attacker, Float:damage, Float:direction[3], trace, damage_type) 
{ 
if(!is_valid_ent(ent)) 
return; 

new szClassName[32]; 
entity_get_string(ent, EV_SZ_classname, szClassName, charsmax(szClassName)) 

if(!equali(szClassName, SNOW_MAN_CLASS_NAME)) 
return; 

new Float:end[3];
get_tr2(trace, TR_vecEndPos, end)

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, end[0])
engfunc(EngFunc_WriteCoord, end[1])
engfunc(EngFunc_WriteCoord, end[2])
write_short(spr_blood_spray)
write_short(spr_blood_drop)
write_byte(247)
write_byte(random_num(5, 10))
message_end()
}

public clcmd_show(id)
{
new ent = create_entity("info_target");

if(!is_valid_ent(ent))
return;

entity_set_string(ent, EV_SZ_classname, SNOW_MAN_CLASS_NAME)
entity_set_model(ent, SNOW_MAN)
entity_set_size(ent, Float:{ -16.0, -16.0, -36.0 }, Float:{ 16.0, 16.0, 36.0 })
entity_set_float(ent, EV_FL_health, SNOW_MAN_HP)
entity_set_float(ent, EV_FL_takedamage, DAMAGE_AIM)
entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
entity_set_int(ent, EV_INT_sequence, 0)
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01)
entity_set_origin(ent, g_vecSnowManSpawnPos)
drop_to_floor(ent)
g_NpcDead = false;
}

load_spawn()
{
new szFile[32], szSpawn[39], szSpawns[3][13];

get_mapname(szFile, charsmax(szFile))

format(szFile, charsmax(szFile), "maps/%s.snowman", szFile)

if(!file_exists(szFile))
return;

new iLen;

read_file(szFile, 0, szSpawn, charsmax(szSpawn), iLen)

parse(szSpawn, szSpawns[0], 12, szSpawns[1], 12, szSpawns[2], 12)

g_vecSnowManSpawnPos[0] = floatstr(szSpawns[0]);
g_vecSnowManSpawnPos[1] = floatstr(szSpawns[1]);
g_vecSnowManSpawnPos[2] = floatstr(szSpawns[2]);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
