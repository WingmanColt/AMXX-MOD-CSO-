#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>
#include <infinitygame>

#define CSW_PETROLBOOMER CSW_MAC10
#define weapon_petrolboomer "weapon_mac10"
#define WEAPON_ANIMEXT "rifle"

#define MOLOTOV_SPEED 750.0
#define TIME_DRAW 2.5
#define TIME_RELOAD 4.0

#define FIRE2_CLASSNAME "smallfire"
#define MOLOTOV_CLASSNAME "molotov"

new const models[][] =
{
"models/ZB5/Primary/v_petrolboomer.mdl",
"models/ZB5/Items/s_petrolboomer.mdl",
}
new const WeaponSounds[6][] = 
{
"ZB5/weapons/petrolboomer_shoot.wav",
"ZB5/weapons/petrolboomer_explosion.wav",
"ZB5/weapons/petrolboomer_idle.wav",
"ZB5/weapons/petrolboomer_reload.wav",
"ZB5/weapons/petrolboomer_draw.wav",
"ZB5/weapons/petrolboomer_draw_empty.wav"
}

new const WeaponResources[4][] = 
{
"sprites/ZB5/extra_fire2.spr",
"sprites/640hud13.spr",
"sprites/640hud108_2.spr",
"sprites/weapon_petrol_MSBG.txt"
}


enum
{
ANIM_IDLE = 0,
ANIM_SHOOT,
ANIM_RELOAD,
ANIM_DRAW,
ANIM_DRAW_EMPTY,
ANIM_IDLE_EMPTY
}

enum _:Options
{
FireEnt,
AMMO,
Old
}

new g_PB, g_Had_PB, g_had2[33][Options], ef_sprite[2]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]

public plugin_init()
{
if(!zb5_weapons_primary())
return
	
Register_SafetyFunc()
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")

register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")	

register_think(FIRE2_CLASSNAME, "fw_GroundFire_Think")
register_touch(MOLOTOV_CLASSNAME, "*", "fw_Touch_Molotov")

RegisterHam(Ham_Item_Deploy, weapon_petrolboomer, "Deploy_Post", 1)
RegisterHam(Ham_Item_AddToPlayer, weapon_petrolboomer, "fw_Item_AddToPlayer_Post", 1)
RegisterHam(Ham_Weapon_WeaponIdle, weapon_petrolboomer, "fw_Weapon_WeaponIdle_Post", 1)

g_PB = zb5_register_weapon("Petrol Boomer", "\rFire \yGround", WPN_DESTROYERS, LEVEL_PETROL, 1)
}

public plugin_precache()
{
new i	

for(i = 0; i < sizeof(models); i++)
PrecacheModel(models[i])
for(i = 0; i < sizeof(WeaponSounds); i++)
PrecacheSound(WeaponSounds[i])

for(i = 0; i < sizeof(WeaponResources); i++)
{
if(i == 0) PrecacheModel(WeaponResources[i])
else PrecacheGeneric(WeaponResources[i])
}

ef_sprite[0] = PrecacheModel("sprites/zerogxplode.spr")
ef_sprite[1] = PrecacheModel("sprites/laserbeam.spr")
}
public zp_fw_round_new()
{
remove_entity_name(FIRE2_CLASSNAME)
remove_entity_name(MOLOTOV_CLASSNAME)		
}
public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_PB) 
Get_PB(id)
}
public Get_PB(id)
{
if(!zb5_weapons_primary())
return
	
Reset_All(id)
Set_BitVar(g_Had_PB, id)

fm_give_item(id, weapon_petrolboomer)
UpdateAmmo(id, CSW_PETROLBOOMER, 3, -1, g_had2[id][AMMO])

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_PETROLBOOMER)
if(!is_valid_ent(Ent)) 
return

Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_PETROLBOOMER)

SPR(id)	
zp_fw_restock_ammo(id)
IG_Muzzleflash_Set(id, "sprites/ZB5/explodeup.spr", 0.25)
}
public zp_fw_restock_ammo(id)
{	
if (!Get_BitVar(g_Had_PB, id)) 
return;

g_had2[id][AMMO] = zb5_had_StrongLife(id) ? 20 : 15

if(get_player_weapon(id) == CSW_PETROLBOOMER)
UpdateAmmo(id, CSW_PETROLBOOMER, 3, -1, g_had2[id][AMMO])
}
public Reset_All(id)
{		
UnSet_BitVar(g_Had_PB, id)

g_had2[id][FireEnt] = 0
g_had2[id][AMMO] = 0
}

