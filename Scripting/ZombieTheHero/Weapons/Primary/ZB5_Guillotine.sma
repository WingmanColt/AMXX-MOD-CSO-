#include <amxmodx>
#include <cstrike>
#include <ZombieMod5>
#include <ScenarioMod>

#define CSW_BASE CSW_TMP
#define weapon_base "weapon_tmp"

#define WEAPON_ANIMEXT "grenade"
#define WEAPON_ANIMEXT2 "knife"

#define GUILLOTINE_CLASSNAME "guillotine"
#define TASK_RESET 14220151

const Float:MAX_RADIUS = 800.0
const Float:FLYING_SPEED = 1300.0
const Float:DAMAGE_DELAY = 0.2
const Float:GUILLOTINE_HITTIME = 4.0

new const sounds[7][] =
{
"ZB5/weapons/guillotine_catch2.wav",
"ZB5/weapons/guillotine_draw.wav",
"ZB5/weapons/guillotine_draw_empty.wav",
"ZB5/weapons/guillotine_explode.wav",
"ZB5/wweapons/guillotine_red.wav",
"ZB5/weapons/guillotine-1.wav",
"ZB5/weapons/guillotine_wall.wav"
}
new const models[][] =
{
"models/ZB5/Primary/v_dripper.mdl",
"models/ZB5/Items/guillotine_projectile.mdl",
"models/ZB5/Items/gibs_guilotine.mdl"
}
new const sprites[][] = 
{
"sprites/weapon_dripper_MSBG.txt",
"sprites/640hud13_2.spr",
"sprites/640hud120.spr",
"sprites/ZB5/guillotine_lost.spr"
}

enum _:Options
{
ENT,
AMMO,
PREAMMO,
MYWEAPON,
Old,
Float:DAMAGE_A,
Float:DAMAGE_B
}

const m_iLastHitGroup = 75
const pev_eteam = EV_INT_iuser1
const pev_return = EV_INT_iuser2
const pev_extra = EV_INT_iuser3

new g_Had_Guillotine, g_had2[33][Options], ef_sprite[2]
new g_Guillotine, g_CanShoot, g_Hit
new g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]

public plugin_init()
{
if(!zb5_weapons_primary())
return

Register_SafetyFunc()
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")

register_forward(FM_CmdStart, "fw_CmdStart")
register_forward(FM_SetModel, "fw_SetModel")	

register_touch(GUILLOTINE_CLASSNAME, "*", "fw_Guillotine_Touch")
register_think(GUILLOTINE_CLASSNAME, "fw_Guillotine_Think")

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_Item_AddToPlayer_Post", 1)
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_Weapon_WeaponIdle_Post", 1)

g_Guillotine = zb5_register_weapon("Blood Dripper", "\rGuillotine", WPN_DESTROYERS, LEVEL_DRIPPER, 1)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(models); i++)
PrecacheModel(models[i])
for(i = 0; i < sizeof(sounds); i++)
PrecacheSound(sounds[i])
for(i = 0; i < sizeof(sprites); i++)
PrecacheGeneric(sprites[i])

ef_sprite[0] = PrecacheModel(sprites[3])
ef_sprite[1] = PrecacheModel(models[2])

register_clcmd("weapon_dripper_MSBG", "HookWeapon")
}
public HookWeapon(id)engclient_cmd(id, weapon_base)

public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_Guillotine) 
Get_Guillotine(id)
}

public Get_Guillotine(id)
{
if(!zb5_weapons_primary())
return

Set_BitVar(g_Had_Guillotine, id)
Set_BitVar(g_CanShoot, id)
UnSet_BitVar(g_Hit, id)

fm_give_item(id, weapon_base)
zp_fw_restock_ammo(id)
SPR(id)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) 
return

Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_BASE)
}
public zp_fw_restock_ammo(id)
{
if(!Get_BitVar(g_Had_Guillotine, id))
return
		
g_had2[id][AMMO] = zb5_had_StrongLife(id)? 15: 10

if(get_player_weapon(id) == CSW_BASE)
update_ammo(id, -1, g_had2[id][AMMO])
}
public Reset_All(id)
{
UnSet_BitVar(g_Had_Guillotine, id)
UnSet_BitVar(g_CanShoot, id)
UnSet_BitVar(g_Hit, id)

g_had2[id][AMMO] = 0
}
public Deploy_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static Id; Id = get_pdata_cbase(Ent, 41, 4)
if(!is_player(Id, 1))
return

