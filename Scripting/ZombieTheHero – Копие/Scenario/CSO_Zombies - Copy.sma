
// https://forums.alliedmods.net/showthread.php?t=145716 
//NPC FEATURES



#include <amxmodx>
#include <amxmisc>
#include <ZombieMod5>
#include <ScenarioMod>

#define ZB_CLASSNAME "ZOMBIE"
#define NAME_MAP "zs_behind2"

#define TASK_CREATE 323422

#define HEALTH 20.0
#define ATTACK_RANGE 60.0

#define SPEED_NORMAL 210.0
#define SPEED_FAST 230.0

#define MAX_ZOMBIES 50
#define MODEL "models/player/ZB5_Regular_NEW/ZB5_Regular_NEW.mdl"

new const ZombieSound[][] =
{
"ZB5/Scenario/zbs_death_1.wav"
}
enum
{
ANIM_IDLE = 1,
ANIM_WALK = 3,
ANIM_RUN = 4,
ANIM_ATTACK = 76,
ANIM_DIE = 101
}

enum
{
STATE_IDLE = 0,
STATE_MOVE,
STATE_ATTACK,
STATE_DEATH
}

new const spawn_file[] = "%s/scenario/%s.cfg"

new Float:g_spawn[MAX_ZOMBIES][3], m_iBlood[2]
new g_total, g_State, g_RegHam, Float:Time1
public plugin_init()
{
if(!zbs_is_scenario()) return	

register_think(ZB_CLASSNAME, "fw_Think")
}

public plugin_precache()
{
for(new i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

m_iBlood[0] = precache_model("sprites/blood.spr")
m_iBlood[1] = precache_model("sprites/bloodspray.spr")	

load_spawn()
}

public zp_fw_game_start()
{
if(!zbs_is_scenario()) return	
	
set_task(1.0, "Create_Zombie", TASK_CREATE, _, _, "b")
}
public zp_fw_game_end()
{	
if(!zbs_is_scenario()) return	
	
if(task_exists(TASK_CREATE))
remove_task(TASK_CREATE)

remove_entity_name(ZB_CLASSNAME)	
}
public Create_Zombie()
{				
if(Get_Zombie_Alive() <= MAX_ZOMBIES)
{
static Float:Origin[3]
static ent		
ent = create_entity("info_target")

if(!pev_valid(ent))
return;

set_pev(ent, pev_classname, ZB_CLASSNAME)
engfunc(EngFunc_SetModel, ent, MODEL)
set_pev(ent, pev_modelindex, engfunc(EngFunc_ModelIndex, MODEL))

set_pev(ent, pev_gravity, 1.0)
set_pev(ent, pev_solid, SOLID_SLIDEBOX)
set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)	

set_pev(ent, pev_takedamage, DAMAGE_YES)
set_pev(ent, pev_health, 10000.0 + HEALTH)

engfunc(EngFunc_SetSize, ent, {-16.0, -16.0, -36.0}, {16.0, 16.0, 36.0})	

collect_spawn_point(Origin)
engfunc(EngFunc_SetOrigin, ent, Origin)	

g_State = STATE_IDLE
drop_to_floor(ent)

if(!g_RegHam)
{
g_RegHam = 1
RegisterHamFromEntity(Ham_TraceAttack, ent, "fw_TraceAttack")
//RegisterHamFromEntity(Ham_TakeDamage, ent, "fw_TakeDamage")
}
set_pev(ent, pev_nextthink, get_gametime() + 1.0)
}
}

