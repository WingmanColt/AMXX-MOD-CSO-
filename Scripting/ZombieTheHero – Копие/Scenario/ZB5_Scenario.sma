#include <amxmodx>
#include <cs_teams_api>
#include <ZombieMod5>
#include <ScenarioMod>
#include <infinitygame>

#define TASK_COUNTDOWN 41816
#define TASK_SCENE 51816

#define TASK_RECHECK 52001
#define TASK_REVIVE 51817

#define PREPARE "rex/game/Scenario_Ready.mp3"
#define FIGHT "rex/game/Scenario_Rush.mp3"

// Dr.Rex & CutScenes
#define DRREX_MODEL "models/rex/dr_rex.mdl"
#define CUTSCENE1 "models/rex/cutscene/dr_rex_cutscene1.mdl"
#define CUTSCENE2 "models/rex/cutscene/dr_rex_cutscene2.mdl"
#define CUTSCENE3 "models/rex/cutscene/dr_rex_cutscene3.mdl"
#define CUTSCENE_SOUND "rex/cutscene/scene.wav"

#define GAMESTART_TIME 10
#define RESPAWN_TIME 60
#define DOOR_HEALTH 5000

enum _:TOTAL_FORWARDS
{
FW_ROUND_NEW = 0,
FW_GAME_START,
FW_GAME_END
}

// Gamemode
new const ready[][] = { "ZB5/Count/zombi_start.mp3", "ZB5/Count/zombi_two.mp3" }

new g_Forwards[TOTAL_FORWARDS], g_ForwardResult
new g_GameAvailable, g_GameStart, g_GameEnd, g_MaxPlayers
new g_CountTime, g_Countdown, g_CountSound

new g_Respawn_Time[33], g_IsAlive, g_IsConnected
new DrRex1, Cut1, Cut2, Cut3, Cut4, Door


public plugin_init()
{	
register_think("func_breakable", "FwdThinkBreak");
if(zbs_is_scenario() == 0) return	

Register_SafetyFunc()

//Find_MainDoor()
//Initialize_Door(1)
IG_EndRound_Block(true, true)

register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
register_event("TextMsg", "Event_GameRestart", "a", "2=#Game_will_restart_in")	

register_logevent("Event_RoundStart", 2, "1=Round_Start")
register_logevent("Event_RoundEnd", 2, "1=Round_End")	

g_MaxPlayers = get_maxplayers()

g_Forwards[FW_ROUND_NEW] = CreateMultiForward("zp_fw_round_new", ET_IGNORE)	
g_Forwards[FW_GAME_START] = CreateMultiForward("zp_fw_game_start", ET_IGNORE)	
g_Forwards[FW_GAME_END] = CreateMultiForward("zp_fw_game_end", ET_IGNORE)

server_cmd("mp_freezetime 20")
server_cmd("mp_timelimit 9000")
server_cmd("mp_maxrounds 0")
server_cmd("mp_winlimit 0")
server_cmd("mp_fraglimit 0")
server_cmd("mp_friendlyfire 0")
}
public plugin_precache()
{
/*// Dr.Rex & Cutscenes
PrecacheModel(DRREX_MODEL)

PrecacheModel(CUTSCENE1)
PrecacheModel(CUTSCENE2)
PrecacheModel(CUTSCENE3)
PrecacheModel("models/rpgrocket.mdl");

PrecacheSound(CUTSCENE_SOUND)	
PrecacheSound(PREPARE)
PrecacheSound(FIGHT)	*/
}
public plugin_cfg()
{	
Event_NewRound()
}

public Event_GameRestart()g_GameEnd = 1
public Event_RoundEnd()g_GameEnd = 1

