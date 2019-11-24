#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define CSW_BASE CSW_P90
#define weapon_base "weapon_p90"

#define CANNONFIRE_CLASSNAME "cannon_fire"
#define SPEAR_CLASSNAME "spear"

#define TASK_RELOAD 13320141
#define WEAPON_ANIMEXT "mp5"

new const sound[][] =
{
"ZB5/weapons/cannon_draw.wav",
"ZB5/weapons/cannon-1.wav",
"ZB5/weapons/speargun_hit.wav",
"ZB5/weapons/speargun_stone1.wav"
}
new const models[][] =
{
"models/ZB5/Primary/v_cannon.mdl",
"models/ZB5/Primary/v_spear.mdl",
"sprites/ZB5/fire.spr"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud69.spr",
"sprites/ZB5/HUD2/640hud103.spr",		
"sprites/weapon_cannon_MSBG.txt",
"sprites/weapon_spear_MSBG.txt"
}

enum Weapons
{
INVALID = 0,	
CANNON,	
SPEAR
}
enum _:Options
{
Float:LastShoot,	
SPEAR_ENT,	
ATTACK,
AMMO,
Old
}

const pev_user = pev_iuser1
const pev_touched = pev_iuser2
const pev_attached = pev_iuser3
const pev_hitgroup = pev_iuser4
const pev_time = pev_fuser1
const pev_time2 = pev_fuser2
const pev_time3 = pev_fuser3

new Weapons:g_had[33], g_had2[33][Options], g_smokepuff_id, g_weapon[2], ef_sprite[5]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33], g_MaxPlayers

public plugin_init() 
{
if(!zb5_weapons_primary())
return

Register_SafetyFunc()	
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")

register_think(CANNONFIRE_CLASSNAME, "fw_Cannon_Think")
register_touch(CANNONFIRE_CLASSNAME, "*", "fw_Cannon_Touch")

register_think(SPEAR_CLASSNAME, "fw_SpearThink")
register_touch(SPEAR_CLASSNAME, "*", "fw_SpearTouch")

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_AddToPlayer_Post", 1)
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_Weapon_WeaponIdle_Post", 1)

register_forward(FM_CmdStart, "fw_CmdStart")
register_forward(FM_SetModel, "fw_SetModel")
g_MaxPlayers = get_maxplayers()

g_weapon[0] = zb5_register_weapon("Dragon Cannon", "\rFire Power", WPN_DESTROYERS, LEVEL_CANNON, 1)
g_weapon[1] = zb5_register_weapon("Spear Gun", "\rFire Power", WPN_DESTROYERS, LEVEL_CANNON, 1)	
}
public plugin_precache()
{	
new i	
for(i = 0; i < sizeof(models); i++)
PrecacheModel(models[i])
for(i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])
for(i = 0; i < sizeof(sprites); i++)
PrecacheGeneric(sprites[i])

register_clcmd("weapon_cannon_MSBG", "Hook_SPR")
register_clcmd("weapon_spear_MSBG", "Hook_SPR")

ef_sprite[0] = PrecacheModel("sprites/smokepuff.spr")
ef_sprite[1] = PrecacheModel("sprites/ZB5/explodeup.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/SpearExp.spr")
ef_sprite[3] = PrecacheModel("sprites/laserbeam.spr")
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}

public plugin_natives()
{
register_native("get_weapon_flameguns", "Get_WPN", 1)	
}

public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0])Get_WPN(id, 1)
else if(wpnid == g_weapon[1])Get_WPN(id, 2)
}
public Get_WPN(id, Weapon)
{
if(!zb5_weapons_primary())
return

drop_weapons(id, 1);
Reset_All(id)

fm_give_item(id, weapon_base)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) 
return

switch(Weapon)
{
case 1:
{
g_had[id] = CANNON
SPR(id, "weapon_cannon_MSBG")	
}
case 2:
{
g_had[id] = SPEAR	
SPR(id, "weapon_spear_MSBG")	
}
}

