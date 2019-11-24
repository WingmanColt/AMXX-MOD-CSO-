#include <amxmodx>
#include <engine>
#include <fakemeta_util>
#include <cstrike>
#include <ZombieMod5>
#include <ScenarioMod>

#define MAP "zs_nightmare2"

// Boss Rex
#define REX_MODEL "models/rex/rex.mdl"
#define REX_CLASSNAME "REX"
#define HEALTH_CLASSNAME "BOSS_HEALTH"

#define HEALTH_OFFSET 1000.0
#define REX_HEALTH 50000.0

#define REX_MOVESPEED 230.0
#define REX_ATTACK_RANGE 180.0

#define TASK_SCENE 1111
#define TASK_RECHECK 3018

new healthbar
new const healthbar_spr[] = "sprites/ZB5/zs_healthbar.spr"

new const RexSounds[17][] = 
{
"rex/appear.wav",
"rex/attack1.wav",
"rex/attack2.wav",
"rex/dash_start.wav",
"rex/dash_end.wav",
"rex/inhale.wav",
"rex/shield.wav",
"rex/skill1_1.wav",
"rex/skill1_2.wav",
"rex/skill2.wav",
"rex/skill3_start.wav",
"rex/skill4_a_start.wav",
"rex/skill4_a_end.wav",
"rex/skill5_end.wav",
"rex/walk.wav",
"rex/death.wav",
"rex/death2.wav"
}

enum
{
REX_DUMMY = 0,
REX_APPEAR,
REX_IDLE,
REX_RUN,
REX_WALK,
REX_ATTACK1,
REX_ATTACK2,
REX_DASH_START,
REX_DASH_LOOP,
REX_DASH_END,
REX_SKILL1,
REX_SKILL2,
REX_SKILL3_START,
REX_SKILL3_LOOP,
REX_SKILL3_END,
REX_SKILL4A_START,
REX_SKILL4A_LOOP,
REX_SKILL4A_END,
REX_SKILL4B_START,
REX_SKILL4B_LOOP,
REX_SKILL4B_END,	
REX_SKILL5_START,
REX_SKILL5_LOOP,
REX_SKILL5_END,	
REX_DEATH,
REX_DEATH2
}

enum
{
REX_STATE_IDLE = 0,
REX_STATE_SEARCHING_ENEMY,
REX_STATE_APPEAR,
REX_STATE_MOVE,
REX_STATE_ATTACK,
REX_STATE_DASH,
REX_STATE_SKILL1,
REX_STATE_SKILL2,
REX_STATE_SKILL3,
REX_STATE_SKILL4A,
REX_STATE_SKILL4B,
REX_STATE_SKILL4C,
REX_STATE_SKILL5,
REX_STATE_DEATH
}

#define TASK_ATTACK 1113
#define TASK_DASH 1114
#define TASK_TENTACLE 1115
#define TASK_POISON 1116
#define TASK_CYCLONE 1117
#define TASK_HARDENING 1118
#define TASK_TELEPORT 1119

new g_BossState, Float:Time1, Float:Time2, Float:Time3, Float:Time4
new Rex, g_RegHam, m_iBlood[2], g_StopTeleport
new g_MaxPlayers, g_MsgScreenShake

// =========================== SKILL ================================
// ==================================================================
#define ATTACK_MODEL "models/rex/effect/ef_rex_attack.mdl"
#define ATTACK_TENTACLE1 "models/rex/effect/ef_tentacle_sign.mdl"
#define ATTACK_TENTACLE2 "models/rex/effect/ef_tentacle.mdl"
#define ATTACK_TENTACLE "models/rex/rex_tentacle.mdl"

#define BLAST_SMALL "models/rex/effect/ef_skill2_zavist.mdl"
#define BLAST_BIG "models/rex/effect/ef_skill4.mdl"

#define POISON_MODEL "models/rex/effect/ef_poison01.mdl"
#define POISON_MODEL2 "models/rex/effect/ef_poison02.mdl"

#define POISON_SMOKE "sprites/rex/ef_smoke_poison.spr"
#define POISON_EFFECT "sprites/rex/ef_boomer_ex.spr"

#define CYCLONE_EFFECT1 "models/rex/effect/ef_inhale.mdl"
#define CYCLONE_EFFECT2 "models/rex/effect/ef_inhale2.mdl"

#define HARDENING_SHIELD "models/rex/effect/ef_shield.mdl"

#define TENTACLE_SOUND "rex/zbs_tentacle_pierce.wav"

new g_Poison_EffectId

public plugin_init()
{	
static MapName[64]; get_mapname(MapName, sizeof(MapName))	
if(!equal(MapName, MAP)) return	
	
register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")

register_think(REX_CLASSNAME, "fw_Rex_Think")
register_touch(REX_CLASSNAME, "player", "fw_Rex_Touch")

register_think("attack_effect", "fw_Effect1_Think")
register_think("earthhole", "fw_EarthHole_Think")
register_think("tentacle", "fw_Tentacle_Think")
register_think("blast", "fw_Blast_Think")
register_think("poisonist", "fw_Poison_Think")
register_think("poisonist2", "fw_Poison2_Think")
register_think("cyclone", "fw_Cyclone_Think")
register_touch("poisonist", "*", "fw_Poison_Touch")

g_MsgScreenShake = get_user_msgid("ScreenShake")
g_MaxPlayers = get_maxplayers()
}

public plugin_precache()
{
static MapName[64]; get_mapname(MapName, sizeof(MapName))	
if(!equal(MapName, MAP)) return	
	
server_cmd("mp_timelimit 9999")

// Boss Rex
PrecacheModel(REX_MODEL)
PrecacheModel(healthbar_spr)

// Skill
PrecacheModel(ATTACK_MODEL)
PrecacheModel(ATTACK_TENTACLE)
PrecacheModel(ATTACK_TENTACLE1)
PrecacheModel(ATTACK_TENTACLE2)

PrecacheModel(POISON_MODEL)
PrecacheModel(POISON_MODEL2)
PrecacheModel(POISON_EFFECT)

PrecacheModel(CYCLONE_EFFECT1)
PrecacheModel(CYCLONE_EFFECT2)

PrecacheModel(HARDENING_SHIELD)
PrecacheModel(BLAST_SMALL)
PrecacheModel(BLAST_BIG)

for(new i = 0; i < sizeof(RexSounds); i++)
PrecacheSound(RexSounds[i])
PrecacheSound(TENTACLE_SOUND)

m_iBlood[0] = PrecacheModel("sprites/blood.spr")
m_iBlood[1] = PrecacheModel("sprites/bloodspray.spr")
g_Poison_EffectId = PrecacheModel(POISON_SMOKE)	
}

