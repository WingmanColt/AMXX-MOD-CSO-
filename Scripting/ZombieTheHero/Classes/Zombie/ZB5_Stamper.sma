#include <amxmodx>
#include <ZombieMod5>

#define COFFIN_CLASSNAME "coffin_ent"

new const ZombieSound[][] =
{
"ZB5/zombi_hurt_stamper_1.wav", 
"ZB5/zombi_hurt_stamper_2.wav",
"ZB5/zombi_death_stamper_1.wav",

"ZB5/stamp_explode.wav", 
"ZB5/zombie_stamping.wav",
"debris/wood1.wav"
}
new const ZombieModel[][] =
{	
"models/player/ZB5_Stamper/ZB5_Stamper.mdl",
"models/ZB5/Claws/v_ZB5_Stamper.mdl",

"sprites/ZB5/zb5_fastrun.spr"
}

enum
{
COFFIN_NONE = 0,
COFFIN_FALL,
COFFIN_STAND,
COFFIN_SAYONARA
}

new g_IsZombie, g_IsAlive, g_IsConnected
new g_had_class[33], ef_sprite[3], g_class, g_MaxPlayers

public plugin_init()
{
Register_SafetyFunc()
	
register_think(COFFIN_CLASSNAME, "fw_Think")	

RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
register_forward(FM_EmitSound, "fw_EmitSound")	

g_MaxPlayers = get_maxplayers()
g_class = zb5_register_zclass("Undertaker", "\y(Coffin)", 0, 1, 2, 7000, 1, 0)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

for(i = 0; i < sizeof(ZombieModel); i++)
PrecacheModel(ZombieModel[i])		

ef_sprite[0] = PrecacheModel("models/woodgibs.mdl")
ef_sprite[1] = PrecacheModel("sprites/ZB5/zombiebomb_exp.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/lv.spr")
}

public zp_fw_round_new()remove_entity_name(COFFIN_CLASSNAME)
public zb5_zclass_selected_post(id, class)
{
if(class == g_class)
Get_Class(id)
}

public Get_Class(id)
{	
zb5_remove_zclass(id)

g_had_class[id] = true	
zb5_skill_zombie(id, SKILL_CAN)

cs_set_player_model(id, "ZB5_Stamper")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Stamper.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
set_weapon_anim(id, 3)
}

// SKILL 1
public zb5_zombieskill(id, SkillButton)
{
if(!g_had_class[id])
return

switch(SkillButton)
{
case SKILL_E:Do_Skill(id)
}
}
public Do_Skill(id)
{	
set_weapon_anim(id, 8)
set_fov(id, 110)

set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

create_fake_attack(id, "knife")
set_pdata_string(id, (492) * 4, "skill", -1 , 20)

set_task(0.7, "Create_Coffin", id)
}

public Create_Coffin(id)
{	
static Float:Origin[3], Float:Angle1[3], Float:Angle2[3], Float:PutOrigin[3]

entity_get_vector(id, EV_VEC_angles, Angle1)
entity_get_vector(id, EV_VEC_origin, Origin)
get_origin_distance(id, PutOrigin, 40.0)

// Add Vector
PutOrigin[2] += 25.0

static ent; ent = create_entity("info_target")
if(!is_valid_ent(ent)) 
return

entity_get_vector(ent, EV_VEC_angles, Angle2)
Angle1[0] = Angle2[0]
entity_set_vector(ent, EV_VEC_angles, Angle1)
entity_set_vector(ent, EV_VEC_origin, PutOrigin)

entity_set_string(ent, EV_SZ_classname, COFFIN_CLASSNAME)
entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES)
entity_set_float(ent, EV_FL_health, 10000.0 + 200.0)

entity_set_model(ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(ent, EV_INT_body, 11 - 1)
entity_set_int(ent, EV_INT_sequence, 10)

entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP)
entity_set_int(ent, EV_INT_solid, SOLID_BBOX)

entity_set_int(ent, EV_INT_iuser1, id)
entity_set_int(ent, EV_INT_iuser2, COFFIN_FALL)
entity_set_float(ent, EV_FL_fuser1, get_gametime() +10.0)

new const Float:mins[3] = {-10.0, -6.0, -36.0}
new const Float:maxs[3] = {10.0, 6.0, 36.0}
entity_set_size(ent, mins, maxs)