public fw_Think(ent, id)
{
if(!pev_valid(ent))
return

static Human; Human = pev(ent, pev_enemy)

engfunc(EngFunc_DropToFloor, ent)
set_pev(ent, pev_nextthink, get_gametime() + 0.1)

static Victim; Victim = FindClosetEnemy(ent, 0)

if(is_user_alive(Victim))
{
set_pev(ent, pev_enemy, Victim)
g_State = STATE_MOVE
set_pev(ent, pev_nextthink, get_gametime() + 0.01)
} else {
set_pev(ent, pev_enemy, 0)
g_State = STATE_IDLE
set_pev(ent, pev_nextthink, get_gametime() + 1.0)
}

switch(g_State)
{
case STATE_IDLE:
{
if(get_gametime() - 1.0 > Time1)
{
Set_EntAnim(ent, ANIM_IDLE, 1.0, 1)
Time1 = get_gametime()
}
}	
case STATE_MOVE:
{
static Enemy; Enemy = pev(ent, pev_enemy)
static Float:EnemyOrigin[3]
pev(Enemy, pev_origin, EnemyOrigin)

if(is_user_alive(Enemy))
{
if(entity_range(Enemy, ent) <= floatround(ATTACK_RANGE))
{
g_State = STATE_ATTACK

Aim_To(ent, EnemyOrigin, 2.0, 1) 
Set_EntAnim(ent, ANIM_ATTACK, 1.0, 1)
Check_AttackDamge(ent)	
//set_pev(ent, pev_nextthink, get_gametime() + 1.5)

} else {
if(pev(ent, pev_movetype) == MOVETYPE_PUSHSTEP)
{
static Float:OriginAhead[3]
get_position(ent, 300.0, 0.0, 0.0, OriginAhead)

Aim_To(ent, EnemyOrigin, 1.0, 1) 
hook_ent2(ent, OriginAhead, SPEED_FAST)

Set_EntAnim(ent, ANIM_RUN, 1.0, 0)
} else {
set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)
}
}
}else g_State = STATE_IDLE
}
}

