#include <amxmodx>
#include <cs_teams_api>
#include <zp50_deathmatch>
#include <zp50_gamemodes>

#define TASK_AMB 1123
new cvar_assassin_allow_respawn, g_MaxPlayers,g_HudSync,g_TargetPlayer
public plugin_init()
{	
zp_gamemodes_register("Assassin Mode")
register_logevent("logevent_round_end", 2, "1=Round_End")
cvar_assassin_allow_respawn = register_cvar("zp_assassin_allow_respawn", "0")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
if (!get_pcvar_num(cvar_assassin_allow_respawn))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public zp_fw_core_spawn_post(id)
{
zp_core_respawn_as_zombie(id, false)
}

public zp_fw_gamemodes_choose_pre(game_mode_id, skipchecks)
{
if (!skipchecks)
{
// Random chance
if (random_num(1, 30) != 1)
return PLUGIN_HANDLED;

// Min players
if (GetAliveCount() < 0)
return PLUGIN_HANDLED;
}
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_post(game_mode_id, target_player)
{
g_TargetPlayer = (target_player == RANDOM_TARGET_PLAYER) ? GetRandomAlive(random_num(1, GetAliveCount())) : target_player
}

public zp_fw_gamemodes_start()
{	
zp_class_assassin_set(g_TargetPlayer)
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id))
continue;
if (zp_class_assassin_get(id))
continue;
cs_set_player_team(id, CS_TEAM_CT)
}
new name[32]
get_user_name(g_TargetPlayer, name, charsmax(name))
set_hudmessage(random_num(50,200), random_num(50,100), 0, -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "%s Is a Assassin!", name)
PlaySound("ZPlague/Round/assassin_round.mp3")
client_cmd(0, "stopsound")	
remove_task(TASK_AMB)
set_task(15.0, "ambience", TASK_AMB)			
}
public ambience(id)
{
id -= TASK_AMB
client_cmd(id, "stopsound")
PlaySound("ZPlague/Ambience/assassin_ambience.mp3")
set_task(75.0, "ambience", id+TASK_AMB, _, _, "b")
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
