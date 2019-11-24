#include <amxmodx>
#include <engine>
#include <fakemeta_util>
#include <cstrike>
#include <hamsandwich>
#include <zp50_core>

#define FIRE_CLASSNAME "fire"
#define CSW_FLAMEGUN CSW_M249	
#define weapon_flamegun "weapon_m249"
const pev_ammo = pev_iuser4
new g_had_flamegun[33], Float:g_PunchAngles[33][3], g_orig_event_m249
public plugin_init()
{
register_event("CurWeapon", "Event_CheckWeapon", "be", "1=1")
RegisterHam(Ham_Item_AddToPlayer, weapon_flamegun, "fw_item_addtoplayer", 1)
RegisterHam(Ham_Weapon_PrimaryAttack, weapon_flamegun, "fw_Weapon_PrimaryAttack")
RegisterHam(Ham_Weapon_PrimaryAttack, weapon_flamegun, "fw_Weapon_PrimaryAttack_Post", 1)
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack")
register_think(FIRE_CLASSNAME, "fw_Fire_Think")
register_touch(FIRE_CLASSNAME, "*", "fw_Fire_Touch")
register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")
}
public plugin_precache()
{	
register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
}
public fwPrecacheEvent_Post(type, const name[])
{
if (equal("events/m249.sc", name))
g_orig_event_m249 = get_orig_retval()
}
public plugin_natives()
{
register_native("give_weapon_flamegun", "native_give_flamegun_add", 1)
register_native("remove_weapon_flamegun", "native_remove_flamegun", 1)
register_native("zp_weapon_flamegun", "native_flamegun", 1)
}
public native_give_flamegun_add(id)
{	
if(!is_user_alive(id))
return

drop_weapons(id, 1)
g_had_flamegun[id] = true
fm_give_item(id, weapon_flamegun)	
cs_set_user_bpammo(id, CSW_FLAMEGUN, 200)
CURWPN(id)
}
public native_remove_flamegun(id)
{
g_had_flamegun[id] = false
remove_entity_name(FIRE_CLASSNAME)	
}
public native_flamegun(id) return g_had_flamegun[id]
public Event_CheckWeapon(id)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))
return
if(get_user_weapon(id) == CSW_FLAMEGUN)
{
if(g_had_flamegun[id])
{
set_pev(id, pev_viewmodel2, "models/ZPlague/Weapons/v_salamander.mdl")
set_pev(id, pev_weaponmodel2, "models/ZPlague/Weapons/p_salamander.mdl")
}
}
}

public fw_SetModel(entity, model[])
{
if(!pev_valid(entity))
return FMRES_IGNORED;

static szClassName[33]
pev(entity, pev_classname, szClassName, charsmax(szClassName))

if(!equal(szClassName, "weaponbox"))
return FMRES_IGNORED;

static iOwner
iOwner = pev(entity, pev_owner)

if(equal(model, "models/w_m249.mdl"))
{
static weapon
weapon = fm_get_user_weapon_entity(entity, CSW_FLAMEGUN)

if(!pev_valid(weapon))
return FMRES_IGNORED;

if(g_had_flamegun[iOwner])
{	
set_pev(weapon, pev_impulse, 918273)
g_had_flamegun[iOwner] = 0
engfunc(EngFunc_SetModel, entity, "models/ZPlague/Weapons/w_salamander.mdl")	
return FMRES_SUPERCEDE
}
}
return FMRES_IGNORED;
}

public fw_item_addtoplayer(ent, id)
{
if(!pev_valid(ent))
return HAM_IGNORED

if(pev(ent, pev_impulse) == 918273)
{
g_had_flamegun[id] = 1
CURWPN(id)
set_pev(ent, pev_impulse, 0)
return HAM_HANDLED
}	
return HAM_HANDLED
}
public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
if(!is_user_alive(id) || !is_user_connected(id))
return FMRES_IGNORED	
if(zp_core_is_zombie(id))
return FMRES_IGNORED
if(get_user_weapon(id) != CSW_FLAMEGUN || !g_had_flamegun[id])
return FMRES_IGNORED
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 

