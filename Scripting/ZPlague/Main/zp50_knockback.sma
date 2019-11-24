#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <zp50_core>


new Float:kb_weapon_power[] = 
{
-1.0,	// ---
2.4,	// P228
-1.0,	// ---
6.5,	// SCOUT
-1.0,	// ---
8.0,	// XM1014
-1.0,	// ---
2.3,	// MAC10
5.0,	// AUG
-1.0,	// ---
2.4,	// ELITE
2.0,	// FIVESEVEN
2.4,	// UMP45
5.3,	// SG550
5.5,	// GALIL
5.5,	// FAMAS
2.2,	// USP
2.0,	// GLOCK18
10.0,	// AWP
2.5,	// MP5NAVY
5.2,	// M249
8.0,	// M3
5.0,	// M4A1
2.4,	// TMP
6.5,	// G3SG1
-1.0,	// ---
5.3,	// DEAGLE
5.0,	// SG552
6.0,	// AK47
-1.0,	// ---
2.0		// P90
}

public plugin_init()
{
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Post", 1)
}
public fw_TraceAttack_Post(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return;

if (!zp_core_is_zombie(victim) || zp_core_is_zombie(attacker))
return;

if (!(damage_type & DMG_BULLET))
return;

if (damage <= 0.0 || GetHamReturnStatus() == HAM_SUPERCEDE || get_tr2(tracehandle, TR_pHit) != victim)
return;

new ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)

if (ducking && 0.4 == 0.0)
return;

static origin1[3], origin2[3]
get_user_origin(victim, origin1)
get_user_origin(attacker, origin2)

if (get_distance(origin1, origin2) > 250)
return;
if(zp_class_nemesis_get(victim) || zp_class_assassin_get(victim))
return
static Float:velocity[3]
pev(victim, pev_velocity, velocity)
xs_vec_mul_scalar(direction, damage, direction)
new attacker_weapon = get_user_weapon(attacker)
if (kb_weapon_power[attacker_weapon] > 0.0)
xs_vec_mul_scalar(direction, kb_weapon_power[attacker_weapon], direction)
if (zp_core_is_zombie(victim))
{
xs_vec_mul_scalar(direction, 1.3, direction)
if(ducking)xs_vec_mul_scalar(direction, 1.0, direction)
}
xs_vec_add(velocity, direction, direction)
direction[2] = velocity[2]
set_pev(victim, pev_velocity, direction)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