cs_set_weapon_ammo(Ent, 0)
set_weapon_anim(id, 3)

Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_BASE)
zp_fw_restock_ammo(id)	
}
public zp_fw_restock_ammo(id)
{	
static Weapons:had 	
had  = g_had[id]	

if(had == INVALID) 
return;

cs_set_user_bpammo(id, CSW_BASE, zb5_had_StrongLife(id) ? 25:20)

if(get_player_weapon(id) == CSW_BASE)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
}

public Reset_All(id)
{	
arrayset(_:g_had[id], false, sizeof(g_had[]))		
arrayset(_:g_had2[id], false, sizeof(g_had2[]))	
}
public Deploy_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static id; id = get_pdata_cbase(Ent, 41, 4)
if(!is_player(id, 1))
return

static SubModel

static Weapons:had
had = g_had[id] 

switch(had)
{
case CANNON:
{
SubModel = 3
set_pev(id, pev_viewmodel2, models[0])
}
case SPEAR:
{
SubModel = 31
set_pev(id, pev_viewmodel2, models[1])
}
}
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
public event_CurWeapon(id)
{
if(!is_player(id, 1))
return

static Weapons:had
had = g_had[id] 

if((get_player_weapon(id) == CSW_BASE && g_had2[id][Old] != CSW_BASE) && had != INVALID)
{
Draw_NewWeapon(id, get_player_weapon(id))
} 

else if((get_player_weapon(id) == CSW_BASE && g_had2[id][Old] == CSW_BASE) && had != INVALID) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent))
{
g_had2[id][Old] = get_player_weapon(id)
return
}
} 

else if(get_player_weapon(id) != CSW_BASE && g_had2[id][Old] == CSW_BASE) 
{
Draw_NewWeapon(id, get_player_weapon(id))
}

g_had2[id][Old] = get_player_weapon(id)
}
public Draw_NewWeapon(id, CSW_ID)
{
if(!is_player(id, 1))
return	
static Weapons:had
had = g_had[id] 

static ent; ent = fm_get_user_weapon_entity(id, CSW_BASE)

if(CSW_ID == CSW_BASE)
{
if(is_valid_ent(ent) && had != INVALID)
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

static Submodel, Sequence;

switch(had)
{
case CANNON:
{
Submodel = 3;Sequence = 2
set_weapon_anim(id, 3)	
}
case SPEAR:
{
Submodel = 31;Sequence = 29
if(g_had2[id][AMMO] > 0) set_weapon_anim(id, 3)
else set_weapon_anim(id, 4)
}
}

engfunc(EngFunc_SetModel, ent, P_Model)		
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)	


set_weapons_timeidle(id, CSW_BASE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
}
} else {

if(is_valid_ent(ent)) 
set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 			
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

if(!equal(model, "models/w_p90.mdl"))
return FMRES_IGNORED

static weapon
weapon = fm_find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED

static Weapons:had
had = g_had[id] 

switch(had)
{
case CANNON:
{
set_pev(weapon, pev_impulse, CANNON)
set_pev(weapon, pev_iuser4, cs_get_user_bpammo(id, CSW_BASE))
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 11 - 1)
Reset_All(id)
return FMRES_SUPERCEDE
}
case SPEAR:
{
set_pev(weapon, pev_impulse, SPEAR)
set_pev(weapon, pev_iuser4, cs_get_user_bpammo(id, CSW_BASE))
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 33 - 1)
Reset_All(id)
return FMRES_SUPERCEDE
}
}

return FMRES_IGNORED
}
public fw_AddToPlayer_Post(ent, id)
{
if(!is_valid_ent(ent))
return 

static impulse; impulse = pev(ent, pev_impulse)
switch(impulse)
{
case CANNON:
{
Reset_All(id)
g_had[id] = CANNON

cs_set_user_bpammo(id, CSW_BASE, pev(ent, pev_iuser4))
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

SPR(id, "weapon_cannon_MSBG")	
set_pev(ent, pev_impulse, 0)
}
case SPEAR:
{
Reset_All(id)
g_had[id] = SPEAR

cs_set_user_bpammo(id, CSW_BASE, pev(ent, pev_iuser4))
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

SPR(id, "weapon_spear_MSBG")
set_pev(ent, pev_impulse, 0)
}
}	
}
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had == INVALID)
return FMRES_IGNORED

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)