if(!Get_BitVar(g_Had_Guillotine, Id))
return

static SubModel; SubModel = 29

set_pev(Id, pev_viewmodel2, models[0])
set_pev(Id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
public event_CurWeapon(id)
{
if(!is_player(id, 1))
return

static CSWID; CSWID = get_player_weapon(id)
static SubModel; SubModel = 3

if((CSWID == CSW_BASE && g_had2[id][Old] != CSW_BASE) && Get_BitVar(g_Had_Guillotine, id))
{
if(SubModel != -1) 
Draw_NewWeapon(id, CSWID)

g_had2[id][PREAMMO] = cs_get_user_bpammo(id, CSW_BASE)
update_ammo(id, -1, g_had2[id][AMMO])
} 

else if((CSWID == CSW_BASE && g_had2[id][Old] == CSW_BASE) && Get_BitVar(g_Had_Guillotine, id)) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent))
{
g_had2[id][Old] = get_player_weapon(id)
return
}
} 

else if(CSWID != CSW_BASE && g_had2[id][Old] == CSW_BASE) 
{
if(SubModel != -1)
Draw_NewWeapon(id, CSWID)

cs_set_user_bpammo(id, CSW_BASE, g_had2[id][PREAMMO])
}

g_had2[id][Old] = get_player_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
if(!is_player(id, 1))
return
	
static ent
ent = fm_get_user_weapon_entity(id, CSW_BASE)
	
if(CSW_ID == CSW_BASE)
{
if(is_valid_ent(ent) && Get_BitVar(g_Had_Guillotine, id))
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

engfunc(EngFunc_SetModel, ent, P_Model2)	
set_pev(ent, pev_body, 29-1)
set_pev(ent, pev_sequence, 23)	

set_pdata_string(id, (492) * 4, WEAPON_ANIMEXT, -1 , 20)
set_weapons_timeidle(id, CSW_BASE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)
update_ammo(id, -1, g_had2[id][AMMO])

static Valid; Valid = is_valid_ent(g_had2[id][MYWEAPON])
set_weapon_anim(id, g_had2[id][AMMO] ? 3:4)

if(!Valid) Set_BitVar(g_CanShoot, id)
else set_weapon_anim(id, 4)
}
} else {

if(is_valid_ent(ent)) 
set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 			
}
}

public RuningTime_Player(id)
{
if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || !Get_BitVar(g_Had_Guillotine, id))
return

if(!Get_BitVar(g_CanShoot, id) && !pev_valid(g_had2[id][MYWEAPON]))
{
set_player_nextattack(id, 1.0)
set_weapons_timeidle(id, CSW_BASE, 1.0)
set_weapon_anim(id, 8)

Set_BitVar(g_CanShoot, id)
UnSet_BitVar(g_Hit, id)

set_task(0.95, "Reset_Guillotine", id+TASK_RESET)
}
}

public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED
if(get_player_weapon(id) != CSW_BASE || !Get_BitVar(g_Had_Guillotine, id))
return FMRES_IGNORED

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)

if(CurButton & IN_ATTACK)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

HandleShot_Guillotine(id)
}

return FMRES_HANDLED
}