public Event_NewRound()
{	
if(zbs_is_scenario() == 0) return
	
remove_task(TASK_COUNTDOWN)	

g_GameEnd = 0
g_GameStart = 0

g_Countdown = 0
g_CountSound = 0

Start_Countdown()
Start_Round()

ExecuteForward(g_Forwards[FW_ROUND_NEW], g_ForwardResult)	
}
public Event_RoundStart()
{
g_Countdown = 1

PlaySound(0, ready[random_num(0, sizeof ready - 1)])
remove_task(TASK_COUNTDOWN)

g_CountTime--
CountingDown()	
}
public Reset_Value()
{
//remove_task(TASK_SCENE)	
remove_task(TASK_COUNTDOWN)
}
/*public Task_NewRound() 
{
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_connected(i))
continue

attach_view(i, i)
client_cmd(i, "hud_draw 1")
}

if(pev_valid(Cut1)) remove_entity(Cut1)
if(pev_valid(Cut2)) remove_entity(Cut2)
if(pev_valid(Cut3)) remove_entity(Cut3)
if(pev_valid(Cut4)) remove_entity(Cut4)
if(pev_valid(DrRex1)) remove_entity(DrRex1)

if(g_GameStart) Initialize_Door(0)
}*/

/// COUNTDOWN ///
public Start_Countdown()
{
g_CountTime = 20

remove_task(TASK_COUNTDOWN)
CountingDown()
}

public CountingDown()
{  
if(!g_GameAvailable || g_GameEnd || g_GameStart)
return	

if(g_CountTime  <= 0)
{
Game_Starting()
return
}

client_print(0, print_center, "Ramaining time for zombies appear: %d second(s)", g_CountTime)

if(g_CountTime <= 10 && !g_CountSound)
{
g_CountSound = 1	
CountSound()
} 

if(g_Countdown) 
--g_CountTime

remove_task(TASK_COUNTDOWN)
set_task(1.1, "CountingDown", TASK_COUNTDOWN)
}

public CountSound()
{
PlaySound(0, "ZB5/Count/CountDown.wav")			
}
public IG_RunningTime()
{		
if(zbs_is_scenario() == 1) return	
	
static Player; Player =  Get_TotalInPlayer(1);
static Player2; Player2 =  Get_TotalInPlayer2(0);

if(!g_GameEnd && !g_GameStart && g_GameAvailable && Player < 2)
{
g_GameAvailable = 0
g_GameStart = 0
g_GameEnd = 0
} else if(!g_GameEnd && !g_GameStart && !g_GameAvailable && Player >= 2) 
{ 
g_GameAvailable = 1
g_GameStart = 0
g_GameEnd = 0

Game_Ending(0)
} 
else if(!g_GameEnd && !g_GameStart && !g_GameAvailable  && Player2 < 2) 
client_print(0, print_center, "Waiting for players to join...")

Check_Gameplay()
RoundDown()
}

/// ROUNDTIME ///
public Start_Round()
{	
if(zbs_is_scenario() == 1) return	
		
g_RoundTime = 246

RoundDown()
}
public RoundDown()
{  
if(zbs_is_scenario() == 1) return	
	
if(!g_GameAvailable || g_GameEnd)
return	

if(g_RoundTime <= 0)
{
Game_Ending(2)	
return
}

if(g_Round) 
--g_RoundTime
}

public Game_Starting()
{	
g_GameStart = 1	

ExecuteForward(g_Forwards[FW_GAME_START], g_ForwardResult)
}

public Check_Gameplay()
{
if(zbs_is_scenario() == 0) return
		
if(!g_GameAvailable || !g_GameStart || g_GameEnd)
return

static Human
Human = Get_PlayerCount(1, 2)

if(Human <= 0)
{
Game_Ending(1)
}
}

public Game_Ending(end)
{
if(g_GameEnd) 
return

g_GameEnd = 1
StopSound() 

switch(end)
{
case 0:	
{
IG_TerminateRound(WIN_DRAW, 7.0, 0)
client_print(0, print_center, "Round Restarted!")
}
case 1:	
{
set_task(9.0, "ChangeMap")	
IG_TerminateRound(WIN_TERRORIST, 10.0, 0)
client_print(0, print_center, "Round failled!")
PlaySound(0, "ZB5/win_zombie.wav")
}
case 2:	
{
set_task(9.0, "ChangeMap")	
IG_TerminateRound(WIN_CT, 10.0, 0)
client_print(0, print_center, "Round Clear!")
PlaySound(0, "ZB5/win_human.wav")
}
}

ExecuteForward(g_Forwards[FW_GAME_END], g_ForwardResult)
}

public ChangeMap()
{
server_cmd("changelevel cs_italy")	
}