return FMRES_HANDLED
}
public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
if ((eventid != g_orig_event_m249))
return FMRES_IGNORED

if (!(1 <= invoker <= get_maxplayers()))
return FMRES_IGNORED

playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
return FMRES_SUPERCEDE
}
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_user_connected(id) || !is_user_alive(id))
return FMRES_IGNORED
if(get_user_weapon(id) != CSW_FLAMEGUN || !g_had_flamegun[id])
return FMRES_IGNORED

static PressedButton
PressedButton = get_uc(uc_handle, UC_Buttons)

if(!(PressedButton & IN_ATTACK))
{
if((pev(id, pev_oldbuttons) & IN_ATTACK) && pev(id, pev_weaponanim) == 1)
{
new clip,ammo 
get_user_ammo(id,CSW_FLAMEGUN,clip,ammo) 
if (clip <= 0) 
return FMRES_IGNORED
static weapon; weapon = fm_get_user_weapon_entity(id, CSW_FLAMEGUN)
if(pev_valid(weapon)) set_pdata_float(weapon, 48, 2.0, 4)
set_weapon_anim(id, 2)
}
}

return FMRES_HANDLED
}
public fw_TraceAttack(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{
if(!is_user_alive(Attacker))
return HAM_IGNORED
if(get_user_weapon(Attacker) != CSW_FLAMEGUN || !g_had_flamegun[Attacker])
return HAM_IGNORED

static Float:Origin[3], Float:TargetOrigin[3]
get_position(Attacker, 40.0, 5.0, -15.0 + 10.0, Origin)
get_position(Attacker, 40.0 * 100.0, 5.0, -15.0 + 10.0, TargetOrigin)
create_fire(Attacker, Origin, TargetOrigin, 500.0)

return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack(ent)
{	
if(!pev_valid(ent))
return HAM_IGNORED
static id; id = pev(ent, pev_owner)
pev(id, pev_punchangle, g_PunchAngles[id])

return HAM_IGNORED	
}

public fw_Weapon_PrimaryAttack_Post(ent)
{
if(!pev_valid(ent))
return HAM_IGNORED	
static id; id = pev(ent,pev_owner)
new clip,ammo 
get_user_ammo(id,CSW_FLAMEGUN,clip,ammo) 
if (clip <= 0) 
return HAM_IGNORED
if(get_user_weapon(id) == CSW_FLAMEGUN && g_had_flamegun[id])
{
static Float:push[3]
pev(id, pev_punchangle, push)
xs_vec_sub(push, g_PunchAngles[id], push)
xs_vec_mul_scalar(push, 0.1, push)
xs_vec_add(push, g_PunchAngles[id], push)
set_pev(id, pev_punchangle, push)
emit_sound(id, CHAN_BODY, "ZPlague/Weapons/flamegun-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
create_fake_attack(id)
set_weapon_anim(id, 1)
}
return HAM_IGNORED	
}

public create_fake_attack(id)
{
if(!is_user_alive(id))
return	
new clip,ammo 
get_user_ammo(id,CSW_FLAMEGUN,clip,ammo) 
if (clip <= 0) 
return 	
static weapon
weapon = fm_find_ent_by_owner(-1, "weapon_knife", id)
if(pev_valid(weapon)) ExecuteHamB(Ham_Weapon_PrimaryAttack, weapon)
}

public create_fire(id, Float:Origin[3], Float:TargetOrigin[3], Float:Speed)
{
new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
if(iEnt)
{
static Float:vfAngle[3], Float:MyOrigin[3], Float:Velocity[3]
pev(id, pev_angles, vfAngle)
pev(id, pev_origin, MyOrigin)
vfAngle[2] = float(random(18) * 20)
set_pev(iEnt, pev_movetype, MOVETYPE_FLY)
set_pev(iEnt, pev_rendermode, kRenderTransAdd)
set_pev(iEnt, pev_renderamt, 200.0)
set_pev(iEnt, pev_fuser1, get_gametime() + 0.350)	// time remove
set_pev(iEnt, pev_scale, 0.2)
set_pev(iEnt, pev_nextthink, get_gametime() + 0.05)
entity_set_string(iEnt, EV_SZ_classname, FIRE_CLASSNAME)
engfunc(EngFunc_SetModel, iEnt, "sprites/ZPlague/fire.spr")
set_pev(iEnt, pev_mins, Float:{-1.0, -1.0, -1.0})
set_pev(iEnt, pev_maxs, Float:{1.0, 1.0, 1.0})
set_pev(iEnt, pev_origin, Origin)
set_pev(iEnt, pev_gravity, 0.01)
set_pev(iEnt, pev_angles, vfAngle)
set_pev(iEnt, pev_solid, SOLID_TRIGGER)
set_pev(iEnt, pev_owner, id)	
set_pev(iEnt, pev_frame, 0.0)
set_pev(iEnt, pev_iuser2, get_user_team(id))
get_speed_vector(Origin, TargetOrigin, Speed, Velocity)
set_pev(iEnt, pev_velocity, Velocity)
}
}

public fw_Fire_Think(iEnt)
{
if(!pev_valid(iEnt)) 
return

new Float:fFrame, Float:fScale, Float:fNextThink
pev(iEnt, pev_frame, fFrame)
pev(iEnt, pev_scale, fScale)

// effect exp
new iMoveType = pev(iEnt, pev_movetype)
if (iMoveType == MOVETYPE_NONE)
{
fNextThink = 0.015
fFrame += 1.0
fScale = floatmax(fScale, 1.00)

if (fFrame > 21.0)
{
engfunc(EngFunc_RemoveEntity, iEnt)
return
}
}
else
{
fNextThink = 0.045
fFrame += 1.0
fFrame = floatmin(21.0, fFrame)
fScale += 0.2
fScale = floatmin(fScale, 1.75)
}

set_pev(iEnt, pev_frame, fFrame)
set_pev(iEnt, pev_scale, fScale)
set_pev(iEnt, pev_nextthink, get_gametime() + fNextThink)

// time remove
static Float:fTimeRemove
pev(iEnt, pev_fuser1, fTimeRemove)
if (get_gametime() >= fTimeRemove)
{
engfunc(EngFunc_RemoveEntity, iEnt)
return;
}
}
public fw_Fire_Touch(ent, id)
{
if(!pev_valid(ent))
return

if(pev_valid(id))
{
static Classname[32]
pev(id, pev_classname, Classname, sizeof(Classname))

if(equal(Classname, FIRE_CLASSNAME)) return
else if(is_user_alive(id)) 
{
if(zp_core_is_zombie(id))
{
if(!zp_class_clown_get(id))
do_attack(pev(ent, pev_owner), id, 0, float(60))
else
do_attack(pev(ent, pev_owner), id, 0, float(250))
}
}
}

set_pev(ent, pev_movetype, MOVETYPE_NONE)
set_pev(ent, pev_solid, SOLID_NOT)
}	
stock CURWPN(id)
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
write_byte(1)
write_byte(CSW_FLAMEGUN)
write_byte(100)
message_end()	
}
stock fm_cs_get_weapon_ent_owner(ent)
{
if(!pev_valid(ent))
return;		
return get_pdata_cbase(ent, 41, 4)
}
stock set_weapon_anim(id, anim)
{
set_pev(id, pev_weaponanim, anim)

message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
write_byte(anim)
write_byte(pev(id,pev_body))
message_end()
}
stock drop_weapons(id, dropwhat)
{
static weapons[32], num, i, weaponid
num = 0
get_user_weapons(id, weapons, num)
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)	
for (i = 0; i < num; i++)
{
weaponid = weapons[i]

if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
{
static wname[32]
get_weaponname(weaponid, wname, sizeof wname - 1)
engclient_cmd(id, "drop", wname)
}
}
}
stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

pev(id, pev_origin, vOrigin)
pev(id, pev_view_ofs,vUp) //for player
xs_vec_add(vOrigin,vUp,vOrigin)
pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles

angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward) //or use EngFunc_AngleVectors
angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
angle_vector(vAngle,ANGLEVECTOR_UP,vUp)

vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}
stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
new_velocity[0] = origin2[0] - origin1[0]
new_velocity[1] = origin2[1] - origin1[1]
new_velocity[2] = origin2[2] - origin1[2]
new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
new_velocity[0] *= num
new_velocity[1] *= num
new_velocity[2] *= num

return 1;
}
do_attack(Attacker, Victim, Inflictor, Float:fDamage)
{
fake_player_trace_attack(Attacker, Victim, fDamage)
fake_take_damage(Attacker, Victim, fDamage, Inflictor)
}

fake_player_trace_attack(iAttacker, iVictim, &Float:fDamage)
{
// get fDirection
new Float:fAngles[3], Float:fDirection[3]
pev(iAttacker, pev_angles, fAngles)
angle_vector(fAngles, ANGLEVECTOR_FORWARD, fDirection)

// get fStart
new Float:fStart[3], Float:fViewOfs[3]
pev(iAttacker, pev_origin, fStart)
pev(iAttacker, pev_view_ofs, fViewOfs)
xs_vec_add(fViewOfs, fStart, fStart)

// get aimOrigin
new iAimOrigin[3], Float:fAimOrigin[3]
get_user_origin(iAttacker, iAimOrigin, 3)
IVecFVec(iAimOrigin, fAimOrigin)

// TraceLine from fStart to AimOrigin
new ptr = create_tr2() 
engfunc(EngFunc_TraceLine, fStart, fAimOrigin, DONT_IGNORE_MONSTERS, iAttacker, ptr)
new pHit = get_tr2(ptr, TR_pHit)
new iHitgroup = get_tr2(ptr, TR_iHitgroup)
new Float:fEndPos[3]
get_tr2(ptr, TR_vecEndPos, fEndPos)

// get target & body at aiming
new iTarget, iBody
get_user_aiming(iAttacker, iTarget, iBody)

// if aiming find target is iVictim then update iHitgroup
if (iTarget == iVictim)
{
iHitgroup = iBody
}

// if ptr find target not is iVictim
else if (pHit != iVictim)
{
// get AimOrigin in iVictim
new Float:fVicOrigin[3], Float:fVicViewOfs[3], Float:fAimInVictim[3]
pev(iVictim, pev_origin, fVicOrigin)
pev(iVictim, pev_view_ofs, fVicViewOfs) 
xs_vec_add(fVicViewOfs, fVicOrigin, fAimInVictim)
fAimInVictim[2] = fStart[2]
fAimInVictim[2] += get_distance_f(fStart, fAimInVictim) * floattan( fAngles[0] * 2.0, degrees )

// check aim in size of iVictim
new iAngleToVictim = get_angle_to_target(iAttacker, fVicOrigin)
iAngleToVictim = abs(iAngleToVictim)
new Float:fDis = 2.0 * get_distance_f(fStart, fAimInVictim) * floatsin( float(iAngleToVictim) * 0.5, degrees )
new Float:fVicSize[3]
pev(iVictim, pev_size , fVicSize)
if ( fDis <= fVicSize[0] * 0.5 )
{
// TraceLine from fStart to aimOrigin in iVictim
new ptr2 = create_tr2() 
engfunc(EngFunc_TraceLine, fStart, fAimInVictim, DONT_IGNORE_MONSTERS, iAttacker, ptr2)
new pHit2 = get_tr2(ptr2, TR_pHit)
new iHitgroup2 = get_tr2(ptr2, TR_iHitgroup)

// if ptr2 find target is iVictim
if ( pHit2 == iVictim && (iHitgroup2 != HIT_HEAD || fDis <= fVicSize[0] * 0.25) )
{
pHit = iVictim
iHitgroup = iHitgroup2
get_tr2(ptr2, TR_vecEndPos, fEndPos)
}

free_tr2(ptr2)
}

// if pHit still not is iVictim then set default HitGroup
if (pHit != iVictim)
{
// set default iHitgroup
iHitgroup = HIT_GENERIC

new ptr3 = create_tr2() 
engfunc(EngFunc_TraceLine, fStart, fVicOrigin, DONT_IGNORE_MONSTERS, iAttacker, ptr3)
get_tr2(ptr3, TR_vecEndPos, fEndPos)

// free ptr3
free_tr2(ptr3)
}
}

// set new Hit & Hitgroup & EndPos
set_tr2(ptr, TR_pHit, iVictim)
set_tr2(ptr, TR_iHitgroup, iHitgroup)
set_tr2(ptr, TR_vecEndPos, fEndPos)

// hitgroup multi fDamage
new Float:fMultifDamage 
switch(iHitgroup)
{
case HIT_HEAD: fMultifDamage  = 4.0
case HIT_STOMACH: fMultifDamage  = 1.25
case HIT_LEFTLEG: fMultifDamage  = 0.75
case HIT_RIGHTLEG: fMultifDamage  = 0.75
default: fMultifDamage  = 1.0
}

fDamage *= fMultifDamage

// ExecuteHam
fake_trake_attack(iAttacker, iVictim, fDamage, fDirection, ptr)

// free ptr
free_tr2(ptr)
}

