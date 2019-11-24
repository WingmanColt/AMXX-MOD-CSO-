#include <amxmodx>
#include <cs_teams_api>
#include <ZombieMod5>
#include <infinitygame>

#define TASK_RECHECK 52001
#define TASK_REVIVE 52002

#define TASK_AMBIENCE 52003
#define TASK_COUNTDOWN 52004

enum _:TOTAL_FORWARDS
{
FW_ROUND_NEW = 0,
FW_GAME_START,
FW_GAME_END
}

// Respawn
new const win_sound[][] = {"ZB5/win_human.wav", "ZB5/win_zombie.wav"}
new const comeback[][] = {"ZB5/zombi_comeback1.wav", "ZB5/zombi_comeback2.wav"}

// Gamemode
new const coming[][] = {"ZB5/zombi_infected1.wav", "ZB5/zombi_infected2.wav"}
new const ready[][] = { "ZB5/Count/zombi_start.mp3", "ZB5/Count/zombi_two.mp3" }
new const ambiences[][] ={"sound/ZB5/Ambience/Zombi_Ambience.mp3" }

new g_Forwards[TOTAL_FORWARDS], g_ForwardResult
new g_GameAvailable, g_GameStart, g_GameEnd, g_GameMode

new g_RespawnTime[33], g_PermDeath, g_spr
new g_MaxPlayers, g_Joined
new g_CountTime, g_Countdown, g_CountSound, g_CountTask
new g_RoundTime, g_Round

public plugin_init() 
{
Register_SafetyFunc()
IG_EndRound_Block(true, true)

register_event("DeathMsg", "Event_Death", "a")	
register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
register_event("TextMsg", "Event_GameRestart", "a", "2=#Game_will_restart_in")	

register_logevent("Event_RoundStart", 2, "1=Round_Start")
register_logevent("Event_RoundEnd", 2, "1=Round_End")	

RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")

g_MaxPlayers = get_maxplayers()

g_Forwards[FW_ROUND_NEW] = CreateMultiForward("zp_fw_round_new", ET_IGNORE)	
g_Forwards[FW_GAME_START] = CreateMultiForward("zp_fw_game_start", ET_IGNORE)	
g_Forwards[FW_GAME_END] = CreateMultiForward("zp_fw_game_end", ET_IGNORE)

set_task(15.0, "CheckRound", _,_,_,"b")
}
public plugin_precache()
{	
new i	

for(i = 0; i < sizeof(coming); i++)
PrecacheSound(coming[i])	
for(i = 0; i < sizeof(comeback); i++)
PrecacheSound(comeback[i])	
for(i = 0; i < sizeof(win_sound); i++)
PrecacheSound(win_sound[i])	

for(i = 0; i < sizeof(ambiences); i++)
PrecacheGeneric(ambiences[i])

PrecacheGeneric("sound/ZB5/Count/zombi_start.mp3")
PrecacheGeneric("sound/ZB5/Count/zombi_two.mp3")
PrecacheSound("ZB5/Count/CountDown.wav")

g_spr = PrecacheModel("sprites/ZB5/zb_respawn.spr")
}

public plugin_natives()
{		
register_native("zp_core_get_players_count", "native_core_get_players_count", 1)
register_native("zp_core_round", "get_user_round", 1)
register_native("zb5_zombie_PermDeath", "native_permdeath", 1)

register_native("zp_GameStart", "native_core_round_started", 1)
register_native("zp_GameAvailable", "native_GameAvailable", 1)
register_native("zp_GameEnd", "native_core_is_endround", 1)

// SCENARIO
register_native("zp_round_terminate", "native_terminate", 1)
}
public plugin_cfg()
{
server_cmd("mp_freezetime 0")
Event_NewRound()
}
public Event_GameRestart()
{
g_GameEnd = 1
}
public Event_RoundEnd()
{
g_GameEnd = 1
}
public Event_NewRound()
{		
remove_task(TASK_AMBIENCE)
remove_task(TASK_COUNTDOWN)	

g_GameMode = 0
g_GameEnd = 0
g_GameStart = 0

g_Countdown = 0
g_CountSound = 0
g_CountTask = 0

Start_Countdown()

switch(zbs_is_scenario()) 	
{
case 0:	
{	
Start_Round()
}
}


ExecuteForward(g_Forwards[FW_ROUND_NEW], g_ForwardResult)
}