public plugin_cfg()
{
static MapName[64]; get_mapname(MapName, sizeof(MapName))	
if(!equal(MapName, MAP)) return	
	
Event_NewRound()
}

public Event_NewRound()
{	
g_StopTeleport = 0

if(pev_valid(Rex)) remove_entity(Rex)

remove_task(TASK_SCENE)	
remove_task(Rex+TASK_ATTACK)
remove_task(Rex+TASK_DASH)
remove_task(Rex+TASK_TENTACLE)
remove_task(Rex+TASK_POISON)
remove_task(Rex+TASK_CYCLONE)
remove_task(Rex+TASK_HARDENING)
remove_task(Rex+TASK_RECHECK)
}


public zbs_gamemode_start()
{	
Make()
}

public Make()
{
if(pev_valid(Rex)) engfunc(EngFunc_RemoveEntity, Rex)

static Rex1; Rex1 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Rex1)) return

Rex = Rex1

// Set Origin & Angles
set_pev(Rex, pev_origin, {0.0, 0.0, 200.0})

static Float:Angles[3]
Angles[1] = 180.0
set_pev(Rex, pev_angles, Angles)

// Set Config
set_pev(Rex, pev_classname, REX_CLASSNAME)
engfunc(EngFunc_SetModel, Rex, REX_MODEL)
set_pev(Rex, pev_modelindex, engfunc(EngFunc_ModelIndex, REX_MODEL))

set_pev(Rex, pev_gamestate, 1)
set_pev(Rex, pev_solid, SOLID_SLIDEBOX)
set_pev(Rex, pev_movetype, MOVETYPE_PUSHSTEP)

// Set Size
new Float:maxs[3] = {70.0, 70.0, 140.0}
new Float:mins[3] = {-70.0, -70.0, 16.0}
engfunc(EngFunc_SetSize, Rex, mins, maxs)

// Set Life
set_pev(Rex, pev_takedamage, DAMAGE_YES)
set_pev(Rex, pev_health, HEALTH_OFFSET + REX_HEALTH)

// Set Config 2
Set_EntAnim(Rex, REX_APPEAR, 1.0, 1)
g_BossState = REX_STATE_APPEAR

healthbar = create_entity("env_sprite")
set_pev(healthbar, pev_scale, 1.0)
set_pev(healthbar, pev_owner, Rex)

set_pev(healthbar, pev_classname, HEALTH_CLASSNAME)
engfunc(EngFunc_SetModel, healthbar, healthbar_spr)	

//set_task(0.1, "recheck_boss", Rex+TASK_RECHECK, _, _, "b")
set_pev(Rex, pev_nextthink, get_gametime() + 1.0)

if(!g_RegHam)
{
g_RegHam = 1
RegisterHamFromEntity(Ham_TraceAttack, Rex, "fw_Rex_TraceAttack")
}

engfunc(EngFunc_DropToFloor, Rex)
}

public recheck_boss(ent)
{
ent -= TASK_RECHECK

if(!pev_valid(ent))
{
remove_task(ent+TASK_RECHECK)
return
}

if(pev_valid(healthbar))
{
static Float:Origin[3], Float:rex_health
pev(ent, pev_origin, Origin)
Origin[2] += 250.0	
engfunc(EngFunc_SetOrigin, healthbar, Origin)
pev(ent, pev_health, rex_health)
if(REX_HEALTH < (rex_health - 1000.0))
{
set_pev(healthbar, pev_frame, 101.0)
}
else
{
set_pev(healthbar, pev_frame, 0.0 + ((((rex_health - 1000.0) - 1 ) * 100) / REX_HEALTH))
}	
}
}


public fw_Rex_Think(ent)
{
if(!pev_valid(ent))
return
if(g_BossState == REX_STATE_DEATH)
return

if((pev(ent, pev_health) - HEALTH_OFFSET) <= 0.0)
{
Rex_Death(ent)
return
}

set_pev(ent, pev_nextthink, get_gametime() + 0.01)

if(get_gametime() - Time4 > Time3)
{
static RandomNum; RandomNum = random_num(0, 4)

switch(RandomNum)
{
case 0: Rex_Dashing(Rex)
case 1: Rex_Tentacle(Rex)
case 2: Rex_Poison(Rex)
case 3: Rex_Cyclone(Rex)
case 4: Rex_Teleport(Rex)
default: Rex_Dashing(Rex)
}

Time4 = random_float(5.0, 15.0)
Time3 = get_gametime()
}

switch(g_BossState)
{
case REX_STATE_APPEAR:
{
g_BossState = REX_STATE_IDLE

Make_PlayerShake(0)
static Float:Origin[3]; pev(ent, pev_origin, Origin)
CreateBlast(1, Origin)

set_pev(ent, pev_nextthink, get_gametime() + 3.5)
}
case REX_STATE_IDLE:
{
if(get_gametime() - 5.0 > Time1)
{
Set_EntAnim(ent, REX_IDLE, 2.0, 1)
Time1 = get_gametime()
}
if(get_gametime() - 1.0 > Time2)
{
g_BossState = REX_STATE_SEARCHING_ENEMY
Time2 = get_gametime()
}
}
case REX_STATE_SEARCHING_ENEMY:
{
static Victim; Victim = FindClosetEnemy(ent, 1)

if(is_user_alive(Victim))
{
set_pev(ent, pev_enemy, Victim)
g_BossState = REX_STATE_MOVE
} else {
set_pev(ent, pev_enemy, 0)
g_BossState = REX_STATE_IDLE
}
}
case REX_STATE_MOVE:
{
static Enemy; Enemy = pev(ent, pev_enemy)
static Float:EnemyOrigin[3]
pev(Enemy, pev_origin, EnemyOrigin)

if(is_user_alive(Enemy))
{
if(entity_range(Enemy, ent) <= floatround(REX_ATTACK_RANGE))
{
g_BossState = REX_STATE_ATTACK

Aim_To(ent, EnemyOrigin, 2.0, 1) 

if(random_num(0, 1) == 1) Rex_StartAttack11(ent+TASK_ATTACK)
else Rex_StartAttack12(ent+TASK_ATTACK)
} else {
if(pev(ent, pev_movetype) == MOVETYPE_PUSHSTEP)
{
static Float:OriginAhead[3]
get_position(ent, 300.0, 0.0, 0.0, OriginAhead)

Aim_To(ent, EnemyOrigin, 1.0, 1) 
hook_ent2(ent, OriginAhead, REX_MOVESPEED)
KillZombies(ent)
Set_EntAnim(ent, REX_RUN, 1.0, 0)
} else {
set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)
}
}
} else {
g_BossState = REX_STATE_SEARCHING_ENEMY
}
}
case REX_STATE_SKILL4A:
{
static Enemy; Enemy = pev(ent, pev_enemy)
static Float:EnemyOrigin[3]
pev(Enemy, pev_origin, EnemyOrigin)

if(is_user_alive(Enemy))
{
Aim_To(ent, EnemyOrigin, 2.0, 0) 
}
}
case REX_STATE_SKILL4B:
{
static Victim; Victim = pev(ent, pev_enemy)
static Float:EnemyOrigin[3]
pev(Victim, pev_origin, EnemyOrigin)

if(is_user_alive(Victim))
{
if(entity_range(ent, Victim) < 175.0)
{
TeleportAttack(ent, Victim)
} else {
Set_EntAnim(ent, REX_SKILL4A_LOOP, 1.0, 0)

Aim_To(ent, EnemyOrigin, 2.0, 0) 

static Float:Origin[3]; pev(Victim, pev_origin, Origin)
hook_ent2(ent, Origin, 1000.0)
KillZombies(ent)
}
} else {
Victim = FindClosetEnemy(ent, 1)
if(is_user_alive(Victim))
{
Set_EntAnim(ent, REX_SKILL4A_LOOP, 1.0, 0)

set_pev(ent, pev_enemy, Victim)
} else {
set_pev(ent, pev_enemy, 0)
Rex_StopTeleport(ent+TASK_TELEPORT)
}
}
}	
}	
}
public KillZombies(ent)
{
if(!pev_valid(ent))
return

static Float:origin[3]
pev(ent, pev_origin, origin)

static victim; victim = -1
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 100.0)) != 0)
{	
if(zbs_is_zombie(victim))
ExecuteHamB(Ham_TakeDamage, victim, 0, 0, 10.0, DMG_GENERIC)
}
}