public Deploy_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static id; id = get_pdata_cbase(Ent, 41, 4)
if(!is_player(id, 1))
return

if(!Get_BitVar(g_Had_PB, id))
return

static SubModel; SubModel = 28

set_pev(id, pev_viewmodel2, models[0])
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
public Event_CurWeapon(id)
{
if(!is_player(id, 1))
return

static CSWID; CSWID = get_player_weapon(id)
static SubModel; SubModel = 28

if((CSWID == CSW_PETROLBOOMER && g_had2[id][Old] != CSW_PETROLBOOMER) && Get_BitVar(g_Had_PB, id))
{
if(SubModel != -1) Draw_NewWeapon(id, CSWID)
} 

else if((CSWID == CSW_PETROLBOOMER && g_had2[id][Old] == CSW_PETROLBOOMER) && Get_BitVar(g_Had_PB, id)) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_PETROLBOOMER)
if(!is_valid_ent(Ent))
{
g_had2[id][Old] = get_player_weapon(id)
return
}
} 

else if(CSWID != CSW_PETROLBOOMER && g_had2[id][Old] == CSW_PETROLBOOMER) 
{
if(SubModel != -1)
Draw_NewWeapon(id, CSWID)
}

g_had2[id][Old] = get_player_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
if(!is_player(id, 1))
return	
static ent
ent = fm_get_user_weapon_entity(id, CSW_PETROLBOOMER)
	
if(CSW_ID == CSW_PETROLBOOMER)
{
if(is_valid_ent(ent) && Get_BitVar(g_Had_PB, id))
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 
engfunc(EngFunc_SetModel, ent, P_Model)	
set_pev(ent, pev_body, 28-1)
set_pev(ent, pev_sequence, 26)	

set_pdata_string(id, (492) * 4, WEAPON_ANIMEXT, -1 , 20)

set_weapons_timeidle(id, CSW_PETROLBOOMER, TIME_DRAW + 0.5)
set_player_nextattack(id, TIME_DRAW)

set_weapon_anim(id, g_had2[id][AMMO] ? ANIM_DRAW : ANIM_DRAW_EMPTY)
UpdateAmmo(id, CSW_PETROLBOOMER, 3, -1, g_had2[id][AMMO])

}
} else {

if(is_valid_ent(ent)) 
set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 	
}
}

public fw_Item_AddToPlayer_Post(ent, id)
{
if(!is_valid_ent(ent))
return 

if(pev(ent, pev_impulse) == 5555)
{
Reset_All(id)
SPR(id)	

Set_BitVar(g_Had_PB, id)
g_had2[id][AMMO] = pev(ent, pev_iuser4)

UpdateAmmo(id, CSW_PETROLBOOMER, 3, -1, g_had2[id][AMMO])
IG_Muzzleflash_Set(id, "sprites/ZB5/explodeup.spr", 0.25)

set_pev(ent, pev_impulse, 0)
}	
}

public fw_SetModel(entity, model[])
{
if(!is_valid_ent(entity))
return FMRES_IGNORED

static szClassName[33]
pev(entity, pev_classname, szClassName, charsmax(szClassName))

if(!equal(szClassName, "weaponbox"))
return FMRES_IGNORED

static id; id = pev(entity, pev_owner)

if(equal(model, "models/w_mac10.mdl"))
{
static weapon
weapon = fm_find_ent_by_owner(-1, weapon_petrolboomer, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED

if(Get_BitVar(g_Had_PB, id))
{
set_pev(weapon, pev_impulse, 5555)
set_pev(weapon, pev_iuser4, g_had2[id][AMMO])
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 31 - 1)
Reset_All(id)	
return FMRES_SUPERCEDE
}
}

return FMRES_IGNORED
}
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED

if(get_player_weapon(id) != CSW_PETROLBOOMER || !Get_BitVar(g_Had_PB, id))
return FMRES_IGNORED

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)
if(CurButton & IN_ATTACK)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