public Event_RoundStart()
{	
g_Countdown = 1

PlaySound(0, ready[random_num(0, sizeof ready - 1)])
remove_task(TASK_COUNTDOWN)

g_CountTime--
CountingDown()

switch(zbs_is_scenario()) 	
{
case 0:	
{	
g_Round = 1
g_CountTask = 1	

g_RoundTime--
RoundDown()	

for (new id = 0; id <= g_MaxPlayers; id++)
{
if (!is_user_connected(id))
continue;

zp_core_respawn_as_zombie(id, false)
}
}
}

}

public CheckRound()
{
if(g_CountTask)	
return	

if(g_GameStart)
return;	

static Player; Player =  Get_TotalInPlayer(1);
if(Player >= 2)
{
		
if(!g_GameAvailable)
{
Game_Ending(0)
return;	
}

if(!g_GameStart)
{
Game_Ending(0)
return;	
}
}
}


/// ROUNDTIME ///
public Start_Round()
{			
g_RoundTime = 246

RoundDown()
}

public RoundDown()
{  	
if(!g_GameAvailable || g_GameEnd)
return	

if(g_RoundTime <= 220 && !g_GameStart && g_CountTask)
{	
g_CountTask = 0	
return
}
if(g_RoundTime <= 0)
{
Game_Ending(2)	
return
}

if(g_Round) 
--g_RoundTime
}

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

client_print(0, print_center, "Ramaining time for zombie selection: %d second(s)", g_CountTime)

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
public Ambience()
{
PlaySound(0, "ZB5/Ambience/Zombi_Ambience.mp3")

remove_task(TASK_AMBIENCE)
set_task(120.0, "Ambience", TASK_AMBIENCE)
}
// COUNTDOWN END

public Game_Starting()
{	
if(!g_GameAvailable || g_GameEnd || g_GameStart)
return	

switch(zbs_is_scenario()) 	
{
case 0:	
{	
g_CountTask = 0	
g_GameStart = 1
	
switch(random_num(1,22))
{
case 1..20:
{
g_GameMode = MODE_NORMAL

ZombieCount()
client_print(0, print_center, "Zombie Infected!")
PlaySound(0, coming[random_num(0, sizeof coming - 1)])	
}
case 21:
{
g_GameMode = MODE_AMBUSH

ZombieCount()
client_print(0, print_center, "Let's go to collect Supplyboxes, Ambush Mode!")
PlaySound(0, coming[random_num(0, sizeof coming - 1)])		
}
case 22:
{
g_GameMode = MODE_SWARM

ZombieCount()
client_print(0, print_center, "Zombie Swarm Mode!")	
}
default:
{
g_GameMode = MODE_NORMAL

ZombieCount()
client_print(0, print_center, "Zombie Infected!")
PlaySound(0, coming[random_num(0, sizeof coming - 1)])
}
}

set_task(7.0, "Ambience", TASK_AMBIENCE)
}

case 1:
{
g_GameStart = 1		
}

}
ExecuteForward(g_Forwards[FW_GAME_START], g_ForwardResult)
}

public ZombieCount()
{	
static PlayerList[32], PlayerNum; PlayerNum = 0
static id; get_players(PlayerList, PlayerNum, "a")
static ZombieNumber; ZombieNumber = Get_ServerZombie()
for(new i = 1; i < 2; i++)
{
id = PlayerList[random(PlayerNum)]

if (!is_user_alive(id))
continue

if (!zp_core_is_zombie(id))
zp_core_infect(id, 0)
}
}
stock Get_ServerZombie()
{
static Player; Player =  Get_TotalInPlayer(1);

static Zombie;

if(Player > 0 && Player < 5)
Zombie = 1;
else if(Player > 5 && Player < 15)
Zombie = 2;
else if(Player > 15 && Player < 32)
Zombie = 3;

return Zombie
}
public IG_RunningTime()
{	
static pplayer;

switch(zbs_is_scenario()) 	
{
case 0:
{
RoundDown()
pplayer = 2;
}
case 1:
{
pplayer = 1;
}
}		

static Player; Player =  Get_TotalInPlayer(1);
static Player2; Player2 =  Get_TotalInPlayer2(0); // 0

if(!g_GameEnd && !g_GameStart && g_GameAvailable && Player < pplayer)
{
g_GameAvailable = 0
g_GameStart = 0
g_GameEnd = 0

Game_Ending(0)
} 
else if(!g_GameEnd && !g_GameStart && !g_GameAvailable && Player >= pplayer) 
{ 
g_GameAvailable = 1
g_GameStart = 0
g_GameEnd = 0

Game_Ending(0)
} 
else if(!g_GameEnd && !g_GameStart && !g_GameAvailable  && Player2 < pplayer) 
client_print(0, print_center, "Waiting for players to join...")

Check_Gameplay()
}