public Rex_Death(Ent)
{
if(!pev_valid(Ent))
return

g_BossState = REX_STATE_DEATH

set_pev(Ent, pev_solid, SOLID_NOT)
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.1, "Rex_Death2", Ent)
}

public Rex_Death2(Ent)
{
Set_EntAnim(Ent, REX_DEATH, 1.0, 1)
set_task(8.0, "Set_Death", Ent+TASK_SCENE)
}

public Set_Death(Ent)
{
Ent -= TASK_SCENE
if(!pev_valid(Ent))
return
	
Set_EntAnim(Ent, REX_DEATH2, 1.0, 1)

set_task(10.0, "ChangeMap")
}

public ChangeMap()
{
server_cmd("mp_timelimit 1")
}

public Rex_StartAttack11(ent)
{
ent -= TASK_ATTACK
if(!pev_valid(ent))
return

set_pev(ent, pev_movetype, MOVETYPE_NONE)
set_pev(ent, pev_velocity, {0.0, 0.0, 0.0})	

set_task(0.1, "Rex_StartAttack112", ent+TASK_ATTACK)
}

public Rex_StartAttack12(ent)
{
ent -= TASK_ATTACK
if(!pev_valid(ent))
return

set_pev(ent, pev_movetype, MOVETYPE_NONE)
set_pev(ent, pev_velocity, {0.0, 0.0, 0.0})	

set_task(0.1, "Rex_StartAttack122", ent+TASK_ATTACK)	
}

public Rex_StartAttack112(ent)
{
ent -= TASK_ATTACK
if(!pev_valid(ent))
return

Set_EntAnim(ent, REX_ATTACK1, 1.0, 1)

set_task(0.5, "Effect_Attack1", ent+TASK_ATTACK)
set_task(1.75, "Done_Attack", ent+TASK_ATTACK)	
}

public Rex_StartAttack122(ent)
{
ent -= TASK_ATTACK
if(!pev_valid(ent))
return

Set_EntAnim(ent, REX_ATTACK2, 1.0, 1)

set_task(0.5, "Effect_Attack2", ent+TASK_ATTACK)
set_task(1.75, "Done_Attack", ent+TASK_ATTACK)	
}

public Effect_Attack1(ent)
{
ent -= TASK_ATTACK
if(!pev_valid(ent))
return

static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Ent)) return

static Float:Vector[3]

pev(ent, pev_origin, Vector); set_pev(Ent, pev_origin, Vector)
pev(ent, pev_angles, Vector); set_pev(Ent, pev_angles, Vector)

// Set Config
set_pev(Ent, pev_classname, "attack_effect")
engfunc(EngFunc_SetModel, Ent, ATTACK_MODEL)

set_pev(Ent, pev_movetype, MOVETYPE_FOLLOW)
set_pev(Ent, pev_aiment, ent)

// Set Size
new Float:maxs[3] = {1.0, 1.0, 1.0}
new Float:mins[3] = {-1.0, -1.0, -1.0}
engfunc(EngFunc_SetSize, Ent, mins, maxs)

Set_EntAnim(Ent, 0, 1.0, 1)

Check_AttackDamge(Ent)
set_pev(Ent, pev_nextthink, get_gametime() + 1.0)
}

public Effect_Attack2(ent)
{
ent -= TASK_ATTACK
if(!pev_valid(ent))
return

static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Ent)) return

static Float:Vector[3]

pev(ent, pev_origin, Vector); set_pev(Ent, pev_origin, Vector)
pev(ent, pev_angles, Vector); set_pev(Ent, pev_angles, Vector)

// Set Config
set_pev(Ent, pev_classname, "attack_effect")
engfunc(EngFunc_SetModel, Ent, ATTACK_MODEL)

set_pev(Ent, pev_movetype, MOVETYPE_FOLLOW)
set_pev(Ent, pev_aiment, ent)

// Set Size
new Float:maxs[3] = {1.0, 1.0, 1.0}
new Float:mins[3] = {-1.0, -1.0, -1.0}
engfunc(EngFunc_SetSize, Ent, mins, maxs)

Set_EntAnim(Ent, 1, 1.0, 1)	

Check_AttackDamge(Ent)
set_pev(Ent, pev_nextthink, get_gametime() + 1.0)
}

public Check_AttackDamge(Ent)
{
static Float:Origin[3]; get_position(Ent, 250.0, 0.0, 0.0, Origin)
static Float:POrigin[3]

for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue

pev(i, pev_origin, POrigin)
if(get_distance_f(Origin, POrigin) > 250.0)
continue

//ExecuteHamB(Ham_TakeDamage, i, 0, i, random_float(5.0, 20.0), DMG_BLAST)
do_attack(i, i, 0, random_float(5.0, 20.0), 1)
Make_PlayerShake(i)
}
}

public fw_Effect1_Think(Ent)
{
if(!pev_valid(Ent))
return

set_pev(Ent, pev_flags, FL_KILLME)
}

public Done_Attack(ent)
{
ent -= TASK_ATTACK
if(!pev_valid(ent))
return

set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)		
g_BossState = REX_STATE_MOVE
}

