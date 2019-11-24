#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define MAXPLAYERS 32
#define MAX_SYNCHUD 6

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

new const MAPS[][] ={"zs_nightmare2", "zs_behind2"}

enum _:TOTAL_FORWARDS
{
FW_USER_INFECT_POST = 0,
FW_USER_CURE_POST,
FW_USER_SPAWN_POST,
FW_USER_DEAD_POST,
FW_USER_SKILL_HUD,
FW_USER_SKILL_HUD2
}

enum Options
{
MaxPlayers,
IsZombie,
IsFirstZombie,
IsLastZombie,
IsLastHuman,
RespawnAsZombie,
ForwardResult
}

new g_IsAlive, g_IsConnected, g_HeadShot, g_HamBot, g_scenario;
new g_[Options], g_Forwards[TOTAL_FORWARDS], g_SyncHud[MAX_SYNCHUD]
static i;
public plugin_init()
{	
static MapName[64]; get_mapname(MapName, sizeof(MapName))

if(equal(MapName, "zs_behind2"))g_scenario = 1
else g_scenario = 0

Register_SafetyFunc()
	
if(!g_scenario)
{	
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Pre", 0)

g_Forwards[FW_USER_INFECT_POST] = CreateMultiForward("zp_fw_core_infect_post", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_USER_CURE_POST] = CreateMultiForward("zp_fw_core_cure_post", ET_IGNORE, FP_CELL, FP_CELL)

g_SyncHud[SYNCHUD_ZOMBIE_HUD] = CreateHudSyncObj(SYNCHUD_ZOMBIE_HUD)
g_SyncHud[SYNCHUD_ZOMBIE_SKILL] = CreateHudSyncObj(SYNCHUD_ZOMBIE_SKILL)
}

register_event("DeathMsg", "Event_Death", "a")	
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)	

register_forward(FM_Sys_Error, "hi_im_crasher")
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)

g_Forwards[FW_USER_SKILL_HUD] = CreateMultiForward("RuningTime", ET_IGNORE)
g_Forwards[FW_USER_SKILL_HUD2] = CreateMultiForward("RuningTime_Player", ET_IGNORE, FP_CELL)
g_Forwards[FW_USER_DEAD_POST] = CreateMultiForward("zp_fw_core_dead_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
g_Forwards[FW_USER_SPAWN_POST] = CreateMultiForward("zp_fw_core_spawn_post", ET_IGNORE, FP_CELL)

g_SyncHud[SYNCHUD_NOTICE] = CreateHudSyncObj(SYNCHUD_NOTICE)
g_SyncHud[SYNCHUD_HUMAN_SKILL] = CreateHudSyncObj(SYNCHUD_HUMAN_SKILL)
g_SyncHud[SYNCHUD_HUMAN_HUD] = CreateHudSyncObj(SYNCHUD_HUMAN_HUD)
g_SyncHud[SYNCHUD_HUMAN_QUESTS] = CreateHudSyncObj(SYNCHUD_HUMAN_QUESTS)

set_task(1.0, "ZEVO_RunningTime", _, _, _, "b")
g_[MaxPlayers] = get_maxplayers()	
}

public plugin_natives()
{
register_native("zbs_is_scenario", "native_scenario", 1)		
register_native("zp_core_is_zombie", "native_core_is_zombie", 1)
register_native("zp_core_is_first_zombie", "native_core_is_first_zombie", 1)	
register_native("zp_core_is_last_zombie", "native_core_is_last_zombie", 1)
register_native("zp_core_is_last_human", "native_core_is_last_human", 1)
register_native("zp_core_respawn_as_zombie", "native_core_respawn_as_zombie", 1)
register_native("zp_core_infect", "native_core_infect", 1)
register_native("zp_core_cure", "native_core_cure", 1)
register_native("zp_get_synchud_id", "native_get_synchud_id", 1)
}
public native_scenario()return g_scenario;
public hi_im_crasher(const err[])log_to_file("itcrashed.log", err)  
public fw_ClientDisconnect_Post(id)
{
if(zbs_is_scenario())
return

// Reset flags AFTER disconnect (to allow checking if the player was zombie before disconnecting)
flag_unset(g_[IsZombie], id)
flag_unset(g_[RespawnAsZombie], id)

// This should be called AFTER client disconnects (post forward)
CheckLastZombieHuman()
}
public fw_PlayerSpawn_Post(id)
{
if(!is_player(id, 1)) 
return	

ExecuteForward(g_Forwards[FW_USER_SPAWN_POST], g_[ForwardResult], id)

if(!zbs_is_scenario())
{
// Set zombie/human attributes upon respawn
if (flag_get(g_[RespawnAsZombie], id))
InfectPlayer(id, id)
else
CurePlayer(id)

// Reset flag afterwards
flag_unset(g_[RespawnAsZombie], id)
}

ham_strip_weapon(id, "weapon_glock18")
ham_strip_weapon(id, "weapon_usp")
ham_strip_weapon(id, "weapon_smokegrenade")
}
// Ham Player Killed Post Forward
public Event_Death()
{
if(!zp_GameAvailable() || zp_GameEnd() || !zp_GameStart())
return
	
static Victim, Headshot

Victim = read_data(2)
Headshot = read_data(3)

if(Headshot) Set_BitVar(g_HeadShot, Victim)
else UnSet_BitVar(g_HeadShot, Victim)
}
public fw_PlayerKilled_Post(victim, attacker)
{		
if(!zp_GameAvailable() || zp_GameEnd() || !zp_GameStart())
return
	
ExecuteForward(g_Forwards[FW_USER_DEAD_POST], g_[ForwardResult], victim, attacker, Get_BitVar(g_HeadShot, victim))

fm_strip_user_weapons(victim)
CheckLastZombieHuman()	
}
public fw_TakeDamage_Pre(vic, inf, att, Float:dmg, dmgbits)
{
if(!zp_GameAvailable() || zp_GameEnd() || !zp_GameStart())
return HAM_IGNORED;
	
if(dmgbits & (1<<24))
{
if(vic == att)
return HAM_SUPERCEDE;

SetHamParamFloat(4, dmg * 3.5)
}

return HAM_IGNORED;
}
public ZEVO_RunningTime()
{
ExecuteForward(g_Forwards[FW_USER_SKILL_HUD], g_[ForwardResult])
		
for(i = 0; i < g_[MaxPlayers]; i++)
{
if(!is_user_connected(i))
continue;

ExecuteForward(g_Forwards[FW_USER_SKILL_HUD2], g_[ForwardResult], i)
}
}
InfectPlayer(id, attacker = 0)
{
if(!is_player(id, 0)) 
return;	
	
if(!zp_GameAvailable() || zp_GameEnd() || !zp_GameStart())
return

static First; First = flag_get(g_[IsFirstZombie], id) ? 1 : 0
if(First) flag_set(g_[IsFirstZombie], id)

flag_set(g_[IsZombie], id)

ExecuteForward(g_Forwards[FW_USER_INFECT_POST], g_[ForwardResult], id, attacker)
CheckLastZombieHuman()
}

