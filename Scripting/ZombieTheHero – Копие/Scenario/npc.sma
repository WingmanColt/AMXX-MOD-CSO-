#include <amxmodx>
#include <amxmisc>
#include <ZombieMod5>
#include <ScenarioMod>

#define HEALTH 50.0
#define ATTACK_RANGE 60.0

#define SPEED_NORMAL 210.0
#define SPEED_FAST 150.0

#define TASK_CREATE 323422
#define MAX_ZOMBIES 50

enum
{
STATE_IDLE = 0,
STATE_MOVE,
STATE_ATTACK,
STATE_DEATH
}


new bool: g_NpcSpawn[256]; 
new const g_NpcClassName[] = "ent_npc"; 
new const spawn_file[] = "%s/scenario/%s.cfg"

new Float:g_spawn[MAX_ZOMBIES][3], g_total
new g_State[256], Float:Time1
new const g_NpcModel[] = "models/player/ZB5_Light/ZB5_Light.mdl"

//Sounds when killed 
new const g_NpcSoundDeath[][] = 
{ 
"ZBS/zbs_death_1.wav", 
"ZBS/zbs_death_boss_1.wav", 
"ZBS/zbs_death_female_1.wav", 
} 

//Sprites for blood when our NPC is damaged
new spr_blood_drop, spr_blood_spray

//Boolean to check if we knifed our NPC
new bool: g_Hit[32];

public plugin_init()
{	
RegisterHam(Ham_TakeDamage, "info_target", "npc_TakeDamage");
RegisterHam(Ham_Killed, "info_target", "npc_Killed");
RegisterHam(Ham_Think, "info_target", "npc_Think");
RegisterHam(Ham_TraceAttack, "info_target", "npc_TraceAttack");
}

public plugin_precache()
{
spr_blood_drop = precache_model("sprites/blood.spr")
spr_blood_spray = precache_model("sprites/bloodspray.spr")

for(new i = 0 ; i < sizeof g_NpcSoundDeath ; i++)
precache_sound(g_NpcSoundDeath[i]);

precache_model(g_NpcModel)
load_spawn()
}

public npc_TakeDamage(iEnt, inflictor, attacker, Float:damage, bits)
{
//Make sure we only catch our NPC by checking the classname
new className[32];
entity_get_string(iEnt, EV_SZ_classname, className, charsmax(className))

if(!equali(className, g_NpcClassName))
return;

//Play a random animation when damanged
Util_PlayAnimation(iEnt, random_num(13, 17), 1.25);

g_Hit[attacker] = true;
}

public npc_Killed(iEnt, attacker)
{
if(!is_valid_ent(iEnt))
return HAM_IGNORED;
	
new className[32];
entity_get_string(iEnt, EV_SZ_classname, className, charsmax(className))

if(!equali(className, g_NpcClassName))
return HAM_IGNORED;

//Because our NPC may look like it is laying down. 
//The bounding box size is still there and it is impossible to change it so we will make the solid of our NPC to nothing
entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);

//The voice of the NPC when it is dead
emit_sound(iEnt, CHAN_VOICE, g_NpcSoundDeath[2],  VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

//Our NPC is dead so it shouldn't take any damage and play any animations
entity_set_float(iEnt, EV_FL_takedamage, 0.0);

UpdateFrags(attacker)

//Our death boolean should now be true!!
g_State[iEnt] = STATE_DEATH

Util_PlayAnimation(iEnt, random_num(101,103), 1.0)	

//The most important part of this forward!! We have to block the death forward.
return HAM_SUPERCEDE
}

public npc_Think(ent)
{
if(!is_valid_ent(ent))
return;

static className[32];
entity_get_string(ent, EV_SZ_classname, className, charsmax(className))

if(!equali(className, g_NpcClassName))
return;

if(g_State[ent] == STATE_DEATH)
{
return;
}

engfunc(EngFunc_DropToFloor, ent)
//set_pev(ent, pev_nextthink, get_gametime() + 1.0)

static Victim; Victim = FindClosetEnemy(ent, 0)
if(is_user_alive(Victim))
{
set_pev(ent, pev_enemy, Victim)
g_State[ent] = STATE_MOVE
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01)
} else {
set_pev(ent, pev_enemy, 0)
g_State[ent] = STATE_IDLE
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0)
}