public fw_Rex_TraceAttack(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{
if(!is_valid_ent(Ent)) 
return HAM_IGNORED

if(g_BossState == REX_STATE_SKILL5)
return HAM_SUPERCEDE

static Classname[32]
pev(Ent, pev_classname, Classname, charsmax(Classname)) 

if(!equal(Classname, REX_CLASSNAME)) 
return HAM_IGNORED

static Float:g_fHaveDamage[33]

g_fHaveDamage[Attacker] += Damage;
	
if (g_fHaveDamage[Attacker] >= 3000.0)
{
zb5_set_user_exp(Attacker, 1, 0)	
g_fHaveDamage[Attacker] = 0.0
}

static Float:EndPos[3] 
get_tr2(ptr, TR_vecEndPos, EndPos)

create_blood(EndPos)
return HAM_IGNORED
}

public Skill(id)
{
Rex_Teleport(Rex)
}

// ================= DASH ========================
public Rex_Dashing(Ent)
{
if(!pev_valid(Ent)) return

if(g_BossState == REX_STATE_IDLE || g_BossState == REX_STATE_MOVE)
{
g_BossState = REX_STATE_DASH
//set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.1, "Rex_DashStart", Ent+TASK_DASH)	
}
}

public Rex_DashStart(ent)
{
ent -= TASK_DASH
if(!pev_valid(ent))
return	

Set_EntAnim(ent, REX_DASH_START, 1.0, 1)

//set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)
set_task(1.0, "Rex_SDashing", ent+TASK_DASH)
set_task(1.0, "DashingHandle", ent+TASK_DASH)
}

public Rex_SDashing(ent)
{
ent -= TASK_DASH
if(!pev_valid(ent))
return	

Set_EntAnim(ent, REX_DASH_LOOP, 1.0, 1)

set_task(2.0, "Rex_Stop_Dashing", ent+TASK_DASH)
}

public DashingHandle(Ent)
{
Ent -= TASK_DASH
if(!pev_valid(Ent))
return	

static Float:OriginAhead[3]
get_position(Ent, 300.0, 0.0, 0.0, OriginAhead)

hook_ent2(Ent, OriginAhead, 5000.0)

set_task(0.01, "DashingHandle", Ent+TASK_DASH)
}

public Rex_Stop_Dashing(ent)
{
ent -= TASK_DASH
if(!pev_valid(ent))
return	

remove_task(ent+TASK_DASH)

Set_EntAnim(ent, REX_DASH_END, 1.0, 1)
set_task(1.0, "Rex_End_Dashing", ent+TASK_DASH)
}

public Rex_End_Dashing(ent)
{
ent -= TASK_DASH
if(!pev_valid(ent))
return	

set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)		
g_BossState = REX_STATE_SEARCHING_ENEMY

set_pev(ent, pev_nextthink, get_gametime() + 0.1)
}

// ==================== Tentacle 
public Rex_Tentacle(Ent)
{
if(!pev_valid(Ent)) return

if(g_BossState == REX_STATE_IDLE || g_BossState == REX_STATE_MOVE)
{
g_BossState = REX_STATE_SKILL1
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.1, "Rex_TentacleStart", Ent+TASK_TENTACLE)	
}
}

public Rex_TentacleStart(Ent)
{
Ent -= TASK_TENTACLE
if(!pev_valid(Ent))
return	

Set_EntAnim(Ent, REX_SKILL1, 1.0, 1)

set_task(3.75, "Rex_TentacleEffect", Ent+TASK_TENTACLE)
set_task(4.0, "Rex_TentacleActive", Ent+TASK_TENTACLE)
set_task(6.25, "Rex_TentacleEnd", Ent+TASK_TENTACLE)
}

public Rex_TentacleEnd(Ent)
{
Ent -= TASK_TENTACLE
if(!pev_valid(Ent))
return	

set_pev(Ent, pev_movetype, MOVETYPE_PUSHSTEP)		
g_BossState = REX_STATE_SEARCHING_ENEMY

set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
}

public Rex_TentacleEffect(Ent)
{
Ent -= TASK_TENTACLE
if(!pev_valid(Ent))
return	

static Float:Origin[3]
get_position(Ent, 120.0, -40.0, 0.0, Origin)

CreateBlast(0, Origin)
Make_PlayerShake(0)
}

public Rex_TentacleActive(Ent)
{
Ent -= TASK_TENTACLE
if(!pev_valid(Ent))
return	

static Float:RanOrigin[16][3]

for(new i = 0; i < 16; i++)
{
RanOrigin[i][0] = random_float(-700.0, 700.0)
RanOrigin[i][1] = random_float(-700.0, 700.0)
RanOrigin[i][2] = 97.5

Create_Tentacle(Ent, RanOrigin[i])
}
}

public Create_Tentacle(Boss, Float:Origin[3])
{
static EarthHole; EarthHole = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
if(!pev_valid(EarthHole)) return

engfunc(EngFunc_SetOrigin, EarthHole, Origin)

// Set Config
set_pev(EarthHole, pev_gamestate, 1)
set_pev(EarthHole, pev_classname, "earthhole")
engfunc(EngFunc_SetModel, EarthHole, ATTACK_TENTACLE1)
set_pev(EarthHole, pev_solid, SOLID_NOT)
set_pev(EarthHole, pev_movetype, MOVETYPE_NONE)

// Set Size
new Float:maxs[3] = {0.0, 0.0, 0.0}
new Float:mins[3] = {0.0, 0.0, 0.0}
entity_set_size(EarthHole, mins, maxs)

set_pev(EarthHole, pev_iuser1, 0)

fm_set_rendering(EarthHole, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 100)

Set_EntAnim(EarthHole, 0, 1.0, 1)
set_pev(EarthHole, pev_nextthink, get_gametime() + random_float(0.5, 2.5))
}

public fw_EarthHole_Think(Ent)
{
if(!pev_valid(Ent))
return
if(pev(Ent, pev_iuser1))
{
set_pev(Ent, pev_flags, FL_KILLME)
return
}

static Float:Origin[3]; pev(Ent, pev_origin, Origin)

Create_Tentacle2(Origin)
engfunc(EngFunc_SetModel, Ent, ATTACK_TENTACLE2)

set_pev(Ent, pev_iuser1, 1)
set_pev(Ent, pev_nextthink, get_gametime() + random_float(2.0, 5.0))
}

public Create_Tentacle2(Float:Origin[3])
{
static Tentacle; Tentacle = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Tentacle)) return

engfunc(EngFunc_SetOrigin, Tentacle, Origin)

// Set Config
set_pev(Tentacle, pev_gamestate, 1)
set_pev(Tentacle, pev_classname, "tentacle")
engfunc(EngFunc_SetModel, Tentacle, ATTACK_TENTACLE)
set_pev(Tentacle, pev_solid, SOLID_NOT)
set_pev(Tentacle, pev_movetype, MOVETYPE_NONE)