// RESPAWN
public zp_fw_core_dead_post(id)
{
if(!zbs_is_scenario()) return		
g_Respawn_Time[id] = RESPAWN_TIME
Start_Revive(id)
}
public Start_Revive(id)
{
id -= TASK_REVIVE

if(!is_user_connected(id))
return

if(g_Respawn_Time[id] <= 0)
{
Revive_Now(id)
return
}

client_print(id, print_center, "You will be Revived after: %i Second(s)", g_Respawn_Time[id])
g_Respawn_Time[id]--
set_task(1.0, "Start_Revive", id+TASK_REVIVE)
}

public Revive_Now(id)
{
if(!is_connected(id))
return	

if(is_alive(id))
return

remove_task(id+TASK_REVIVE)
//IG_TeamSet(id, CS_TEAM_CT)	
//ExecuteHamB(Ham_CS_RoundRespawn, id)
}
// DOOR AND CUTSCENE
public FwdThinkBreak(iEntity) 
{
if(!pev_valid(iEntity))
return

if(entity_get_int(iEntity, EV_INT_solid ) == SOLID_NOT) 
{
static iEffects
iEffects = entity_get_int(iEntity, EV_INT_effects);

if(!(iEffects & EF_NODRAW))
entity_set_int(iEntity, EV_INT_effects, iEffects | EF_NODRAW);

if(entity_get_int(iEntity, EV_INT_deadflag ) != DEAD_DEAD)
entity_set_int(iEntity, EV_INT_deadflag, DEAD_DEAD );

remove_entity(iEntity)
}
}
public Find_MainDoor()
{
static Classname[32]

for(new i = 0; i < entity_count(); i++)
{
if(!pev_valid(i))
continue

pev(i, pev_classname, Classname, sizeof(Classname))
if(!equal(Classname, "func_breakable"))
continue

pev(i, pev_targetname, Classname, sizeof(Classname))
if(!equal(Classname, "door_brk"))
continue

Door = i
server_print("[CSO] Dr.Rex: Found Door (%i)", Door)
}
}
public Initialize_Door(First)
{
if(!pev_valid(Door))
return

set_pev(Door, pev_takedamage, DAMAGE_YES)
set_pev(Door, pev_health, float(DOOR_HEALTH))
fm_set_rendering(Door, kRenderFxNone, 120, 0, 0, kRenderTransColor, 200)

if(First) 
{
RegisterHamFromEntity(Ham_TakeDamage, Door, "fw_Door_TakeDamage")
RegisterHamFromEntity(Ham_TakeDamage, Door, "fw_Door_TakeDamage_Post", 1)
}
}

public fw_Door_TakeDamage(Victim, Inflictor, Attacker, Float:Damage, DamageBits)
{
return HAM_IGNORED
}

public fw_Door_TakeDamage_Post(Victim, Inflictor, Attacker, Float:Damage, DamageBits)
{
static Float:Health; pev(Victim, pev_health, Health)
if(Health <= 0.0) 
{
Activate_Cutscene()
return
}
static Float:g_fHaveDamage[33]

g_fHaveDamage[Attacker] += Damage;

if (g_fHaveDamage[Attacker] >= 2000.0)
{
zb5_set_user_exp(Attacker, 1, 0)
g_fHaveDamage[Attacker] = 0.0	
}

client_print(Attacker, print_center, "Health: %i", floatround(Health))
}

public Create_DrRex()
{
static Float:Origin[3], Float:Angles[3]

Origin[0] = 900.0
Origin[1] = 0.0
Origin[2] = 130.0

Angles[1] = 180.0

static Ent; Ent = create_entity("info_target")
if(!pev_valid(Ent)) return

DrRex1 = Ent

set_pev(Ent, pev_origin, Origin)
set_pev(Ent, pev_angles, Angles)

set_pev(Ent, pev_classname, "doctorrex")
engfunc(EngFunc_SetModel, Ent, DRREX_MODEL)

set_pev(Ent, pev_mins, Float:{-36.0, -36.0, -66.0})
set_pev(Ent, pev_maxs, Float:{36.0, 36.0, 66.0})		

set_pev(Ent, pev_movetype, MOVETYPE_NONE)
set_pev(Ent, pev_solid, SOLID_SLIDEBOX)

set_pev(Ent, pev_animtime, get_gametime())
set_pev(Ent, pev_framerate, 1.0)
set_pev(Ent, pev_sequence, 1)
}

