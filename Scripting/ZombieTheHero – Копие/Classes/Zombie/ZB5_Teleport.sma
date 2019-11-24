#include <amxmodx>
#include <ZombieMod5>

#define TELEPORT_CLASSNAME "teleport_ent"
#define TELEPORT_PORTAL_CLASSNAME "portal_ent"

new const ZombieSound[][] =
{
"ZB5/zombi_teleport_hurt.wav",
"ZB5/zombi_death_teleport_2.wav",

"ZB5/zombi_teleport_gate.wav", 
"ZB5/teleport_skill2.wav",
"ZB5/zombie_teleport_skill1.wav",
}
new const ZombieModel[][] =
{	
"models/player/ZB5_Teleport/ZB5_Teleport.mdl",
"models/ZB5/Claws/v_ZB5_Teleport.mdl",
"sprites/ZB5/ef_teleportzombie.spr"
}

enum
{
COFFIN_NONE = 0,
COFFIN_FALL,
COFFIN_STAND,
COFFIN_SAYONARA
}

new g_had_class[33], g_Orgin[33][3], Teleport_ENT[33]
new ef_sprite[1], g_class, g_IsZombie, g_IsAlive, g_IsConnected

public plugin_init()
{
Register_SafetyFunc()
	
register_think(TELEPORT_CLASSNAME, "fw_Think_Teleport")
register_think(TELEPORT_PORTAL_CLASSNAME, "Fw_Portal_Think")

register_forward(FM_EmitSound, "fw_EmitSound")	

g_class = zb5_register_zclass("Lilith Zombie", "\y(Teleport)", 0, 1, 3, 3000, 1, 1)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

for(i = 0; i < sizeof(ZombieModel); i++)
PrecacheModel(ZombieModel[i])	

ef_sprite[0] = PrecacheModel("sprites/ZB5/lv.spr")	
}
public zp_fw_round_new()
{
remove_entity_name(TELEPORT_CLASSNAME)
remove_entity_name(TELEPORT_PORTAL_CLASSNAME)	
}

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
zb5_skill_zombie(id, SKILL_CAN_2)

cs_set_player_model(id, "ZB5_Teleport")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Teleport.mdl")
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
case SKILL_Q:Do_Skill2(id)
}
}
public Do_Skill(id)
{	
create_fake_attack(id, "knife")
set_weapon_anim(id, 2)

set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

get_user_origin(id, g_Orgin[id])
Create_Teleport(id, 0)

EmitSound(id, CHAN_WEAPON, ZombieSound[4])
}
public Activate_Teleport(id)
{
static origin[3]				
get_user_origin(id, origin)

fm_set_user_origin(id, g_Orgin[id])
Create_Teleport(id, 1)	
//zb5_set_user_unstuck(id)
}

// TELEPORT //
public Create_Teleport(id, Run)
{	
static Float:Origin[3], Float:Angle1[3], Float:Angle2[3], Float:PutOrigin[3]

entity_get_vector(id, EV_VEC_angles, Angle1)
entity_get_vector(id, EV_VEC_origin, Origin)
get_origin_distance(id, PutOrigin, 40.0)

// Add Vector
PutOrigin[2] += 25.0
if(!Run)
{
static ent; ent = create_entity("info_target")
if(!is_valid_ent(ent)) return;
Teleport_ENT[id] = ent 

entity_get_vector(ent, EV_VEC_angles, Angle2)
Angle1[0] = Angle2[0]
entity_set_vector(ent, EV_VEC_angles, Angle1)
entity_set_vector(ent, EV_VEC_origin, PutOrigin)

entity_set_string(ent, EV_SZ_classname, TELEPORT_CLASSNAME)
entity_set_model(ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(ent, EV_INT_body, 10 - 1)

entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.05) 
set_entity_anim(ent, 8)

entity_set_float(ent, EV_FL_scale, 3.0)
drop_to_floor(ent)
entity_set_float(ent, EV_FL_fuser2, get_gametime() + zb5_skill_zombie(id, SKILL_RTIME))

static Float:originF[3]
entity_get_vector(ent, EV_VEC_origin, originF)

engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_BEAMCYLINDER)
write_coord_f(originF[0])
write_coord_f(originF[1])
write_coord_f(originF[2])
write_coord_f(originF[0])
write_coord_f(originF[1])
write_coord_f(originF[2] + 200.0)
write_short(ef_sprite[0])
write_byte(0)
write_byte(0)
write_byte(4)
write_byte(10)
write_byte(0)
write_byte(150)
write_byte(150)
write_byte(150)
write_byte(200)
write_byte(0)
message_end()
}
else
{	
if(!is_valid_ent(Teleport_ENT[id]))
return			

create_teleport_portal(Teleport_ENT[id], Origin)	
set_task(2.5, "RemoveENT", id)
}
}
public RemoveENT(id)
{
if(!is_valid_ent(Teleport_ENT[id]))
return;	

engfunc(EngFunc_RemoveEntity, Teleport_ENT[id])	
}
public fw_Think_Teleport(ent)
{
if(!is_valid_ent(ent))
return

Make_Dlight(ent, 8, 10, 124, 255, 1, 0)

if(get_gametime() - 1.0 > pev(ent, pev_fuser1))
{
EmitSound(ent, CHAN_AUTO, ZombieSound[2])
set_pev(ent, pev_sequence, 8)
	
set_pev(ent, pev_fuser1, get_gametime())
set_pev(ent, pev_fuser2, pev(ent, pev_fuser2) - 1.0)
}
if(pev(ent, pev_fuser2) <= 0.0)
{
set_pev(ent, pev_sequence, 9)	
set_task(1.0, "Remove_Teleport", ent)
return
}

set_pev(ent, pev_nextthink, get_gametime() + 0.1)
}