public fw_SetModel(entity, model[])
{
if(!is_valid_ent(entity))
return FMRES_IGNORED

static Classname[32]
pev(entity, pev_classname, Classname, sizeof(Classname))

if(!equal(Classname, "weaponbox"))
return FMRES_IGNORED

static iOwner
iOwner = pev(entity, pev_owner)

if(equal(model, "models/w_tmp.mdl"))
{
static weapon; weapon = find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

if(Get_BitVar(g_Had_Guillotine, iOwner))
{
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 38 - 1)	

set_pev(weapon, pev_impulse, 1422015)
set_pev(weapon, pev_iuser4, g_had2[iOwner][AMMO])
cs_set_user_bpammo(iOwner, CSW_BASE, g_had2[iOwner][PREAMMO])
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
}

return FMRES_IGNORED;
}

public fw_Item_AddToPlayer_Post(Ent, id)
{
if(!is_valid_ent(Ent))
return

if(pev(Ent, pev_impulse) == 1422015)
{
Set_BitVar(g_Had_Guillotine, id)
Set_BitVar(g_CanShoot, id)
g_had2[id][AMMO] = pev(Ent, pev_iuser4)

SPR(id)
set_pev(Ent, pev_impulse, 0)
}
}

public fw_Weapon_WeaponIdle_Post(iEnt)
{
if(!is_valid_ent(iEnt))
return

static Id; Id = get_pdata_cbase(iEnt, 41, 4)

if(!Get_BitVar(g_Had_Guillotine, Id))
return

if(get_pdata_float(iEnt, 48, 4) <= 0.25)
{
if(g_had2[Id][AMMO]) 
{	
if(Get_BitVar(g_CanShoot, Id)) set_weapon_anim(Id, 0)
else {
if(Get_BitVar(g_Hit, Id)) set_weapon_anim(Id, 6)
else set_weapon_anim(Id, 5)
}
} else set_weapon_anim(Id, 1)

set_pdata_float(iEnt, 48, 20.0, 4)
}	
}
public fw_Guillotine_Touch(Ent, Touched)
{
if(!pev_valid(Ent))
return

static id; id = pev(Ent, pev_owner)

if(!is_user_alive(id))
{
Guillotine_Broken(Ent)
return
}

static Classname[32];
pev(Touched, pev_classname, Classname, 31)

if(equal(Classname, "func_breakable"))
{
do_attack(id, Touched, 0, random_float(200.0, 300.0), 1) // NORMAL DMG
set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
set_pev(Ent, pev_return, 1)
return
}

if(zbs_is_scenario() == 1)
{
if(equal(Classname, "ent_npc") && equal(Classname, "REX"))
{
Check_AttackDamge(Ent, 30.0, random_float(200.0, 300.0))
set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
set_pev(Ent, pev_return, 1)
return
}
} else {
if(Get_BitVar(g_IsConnected, Touched)) // Touch Human
{ 
if(!Get_BitVar(g_IsAlive, Touched))
return
if(!Get_BitVar(g_IsZombie, Touched))
return
if(Get_BitVar(g_Hit, id))
return
if(Touched == id)
return

static Float:HeadOrigin[3], Float:HeadAngles[3];
engfunc(EngFunc_GetBonePosition, Touched, 8, HeadOrigin, HeadAngles);		

static Float:EntOrigin[3]; pev(Ent, pev_origin, EntOrigin)

if(get_distance_f(EntOrigin, HeadOrigin) <= 21.0)
{
if(!pev(Ent, pev_return))
{
// Set
Set_BitVar(g_Hit, id)
set_weapon_anim(id, 6)

set_pev(Ent, pev_enemy, Touched)
set_pev(Ent, pev_return, 1)
set_pev(Ent, pev_movetype, MOVETYPE_FOLLOW)
set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
set_pev(Ent, pev_fuser1, get_gametime() + GUILLOTINE_HITTIME)

// Animation
set_pev(Ent, pev_animtime, get_gametime())
set_pev(Ent, pev_framerate, 5.0)
set_pev(Ent, pev_sequence, 1)
} else {
if(get_gametime() - DAMAGE_DELAY > g_had2[id][DAMAGE_A])
{	
do_attack(id, Touched, 0, random_float(10.0, 30.0), 1) // NORMAL DMG
g_had2[id][DAMAGE_A] = get_gametime()
}
}
} else {	
// Knockback
set_weapon_kick(id, Touched, 3000.0)
do_attack(id, Touched, 0, random_float(100.0, 200.0), 1) // NORMAL DMG
}	
} 
else { // Touch Wall
if(!pev(Ent, pev_return))
{
set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})

set_pev(Ent, pev_return, 1)
emit_sound(Ent, CHAN_BODY, sounds[6], 1.0, 0.4, 0, 94 + random_num(0, 15))

// Reset Angles
static Float:Angles[3]
pev(id, pev_v_angle, Angles)

Angles[0] *= -1.0
set_pev(Ent, pev_angles, Angles)

}
 else {	
if(!Get_BitVar(g_Hit, id) && !equal(Classname, "weaponbox"))Guillotine_Broken(Ent)
return
}
}
}
}
public fw_Guillotine_Think(Ent)
{
if(!pev_valid(Ent))
return

static id; id = pev(Ent, pev_owner)
if(!is_user_alive(id))
{
Guillotine_Broken(Ent)
return
}

if(!Get_BitVar(g_Had_Guillotine, id))
{
Guillotine_Broken(Ent)
return
}

static Float:LiveTime
pev(Ent, pev_fuser2, LiveTime)

if(get_gametime() >= LiveTime)
{
Guillotine_Broken(Ent)
return
}

if(pev(Ent, pev_return)) // Returning to the owner
{
static Target; Target = pev(Ent, pev_enemy)
if(!is_user_alive(Target))
{
UnSet_BitVar(g_Hit, id)

if(pev(Ent, pev_sequence) != 0) set_pev(Ent, pev_sequence, 0)
if(pev(Ent, pev_movetype) != MOVETYPE_FLY) set_pev(Ent, pev_movetype, MOVETYPE_FLY)
set_pev(Ent, pev_aiment, 0)

if(entity_range(Ent, id) > 100.0)
{
static Float:Origin[3]; pev(id, pev_origin, Origin)
Hook_The_Fucking_Ent(Ent, Origin, FLYING_SPEED)
} else {
Guillotine_Catch(id, Ent)
return
}
} else {
static Float:fTimeRemove
pev(Ent, pev_fuser1, fTimeRemove)

if(get_gametime() >= fTimeRemove)
{
set_pev(Ent, pev_enemy, 0)
} else {
static Float:HeadOrigin[3], Float:HeadAngles[3];
engfunc(EngFunc_GetBonePosition, Target, 8, HeadOrigin, HeadAngles);

static Float:Velocity[3];
pev(Ent, pev_velocity, Velocity)

set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
set_pev(Ent, pev_angles, HeadAngles)

static Float:EnemyOrigin[3]; pev(Target, pev_origin, EnemyOrigin)
if(get_distance_f(EnemyOrigin, HeadOrigin) <= 24.0) engfunc(EngFunc_SetOrigin, Ent, HeadOrigin)
else engfunc(EngFunc_SetOrigin, Ent, EnemyOrigin)

if(get_gametime() - DAMAGE_DELAY > g_had2[id][DAMAGE_B])
{	
// Animation
if(!pev(Ent, pev_sequence))
{
set_pev(Ent, pev_animtime, get_gametime())
set_pev(Ent, pev_framerate, 5.0)
set_pev(Ent, pev_sequence, 1)
}

set_pdata_int(Target, m_iLastHitGroup, HIT_HEAD, 5)
do_attack(id, Target, 0, random_float(50.0, 150.0), 1) // HEAD DMG	
g_had2[id][DAMAGE_B] = get_gametime()
}
// Knockback
set_weapon_kick(id, Target, KNOCKBACK / 5.0)

//HeadShot
set_weapons_headshot(id, 1)
}
}
} else {
if(entity_range(Ent, id) >= MAX_RADIUS)
{
set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
set_pev(Ent, pev_return, 1)
}
}

set_pev(Ent, pev_nextthink, get_gametime() + 0.01)
}