// Set Size
new Float:maxs[3] = {0.0, 0.0, 0.0}
new Float:mins[3] = {0.0, 0.0, 0.0}
entity_set_size(Tentacle, mins, maxs)
Set_EntAnim(Tentacle, 1, 1.0, 1)

static Float:POrigin[3]
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue

pev(i, pev_origin, POrigin)

if(get_distance_f(POrigin, Origin) < 250.0)
Make_PlayerShake(i)

if(get_distance_f(POrigin, Origin) < 60.0)
{
//ExecuteHamB(Ham_TakeDamage, i, 0, i, random_float(35.0, 50.0), DMG_BLAST)
do_attack(i, i, 0, random_float(35.0, 50.0), 1)
static Float:Velocity[3]
Velocity[0] = random_float(0.0, 200.0)
Velocity[1] = random_float(0.0, 200.0)
Velocity[2] = random_float(600.0, 900.0)
set_pev(i, pev_velocity, Velocity)
}
}

emit_sound(Tentacle, CHAN_BODY, TENTACLE_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
set_pev(Tentacle, pev_nextthink, get_gametime() + 1.0)
}

public fw_Tentacle_Think(Ent)
{
if(!pev_valid(Ent))
return

set_pev(Ent, pev_flags, FL_KILLME)
}

// ==================== POISON
public Rex_Poison(Ent)
{
if(!pev_valid(Ent)) return

if(g_BossState == REX_STATE_IDLE || g_BossState == REX_STATE_MOVE)
{
g_BossState = REX_STATE_SKILL2
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.1, "Rex_PoisonStart", Ent+TASK_POISON)	
}
}

public Rex_PoisonStart(Ent)
{
Ent -= TASK_POISON
if(!pev_valid(Ent))
return	

Set_EntAnim(Ent, REX_SKILL2, 1.0, 1)

set_task(2.75, "Rex_PoisonActive", Ent+TASK_POISON)
set_task(4.5, "Rex_PoisonEnd", Ent+TASK_POISON)
}

public Rex_PoisonEnd(Ent)
{
Ent -= TASK_POISON
if(!pev_valid(Ent))
return	

set_pev(Ent, pev_movetype, MOVETYPE_PUSHSTEP)		
g_BossState = REX_STATE_SEARCHING_ENEMY

set_pev(Ent, pev_nextthink, get_gametime() + 0.1)	
}

public Rex_PoisonActive(Ent)
{
Ent -= TASK_POISON
if(!pev_valid(Ent))
return	

static Float:StartOrigin[12][3], Float:TargetOrigin[12][3]

get_position(Ent, 180.0, 60.0, 80.0, StartOrigin[0]); get_position(Ent, 180.0 * 3.0, 60.0 * 3.0, 20.0, TargetOrigin[0])
get_position(Ent, 180.0, 40.0, 80.0, StartOrigin[1]); get_position(Ent, 180.0 * 3.0, 40.0 * 3.0, 10.0, TargetOrigin[1])
get_position(Ent, 180.0, 20.0, 80.0, StartOrigin[2]); get_position(Ent, 180.0 * 3.0, 20.0 * 3.0, 20.0, TargetOrigin[2])
get_position(Ent, 180.0, -20.0, 80.0, StartOrigin[3]); get_position(Ent, 180.0 * 3.0, -20.0 * 3.0, 10.0, TargetOrigin[3])
get_position(Ent, 180.0, -40.0, 80.0, StartOrigin[4]); get_position(Ent, 180.0 * 3.0, -40.0 * 3.0, 20.0, TargetOrigin[4])
get_position(Ent, 180.0, -60.0, 80.0, StartOrigin[5]); get_position(Ent, 180.0 * 3.0, -60.0 * 3.0, 10.0, TargetOrigin[5])	

get_position(Ent, 200.0, 90.0, 100.0, StartOrigin[6]); get_position(Ent, 200.0 * 4.0, 90.0 * 3.0, 40.0, TargetOrigin[6])
get_position(Ent, 200.0, 60.0, 100.0, StartOrigin[7]); get_position(Ent, 200.0 * 4.0, 60.0 * 3.0, 30.0, TargetOrigin[7])
get_position(Ent, 200.0, 30.0, 100.0, StartOrigin[8]); get_position(Ent, 200.0 * 4.0, 30.0 * 3.0, 40.0, TargetOrigin[8])
get_position(Ent, 200.0, -30.0, 100.0, StartOrigin[9]); get_position(Ent, 200.0 * 4.0, -30.0 * 3.0, 30.0, TargetOrigin[9])
get_position(Ent, 200.0, -60.0, 100.0, StartOrigin[10]); get_position(Ent, 200.0 * 4.0, -60.0 * 3.0, 40.0, TargetOrigin[10])
get_position(Ent, 200.0, -90.0, 100.0, StartOrigin[11]); get_position(Ent, 200.0 * 4.0, -90.0 * 3.0, 30.0, TargetOrigin[11])	

for(new i = 0; i < 12; i++)
CreatePoison(Ent, StartOrigin[i], TargetOrigin[i])
}

public CreatePoison(Ent, Float:Origin[3], Float:Target[3])
{
static Poison; Poison = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
if(!pev_valid(Poison)) return

static Float:Vector[3]; pev(Ent, pev_angles, Vector)

engfunc(EngFunc_SetOrigin, Poison, Origin)
set_pev(Poison, pev_angles, Vector)

// Set Config
set_pev(Poison, pev_gamestate, 1)
set_pev(Poison, pev_classname, "poisonist")

engfunc(EngFunc_SetModel, Poison, POISON_MODEL)

set_pev(Poison, pev_solid, SOLID_TRIGGER)
set_pev(Poison, pev_movetype, MOVETYPE_FLY)

// Set Size
new Float:maxs[3] = {5.0, 5.0, 5.0}
new Float:mins[3] = {-5.0, -5.0, -5.0}
entity_set_size(Poison, mins, maxs)

fm_set_rendering(Poison, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 250)
set_pev(Poison, pev_nextthink, get_gametime() + 0.75)

// Target
hook_ent2(Poison, Target, 5000.0)
Aim_To(Poison, Target, 0.0, 0)

set_pev(Poison, pev_nextthink, get_gametime() + random_float(2.0, 3.0))
}

public fw_Poison_Think(Ent)
{
if(!pev_valid(Ent))
return

set_pev(Ent, pev_flags, FL_KILLME)
}