drop_to_floor(ent)
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1) 

set_fov(id)
set_pdata_string(id, (492) * 4, "knife", -1 , 20)
}
public fw_Think(Ent)
{
if(!is_valid_ent(Ent))
return
if((entity_get_float(Ent, EV_FL_health) - 10000.0) <= 0.0)
{
Coffin_Explosion(Ent)
return
}

static id; id = entity_get_int(Ent, EV_INT_iuser1)
if(is_alive(id) && !is_zombie(id))
{
Coffin_Break(Ent)
return
}

switch(entity_get_int(Ent, EV_INT_iuser2))
{
case COFFIN_FALL:
{
if(is_player_stuck(Ent))
{
Coffin_Explosion(Ent)
return
}

if(!(pev(Ent, pev_flags) & FL_ONGROUND))
{
entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.1) 
return
}

Make_StampingEffect(Ent)

//set_pev(Ent, pev_movetype, MOVETYPE_NONE)
entity_set_int(Ent, EV_INT_iuser2, COFFIN_STAND)
}
case COFFIN_STAND:
{
if(entity_get_float(Ent, EV_FL_fuser1) <= get_gametime())
{
Coffin_Break(Ent)
return
}
}
}

entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.1) 
}

public Coffin_Break(Ent)
{
Coffin_BreakEffect(Ent)

// Remove Ent
entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.01) 
entity_set_int(Ent, EV_INT_flags, FL_KILLME)
}

public Coffin_Explosion(Ent)
{
static Float:Origin[3]
entity_get_vector(Ent, EV_VEC_origin, Origin)

// Exp Spr
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
write_coord_f(Origin[0])
write_coord_f(Origin[1])
write_coord_f(Origin[2] - 26.0)
write_short(ef_sprite[1])
write_byte(20)
write_byte(30)
write_byte(14)
message_end()

Coffin_BreakEffect(Ent)
EmitSound(Ent, CHAN_BODY, ZombieSound[3])

Check_KnockPower(Ent, Origin)

// Remove Ent
entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.01) 
entity_set_int(Ent, EV_INT_flags, FL_KILLME)
}

public Check_KnockPower(Ent, Float:Origin[3])
{
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_alive(i))
continue
if(entity_range(Ent, i) > 120.0)
continue

Make_ScreenShake(i, 5, 3, 5)
hook_ent3(i, Origin, 350.0, 1.0, 2)
}
}

public Coffin_BreakEffect(Ent)
{
static Float:Origin[3]
entity_get_vector(Ent, EV_VEC_origin, Origin)
		
// Break Model
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_BREAKMODEL)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] - 36.0)
engfunc(EngFunc_WriteCoord, 36)
engfunc(EngFunc_WriteCoord, 36)
engfunc(EngFunc_WriteCoord, 36)
engfunc(EngFunc_WriteCoord, random_num(-25, 25))
engfunc(EngFunc_WriteCoord, random_num(-25, 25))
engfunc(EngFunc_WriteCoord, 25)
write_byte(20)
write_short(ef_sprite[0])
write_byte(10)
write_byte(25)
write_byte(0x08) // 0x08 = Wood
message_end()

EmitSound(Ent, CHAN_ITEM, ZombieSound[5])
}

public Make_StampingEffect(Ent)
{
static Float:Origin[3]
entity_get_vector(Ent, EV_VEC_origin, Origin)

engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_BEAMCYLINDER)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] - 16.0)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 150.0)
write_short(ef_sprite[2])
write_byte(0)
write_byte(0)
write_byte(4)
write_byte(15)
write_byte(0)
write_byte(100)
write_byte(100)
write_byte(100)
write_byte(50)
write_byte(0)
message_end()	

EmitSound(Ent, CHAN_VOICE, ZombieSound[4])
}

public fw_CoffinTrace(ent, attacker, Float: damage, Float: direction[3], trace, damageBits)
{
if(!is_valid_ent(ent))
return HAM_IGNORED
if(!is_alive(attacker))
return HAM_IGNORED

if(is_zombie(attacker) && get_user_weapon(attacker) == CSW_KNIFE)
{
SetHamParamFloat(3, 125.0)
return HAM_IGNORED
}
static Float:End[3]
get_tr2(trace, TR_vecEndPos, End)

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_SPARKS)
engfunc(EngFunc_WriteCoord, End[0])
engfunc(EngFunc_WriteCoord, End[1])
engfunc(EngFunc_WriteCoord, End[2])
message_end()

