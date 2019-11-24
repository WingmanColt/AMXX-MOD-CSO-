#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define WALL1_CLASSNAME "ent_wall1"
#define WALL2_CLASSNAME "ent_wall2"
new g_spr
public plugin_init() 
{
RegisterHam(Ham_TraceAttack, "info_target", "fw_TraceAttack")
RegisterHam(Ham_Think, "info_target", "fw_Think")	
register_clcmd("say origin", "Get_Origin"); 
}
public plugin_precache()
{
g_spr = precache_model("sprites/zerogxplode.spr")	
precache_model("models/ZBS/jeep-explode.mdl")	
precache_model("models/ZBS/jeep-russian.mdl")	
}
public plugin_cfg()
{
Create_Wall()	
Create_Wall2()
}
public Get_Origin(id)
{
new Float:Origin[3]
pev(id, pev_origin, Origin)
client_print(id, print_chat,"Current origin: {%f, %f, %f}", Origin[0], Origin[1], Origin[2]);
}
public fw_TraceAttack(ent, attacker, Float: damage, Float: direction[3], trace, damageBits)
{
if(ent == attacker || !is_user_connected(attacker) || !is_valid_ent(ent)) return HAM_IGNORED;
if(!(damageBits & DMG_BULLET)) return HAM_IGNORED;
new className[32];
entity_get_string(ent, EV_SZ_classname, className, charsmax(className))
if(!equali(className, WALL1_CLASSNAME) || !equali(className, WALL2_CLASSNAME)) 
return HAM_IGNORED;
new Float: end[3]
get_tr2(trace, TR_vecEndPos, end);
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_SPARKS)
engfunc(EngFunc_WriteCoord, end[0])
engfunc(EngFunc_WriteCoord, end[1])
engfunc(EngFunc_WriteCoord, end[2])
message_end()
return HAM_IGNORED;
}

public fw_Think(ent)
{
if(!is_valid_ent(ent)) return;
static className[32];
entity_get_string(ent, EV_SZ_classname, className, charsmax(className))
if(!equali(className, WALL1_CLASSNAME) || !equali(className, WALL2_CLASSNAME)) 
return;
Explosion(ent)
}

public Create_Wall()
{	
new ent = create_entity("info_target")
new Float:origin[3]		
entity_set_string(ent, EV_SZ_classname, WALL1_CLASSNAME);

origin[0] = -23.112951
origin[1] = 270.666107
origin[2] = 124.031250	

entity_set_origin(ent, origin);
entity_set_model(ent, "models/ZBS/jeep-explode.mdl");
entity_set_float(ent, EV_FL_takedamage, 1.0);
entity_set_float(ent, EV_FL_health, 1000.0+5000.0)
entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP);
entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
drop_to_floor(ent)
new Float:mins[3] = {-30.0, -10.0, -5.0}
new Float:maxs[3] = {70.0, 40.0, 60.0}
entity_set_size(ent, mins, maxs)
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0) 
}
public Create_Wall2()
{	
new ent = create_entity("info_target")
new Float:origin[3]		
entity_set_string(ent, EV_SZ_classname, WALL2_CLASSNAME);

origin[0] = 123.151199
origin[1] = 389.426055
origin[2] = 124.031250	

entity_set_origin(ent, origin);
entity_set_model(ent, "models/ZBS/jeep-russian.mdl");
entity_set_float(ent, EV_FL_takedamage, 1.0);
entity_set_float(ent, EV_FL_health, 1000.0+5000.0)
entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP);
entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
drop_to_floor(ent)
new Float:mins[3] = {-30.0, -10.0, -5.0}
new Float:maxs[3] = {70.0, 40.0, 60.0}
entity_set_size(ent, mins, maxs)
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0) 
}
Explosion(ent)
{
if(!is_valid_ent(ent)) 
return;

static Float:flOrigin[3]
entity_get_vector(ent, EV_VEC_origin, flOrigin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, flOrigin[0])
engfunc(EngFunc_WriteCoord, flOrigin[1])
engfunc(EngFunc_WriteCoord, flOrigin[2])
write_short(g_spr)
write_byte(40)
write_byte(30)
write_byte(14)
message_end()
remove_entity(ent)
}