switch(had)
{
case CANNON:
{
if(CurButton & IN_ATTACK)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(get_pdata_float(id, 83, 5) <= 0.0 && get_gametime() - 3.5 > g_had2[id][LastShoot])
{
if(cs_get_user_bpammo(id, CSW_BASE) <= 0)
{
return FMRES_HANDLED
}

cs_set_user_bpammo(id, CSW_BASE, cs_get_user_bpammo(id, CSW_BASE) - 1)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

Set_1st_Attack(id)
set_task(0.1, "Set_2nd_Attack", id)
g_had2[id][LastShoot] = get_gametime()
}
}
}

case SPEAR:
{
if(CurButton & IN_ATTACK)
{
if(get_pdata_float(id, 83, 5) > 0.0)
return FMRES_IGNORED

CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(get_gametime() - 2.5 > g_had2[id][LastShoot])
{
Spear_Shooting(id)
g_had2[id][LastShoot] = get_gametime()
}
} 
else if(CurButton & IN_ATTACK2) 
{
CurButton &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, CurButton)

if(!g_had2[id][ATTACK])
return FMRES_IGNORED

if(pev_valid(g_had2[id][SPEAR_ENT]))
{
SpearExplosion(g_had2[id][SPEAR_ENT], 1)
set_pev(g_had2[id][SPEAR_ENT], pev_flags, FL_KILLME)

g_had2[id][ATTACK] = false
}
}
}
}
return FMRES_HANDLED
}
/// CANNON ////
public Set_1st_Attack(id)
{
create_fake_attack(id, WEAPON_ANIMEXT)
Create_FireSystem(id, 1)

set_weapon_anim(id, random_num(1,2))
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/cannon-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	
Make_PunchAngle(id, random_float(-6.0, -10.0), random_float(6.0, 7.0))
}

public Set_2nd_Attack(id)
{
Create_FireSystem(id, 1)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/cannon-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Sprite(id, g_smokepuff_id, 9, 20, 30, 10,  -5)

set_weapon_anim(id, random_num(1,2))
set_player_nextattack(id, 3.5)
set_pdata_float(id, 83, 3.5, 5)	
}

/// SPEAR GUN ////
public Spear_Shooting(id)
{
if(cs_get_user_bpammo(id, CSW_BASE) <= 0)
return

g_had2[id][ATTACK] = true
create_fake_attack(id, WEAPON_ANIMEXT)

cs_set_user_bpammo(id, CSW_BASE, cs_get_user_bpammo(id, CSW_BASE) - 1)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

set_weapon_anim(id, 1)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/speargun_hit.wav", 1.0, 0.4, 0, 94 + random_num(0, 15))
Make_PunchAngle(id, random_float(-3.5, -7.0), 0.0)

set_player_nextattack(id, 2.5)
set_weapons_timeidle(id, CSW_BASE, 2.5)

Create_Spear(id)
set_task(1.0, "Play_ReloadAnim", id+TASK_RELOAD)
}

