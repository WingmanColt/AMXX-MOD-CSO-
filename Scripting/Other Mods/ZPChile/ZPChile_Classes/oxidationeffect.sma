public AttackBeginAbility(id)
{
if (!is_user_alive(id))
return;

if(zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID && !zp_class_assassin_get(id) && !zp_class_nemesis_get(id) && a_countdown[id])
{
a_Cdown[id] = 28
Time_Attack[id] = 3.4;
a_countdown[id] = false;
emit_sound(id, CHAN_STREAM, "ZPChile/Oxidation/gas_ability.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH )
set_task(1.0, "ResetAttackAbility", id+TASK_RESET_A)
set_task(0.1, "OxidAttack", id+TASK_ATTACK, _, _, "a",floatround(Time_Attack[id])*10)
}
}
public OxidAttack(taskid)
{
new id = ID_TASK_ATTACK
if((Time_Attack[id] > 0.0) && zp_core_is_zombie(id) && is_user_alive(id))
{
new vec[ 3 ], aimvec[ 3 ], velocityvec[ 3 ]
new length
get_user_origin( id, vec )
get_user_origin( id, aimvec, 2 )

velocityvec[ 0 ] = aimvec[ 0 ] - vec[ 0 ]
velocityvec[ 1 ] = aimvec[ 1 ] - vec[ 1 ]
velocityvec[ 2 ] = aimvec[ 2 ] - vec[ 2 ]
length = sqrt( velocityvec[ 0 ] * velocityvec[ 0 ] + velocityvec[ 1 ] * velocityvec[ 1 ] + velocityvec[ 2 ] * velocityvec[ 2 ] )
velocityvec[ 0 ] =velocityvec[ 0 ] * 10 / length
velocityvec[ 1 ] = velocityvec[ 1 ] * 10 / length
velocityvec[ 2 ] = velocityvec[ 2 ] * 10 / length
message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
write_byte( 120 )
write_coord( vec[ 0 ] )
write_coord( vec[ 1 ] )
write_coord( vec[ 2 ] )
write_coord( velocityvec[ 0 ] )
write_coord( velocityvec[ 1 ] )
write_coord( velocityvec[ 2 ] )
write_short( g_Sprite )
write_byte( 5 )
write_byte( 70 )
write_byte( 100 )
write_byte( 5 )
message_end( )
Time_Attack[id]-=0.1
DamageBegin(id, vec, aimvec)	
}
else remove_task(ID_TASK_ATTACK)
}

DamageBegin(id, vec[3], Aimvec[3])
{
static victim, Float:originAim[3], Float:originF[3]
new Float:damage; damage = 1.0;
victim = -1;	IVecFVec(Aimvec, originAim);	IVecFVec(vec, originF)
new Float:flDistance = get_distance_f (originAim, originF )
if(flDistance <= 400.0)
{
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originAim, 38.0)) != 0)
{ 
if (!is_user_alive(victim) || zp_core_is_zombie(victim) || zp_class_nemesis_get(victim) || zp_class_assassin_get(victim))
continue

do_screen_fade(victim, 0.2, 0.1, 200, 200, 200, 120);
user_screen_shake(victim, 4, 2, 5)
ExecuteHam(Ham_TakeDamage, victim, 0, id, damage, DMG_BULLET)	
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, victim)
write_byte(0) // damage save
write_byte(0) // damage take
write_long(DMG_DROWN) // Freeze
write_coord(0) // x
write_coord(0) // y
write_coord(0) // z
message_end()
static Float:flSpeed, Float:vOrigin[3]
flSpeed = 450.0
pev(victim, pev_origin, vOrigin)
static Float:flVelocity [3]
get_speed_vector(originF, vOrigin, flSpeed, flVelocity)

set_pev(victim, pev_velocity,flVelocity)
if(!g_Slow[victim])
{
g_Slow[victim] = true;
set_task(3.0, "ResetSlow", victim);
}
}
}
}
public ResetSlow(id)
{
g_Slow[id] = false;
remove_task(id);
}
public ResetAttackAbility(taskid)
{
new id = ID_TASK_RESET_ATTACK
if(a_Cdown[id] > 0 && zp_core_is_zombie(id))
{
set_hudmessage(200, 100, 0, 0.7, 0.91, 0, 1.0, 1.1, 0.0, 0.0, -1)
show_hudmessage(id, "Wait %d sec. to attack again",a_Cdown[id])
a_Cdown[id]-=1
set_task(1.0, "ResetAttackAbility", id+TASK_RESET_A)
}
else
{
if(zp_core_is_zombie(id))
{
a_countdown[id] = true;
}
remove_task(ID_TASK_RESET_ATTACK)
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