public Check_Gameplay()
{
if(!g_GameAvailable || !g_GameStart || g_GameEnd)
return	

switch(zbs_is_scenario()) 	
{
case 0:
{	
static Zombie, Human
Zombie = Get_LivingZombie()
Human = Get_PlayerCount(1, 2)

if(Zombie <= 0) Game_Ending(2)
else if(Human <= 0)Game_Ending(1)

}
case 1:
{	
static Human
Human = Get_PlayerCount(1, 2)

if(Human <= 0)Game_Ending(1)
}
}
}

public fw_TraceAttack(victim, attacker)
{		
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (zp_core_is_zombie(attacker) == zp_core_is_zombie(victim))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{	
if (!is_user_alive(victim) || !is_user_alive(attacker))
return HAM_IGNORED;

if (g_GameStart && zp_core_is_zombie(attacker) && !zp_core_is_zombie(victim))
{
if (Get_PlayerCount(1, 2) == 1)
return HAM_IGNORED;

if (damage_type & (1<<24))
return HAM_SUPERCEDE;

if (damage > 0.0 && GetHamReturnStatus() != HAM_SUPERCEDE)
{
zp_core_infect(victim, attacker)
return HAM_SUPERCEDE;
}
}

if (g_GameEnd && zp_core_is_zombie(victim))
{
SetHamParamFloat(4, damage * 0.0)
set_pdata_float(victim, 108, 1.25, 5)
return HAM_SUPERCEDE;
}

return HAM_IGNORED;
}
/// RESPAWN 
public Event_Death()
{
if(!g_GameStart || g_GameEnd)
return

static victim, headshot
victim = read_data(2)
headshot = read_data(3)

if(!zp_core_is_zombie(victim))
return

if(headshot) 
{
Set_BitVar(g_PermDeath, victim)
}else{
UnSet_BitVar(g_PermDeath, victim)
RespawnVictim(victim)
}
}
public RespawnVictim(id)
{		
g_RespawnTime[id] = zb5_had_ZombieRespawn(id) ? 2 : 6
sendmsg_BarTime(id, g_RespawnTime[id]+1)

set_task(1.0, "Start_Revive", id+TASK_REVIVE)
set_task(1.0, "Dead_Effect", id)
set_task(3.0, "Dead_Effect", id)

emit_sound(0, CHAN_VOICE, comeback[random_num(0, sizeof comeback - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
}
public Dead_Effect(id)
{
if(!g_GameStart || g_GameEnd)
return
if(!is_user_connected(id))
return
if(Get_BitVar(g_PermDeath, id))
return

static Float:Origin[3]
pev(id, pev_origin, Origin)

message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(g_spr)
write_byte(10)
write_byte(20)
write_byte(14)
message_end()
}

public Start_Revive(id)
{
id -= TASK_REVIVE

if(!g_GameStart || g_GameEnd)
return

if(!is_user_connected(id))
return

if(Get_BitVar(g_PermDeath, id))
{
remove_task(id)	
return;
}

if(g_RespawnTime[id] <= 0)
{
Revive_Now(id)
return
}

client_print(id, print_center, "You will be Revived after: %i Second(s)", g_RespawnTime[id])
g_RespawnTime[id]--

set_task(1.0, "Start_Revive", id+TASK_REVIVE)
}
public Revive_Now(id)
{
if (is_user_alive(id))
return

if(zp_core_round() == MODE_SWARM)
{	
switch(random_num(1,2))
{
case 1:zp_core_respawn_as_zombie(id, true)
case 2:zp_core_respawn_as_zombie(id, false)
}
}else zp_core_respawn_as_zombie(id, true)

ExecuteHamB(Ham_CS_RoundRespawn, id)
}

// STOCKS
stock Get_LivingZombie()
{
static Count; Count = 0

for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_user_connected(i))
continue
if(!zp_core_is_zombie(i))
continue

if(is_user_alive(i))
{
Count++
}
else 
{
if(!Get_BitVar(g_PermDeath, i))
Count++
}

}

return Count
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
switch(zbs_is_scenario()) 	
{
case 0:
{
IG_TerminateRound(WIN_TERRORIST, 5.0, 0)
client_print(0, print_center, "Zombies Win!")
PlaySound(0, "ZB5/win_zombie.wav")
}
case 1:
{
IG_TerminateRound(WIN_TERRORIST, 5.0, 0)
client_print(0, print_center, "Round Fail!")
PlaySound(0, "ZB5/win_zombie.wav")
server_cmd("changelevel cs_italy")
}
}	
}
case 2:	
{
IG_TerminateRound(WIN_CT, 7.0, 0)
client_print(0, print_center, "Humans Win!")
PlaySound(0, "ZB5/win_human.wav")
}
}

ExecuteForward(g_Forwards[FW_GAME_END], g_ForwardResult)
}