public Guillotine_Broken(Ent)
{
static Float:Origin[3];
pev(Ent, pev_origin, Origin)

// Effect
message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[0])	// sprite index
write_byte(5)	// scale in 0.1's
write_byte(30)	// framerate
write_byte(TE_EXPLFLAG_NOSOUND)	// flags
message_end()

message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
write_byte(TE_BREAKMODEL)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_coord(64); // size x
write_coord(64); // size y
write_coord(64); // size z
write_coord(random_num(-64,64)); // velocity x
write_coord(random_num(-64,64)); // velocity y
write_coord(25); // velocity z
write_byte(10); // random velocity
write_short(ef_sprite[1]); // model index that you want to break
write_byte(32); // count
write_byte(25); // life
write_byte(0x01); // flags: BREAK_GLASS
message_end(); 
 	
emit_sound(Ent, CHAN_BODY, sounds[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
remove_entity(Ent)
}

public Reset_Guillotine(id)
{
id -= TASK_RESET

if(!is_player(id, 1))
return
if(!Get_BitVar(g_Had_Guillotine, id))
return

Set_BitVar(g_CanShoot, id)

if(get_player_weapon(id) != CSW_BASE)
return

set_player_nextattack(id, 0.75)
set_weapons_timeidle(id, CSW_BASE, 0.75)

if(g_had2[id][AMMO]) 
{	
set_weapon_anim(id, 3)
PlaySound(id, sounds[0])
}
}
public Guillotine_Catch(id, Ent)
{
// Remove Entity
remove_entity(Ent)
g_had2[id][MYWEAPON] = -1

// Reset Player
if(get_player_weapon(id) == CSW_BASE && Get_BitVar(g_Had_Guillotine, id))
{
static Clip; Clip = zb5_had_StrongLife(id)? 15: 10	
g_had2[id][AMMO] = min(g_had2[id][AMMO] + 1, Clip)
update_ammo(id, -1, g_had2[id][AMMO])

create_fake_attack(id, WEAPON_ANIMEXT2)
set_weapons_headshot(id, 0)

set_player_nextattack(id, 1.0)
set_weapons_timeidle(id, CSW_BASE, 1.0)

set_weapon_anim(id, 7)
Set_BitVar(g_CanShoot, id)
UnSet_BitVar(g_Hit, id)

emit_sound(id, CHAN_WEAPON, sounds[0], 1.0, 0.4, 0, 94 + random_num(0, 15))
} else {
emit_sound(id, CHAN_WEAPON, sounds[3], 1.0, 0.4, 0, 94 + random_num(0, 15))
Set_BitVar(g_CanShoot, id)
UnSet_BitVar(g_Hit, id)
}
}
public HandleShot_Guillotine(id)
{
if(get_pdata_float(id, 83, 5) > 0.0)
return
if(g_had2[id][AMMO] <= 0)
return
if(!Get_BitVar(g_CanShoot, id))
return

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!pev_valid(Ent)) return		

UnSet_BitVar(g_CanShoot, id)
create_fake_attack(id, WEAPON_ANIMEXT2)

set_weapon_anim(id, 2)
emit_sound(id, CHAN_WEAPON, sounds[5], 1.0, 0.4, 0, 94 + random_num(0, 15))

Create_Guillotine(id)

set_player_nextattack(id, 0.5)
set_weapons_timeidle(id, CSW_BASE, 0.5)

g_had2[id][AMMO]--
update_ammo(id, -1, g_had2[id][AMMO])
}