if((pev(ent, pev_health) - 10000.0) <= 0.0)
{	
g_State = STATE_DEATH	
UpdateFrags(Human)
Zombie_Death(ent)
//set_pev(ent, pev_nextthink, get_gametime() + 0.01)
return
}
}
public Zombie_Death(Ent)
{
if(!pev_valid(Ent))
return

Set_EntAnim(Ent, ANIM_DIE, 1.0, 1)
EmitSound(Ent, CHAN_AUTO, ZombieSound[0])

set_pev(Ent, pev_solid, SOLID_NOT)
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(2.0, "Death", Ent)
}
public Death(Ent)
{
if(!pev_valid(Ent))
return

remove_entity(Ent)
}
public Check_AttackDamge(Ent)
{
if(!pev_valid(Ent))
return

static Float:origin[3]
pev(Ent, pev_origin, origin)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, 200.0)) != 0)
{			
if(!is_user_alive(Victim))
continue

ExecuteHamB(Ham_TakeDamage, Victim, 0, 0, random_float(20.0, 50.0), DMG_GENERIC)
}
}
public fw_TraceAttack(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{
if(!is_valid_ent(Ent)) 
return HAM_IGNORED

static Classname[32]
pev(Ent, pev_classname, Classname, charsmax(Classname)) 

if(!equal(Classname, ZB_CLASSNAME)) 
return HAM_IGNORED

static Float:EndPos[3] 
get_tr2(ptr, TR_vecEndPos, EndPos)

create_blood(EndPos)
return HAM_IGNORED
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
// Fix bug not is valid
if (victim == attacker)
return HAM_IGNORED;

// Fix bug not is valid
if (!pev_valid(victim) || !pev_valid(attacker))
return HAM_IGNORED;

// player can't attack player
if (is_user_connected(victim) && is_user_connected(attacker))
return HAM_SUPERCEDE;

static victim2; victim2 = zbs_is_zombie(victim)
static Human; Human = pev(victim2, pev_enemy)

// get classname of victim
static Classname[32]
pev(victim2, pev_classname, Classname, charsmax(Classname)) 

// victim is NPC
if (equal(Classname, ZB_CLASSNAME))
{
// check NPC die
if (g_State == STATE_DEATH) 
return HAM_SUPERCEDE

// get aim
new aimOrigin[3], target, body
get_user_origin(attacker, aimOrigin, 3)
get_user_aiming(attacker, target, body)

// fix hit body damage
if (!(damage_type & (1<<24))) 
damage = float(get_damage_body(body, damage))

// nst wpn mod xdamage
new Float:xdamage = 1.0
if (xdamage>0.0) damage *= xdamage

// x damage level
damage = 1.0

// he x damage
if (damage_type & (1<<24))
{
new Float:hedmg = 300.0
if (damage < hedmg) 
damage += hedmg
}

// set new damage
SetHamParamFloat(4, damage)

// NPC die
if((pev(victim2, pev_health) - 10000.0) <= 0.0)
{
UpdateFrags(Human)
Zombie_Death(victim2)
return HAM_SUPERCEDE
}
}

return HAM_IGNORED
}
// STOCKS
stock Set_EntAnim(ent, anim, Float:framerate, resetframe)
{
if(!pev_valid(ent))
return

if(!resetframe)
{
if(pev(ent, pev_sequence) != anim)
{
set_pev(ent, pev_animtime, get_gametime())
set_pev(ent, pev_framerate, framerate)
set_pev(ent, pev_sequence, anim)
}
} else {
set_pev(ent, pev_animtime, get_gametime())
set_pev(ent, pev_framerate, framerate)
set_pev(ent, pev_sequence, anim)
}
}
stock create_blood(const Float:origin[3])
{
// Show some blood :)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, origin[0])
engfunc(EngFunc_WriteCoord, origin[1])
engfunc(EngFunc_WriteCoord, origin[2])
write_short(m_iBlood[1])
write_short(m_iBlood[0])
write_byte(75)
write_byte(5)
message_end()
}
stock Get_Zombie_Alive()
{
static iAlive, i
iAlive = 0

static classname[32]

for (i = 1; i <= entity_count(); i++)
{
if(is_valid_ent(i))
{
pev(i, pev_classname, classname, sizeof(classname))
if(equal(classname, ZB_CLASSNAME))
iAlive++
}
}

return iAlive;
}

UpdateFrags(attacker)
{
if(!is_user_connected(attacker))	
return

static money
money = cs_get_user_money(attacker)
cs_set_user_money(attacker, money + 100)

fm_set_user_frags(attacker, get_user_frags(attacker) + 1)

message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
write_byte(attacker) // id
write_short(get_user_frags(attacker)) // frags
write_short(get_user_deaths(attacker)) // deaths
write_short(0) // class?
write_short(_:cs_get_user_team(attacker)) // team
message_end()
}


// SEARCH ENEMY
public FindClosetEnemy(ent, can_see)
{
if(!pev_valid(ent))
return 0

new Float:maxdistance = 9999.0
new indexid = 0	
new Float:current_dis = maxdistance

for(new i = 1 ;i <= get_maxplayers(); i++)
{
if(can_see)
{
if(is_user_alive(i) && can_see_fm(ent, i) && entity_range(ent, i) < current_dis)
{
current_dis = entity_range(ent, i)
indexid = i
}
} else {
if(is_user_alive(i) && entity_range(ent, i) < current_dis)
{
current_dis = entity_range(ent, i)
indexid = i
}			
}
}	

return indexid
}
stock Aim_To(iEnt, Float:vTargetOrigin[3], Float:flSpeed, Style)
{
if(!pev_valid(iEnt))	
return

if(!Style)
{
static Float:Vec[3], Float:Angles[3]
pev(iEnt, pev_origin, Vec)

Vec[0] = vTargetOrigin[0] - Vec[0]
Vec[1] = vTargetOrigin[1] - Vec[1]
Vec[2] = vTargetOrigin[2] - Vec[2]
engfunc(EngFunc_VecToAngles, Vec, Angles)
//Angles[0] = Angles[2] = 0.0 

set_pev(iEnt, pev_v_angle, Angles)
set_pev(iEnt, pev_angles, Angles)
} else {
new Float:f1, Float:f2, Float:fAngles, Float:vOrigin[3], Float:vAim[3], Float:vAngles[3];
pev(iEnt, pev_origin, vOrigin);
xs_vec_sub(vTargetOrigin, vOrigin, vOrigin);
xs_vec_normalize(vOrigin, vAim);
vector_to_angle(vAim, vAim);

if (vAim[1] > 180.0) vAim[1] -= 360.0;
if (vAim[1] < -180.0) vAim[1] += 360.0;

fAngles = vAim[1];
pev(iEnt, pev_angles, vAngles);

if (vAngles[1] > fAngles)
{
f1 = vAngles[1] - fAngles;
f2 = 360.0 - vAngles[1] + fAngles;
if (f1 < f2)
{
vAngles[1] -= flSpeed;
vAngles[1] = floatmax(vAngles[1], fAngles);
}
else
{
vAngles[1] += flSpeed;
if (vAngles[1] > 180.0) vAngles[1] -= 360.0;
}
}
else
{
f1 = fAngles - vAngles[1];
f2 = 360.0 - fAngles + vAngles[1];
if (f1 < f2)
{
vAngles[1] += flSpeed;
vAngles[1] = floatmin(vAngles[1], fAngles);
}
else
{
vAngles[1] -= flSpeed;
if (vAngles[1] < -180.0) vAngles[1] += 360.0;
}		
}

set_pev(iEnt, pev_v_angle, vAngles)
set_pev(iEnt, pev_angles, vAngles)
}
}
stock hook_ent2(ent, Float:VicOrigin[3], Float:speed)
{
if(!pev_valid(ent))
return

static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time

pev(ent, pev_origin, EntOrigin)

distance_f = get_distance_f(EntOrigin, VicOrigin)
fl_Time = distance_f / speed

fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
}
public bool:can_see_fm(entindex1, entindex2)
{
if (!entindex1 || !entindex2)
return false

if (pev_valid(entindex1) && pev_valid(entindex1))
{
new flags = pev(entindex1, pev_flags)
if (flags & EF_NODRAW || flags & FL_NOTARGET)
{
return false
}

new Float:lookerOrig[3]
new Float:targetBaseOrig[3]
new Float:targetOrig[3]
new Float:temp[3]

pev(entindex1, pev_origin, lookerOrig)
pev(entindex1, pev_view_ofs, temp)
lookerOrig[0] += temp[0]
lookerOrig[1] += temp[1]
lookerOrig[2] += temp[2]

pev(entindex2, pev_origin, targetBaseOrig)
pev(entindex2, pev_view_ofs, temp)
targetOrig[0] = targetBaseOrig [0] + temp[0]
targetOrig[1] = targetBaseOrig [1] + temp[1]
targetOrig[2] = targetBaseOrig [2] + temp[2]

engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
{
return false
} 
else 
{
new Float:flFraction
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2]
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2] - 17.0
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
}
}
}
}
return false
}

