#include <amxmodx>
#include <ZombieMod5>

public plugin_init() 
{
RegisterHam(Ham_TraceAttack, "player", "fw_PlayerTraceAttack_Post", 1)
}

public fw_PlayerTraceAttack_Post(Victim, Attacker, Float:Damage, Float:Direction[3], Trace, DamageBits)
{
if(!is_user_alive(Victim) || !is_user_connected(Attacker))
return HAM_IGNORED
if(!zp_core_is_zombie(Victim))
return HAM_IGNORED

static ducking; ducking = pev(Victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)

if(ducking) Damage /= 1.25
if(!(pev(Victim, pev_flags) & FL_ONGROUND)) Damage *= 2.0

static Float:Origin[3]
pev(Attacker, pev_origin, Origin)

static classzb_knockback
classzb_knockback = zb5_get_zombie_info(Victim, KNOCKBACK)

hook_ent2(Victim, Origin, Damage, float(classzb_knockback), 2)
return HAM_HANDLED
}

public plugin_natives()
{
register_native("set_weapon_kick", "kickback", 1)
register_native("set_weapon_knockback", "knockack_guns", 1)
}
public knockack_guns(attacker, victim, Float:jump)
{
static Float:Origin[3], Float:Damage
pev(attacker, pev_origin, Origin)

static ducking; ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)

if(ducking) Damage /= 1.25
if(!(pev(victim, pev_flags) & FL_ONGROUND)) Damage *= 2.0

hook_ent2(victim, Origin, jump, Damage, 2)
}
public kickback(attacker, victim, Float:jump)
{
static ducking
ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)	
if (ducking)
jump = (jump * 0.5) 
else if(!(pev(victim,pev_flags) & FL_ONGROUND))
jump = (jump / 1.0) 

static Float:OriginA[3]; pev(attacker, pev_origin, OriginA)
static Float:Origin[3]; pev(victim, pev_origin, Origin)
static Float:VelocityA[3]; get_speed_vector(OriginA, Origin, jump, VelocityA)
set_pev(victim, pev_velocity, VelocityA)
}
stock hook_ent2(ent, Float:VicOrigin[3], Float:speed, Float:multi, type)
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