CurePlayer(id, attacker = 0)
{
if(!is_player(id, 0)) 
return;	

flag_unset(g_[IsZombie], id)

ExecuteForward(g_Forwards[FW_USER_CURE_POST], g_[ForwardResult], id, attacker)
CheckLastZombieHuman()

ham_strip_weapon(id, "weapon_glock18")
ham_strip_weapon(id, "weapon_usp")
ham_strip_weapon(id, "weapon_smokegrenade")
}

// Last Zombie/Human Check
CheckLastZombieHuman()
{
static id, zombie_count, human_count
zombie_count = zp_core_get_players_count(1, 1)
human_count = zp_core_get_players_count(1, 2)

if (zombie_count == 1)
{
for (id = 1; id <= g_[MaxPlayers]; id++)
{
// Last zombie
if (is_player(id, 1) && flag_get(g_[IsZombie], id))
{
flag_set(g_[IsLastZombie], id)
}
else
flag_unset(g_[IsLastZombie], id)
}
}
else
{
for (id = 1; id <= g_[MaxPlayers]; id++)
flag_unset(g_[IsLastZombie], id)
}


if (human_count == 1)
{
for (id = 1; id <= g_[MaxPlayers]; id++)
{
// Last human
if (is_player(id, 1) && !flag_get(g_[IsZombie], id))
{
flag_set(g_[IsLastHuman], id)
}
else
flag_unset(g_[IsLastHuman], id)
}
}
else
{
for (id = 1; id <= g_[MaxPlayers]; id++)
flag_unset(g_[IsLastHuman], id)
}
}

public native_core_is_zombie(id)
{
if (!is_player(id, 0))
return 1;

return flag_get_boolean(g_[IsZombie], id);
}
public native_core_is_first_zombie(id)
{
if (!is_player(id, 0))
return 1;

return flag_get_boolean(g_[IsFirstZombie], id);
}
public native_core_is_last_zombie(id)
{
if (!is_player(id, 0))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

return flag_get_boolean(g_[IsLastZombie], id);
}

public native_core_is_last_human(id)
{
if (!is_player(id, 0))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

return flag_get_boolean(g_[IsLastHuman], id);
}

public native_core_infect(id, attacker)
{
if (!is_player(id, 1))
return 

if (flag_get(g_[IsZombie], id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already infected (%d)", id)
return 
}

if (attacker && !is_user_alive(attacker))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", attacker)
return 
}

InfectPlayer(id, attacker)
return 
}

public native_core_cure(id, attacker)
{
if (!is_player(id, 1))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (!flag_get(g_[IsZombie], id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player not infected (%d)", id)
return false;
}

if (attacker && !is_user_alive(attacker))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", attacker)
return false;
}

CurePlayer(id, attacker)
return false;
}

public native_core_respawn_as_zombie(id, respawn_as_zombie)
{
if (!is_player(id, 0))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (respawn_as_zombie)
flag_set(g_[RespawnAsZombie], id)
else
flag_unset(g_[RespawnAsZombie], id)

return true;
}
public native_get_synchud_id(hudtype)
{
return g_SyncHud[hudtype]
}

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)
{
if(!g_HamBot && is_user_bot(id))
{
g_HamBot = 1
set_task(0.1, "Register_SafetyFuncBot", id)
}	

Safety_Connected(id)
}

Register_SafetyFunc()
{
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
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
}
public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