public Create_Guillotine(id)
{
static iEnt; iEnt = create_entity("info_target")
if(!is_valid_ent(iEnt))
return

static Float:Origin[3], Float:TargetOrigin[3], Float:Velocity[3], Float:Angles[3]

get_weapon_attachment(id, Origin, 0.0)
Origin[2] -= 10.0
get_position(id, 1024.0, 0.0, 0.0, TargetOrigin)

entity_get_vector(id, EV_VEC_angles, Angles)
Angles[0] *= -1.0

// set info for ent
entity_set_string(iEnt, EV_SZ_classname, GUILLOTINE_CLASSNAME)
entity_set_model(iEnt, models[1])

entity_set_vector(iEnt, EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(iEnt, EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(iEnt, Origin)
entity_set_vector(iEnt, EV_VEC_angles, Angles)
entity_set_float(iEnt, EV_FL_gravity, 0.01)

entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER)

entity_set_edict(iEnt, EV_ENT_owner, id);
entity_set_int(iEnt, pev_eteam, get_user_team(id));

entity_set_int(iEnt, pev_return, 0)
entity_set_int(iEnt, pev_extra, 0)
entity_set_int(iEnt, pev_enemy, 0)

entity_set_float(iEnt, EV_FL_fuser2, get_gametime() + 8.0) 

get_speed_vector(Origin, TargetOrigin, FLYING_SPEED, Velocity)
entity_set_vector(iEnt, EV_VEC_velocity, Velocity) 

entity_set_float(iEnt, EV_FL_nextthink, halflife_time() + 0.1) 

g_had2[id][MYWEAPON] = iEnt

// Animation
entity_set_float(iEnt, EV_FL_animtime, get_gametime())
entity_set_float(iEnt, EV_FL_framerate, 2.0)
entity_set_int(iEnt, EV_INT_sequence, 0)
}

public update_ammo(Id, Ammo, BpAmmo)
{
static weapon_ent; weapon_ent = fm_get_user_weapon_entity(Id, CSW_BASE)
if(is_valid_ent(weapon_ent))
{
if(BpAmmo > 0) cs_set_weapon_ammo(weapon_ent, 1)
else cs_set_weapon_ammo(weapon_ent, 0)
}

engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0, 0, 0}, Id)
write_byte(1)
write_byte(CSW_BASE)
write_byte(Ammo)
message_end()

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, Id)
write_byte(10)
write_byte(BpAmmo)
message_end()