public Activate_Cutscene()
{
new Float:Origin[3], Float:Angles[3]
Origin[2] = 512.0

static Ent1, Ent2, Ent3

// Main Rex
Ent1 = create_entity("info_target")

set_pev(Ent1, pev_origin, Origin)

set_pev(Ent1, pev_classname, "cut1")
engfunc(EngFunc_SetModel, Ent1, CUTSCENE1)

Cut1 = Ent1

// Tentacle 1
Ent2 = create_entity("info_target")

set_pev(Ent2, pev_origin, Origin)

set_pev(Ent1, pev_classname, "cut2")
engfunc(EngFunc_SetModel, Ent2, CUTSCENE2)

set_pev(Ent2, pev_aiment, Ent1)
set_pev(Ent2, pev_movetype, MOVETYPE_FOLLOW)
set_pev(Ent2, pev_solid, SOLID_NOT)

Cut2 = Ent2

// Tentacle 2
Ent3 = create_entity("info_target")

set_pev(Ent3, pev_origin, Origin)

set_pev(Ent1, pev_classname, "cut3")
engfunc(EngFunc_SetModel, Ent3, CUTSCENE3)

set_pev(Ent3, pev_aiment, Ent1)
set_pev(Ent3, pev_movetype, MOVETYPE_FOLLOW)
set_pev(Ent3, pev_solid, SOLID_NOT)

Cut3 = Ent3

// Run Animation
set_pev(Ent1, pev_animtime, get_gametime())
set_pev(Ent1, pev_framerate, 1.0)
set_pev(Ent1, pev_sequence, 0)

set_pev(Ent2, pev_animtime, get_gametime())
set_pev(Ent2, pev_framerate, 1.0)
set_pev(Ent2, pev_sequence, 0)

set_pev(Ent3, pev_animtime, get_gametime())
set_pev(Ent3, pev_framerate, 1.0)
set_pev(Ent3, pev_sequence, 0)

emit_sound(Ent1, CHAN_BODY, CUTSCENE_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)

// Watching Ent
static Watch; Watch = create_entity("info_target")

Origin[0] = 100.0
Origin[1] = 0.0
Origin[2] = 610.0

Angles[1] = 180.0

set_pev(Watch, pev_classname, "cut4")
engfunc(EngFunc_SetModel, Watch, "models/rpgrocket.mdl")

set_pev(Watch, pev_origin, Origin)
set_pev(Watch, pev_angles, Angles)
set_pev(Watch, pev_v_angle, Angles)

entity_set_int(Watch, EV_INT_rendermode, kRenderTransTexture);
entity_set_float(Watch, EV_FL_renderamt, 0.0);

set_pev(Watch, pev_solid, SOLID_TRIGGER)
set_pev(Watch, pev_movetype, MOVETYPE_FLY)

Cut4 = Watch

for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_connected(i))
continue

attach_view(i, Watch)
client_cmd(i, "hud_draw 0")
}

set_task(8.0, "KickBack", TASK_SCENE)
set_task(9.0, "End_Cutscene", TASK_SCENE)
}
/*
public End_Cutscene()
{
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_connected(i))
continue

attach_view(i, i)
client_cmd(i, "hud_draw 1")
}

if(pev_valid(Cut1)) remove_entity(Cut1)
if(pev_valid(Cut2)) remove_entity(Cut2)
if(pev_valid(Cut3)) remove_entity(Cut3)
if(pev_valid(Cut4)) remove_entity(Cut4)
if(pev_valid(DrRex1)) remove_entity(DrRex1) 
remove_entity_name("doctorrex")

ExecuteForward(g_Forwards[FW_GAMEMODE_START], g_ForwardResult)
}*/

public KickBack()
{
static Float:Origin[3]
Origin[0] = 0.0
Origin[1] = 0.0
Origin[2] = 200.0

Check_Knockback(Origin)
}
public Check_Knockback(Float:Origin[3])
{
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue

fuck_ent(i, Origin, 5000.0)
}
}

