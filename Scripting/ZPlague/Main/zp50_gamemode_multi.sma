#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cs_teams_api>
#include <zp50_deathmatch>
#include <zp50_gamemodes>

#define TASK_AMB 1142
new g_MaxPlayers, g_HudSync
new cvar_infection_allow_respawn, cvar_respawn_after_last_human
public plugin_init()
{
zp_gamemodes_register("Multiple Infection Mode")
register_logevent("logevent_round_end", 2, "1=Round_End")
cvar_infection_allow_respawn = register_cvar("zp_multi_allow_respawn", "1")
cvar_respawn_after_last_human = register_cvar("zp_respawn_after_last_human2", "0")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
// Respawning allowed?
if (!get_pcvar_num(cvar_infection_allow_respawn))
return PLUGIN_HANDLED;

// Respawn if only the last human is left?
if (!get_pcvar_num(cvar_respawn_after_last_human) && zp_core_get_human_count() == 1)
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public zp_fw_gamemodes_choose_pre(game_mode_id, skipchecks)
{
new alive_count = GetAliveCount()

// Calculate zombie count with current ratio setting
new zombie_count = floatround(alive_count * 0.15, floatround_ceil)

if (!skipchecks)
{
// Random chance
if (random_num(1, 25) != 1)
return PLUGIN_HANDLED;

// Min players
if (alive_count < 7)
return PLUGIN_HANDLED;

// Min zombies
if (zombie_count < 2)
return PLUGIN_HANDLED;
}

// Zombie count should be smaller than alive players count, so that there's humans left in the round
if (zombie_count >= alive_count)
return PLUGIN_HANDLED;

// Game mode allowed
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
// Allow infection for this game mode
zp_gamemodes_set_allow_infect()

// iMaxZombies is rounded up, in case there aren't enough players
new iZombies, id, alive_count = GetAliveCount()
new iMaxZombies = floatround(alive_count * 0.15, floatround_ceil)
while (iZombies < iMaxZombies)
{
id = GetRandomAlive(random_num(1, alive_count))

if (!is_user_alive(id) || zp_core_is_zombie(id))
continue;

zp_core_infect(id, 0)
iZombies++
}

for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id) || zp_core_is_zombie(id))
continue;
cs_set_player_team(id, CS_TEAM_CT)
}
set_hudmessage(random_num(50,200), random_num(50,200), 0, -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "Multi Infection ...")
client_cmd(0, "stopsound")	
remove_task(TASK_AMB)
set_task(5.0, "ambience", TASK_AMB)			
}
public ambience(id)
{
id -= TASK_AMB
client_cmd(id, "stopsound")
PlaySound("ZPlague/Ambience/fear1_ambience.mp3")
set_task(170.0, "ambience", id+TASK_AMB, _, _, "b")
}
public logevent_round_end(id)remove_task(id+TASK_AMB)	
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

// Get Random Alive -returns index of alive player number target_index -
GetRandomAlive(target_index)
{
new iAlive, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id))
iAlive++

if (iAlive == target_index)
return id;
}

return -1;
}
stock PlaySound(const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "mp3 play ^"sound/%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