////// NATIVES //////
public get_user_round()return g_GameMode;
public native_core_is_endround()return g_GameEnd;
public native_core_round_started()return g_GameStart;
public native_GameAvailable()return g_GameAvailable;
public native_permdeath(id)Set_BitVar(g_PermDeath, id)
public native_core_get_players_count(Alive, Team)return Get_PlayerCount(Alive, Team)	
public native_terminate(end) Game_Ending(end);


///// STOCK /////
stock StopSound() 
{
client_cmd(0, "mp3 stop; stopsound")
}
stock Float:Get_RoundTimeLeft()
{
return (g_RoundTimeLeft > 0.0) ? (g_RoundTimeLeft - get_gametime()) : -1.0
}

/* Sets indexes of players.
* Flags:
* "a" - don't collect dead players.
* "b" - don't collect alive players.
* "c" - skip bots.
* "d" - skip real players.
* "e" - match with team.
* "f" - match with part of name.
* "g" - ignore case sensitivity.
* "h" - skip HLTV.
* Example: Get all alive CTs: get_players(players,num,"ae","CT") */

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
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)
{	
set_task(0.25, "Recheck_NewPlayer", id+TASK_RECHECK)

Safety_Connected(id)
}
Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
ResetVars(id)	
Check_Gameplay()
}

Safety_Disconnected(id)
{
ResetVars(id)
Check_Gameplay()
}

ResetVars(id)
{
if(task_exists(id+TASK_REVIVE))	
remove_task(id+TASK_REVIVE)

UnSet_BitVar(g_Joined, id)
UnSet_BitVar(g_PermDeath, id)

g_RespawnTime[id] = 0	
}
public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

remove_task(id+TASK_RECHECK)
Set_BitVar(g_Joined, id)

if(zp_core_is_zombie(id))
IG_TeamSet(id, CS_TEAM_T)
else IG_TeamSet(id, CS_TEAM_CT)

Check_Gameplay()
}
public zp_fw_core_cure_post(id)
{
IG_TeamSet(id, CS_TEAM_CT)
Check_Gameplay()
}

public fw_Safety_Killed_Post(id)
{	
Check_Gameplay()
}
public zp_fw_core_infect_post(id)
{
if(zp_core_is_zombie(id))
{
IG_TeamSet(id, CS_TEAM_T)
}
Check_Gameplay()
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
public Recheck_NewPlayer(id)
{
id -= TASK_RECHECK

if(!is_user_connected(id))
return
if(Get_BitVar(g_Joined, id))
return

if(cs_get_user_team(id) == CS_TEAM_T)
{
IG_TeamSet(id, CS_TEAM_CT)	
return
}

set_task(0.25, "Recheck_NewPlayer", id+TASK_RECHECK)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