cs_set_user_bpammo(Id, CSW_BASE, BpAmmo)
}
stock Hook_The_Fucking_Ent(ent, Float:TargetOrigin[3], Float:Speed)
{
static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time

pev(ent, pev_origin, EntOrigin)

distance_f = get_distance_f(EntOrigin, TargetOrigin)
fl_Time = distance_f / Speed

pev(ent, pev_velocity, fl_Velocity)

fl_Velocity[0] = (TargetOrigin[0] - EntOrigin[0]) / fl_Time
fl_Velocity[1] = (TargetOrigin[1] - EntOrigin[1]) / fl_Time
fl_Velocity[2] = (TargetOrigin[2] - EntOrigin[2]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
}
public Check_AttackDamge(Ent, Float:Ratio, Float:ZombieDamage)
{
if(!is_valid_ent(Ent))
return

static Attacker;Attacker = pev(Ent, pev_owner)	

if(!is_player(Attacker, 1))
return

static Float:origin[3]
pev(Ent, pev_origin, origin)
	
static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, Ratio)) != 0)
{
if(Attacker == Victim)
continue;
		
do_attack(Attacker, Victim, 0, ZombieDamage, 0)
}
}
stock SPR(id)	
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
write_string("weapon_dripper_MSBG")
write_byte(10)
write_byte(120)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(11)
write_byte(23)
write_byte(0)
message_end()	
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
public zb5_weapon_remove_post(id)Reset_All(id)

Register_SafetyFunc()
{
register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")

RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Reset_All(id)

Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
}

Safety_Disconnected(id)
{
Reset_All(id)

UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
}

public Safety_CurWeapon(id)
{
if(!is_player(id, 1))
return

static CSW; CSW = read_data(2)
if(g_PlayerWeapon[id] != CSW) g_PlayerWeapon[id] = CSW
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

Reset_All(id)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id)
}

public fw_Safety_Killed_Post(id)
{
Reset_All(id)
	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)

Reset_All(id)
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(Get_BitVar(g_IsZombie, id))
return 0
if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}

return 1
}

public get_player_weapon(id)
{
if(!is_player(id, 1))
return 0

return g_PlayerWeapon[id]
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