PetrolBoomer_AttackHandle(id)
return FMRES_IGNORED
}
return FMRES_HANDLED
}
public PetrolBoomer_AttackHandle(id)
{
if(get_pdata_float(id, 83, 5) > 0.0)
return
if(!g_had2[id][AMMO])
{
set_pdata_float(id, 83, 1.0, 5)
set_weapon_anim(id, ANIM_IDLE_EMPTY)

return
}

g_had2[id][AMMO]--
UpdateAmmo(id, CSW_PETROLBOOMER, 3, -1, g_had2[id][AMMO])

IG_Muzzleflash_Activate(id)
create_fake_attack(id, WEAPON_ANIMEXT)

set_weapon_anim(id, ANIM_SHOOT)
set_task(0.5, "ReloadAnim", id)


emit_sound(id, CHAN_WEAPON, WeaponSounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

Create_Molotov(id)
Make_PunchAngle(id, random_float(-1.0, -14.0), random_float(1.0, -10.0))

set_player_nextattack(id, TIME_RELOAD)
set_weapons_timeidle(id, CSW_PETROLBOOMER, TIME_RELOAD)
}

public ReloadAnim(id)
{
if(!is_player(id, 1))
return 

if(get_player_weapon(id) != CSW_PETROLBOOMER || !Get_BitVar(g_Had_PB, id))
return	

set_weapon_anim(id, ANIM_RELOAD)
}

public Create_Molotov(id)
{
static Float:StartOrigin[3], Float:EndOrigin[3], Float:Angles[3]

get_position(id, 48.0, 8.0, 5.0, StartOrigin)
get_position(id, 1024.0, 0.0, 0.0, EndOrigin)
entity_get_vector(id, EV_VEC_angles, Angles)

Angles[0] *= -1

static Molotov; Molotov = create_entity("info_target")
if(!is_valid_ent(Molotov))
return

entity_set_int(Molotov, EV_INT_movetype, MOVETYPE_PUSHSTEP)
entity_set_int(Molotov, EV_INT_solid, SOLID_BBOX)

entity_set_int(Molotov,EV_INT_iuser1, id)	
entity_set_int(Molotov,EV_INT_iuser2, 0)	
entity_set_int(Molotov,EV_INT_iuser3, 0)	
entity_set_int(Molotov,EV_INT_iuser4, 0)	

entity_set_string(Molotov, EV_SZ_classname, MOLOTOV_CLASSNAME)
entity_set_model(Molotov, models[1])

entity_set_vector(Molotov, EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(Molotov, EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(Molotov, StartOrigin)
entity_set_vector(Molotov, EV_VEC_angles, Angles)
entity_set_float(Molotov, EV_FL_gravity, 1.0)

entity_set_float(Molotov, EV_FL_nextthink, halflife_time() + 0.1) 

static Float:Velocity[3]
get_speed_vector(StartOrigin, EndOrigin, MOLOTOV_SPEED, Velocity)
entity_set_vector(Molotov, EV_VEC_velocity, Velocity) 

// Make a Beam
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(Molotov) // entity
write_short(ef_sprite[1]) // sprite
write_byte(20)  // life
write_byte(4)  // width
write_byte(200) // r
write_byte(200);  // g
write_byte(200);  // b
write_byte(200); // brightness
message_end();
}
public fw_Touch_Molotov(Ent, Id)
{
if(!is_valid_ent(Ent))
return

if(entity_get_int(Ent,EV_INT_movetype)  == MOVETYPE_NONE)
return

static Attacker; Attacker = entity_get_int(Ent,EV_INT_iuser1)
if(!is_player(Attacker, 0))
{
remove_entity(Ent)
return
}

Check_AttackDamge(Ent, Attacker, 50.0,  random_float(300.0, 600.0))
Create_GroundFire(Attacker, Ent)

entity_set_int(Ent,EV_INT_movetype, MOVETYPE_NONE)
entity_set_int(Ent,EV_INT_solid, SOLID_NOT)

emit_sound(Ent, CHAN_BODY, WeaponSounds[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
engfunc(EngFunc_RemoveEntity, Ent)	
}
public Create_GroundFire(Owner, Ent)
{
static Float:Origin[3]
entity_get_vector(Ent, EV_VEC_origin, Origin)

message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[0])	// sprite index
write_byte(70)	// scale in 0.1's
write_byte(30)	// framerate
write_byte(0)	// flags
message_end()


static Float:FireOrigin[4][3], i

get_position(Ent, 64.0, 0.0, 0.0, FireOrigin[0])
get_position(Ent, 0.0, 0.0, 0.0, FireOrigin[1])
get_position(Ent, -64.0, 0.0, 0.0, FireOrigin[2])

for(i = 0; i < 4; i++)
Create_SmallFire(Owner, FireOrigin[i], Ent)
}

public Create_SmallFire(Owner, Float:Origin[3], Master)
{
static Ent; Ent = create_entity("env_sprite")
if(!is_valid_ent(Ent)) return

// Set info for ent
entity_set_int(Ent,EV_INT_rendermode, kRenderTransAdd)
entity_set_float(Ent,EV_FL_renderamt, 100.0)
entity_set_float(Ent,EV_FL_scale, random_float(1.0, 2.70))

entity_set_string(Ent, EV_SZ_classname, FIRE2_CLASSNAME)
entity_set_model(Ent, WeaponResources[0])

entity_set_vector(Ent, EV_VEC_mins, Float:{-16.0, -16.0, -6.0})
entity_set_vector(Ent, EV_VEC_maxs, Float:{16.0, 16.0, 36.0})
entity_set_vector(Ent, EV_VEC_origin, Origin)

entity_set_int(Ent,EV_INT_iuser1, Owner)	
entity_set_int(Ent,EV_INT_iuser2, pev(Master, pev_iuser2))	

entity_set_float(Ent, EV_FL_gravity, 0.01)
entity_set_float(Ent, EV_FL_frame, 0.0)

entity_set_int(Ent,EV_INT_movetype, MOVETYPE_PUSHSTEP)
entity_set_int(Ent,EV_INT_solid, SOLID_TRIGGER)

entity_set_float(Ent, EV_FL_fuser1, get_gametime() + 7.0) 
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.01) 
}

public fw_GroundFire_Think(ent)
{
if(!is_valid_ent(ent))
return

static Float:fFrame; fFrame = entity_get_float(ent, EV_FL_frame) 
static Attacker; Attacker = entity_get_int(ent,EV_INT_iuser1)
static Float:fTimeRemove; fTimeRemove = entity_get_float(ent,EV_FL_fuser1)

fFrame += random_float(0.5, 1.0)
if(fFrame >= 14.0) fFrame = 0.0
set_pev(ent, pev_frame, fFrame)

if(get_gametime() - 1.0 > entity_get_float(ent,EV_FL_fuser2))
{
Check_AttackDamge(ent, Attacker, 100.0,  random_float(50.0, 100.0))
entity_set_float(ent, EV_FL_fuser2, get_gametime())
}	

if(get_gametime() >= fTimeRemove)
{
remove_entity(ent)
return
}

entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.06) 
}

public Check_AttackDamge(Ent, Attacker, Float:Ratio, Float:ZombieDamage)
{	
if(!is_valid_ent(Ent) && !is_player(Attacker, 0))
return
		
static Float:origin[3]
pev(Ent, pev_origin, origin)
	
static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, Ratio)) != 0)
{
if(Attacker == Victim)
continue;

do_attack(Attacker, Victim, 0, ZombieDamage, 1)	
}
}