public Play_ReloadAnim(id)
{
id -= TASK_RELOAD

if(!is_player(id, 1))
return

set_weapon_anim(id, 2)
}
// FLAME EFFECT
public Create_FireSystem(id, OffSet)
{
const MAX_FIRE = 10
static Float:StartOrigin[3], Float:TargetOrigin[MAX_FIRE][3], Float:Speed[MAX_FIRE], Float:RTime[MAX_FIRE], i

// -- Left
get_position(id, 100.0, 2.0, 2.0, TargetOrigin[0]); Speed[0] = 700.0; RTime[0] = 0.8
get_position(id, 100.0,	6.0, 2.0, TargetOrigin[1]); Speed[1] = 700.0; RTime[1] = 0.8
get_position(id, 100.0, 8.0, 3.0, TargetOrigin[2]); Speed[2] = 700.0; RTime[2] = 0.8
get_position(id, 100.0, 10.0, 3.0, TargetOrigin[3]); Speed[3] = 700.0; RTime[3] = 0.8

// -- Center
get_position(id, 100.0, 12.0, 0.0, TargetOrigin[4]); Speed[4] = 900.0; RTime[4] = 0.01 
get_position(id, 100.0, -12.0, 0.0, TargetOrigin[5]); Speed[5] = 900.0; RTime[5] = 0.01

// -- Right
get_position(id, 100.0, -2.0 , 2.0, TargetOrigin[6]); Speed[6] = 700.0; RTime[6] = 0.8
get_position(id, 100.0, -6.0, 2.0, TargetOrigin[7]); Speed[7] = 700.0; RTime[7] = 0.8
get_position(id, 100.0,	-8.0, 3.0, TargetOrigin[8]); Speed[8] = 700.0; RTime[8] = 0.8
get_position(id, 100.0,	-10.0, 3.0, TargetOrigin[9]); Speed[9] = 700.0; RTime[9] = 0.8


for(i = 0; i < MAX_FIRE; i++)
{
get_position(id, random_float(20.0, 60.0), 0.0, -5.0, StartOrigin)
create_fire(id, StartOrigin, TargetOrigin[i], Speed[i], RTime[i], OffSet)
}
}

public create_fire(id, Float:Origin[3], Float:TargetOrigin[3], Float:Speed, Float:RTime, OffSet)
{
static ent; ent = create_entity("info_target")
if(!is_valid_ent(ent))
return;

static Float:vfAngle[3], Float:MyOrigin[3], Float:Velocity[3]
entity_get_vector(id, EV_VEC_angles, vfAngle)
entity_get_vector(id, EV_VEC_origin, MyOrigin)
vfAngle[2] = float(random(18) * 20)

entity_set_string(ent, EV_SZ_classname, CANNONFIRE_CLASSNAME)
entity_set_model(ent,"sprites/ZB5/fire.spr")

entity_set_int(ent,EV_INT_iuser1, id)	
entity_set_int(ent,EV_INT_iuser4, OffSet)

entity_set_int(ent,EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(ent,EV_INT_solid, SOLID_TRIGGER)

entity_set_int(ent,EV_INT_rendermode, kRenderTransAdd)
entity_set_float(ent,EV_FL_renderamt, 70.0)

entity_set_vector(ent,EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(ent,EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(ent, Origin)
entity_set_vector(ent, EV_VEC_angles, vfAngle)

get_speed_vector(Origin, TargetOrigin, Speed, Velocity)
entity_set_vector(ent, EV_VEC_velocity, Velocity) 

entity_set_float(ent, EV_FL_fuser1, get_gametime() + RTime) 
entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.05) 
}

public fw_Cannon_Think(ent)
{
if(!is_valid_ent(ent)) 
return

static Float:fFrame; fFrame = entity_get_float(ent, EV_FL_frame) 

fFrame += 1.5
fFrame = floatmin(21.0, fFrame)

entity_set_float(ent, EV_FL_frame, fFrame) 
entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.05) 

// time remove
static Float:fTimeRemove; fTimeRemove = entity_get_float(ent,EV_FL_fuser1)
static Float:Amount; Amount = entity_get_float(ent,EV_FL_renderamt)

if(get_gametime() >= fTimeRemove) 
{
Amount -= 10.0
entity_set_float(ent,EV_FL_renderamt, Amount)

if(Amount <= 15.0) 
remove_entity(ent)
}
}
public fw_Cannon_Touch(ent, id)
{
if(!is_valid_ent(ent))
return

static Classname[32]
pev(id, pev_classname, Classname, sizeof(Classname))

if(equal(Classname, CANNONFIRE_CLASSNAME)) 
return

entity_set_int(ent,EV_INT_movetype, MOVETYPE_NONE)
entity_set_int(ent,EV_INT_solid, SOLID_NOT)

static Attacker; Attacker = entity_get_int(ent,EV_INT_iuser1)

if(is_player(Attacker, 0))
{
if(Get_BitVar(g_IsZombie, id))
{
set_weapon_kick(Attacker, id, 1000.0)
zb5_make_burn(id, Attacker, 6.0, 0.5, "sprites/ZB5/flame_burn01.spr")
}
do_attack(Attacker, id, 0, random_float(50.0, 200.0), 0)
}
}

////// SPEAR ARROW SYSTEM //////
public Create_Spear(id)
{
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent)) return