// NATIVES 
public plugin_natives()
{
register_native("zbs_is_door", "native_door", 1)
register_native("zbs_is_boss", "native_boss", 1)
register_native("zbs_is_zombie", "native_npc", 1)
register_native("zbs_is_game_started", "native_game", 1)

register_native("zp_core_get_players_count", "native_core_get_players_count", 1)
register_native("zp_GameStart", "native_core_round_started", 1)
register_native("zp_GameAvailable", "native_GameAvailable", 1)
register_native("zp_GameEnd", "native_core_is_endround", 1)
register_native("zp_round_terminate", "native_terminate", 1)
}

public native_game()return g_GameStart;
public native_door(ent)return is_door(ent);
public native_npc(bot) return is_npc(bot);
public native_boss(bot) return is_boss(bot);

public native_core_is_endround()return g_GameEnd;
public native_core_round_started()return g_GameStart;
public native_GameAvailable()return g_GameAvailable;
public native_core_get_players_count(Alive, Team)return Get_PlayerCount(Alive, Team)	
public native_terminate(end) Game_Ending(end);
// STOCKS
stock is_boss(ent)
{
if (!pev_valid(ent)) 
return 0;

static classname[32]
pev(ent, pev_classname, classname, charsmax(classname))

if (equal(classname, "BOSS"))return 1;
return 0;
}

stock is_npc(ent)
{
if (!pev_valid(ent)) 
return 0;

static classname[32]
pev(ent, pev_classname, classname, charsmax(classname))

if (equal(classname, "ZOMBIE"))return 1;

return 0;
}

stock is_door(ent)
{
if (!pev_valid(ent)) 
return 0;

static Classname[32]
pev(ent, pev_classname, Classname, sizeof(Classname))

if (equal(Classname, "door_brk") || equal(Classname, "func_breakable")) return 1;
return 0;
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
stock Get_PlayerCount(Alive, Team)
// Alive: 0 - Dead | 1 - Alive | 2 - Both
// Team: 1 - T | 2 - CT
{
new Flag[4], Flag2[12]
new Players[32], PlayerNum

if(!Alive) formatex(Flag, sizeof(Flag), "%sb", Flag)
else if(Alive == 1) formatex(Flag, sizeof(Flag), "%sa", Flag)

if(Team == 1) 
{
formatex(Flag, sizeof(Flag), "%se", Flag)
formatex(Flag2, sizeof(Flag2), "TERRORIST", Flag)
} else if(Team == 2) 
{
formatex(Flag, sizeof(Flag), "%se", Flag)
formatex(Flag2, sizeof(Flag2), "CT", Flag)
}

get_players(Players, PlayerNum, Flag, Flag2)

return PlayerNum
}

stock Get_TotalInPlayer(Alive)return Get_PlayerCount(Alive, 1) + Get_PlayerCount(Alive, 2)
stock Get_TotalInPlayer2(Alive)return Get_PlayerCount(Alive, 1) + Get_PlayerCount(Alive, 2)

stock StopSound() 
{
client_cmd(0, "mp3 stop; stopsound")
}



/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)
{
if(zbs_is_scenario() == 0) return

Safety_Connected(id)
}
Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}
Safety_Connected(id)
{
if(zbs_is_scenario() == 0) return
		
remove_task(id+TASK_REVIVE)
	
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)

if(g_GameStart)
{
g_Respawn_Time[id] = RESPAWN_TIME
Start_Revive(id)
}else Revive_Now(id)

Check_Gameplay()
}

Safety_Disconnected(id)
{	
if(zbs_is_scenario() == 0) return

UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)

remove_task(id+TASK_REVIVE)	
g_Respawn_Time[id] = 0

Check_Gameplay()
}

public fw_Safety_Spawn_Post(id)
{		
if(!is_user_alive(id))
return

remove_task(id+TASK_RECHECK)
Set_BitVar(g_IsAlive, id)

IG_TeamSet(id, CS_TEAM_CT)
Check_Gameplay()
}
public fw_Safety_Killed_Post(id)
{		
UnSet_BitVar(g_IsAlive, id)
Check_Gameplay()
}
public is_connected(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0

return 1
}

public is_alive(id)
{
if(!is_connected(id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