public Remove_Teleport(ent)
{
if(!is_valid_ent(ent))
return

remove_entity(ent)	
}

public create_teleport_portal(ent, Float:Origin[3])
{	
ent = create_entity("env_sprite")

if(!is_valid_ent(ent))
return

Origin[0] += 19.0
Origin[2] += 85.0

entity_set_string(ent, EV_SZ_classname,  TELEPORT_PORTAL_CLASSNAME)
entity_set_model(ent, ZombieModel[2])

entity_set_int(ent,EV_INT_movetype, MOVETYPE_NOCLIP)
entity_set_int(ent,EV_INT_solid, SOLID_NOT)

entity_set_int(ent,EV_INT_rendermode, kRenderTransAdd)
entity_set_float(ent,EV_FL_renderamt, 255.0)

entity_set_float(ent,EV_FL_scale, 0.5)
entity_set_float(ent,EV_FL_framerate, 1.0)
entity_set_float(ent,EV_FL_fuser1, get_gametime() + 3.0)

entity_set_origin(ent, Origin)
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)
}

public Fw_Portal_Think(ent)
{
if(!is_valid_ent(ent))
return

static Float:fFrame; fFrame = entity_get_float(ent, EV_FL_frame) 
static Float:Origin[3]; entity_get_vector(ent, EV_VEC_origin, Origin)

fFrame += 1.0
if(fFrame > 15.0) fFrame = 0.0

entity_set_float(ent, EV_FL_frame, fFrame)
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)

static Float:fTimeRemove; fTimeRemove = entity_get_float(ent,EV_FL_fuser1)
if(get_gametime() >= fTimeRemove)
{
remove_entity(ent)
return
}
}

/// SKILL 2 ///
public Do_Skill2(id)
{	
if(!is_valid_ent(Teleport_ENT[id]))
return			
		
set_weapon_anim(id, 8)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

set_pdata_string(id, (492) * 4, "skill", -1 , 20)
static Float:originF[3]
pev(id, pev_origin, originF) 

create_teleport_portal(Teleport_ENT[id], originF)
EmitSound(id, CHAN_VOICE, ZombieSound[3])
set_task(1.5, "Activate_Teleport", id)	
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
emit_sound(id, channel, ZombieSound[0], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, ZombieSound[1], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
return FMRES_IGNORED 
} 
///////////// STOCK ///////////////////

stock get_origin_distance(index, Float:Origin[3], Float:Dist)
{
if(!is_valid_ent(index))
return 0

static Float:start[3]
static Float:view_ofs[3]

pev(index, pev_origin, start)
pev(index, pev_view_ofs, view_ofs)
xs_vec_add(start, view_ofs, start)

static Float:dest[3]
pev(index, pev_angles, dest)

engfunc(EngFunc_MakeVectors, dest)
global_get(glb_v_forward, dest)

xs_vec_mul_scalar(dest, Dist, dest)
xs_vec_add(start, dest, dest)

engfunc(EngFunc_TraceLine, start, dest, 0, index, 0)
get_tr2(0, TR_vecEndPos, Origin)

return 1
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