stock fake_trake_attack(iAttacker, iVictim, Float:fDamage, Float:fDirection[3], iTraceHandle, iDamageBit = (DMG_NEVERGIB | DMG_BULLET))
{
ExecuteHam(Ham_TraceAttack, iVictim, iAttacker, fDamage, fDirection, iTraceHandle, iDamageBit)
}

stock fake_take_damage(iAttacker, iVictim, Float:fDamage, iInflictor, iDamageBit = (DMG_NEVERGIB | DMG_BULLET))
{
ExecuteHam(Ham_TakeDamage, iVictim, iInflictor, iAttacker, fDamage, iDamageBit)
}

stock get_angle_to_target(id, const Float:fTarget[3], Float:TargetSize = 0.0)
{
new Float:fOrigin[3], iAimOrigin[3], Float:fAimOrigin[3], Float:fV1[3]
pev(id, pev_origin, fOrigin)
get_user_origin(id, iAimOrigin, 3) // end position from eyes
IVecFVec(iAimOrigin, fAimOrigin)
xs_vec_sub(fAimOrigin, fOrigin, fV1)

new Float:fV2[3]
xs_vec_sub(fTarget, fOrigin, fV2)

new iResult = get_angle_between_vectors(fV1, fV2)

if (TargetSize > 0.0)
{
new Float:fTan = TargetSize / get_distance_f(fOrigin, fTarget)
new fAngleToTargetSize = floatround( floatatan(fTan, degrees) )
iResult -= (iResult > 0) ? fAngleToTargetSize : -fAngleToTargetSize
}

return iResult
}

stock get_angle_between_vectors(const Float:fV1[3], const Float:fV2[3])
{
new Float:fA1[3], Float:fA2[3]
engfunc(EngFunc_VecToAngles, fV1, fA1)
engfunc(EngFunc_VecToAngles, fV2, fA2)

new iResult = floatround(fA1[1] - fA2[1])
iResult = iResult % 360
iResult = (iResult > 180) ? (iResult - 360) : iResult

return iResult
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