EmitSound(ent, CHAN_VOICE, ZombieSound[5])

return HAM_IGNORED
}

public fw_TraceAttack(Victim, Attacker, Float:Damage, Float:Direction[3], TrResult, DamageType)
{
if(!is_valid_ent(Victim) || !is_alive(Attacker))
return HAM_IGNORED

static Float:OriginA[3], Float:OriginB[3]

pev(Attacker, pev_origin, OriginA)
pev(Victim, pev_origin, OriginB)

if(Is_Coffin_Between(Attacker, OriginA, OriginB))
return HAM_SUPERCEDE

return HAM_IGNORED
}
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if(!is_alive(id))
return FMRES_IGNORED;
if(!is_zombie(id))
return FMRES_IGNORED;
if(!g_had_class[id])
return FMRES_IGNORED;

if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, ZombieSound[random_num(0, 1)], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, ZombieSound[2], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
return FMRES_IGNORED 
} 
public Is_Coffin_Between(Ignore, Float:OriginA[3], Float:OriginB[3])
{
static Ptr; Ptr = create_tr2()
engfunc(EngFunc_TraceLine, OriginA, OriginB, DONT_IGNORE_MONSTERS, Ignore, Ptr)

static pHit; pHit = get_tr2(Ptr, TR_pHit)
free_tr2(Ptr)

if(!is_valid_ent(pHit))
return 0

static Classname[32]; pev(pHit, pev_classname, Classname, sizeof(Classname))
if(!equal(Classname, COFFIN_CLASSNAME)) 
return 0

return 1
}

stock get_origin_distance(index, Float:Origin[3], Float:Dist)
{
if(!pev_valid(index))
return 0

new Float:start[3]
new Float:view_ofs[3]

pev(index, pev_origin, start)
pev(index, pev_view_ofs, view_ofs)
xs_vec_add(start, view_ofs, start)

new Float:dest[3]
pev(index, pev_angles, dest)

engfunc(EngFunc_MakeVectors, dest)
global_get(glb_v_forward, dest)

xs_vec_mul_scalar(dest, Dist, dest)
xs_vec_add(start, dest, dest)

engfunc(EngFunc_TraceLine, start, dest, 0, index, 0)
get_tr2(0, TR_vecEndPos, Origin)

return 1
}

stock hook_ent3(ent, Float:VicOrigin[3], Float:speed, Float:multi, type)
{
static Float:fl_Velocity[3]
static Float:EntOrigin[3]
static Float:EntVelocity[3]

pev(ent, pev_velocity, EntVelocity)
pev(ent, pev_origin, EntOrigin)
static Float:distance_f
distance_f = get_distance_f(EntOrigin, VicOrigin)

static Float:fl_Time; fl_Time = distance_f / speed
static Float:fl_Time2; fl_Time2 = distance_f / (speed * multi)

if(type == 1)
{
fl_Velocity[0] = ((VicOrigin[0] - EntOrigin[0]) / fl_Time2) * 1.5
fl_Velocity[1] = ((VicOrigin[1] - EntOrigin[1]) / fl_Time2) * 1.5
fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time		
} else if(type == 2) {
fl_Velocity[0] = ((EntOrigin[0] - VicOrigin[0]) / fl_Time2) * 1.5
fl_Velocity[1] = ((EntOrigin[1] - VicOrigin[1]) / fl_Time2) * 1.5
fl_Velocity[2] = (EntOrigin[2] - VicOrigin[2]) / fl_Time
}

xs_vec_add(EntVelocity, fl_Velocity, fl_Velocity)
set_pev(ent, pev_velocity, fl_Velocity)
}

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
public zb5_zclass_remove_post(id)g_had_class[id] = false

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
{
Set_BitVar(g_IsZombie, id)

if(g_had_class[id])	
Get_Class(id)
}else g_had_class[id] = false
}
public zp_fw_core_cure_post(id)
{
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)

if(g_had_class[id])	
Get_Class(id)
}
is_alive(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0

return 1
}
is_zombie(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsZombie, id))
return 0

return 1
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