public fw_Weapon_WeaponIdle_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static Id; Id = get_pdata_cbase(Ent, 41, 4)
if(get_player_weapon(Id) != CSW_PETROLBOOMER || !Get_BitVar(g_Had_PB, Id))
return

if(get_pdata_float(Ent, 48, 4) <= 0.1) 
{
set_weapon_anim(Id, g_had2[Id][AMMO] ? ANIM_IDLE : ANIM_IDLE_EMPTY)
set_pdata_float(Ent, 48, 20.0, 4)
}

return
}
public UpdateAmmo(id, CSWID, AmmoID, Ammo, BpAmmo)
{
static weapon_ent; weapon_ent = fm_get_user_weapon_entity(id, CSW_PETROLBOOMER)
if(is_valid_ent(weapon_ent))
{
if(BpAmmo > 0) cs_set_weapon_ammo(weapon_ent, 1)
else cs_set_weapon_ammo(weapon_ent, 0)
}

engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0, 0, 0}, id)
write_byte(6)
write_byte(CSWID)
write_byte(Ammo)
message_end()

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, id)
write_byte(AmmoID)
write_byte(BpAmmo)
message_end()

cs_set_user_bpammo(id, CSWID, BpAmmo)
}

stock SPR(id)	
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
write_string("weapon_petrol_MSBG")
write_byte(6)
write_byte(100)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(13)
write_byte(7)
write_byte(0)
message_end()	
}

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_weapon_remove_post(id)Reset_All(id)

public client_putinserver(id)
{
Safety_Connected(id)

if(!g_HamBot && is_user_bot(id))
{
g_HamBot = 1
set_task(0.1, "Register_SafetyFuncBot", id)
}
}

Register_SafetyFunc()
{
register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")

RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

public Register_SafetyFuncBot(id)
{
RegisterHamFromEntity(Ham_Spawn, id, "fw_Safety_Spawn_Post", 1)
RegisterHamFromEntity(Ham_Killed, id, "fw_Safety_Killed_Post", 1)
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
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
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

Reset_All(id)

Set_BitVar(g_IsZombie, id)
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