switch(g_State[ent])
{	
case STATE_IDLE:
{
if(get_gametime() - 1.0 > Time1)
{
Set_EntAnim(ent, 1, 1.0, 1)
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
g_State[ent] = STATE_ATTACK

Aim_To(ent, EnemyOrigin, 2.0, 1) 
Set_EntAnim(ent, 76, 1.0, 1)
Check_AttackDamge(ent)	
entity_set_float(ent, EV_FL_nextthink,  1.5)

} else {
if(pev(ent, pev_movetype) == MOVETYPE_PUSHSTEP)
{
static Float:OriginAhead[3]
get_position(ent, 300.0, 0.0, 0.0, OriginAhead)

Aim_To(ent, EnemyOrigin, 1.0, 1) 
hook_ent2(ent, OriginAhead, SPEED_FAST)

Set_EntAnim(ent, 4, 1.0, 0)
} else {
set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)
}
}
}else g_State[ent] = STATE_IDLE
}
}

//Make our NPC think every so often
entity_set_float(ent, EV_FL_nextthink, 1.0)
}
public Check_AttackDamge(Ent)
{
if(!pev_valid(Ent))
return

static Float:origin[3]
pev(Ent, pev_origin, origin)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, 100.0)) != 0)
{			
if(!is_user_alive(Victim))
continue

//ExecuteHamB(Ham_TakeDamage, Victim, 0, 0, random_float(20.0, 50.0), DMG_GENERIC)
}
}
public npc_TraceAttack(iEnt, attacker, Float: damage, Float: direction[3], trace, damageBits)
{
if(!is_valid_ent(iEnt))
return;

new className[32];
entity_get_string(iEnt, EV_SZ_classname, className, charsmax(className))

if(!equali(className, g_NpcClassName))
return;

//Retrieve the end of the trace
new Float: end[3]
get_tr2(trace, TR_vecEndPos, end);

//This message will draw blood sprites at the end of the trace
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, end[0])
engfunc(EngFunc_WriteCoord, end[1])
engfunc(EngFunc_WriteCoord, end[2])
write_short(spr_blood_spray)
write_short(spr_blood_drop)
write_byte(247) // color index
write_byte(random_num(1, 5)) // size
message_end()
}

public zp_fw_game_start()
{
if(zbs_is_scenario() == 0) return	

set_task(1.0, "Create_Npc", TASK_CREATE, _, _, "b")
}
public zp_fw_game_end()
{	
if(zbs_is_scenario() == 0) return	

if(task_exists(TASK_CREATE))
remove_task(TASK_CREATE)

remove_entity_name(g_NpcClassName);	
}
public  Create_Npc()
{
if(Get_Zombie_Alive() <= MAX_ZOMBIES)
{	
new iEnt = create_entity("info_target")

entity_set_string(iEnt, EV_SZ_classname, g_NpcClassName);

static Float:Origin[3]
collect_spawn_point(Origin)
engfunc(EngFunc_SetOrigin, iEnt, Origin)	
engfunc(EngFunc_DropToFloor, iEnt)

entity_set_float(iEnt, EV_FL_takedamage, 1.0);
entity_set_float(iEnt, EV_FL_health, HEALTH);

entity_set_model(iEnt, g_NpcModel);
entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_PUSHSTEP);
entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);

engfunc(EngFunc_SetSize, iEnt, {-16.0, -16.0, -36.0}, {16.0, 16.0, 36.0})	
entity_set_byte(iEnt,EV_BYTE_controller1,125);

entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.0)

g_State[iEnt] = STATE_IDLE
g_NpcSpawn[iEnt] = true;
}
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
if(equal(classname, g_NpcClassName))
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
while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", g_NpcClassName)) != 0)
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
stock Util_PlayAnimation(ent, sequence, Float: framerate)
{
set_pev(ent, pev_sequence, sequence)
set_pev(ent, pev_animtime, halflife_time())
set_pev(ent, pev_framerate, framerate)
}
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