static Float:Origin[3], Float:Target[3], Float:Angles[3], Float:Velocity[3]

get_weapon_attachment(id, Origin, 0.0)
get_position(id, 1024.0, 0.0, 0.0, Target)

entity_get_vector(id, EV_VEC_angles, Angles); Angles[0] *= -1.0

// Set info for ent
entity_set_string(Ent, EV_SZ_classname, SPEAR_CLASSNAME)
entity_set_model(Ent,"models/ZB5/Items/ZB5_Items_NEW.mdl")
set_pev(Ent, pev_body, 9 - 1)
set_pev(Ent, pev_sequence, 7)

entity_set_vector(Ent, EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(Ent, EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, Angles)
entity_set_float(Ent, EV_FL_gravity, 0.01)

entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(Ent, EV_INT_solid, SOLID_TRIGGER)

set_pev(Ent, pev_user, id)
set_pev(Ent, pev_touched, 0)
set_pev(Ent, pev_time, 0.0)
set_pev(Ent, pev_time2, get_gametime() + 5.0)
set_pev(Ent, pev_hitgroup, -1)

entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.01) 

get_speed_vector(Origin, Target, float(1500), Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 

g_had2[id][SPEAR_ENT] = Ent

// Create Beam
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(Ent)
write_short(ef_sprite[3])
write_byte(5)
write_byte(2)
write_byte(42)
write_byte(255)
write_byte(170)
write_byte(100)
message_end()
}

public fw_SpearThink(Ent)
{
if(!pev_valid(Ent))
return
if(pev(Ent, pev_flags) == FL_KILLME)
return

static Victim; Victim = pev(Ent, pev_attached)
static Owner; Owner = pev(Ent, pev_user)

if(!pev(Ent, pev_touched) && is_alive(Owner))
{
static i, Target; Target = 0
for(i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue
if(entity_range(Ent, i) > 24.0)
continue

Target = i
break
}

if(Get_BitVar(g_IsAlive, Target) && Target != Owner)
{
// Check hitgroup
static Float:HeadOrigin[3], Float:HeadAngles[3];
engfunc(EngFunc_GetBonePosition, Target, 8, HeadOrigin, HeadAngles);

static Float:EntOrigin[3]
pev(Ent, pev_origin, EntOrigin)

if(get_distance_f(EntOrigin, HeadOrigin) <= 10.0) set_pev(Ent, pev_hitgroup, HIT_HEAD)
else set_pev(Ent, pev_hitgroup, HIT_CHEST)

// Handle
set_pev(Ent, pev_touched, 1)
set_pev(Ent, pev_time, get_gametime() + 3.0)
set_pev(Ent, pev_attached, Target)
}
}

if(is_alive(Victim))
{
static Float:Origin[3]; pev(Victim, pev_origin, Origin)
engfunc(EngFunc_SetOrigin, Ent, Origin)

static i
for(i = 0; i < g_MaxPlayers; i++)
{
if(Victim == i)
continue
if(!is_alive(i))
continue
if(entity_range(Victim, i) > 70.0)
continue

set_weapon_kick(Owner, Victim, 5000.0)
}
}

if(pev(Ent, pev_touched) && pev(Ent, pev_time) <= get_gametime())
{
SpearExplosion(Ent, 0)
set_pev(Ent, pev_flags, FL_KILLME)

static Owner; Owner = pev(Ent, pev_user)
g_had2[Owner][ATTACK] = false
}

if(pev(Ent, pev_time2) <= get_gametime())
{
set_pev(Ent, pev_flags, FL_KILLME)

static Owner; Owner = pev(Ent, pev_user)
g_had2[Owner][ATTACK] = false
}

set_pev(Ent, pev_nextthink, get_gametime() + 0.01)
}