// SPAWN ORIGIN
public load_spawn()
{
// Check for spawns points of the current map
new cfgdir[32], mapname[32], filepath[100], linedata[64]
get_configsdir(cfgdir, charsmax(cfgdir))
get_mapname(mapname, charsmax(mapname))
formatex(filepath, charsmax(filepath), spawn_file, cfgdir, mapname)

// Load spawns points
if (file_exists(filepath))
{
new file = fopen(filepath,"rt"), row[4][6]

while (file && !feof(file))
{
fgets(file, linedata, charsmax(linedata))

// invalid spawn
if(!linedata[0] || str_count(linedata,' ') < 2) continue;

// get spawn point data
parse(linedata,row[0],5,row[1],5,row[2],5)

// origin
g_spawn[g_total][0] = floatstr(row[0])
g_spawn[g_total][1] = floatstr(row[1])
g_spawn[g_total][2] = floatstr(row[2])

g_total++
if (g_total >= MAX_ZOMBIES) 
break
}
if (file) fclose(file)
}
}
check_spawn_zombie(Float:origin[3]) // By Sontung0
{
new Float:originE[3], Float:origin1[3], Float:origin2[3]
new ent = -1
while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", ZB_CLASSNAME)) != 0)
{
pev(ent, pev_origin, originE)

// xoy
origin1 = origin
origin2 = originE
origin1[2] = origin2[2] = 0.0
if (vector_distance(origin1, origin2) <= 32.0) return 0;
}
return 1;
}
collect_spawn_point(Float:origin[3]) // By Sontung0
{
for (new i = 1; i <= g_total*3 ; i++)
{
origin = g_spawn[random(g_total)]
if (check_spawn_zombie(origin)) return 1;
}

return 0;
}
str_count(const str[], searchchar) // By Twilight Suzuka
{
new count, i, len = strlen(str)

for (i = 0; i <= len; i++)
{
if(str[i] == searchchar)
count++
}

return count;
}
stock get_damage_body(body, Float:damage) 
{
switch(body) 
{
case HIT_HEAD: damage *= 3.0
case HIT_STOMACH: damage *= 2.0
case HIT_CHEST: damage *= 1.9
case HIT_LEFTARM: damage *= 1.75
case HIT_RIGHTARM: damage *= 1.75
case HIT_LEFTLEG: damage *= 1.25
case HIT_RIGHTLEG: damage *= 1.25
default: damage *= 1.0
}
return floatround(damage)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