public fw_Poison_Touch(Ent, Id)
{
if(!pev_valid(Ent))
return

set_pev(Ent, pev_solid, SOLID_NOT)
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

engfunc(EngFunc_SetModel, Ent, POISON_MODEL2)

set_pev(Ent, pev_angles, {0.0, 0.0, 0.0})
engfunc(EngFunc_DropToFloor, Ent)

static Float:Origin[3]; pev(Ent, pev_origin, Origin)
Create_PoisonEffect(Origin)
}

public Create_PoisonEffect(Float:Origin[3])
{
message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] - 10.0)
write_short(g_Poison_EffectId)	// sprite index
write_byte(20)	// scale in 0.1's
write_byte(3)	// framerate
write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NOPARTICLES)
message_end()

Create_PoisonEffect2(Origin)
Check_DamagePoison(Origin)
}

public Create_PoisonEffect2(Float:Origin[3])
{
static Poison; Poison = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))

set_pev(Poison, pev_origin, Origin)

set_pev(Poison, pev_movetype, MOVETYPE_NONE)
set_pev(Poison, pev_rendermode, kRenderTransAdd)
set_pev(Poison, pev_renderamt, 100.0)
set_pev(Poison, pev_scale, 0.1)
set_pev(Poison, pev_nextthink, get_gametime() + 0.05)
set_pev(Poison, pev_fuser1, get_gametime() + 3.0)

set_pev(Poison, pev_classname, "poisonist2")
engfunc(EngFunc_SetModel, Poison, POISON_EFFECT)
set_pev(Poison, pev_mins, Float:{-5.0, -5.0, -10.0})
set_pev(Poison, pev_maxs, Float:{5.0, 5.0, 10.0})

set_pev(Poison, pev_gravity, 1.0)
set_pev(Poison, pev_solid, SOLID_TRIGGER)	
}

public Check_DamagePoison(Float:Origin[3])
{
static Float:POrigin[3]
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue

pev(i, pev_origin, POrigin)
if(get_distance_f(Origin, POrigin) > 120.0)
continue

Make_PlayerShake(i)
do_attack(i, i, 0, random_float(50.0, 80.0), 1)

//ExecuteHamB(Ham_TakeDamage, i, 0, i, random_float(40.0, 60.0), DMG_BLAST)
}
}

public fw_Poison2_Think(iEnt)
{
if(!pev_valid(iEnt)) 
return

static Float:fScale
pev(iEnt, pev_scale, fScale)

fScale += 0.05
fScale = floatmin(fScale, 2.0)

set_pev(iEnt, pev_scale, fScale)
set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)

// time remove
static Float:fTimeRemove
pev(iEnt, pev_fuser1, fTimeRemove)
if (get_gametime() >= fTimeRemove)
{
static Float:fAmt; pev(iEnt, pev_renderamt, fAmt)

if(fAmt <= 0.0)
{
set_pev(iEnt, pev_flags, FL_KILLME)
return
} else {
fAmt -= 10.0
set_pev(iEnt, pev_renderamt, fAmt)
}
}	
}

// ====================== CYCLONE
public Rex_Cyclone(Ent)
{
if(!pev_valid(Ent)) return

if(g_BossState == REX_STATE_IDLE || g_BossState == REX_STATE_MOVE)
{
g_BossState = REX_STATE_SKILL3
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.1, "Rex_CycloneStart", Ent+TASK_CYCLONE)	
}
}

public Rex_CycloneStart(ent)
{
ent -= TASK_CYCLONE
if(!pev_valid(ent))
return	

Set_EntAnim(ent, REX_SKILL3_START, 1.0, 1)

set_task(1.5, "Rex_SCyclone", ent+TASK_CYCLONE)
}

public Rex_SCyclone(ent)
{
ent -= TASK_CYCLONE
if(!pev_valid(ent))
return	

Set_EntAnim(ent, REX_SKILL3_LOOP, 1.0, 1)
EmitSound(ent, CHAN_BODY, RexSounds[5])

set_task(0.1, "Rex_CycloneGet", ent+TASK_CYCLONE, _, _, "b")
set_task(5.0, "Rex_Stop_Cyclone", ent+TASK_CYCLONE)

Create_CycloneEffect(ent)
}

public Rex_CycloneGet(Ent)
{
Ent -= TASK_CYCLONE
if(!pev_valid(Ent))
return	

static Float:Origin[3], Float:EntOrigin[3], Float:EntOrigin2[3]

pev(Ent, pev_origin, EntOrigin2)
get_position(Ent, 500.0, 0.0, 0.0, EntOrigin)

for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue

pev(i, pev_origin, Origin)

if(get_distance_f(Origin, EntOrigin2) <= 100.0)
{
user_kill(i)
continue
}

if(get_distance_f(Origin, EntOrigin) > 650.0)
continue
/*
if(get_distance_f(Origin, EntOrigin) <= 200.0)
{
Make_PlayerShake(i)
hook_ent2(i, EntOrigin2, 500.0)
continue
}*/

Make_PlayerShake(i)
hook_ent2(i, EntOrigin2, 500.0)
}
}

public Rex_Stop_Cyclone(ent)
{
ent -= TASK_CYCLONE
if(!pev_valid(ent))
return	

remove_task(ent+TASK_CYCLONE)

static Float:Percent
Percent = ((pev(ent, pev_health) - HEALTH_OFFSET) / REX_HEALTH) * 100.0

if(Percent >= 70.0)
{
Set_EntAnim(ent, REX_SKILL3_END, 1.0, 1)
set_task(1.0, "Rex_End_Cyclone", ent+TASK_CYCLONE)
} else {
switch(random_num(0, 100))
{
case 0..50: 
{
Rex_Hardening(ent)
} 
case 51..100:
{
Set_EntAnim(ent, REX_SKILL3_END, 1.0, 1)
set_task(1.0, "Rex_End_Cyclone", ent+TASK_CYCLONE)
}
}
}
}

public Rex_End_Cyclone(ent)
{
ent -= TASK_CYCLONE
if(!pev_valid(ent))
return	

set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)		
g_BossState = REX_STATE_SEARCHING_ENEMY

set_pev(ent, pev_nextthink, get_gametime() + 0.1)
}

public Create_CycloneEffect(Boss)
{
static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Ent)) return

static Float:Vector[3]

pev(Boss, pev_origin, Vector); 
Vector[2] += 36.0
set_pev(Ent, pev_origin, Vector)
pev(Boss, pev_angles, Vector); set_pev(Ent, pev_angles, Vector)

// Set Config
set_pev(Ent, pev_classname, "cyclone")
engfunc(EngFunc_SetModel, Ent, CYCLONE_EFFECT1)

set_pev(Ent, pev_movetype, MOVETYPE_FOLLOW)
//	set_pev(Ent, pev_aiment, Boss)

//set_pev(Ent, pev_rendermode, kRenderTransAdd)
//set_pev(Ent, pev_renderamt, 250.0)	

