#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_gamemodes>

#define TASK_RESPAWN 511223123
#define ID_RESPAWN (taskid - TASK_RESPAWN)

enum _:TOTAL_FORWARDS
{
FW_USER_RESPAWN_PRE = 0
}
new g_Forwards[TOTAL_FORWARDS],g_ForwardResult, cvar_deathmatch
new g_GameModeStarted, gibtypes, g_MaxPlayers
new cvar_respawn_zombies, cvar_respawn_humans
public plugin_init()
{
RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
cvar_deathmatch = register_cvar("zp_deathmatch", "2")
cvar_respawn_zombies = register_cvar("zp_respawn_zombies", "1")
cvar_respawn_humans = register_cvar("zp_respawn_humans", "1")
g_MaxPlayers = get_maxplayers()
g_Forwards[FW_USER_RESPAWN_PRE] = CreateMultiForward("zp_fw_deathmatch_respawn_pre", ET_CONTINUE, FP_CELL)
}
public plugin_precache()
{
gibtypes = precache_model("models/hgibs.mdl")	
}
public fw_PlayerSpawn_Post(id)
{
if (!is_user_alive(id) || !cs_get_user_team(id))
return;

remove_task(id+TASK_RESPAWN)
}

public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
if ((victim == attacker || !is_user_connected(attacker)))
return;

if ((zp_core_is_zombie(victim) && !get_pcvar_num(cvar_respawn_zombies)) || (!zp_core_is_zombie(victim) && !get_pcvar_num(cvar_respawn_humans)))
return;

gib_death(victim)
set_pev(victim, pev_effects, EF_NODRAW)	
set_task(5.0, "respawn_player_task", victim+TASK_RESPAWN)
}

// Respawn Player Task (deathmatch)
public respawn_player_task(taskid)
{
// Already alive or round ended
if (is_user_alive(ID_RESPAWN) || zp_gamemodes_get_current() == ZP_NO_GAME_MODE)
return;

// Get player's team
new CsTeams:team = cs_get_user_team(ID_RESPAWN)

// Player moved to spectators
if (team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED)
return;

// Allow other plugins to decide whether player can respawn or not
ExecuteForward(g_Forwards[FW_USER_RESPAWN_PRE], g_ForwardResult, ID_RESPAWN)
if (g_ForwardResult >= PLUGIN_HANDLED)
return;

if (get_pcvar_num(cvar_deathmatch) == 2 || (get_pcvar_num(cvar_deathmatch) == 3 && random_num(0, 1)) || (get_pcvar_num(cvar_deathmatch) == 4 && zp_core_get_zombie_count() < GetAliveCount()/2))
{
// Only allow respawning as zombie after a game mode started
if (g_GameModeStarted) zp_core_respawn_as_zombie(ID_RESPAWN, true)
}
respawn_player_manually(ID_RESPAWN)
}
respawn_player_manually(id)
{
ExecuteHamB(Ham_CS_RoundRespawn, id)
}

public client_disconnect(id)
{
remove_task(id+TASK_RESPAWN)
}

public zp_fw_gamemodes_start()
{
g_GameModeStarted = true
}

public zp_fw_gamemodes_end()
{
g_GameModeStarted = false

for (new id = 1; id <= g_MaxPlayers; id++)
remove_task(id+TASK_RESPAWN)
}
public gib_death(id)
{
new origin[3]
get_user_origin(id,origin)

message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(108); // TE_BREAKMODEL 
write_coord(origin[0]); // x 
write_coord(origin[1]); // y 
write_coord(origin[2] + 24); // z 
write_coord(16); // size x 
write_coord(16); // size y 
write_coord(16); // size z 
write_coord(random_num(-50,50)); // velocity x 
write_coord(random_num(-50,50)); // velocity y 
write_coord(25); // velocity z 
write_byte(10); // random velocity 
write_short(gibtypes)
write_byte(10); // count 
write_byte(25); // life 
write_byte(0); // flags: BREAK_GLASS 
message_end(); 
}
GetAliveCount()
{
new iAlive, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id))
iAlive++
}

return iAlive;
}