public fw_SpearTouch(Ent, Touched)
{
if(!pev_valid(Ent))
return

static id; id = pev(Ent, pev_user)
if(!is_alive(id))
{
remove_entity(Ent)
return
}
if(pev(Ent, pev_touched))
return

if(!is_user_alive(Touched))
{
emit_sound(Ent, CHAN_BODY, "ZB5/weapons/speargun_stone1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_pev(Ent, pev_touched, 1)
set_pev(Ent, pev_time, get_gametime() + 3.0)
}
}
public SpearExplosion(Ent, Remote)
{
static Float:Origin[3]
pev(Ent, pev_origin, Origin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[1])
write_byte(20)
write_byte(90)
write_byte(TE_EXPLFLAG_NOSOUND)
message_end()

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_SPARKS)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
message_end()

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_TAREXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
message_end()

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[2])
write_byte(6)
write_byte(20)
write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND)
message_end()

static Id; Id = pev(Ent, pev_user)
if(is_user_connected(Id)) 
{
static Hitgroup; Hitgroup = pev(Ent, pev_hitgroup)
static Target; Target = pev(Ent, pev_attached)

Check_Damage(Ent, Id, Origin, Target)

if(is_user_alive(Target))
{

if(cs_get_user_team(Id) == cs_get_user_team(Target))
return


if(Hitgroup == HIT_HEAD) 
{
set_pdata_int(Target, 75, HIT_HEAD, 5)
ExecuteHamB(Ham_TakeDamage, Target, 0, Id, float(560) * 4.0, DMG_BURN)
} else {
set_pdata_int(Target, 75, HIT_CHEST, 5)
ExecuteHamB(Ham_TakeDamage, Target, 0, Id, float(560), DMG_BURN)
}
}
}

// Extra
if(Remote) SpearExplosion(Ent, 0)
}

public Check_Damage(Ent, id, Float:Origin[3], Except)
{
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue
if(entity_range(Ent, i) > 100.0)
continue
if(Except == i)
continue

if(id != i) 
ExecuteHamB(Ham_TakeDamage, i, 0, id, float(560) / 3.0, DMG_BURN)
set_weapon_kick(id, i, 500.0)
}
}


public fw_Weapon_WeaponIdle_Post(Ent)
{
if(!is_valid_ent(Ent))
return HAM_IGNORED	

static Id; Id = get_pdata_cbase(Ent, 41, 4)
if(get_pdata_cbase(Id, 373) != Ent)
return HAM_IGNORED	

if(g_had[Id] != SPEAR)
return HAM_IGNORED	

if(get_pdata_float(Ent, 48, 4) <= 0.1) 
{	
if(g_had2[Id][AMMO] > 0) set_weapon_anim(Id, 0)
else set_weapon_anim(Id, 5)

set_pdata_float(Ent, 48, 20.0, 4)
}

return HAM_IGNORED	
}

/////// END SPEAR ARROW ///////



public UpdateAmmo(Id, Ammo, BpAmmo)
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
write_byte(-1)
message_end()

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, Id)
write_byte(7)
write_byte(BpAmmo)
message_end()

cs_set_user_bpammo(Id, CSW_BASE, BpAmmo)
}
stock SPR(id, const weapon[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
write_string(weapon)
write_byte(7)
write_byte(100)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(8)
write_byte(30)
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
public is_alive(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0

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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