// Set Size
new Float:maxs[3] = {1.0, 1.0, 1.0}
new Float:mins[3] = {-1.0, -1.0, -1.0}
engfunc(EngFunc_SetSize, Ent, mins, maxs)

Set_EntAnim(Ent, 0, 1.0, 1)
set_pev(Ent, pev_nextthink, get_gametime() + 5.0)

// Effect 2
static Ent2; Ent2 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Ent2)) return

pev(Boss, pev_origin, Vector); 

Vector[2] += 36.0
set_pev(Ent2, pev_origin, Vector)
pev(Boss, pev_angles, Vector); set_pev(Ent2, pev_angles, Vector)

// Set Config
set_pev(Ent2, pev_classname, "cyclone")
engfunc(EngFunc_SetModel, Ent2, CYCLONE_EFFECT2)

set_pev(Ent2, pev_movetype, MOVETYPE_FOLLOW)
//set_pev(Ent2, pev_aiment, Boss)

//set_pev(Ent2, pev_rendermode, kRenderTransAdd)
//set_pev(Ent2, pev_renderamt, 250.0)		

// Set Size
engfunc(EngFunc_SetSize, Ent2, mins, maxs)

Set_EntAnim(Ent2, 0, 1.0, 1)
set_pev(Ent2, pev_nextthink, get_gametime() + 5.0)
}

public fw_Cyclone_Think(Ent)
{
if(!pev_valid(Ent)) 
return

set_pev(Ent, pev_nextthink, get_gametime() + 0.1)

static Float:fAmt; pev(Ent, pev_renderamt, fAmt)
if(fAmt <= 0.0)
{
set_pev(Ent, pev_flags, FL_KILLME)
return
} else {
fAmt -= 10.0
set_pev(Ent, pev_renderamt, fAmt)
}
}

// ====================== Hardening
public Rex_Hardening(Ent)
{
if(!pev_valid(Ent)) return

if(g_BossState == REX_STATE_SKILL3)
{
g_BossState = REX_STATE_SKILL5
set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.1, "Rex_HardeningStart", Ent+TASK_HARDENING)	
}
}

public Rex_HardeningStart(ent)
{
ent -= TASK_HARDENING
if(!pev_valid(ent))
return	

// Effect
static Float:Origin[3];
pev(ent, pev_origin, Origin)

Make_ScreenFade(0, 0.25, 255, 255 ,255 ,255, FADE_IN)
Make_PlayerShake(0)
CreateBlast(1, Origin)

// Heal
static Health; Health = pev(ent, pev_health)
Health -= floatround(HEALTH_OFFSET)
static NewHealth; NewHealth = min(floatround(REX_HEALTH), Health + floatround(REX_HEALTH / 4.0))

set_pev(ent, pev_health, float(NewHealth) + HEALTH_OFFSET)

// Shield
CreateShield(Origin)

Check_Knockback(Origin, 0)

// Continue
Set_EntAnim(ent, REX_SKILL5_START, 1.0, 1)
set_task(0.5, "Rex_SHardening", ent+TASK_HARDENING)
}

public Rex_SHardening(ent)
{
ent -= TASK_HARDENING
if(!pev_valid(ent))
return	

Set_EntAnim(ent, REX_SKILL5_LOOP, 1.0, 1)
set_task(5.0, "Rex_StopHardening", ent+TASK_HARDENING)
}

public Rex_StopHardening(ent)
{
ent -= TASK_HARDENING
if(!pev_valid(ent))
return	

remove_task(ent+TASK_HARDENING)

static Float:Origin[3];
pev(ent, pev_origin, Origin)

Make_ScreenFade(0, 0.25, 255, 255 ,255 ,255, FADE_IN)
Make_PlayerShake(0)
CreateBlast(1, Origin)	

Check_Knockback(Origin, 1)

Set_EntAnim(ent, REX_SKILL5_END, 1.0, 1)
set_task(2.0, "Rex_EndHardening", ent+TASK_HARDENING)
}

public Rex_EndHardening(ent)
{
ent -= TASK_HARDENING
if(!pev_valid(ent))
return	

set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)		
g_BossState = REX_STATE_SEARCHING_ENEMY

set_pev(ent, pev_nextthink, get_gametime() + 0.1)
}

public Check_Knockback(Float:Origin[3], Damage)
{
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue

fuck_ent(i, Origin, 5000.0)
if(Damage) 
{
if(entity_range(i, Rex) < 800.0)
{
ExecuteHamB(Ham_TakeDamage, i, 0, i, 300.0, DMG_BLAST)
}
}
}
}

public CreateShield(Float:Origin[3])
{
static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Ent)) return

set_pev(Ent, pev_origin, Origin)

// Set Config
set_pev(Ent, pev_classname, "tentacle")
engfunc(EngFunc_SetModel, Ent, HARDENING_SHIELD)

set_pev(Ent, pev_movetype, MOVETYPE_NONE)
set_pev(Ent, pev_solid, SOLID_BBOX)

set_pev(Ent, pev_rendermode, kRenderTransAdd)
set_pev(Ent, pev_renderfx, kRenderFxGlowShell)
set_pev(Ent, pev_renderamt, 100.0)	

// Set Size
new Float:maxs[3] = {250.0, 250.0, 250.0}
new Float:mins[3] = {-250.0, -250.0, -250.0}
engfunc(EngFunc_SetSize, Ent, mins, maxs)

Set_EntAnim(Ent, 0, 1.0, 1)
set_pev(Ent, pev_nextthink, get_gametime() + 6.0)
}
// ====================== Teleport
public Rex_Teleport(Ent)
{
if(!pev_valid(Ent)) return

if(g_BossState == REX_STATE_IDLE || g_BossState == REX_STATE_MOVE)
{
g_BossState = REX_STATE_SKILL4C
//set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.1, "Rex_TeleportStart", Ent+TASK_TELEPORT)	
}
}

public Rex_TeleportStart(ent)
{
ent -= TASK_TELEPORT
if(!pev_valid(ent))
return	

g_StopTeleport = 0	

Set_EntAnim(ent, REX_SKILL4A_START, 1.0, 1)

//set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)
set_task(1.0, "Rex_STeleport", ent+TASK_TELEPORT)
set_task(0.85, "TeleportHandle", ent+TASK_TELEPORT)
set_task(5.0, "Rex_StopTeleportF", ent+TASK_TELEPORT)
}

public Rex_STeleport(ent)
{
ent -= TASK_TELEPORT
if(!pev_valid(ent))
return	

Set_EntAnim(ent, REX_SKILL4A_LOOP, 1.0, 1)

set_pev(ent, pev_rendermode, kRenderTransAdd)
set_pev(ent, pev_renderfx, kRenderFxGlowShell)
set_pev(ent, pev_renderamt, 200.0)		
}

public TeleportHandle(Ent)
{
Ent -= TASK_TELEPORT
if(!pev_valid(Ent))
return	

set_pev(Ent, pev_rendermode, kRenderTransAdd)
set_pev(Ent, pev_renderfx, kRenderFxGlowShell)
set_pev(Ent, pev_renderamt, 200.0)

g_BossState = REX_STATE_SKILL4B
}

public TeleportAttack(Ent, Victim)
{
g_BossState = REX_STATE_SKILL4A

set_pev(Ent, pev_movetype, MOVETYPE_NONE)

set_task(0.5, "TeleportAttackDMG", Ent+TASK_TELEPORT)
set_task(0.1, "TeleportAttack2", Ent+TASK_TELEPORT)
}

public TeleportAttackDMG(Ent)
{
Ent -= TASK_TELEPORT
if(!pev_valid(Ent))
return	

Check_AttackDamge(Ent)
}

public TeleportAttack2(Ent)
{
Ent -= TASK_TELEPORT
if(!pev_valid(Ent))
return	

set_pev(Ent, pev_rendermode, kRenderTransAlpha)
set_pev(Ent, pev_renderfx, kRenderFxNone)
set_pev(Ent, pev_renderamt, 255.0)		

Set_EntAnim(Ent, REX_SKILL4A_END, 1.0, 1)

if(g_StopTeleport) set_task(1.0, "Rex_StopTeleport", Ent+TASK_TELEPORT)
else set_task(1.0, "ContinueTeleport", Ent+TASK_TELEPORT)
}

public ContinueTeleport(Ent)
{
Ent -= TASK_TELEPORT
if(!pev_valid(Ent))
return	

Set_EntAnim(Ent, REX_SKILL4B_START, 1.0, 1)

set_pev(Ent, pev_movetype, MOVETYPE_PUSHSTEP)
set_task(0.15, "TeleportHandle", Ent+TASK_TELEPORT)
}

public Rex_StopTeleportF(ent)
{
ent -= TASK_TELEPORT
if(!pev_valid(ent))
return	

g_StopTeleport = 1
}

public Rex_StopTeleport(ent)
{
ent -= TASK_TELEPORT
if(!pev_valid(ent))
return	

g_BossState = REX_STATE_SKILL4C

remove_task(ent+TASK_TELEPORT)

set_pev(ent, pev_rendermode, kRenderTransAlpha)
set_pev(ent, pev_renderfx, kRenderFxNone)
set_pev(ent, pev_renderamt, 255.0)	

set_task(0.75, "Rex_EndTeleport", ent+TASK_TELEPORT)
}

public Rex_EndTeleport(ent)
{
ent -= TASK_TELEPORT
if(!pev_valid(ent))
return	

set_pev(ent, pev_movetype, MOVETYPE_NONE)		
g_BossState = REX_STATE_SEARCHING_ENEMY

set_pev(ent, pev_nextthink, get_gametime() + 0.1)
}

// ====================== BLAST
public CreateBlast(Big, Float:Origin[3])
{
static Blast; Blast = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
if(!pev_valid(Blast)) return

Origin[2] -= 36.0

engfunc(EngFunc_SetOrigin, Blast, Origin)

// Set Config
set_pev(Blast, pev_gamestate, 1)
set_pev(Blast, pev_classname, "blast")
if(Big) engfunc(EngFunc_SetModel, Blast, BLAST_BIG)
else engfunc(EngFunc_SetModel, Blast, BLAST_SMALL)
set_pev(Blast, pev_solid, SOLID_NOT)
set_pev(Blast, pev_movetype, MOVETYPE_NONE)

// Set Size
new Float:maxs[3] = {0.0, 0.0, 0.0}
new Float:mins[3] = {0.0, 0.0, 0.0}
entity_set_size(Blast, mins, maxs)

if(Big) 
{
fm_set_rendering(Blast, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 150)
Set_EntAnim(Blast, 0, 0.45, 1)
} else {
Set_EntAnim(Blast, 0, 0.5, 1)
}

if(Big) set_pev(Blast, pev_nextthink, get_gametime() + 1.0)
else set_pev(Blast, pev_nextthink, get_gametime() + 0.75)
}

public fw_Blast_Think(Ent)
{
if(!pev_valid(Ent))
return

set_pev(Ent, pev_flags, FL_KILLME)
}

public fw_Rex_Touch(Ent, Id)
{
if(!pev_valid(Ent))
return

if(g_BossState == REX_STATE_DASH)
{
if(is_user_alive(Id))
{
user_kill(Id)
Make_PlayerShake(Id)
}
}
}

public Make_PlayerShake(id)
{
if(!id) 
{
message_begin(MSG_BROADCAST, g_MsgScreenShake)
write_short(8<<12)
write_short(5<<12)
write_short(4<<12)
message_end()
} else {
if(!is_user_connected(id))
return

message_begin(MSG_BROADCAST, g_MsgScreenShake, _, id)
write_short(8<<12)
write_short(5<<12)
write_short(4<<12)
message_end()
}
}

/*
public Make_PlayerFade(id)
{
static Float:Duration; Duration = 0.25
if(!id) 
{
message_begin(MSG_BROADCAST, g_MsgScreenFade)
write_short(floatround(4096.0 * Duration, floatround_round));
write_short(floatround(4096.0 * Duration, floatround_round));
write_short(0x0000)
write_byte(255)
write_byte(255)
write_byte(255)
write_byte(255)
message_end();
} else {
if(!is_user_connected(id))
return

message_begin(MSG_BROADCAST, g_MsgScreenFade, _, id)
write_short(floatround(4096.0 * Duration, floatround_round));
write_short(floatround(4096.0 * Duration, floatround_round));
write_short(0x0000)
write_byte(255)
write_byte(255)
write_byte(255)
write_byte(255)
message_end();
}
}*/

public Aim_To(iEnt, Float:vTargetOrigin[3], Float:flSpeed, Style)
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

public FindClosetEnemy(ent, can_see)
{
if(!pev_valid(ent))	
return 0
	
new Float:maxdistance = 4980.0
new indexid = 0	
new Float:current_dis = maxdistance

for(new i = 1 ;i <= g_MaxPlayers; i++)
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

stock fuck_ent(ent, Float:VicOrigin[3], Float:speed)
{
if(!pev_valid(ent))
return

static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time

pev(ent, pev_origin, EntOrigin)

distance_f = get_distance_f(EntOrigin, VicOrigin)
fl_Time = distance_f / speed

fl_Velocity[0] = (EntOrigin[0]- VicOrigin[0]) / fl_Time
fl_Velocity[1] = (EntOrigin[1]- VicOrigin[1]) / fl_Time
fl_Velocity[2] = (EntOrigin[2]- VicOrigin[2]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
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
