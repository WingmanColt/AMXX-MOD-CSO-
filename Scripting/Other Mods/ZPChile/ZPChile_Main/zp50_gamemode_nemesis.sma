#include <amxmodx>
#include <dhudmessage>
#include <cs_teams_api>
#include <zp50_gamemodes>
#include <zp50_core>

new g_MaxPlayers,g_TargetPlayer, cvar_allow_respawn
public plugin_init()
{
zp_gamemodes_register("Nemesis Mode")
cvar_allow_respawn = register_cvar("zp_allow7_respawn", "0")
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
if (!get_pcvar_num(cvar_allow_respawn))
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
if (random_num(1, 18) != 1)
return PLUGIN_HANDLED;

// Min players
if (GetAliveCount() < 0)
return PLUGIN_HANDLED;
}
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_post(game_mode_id, target_player)
{
// Pick player randomly?
g_TargetPlayer = (target_player == RANDOM_TARGET_PLAYER) ? GetRandomAlive(random_num(1, GetAliveCount())) : target_player
}

public zp_fw_gamemodes_start()
{
zp_class_nemesis_set(g_TargetPlayer)
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id))
continue;
if (zp_class_nemesis_get(id))
continue;
cs_set_player_team(id, CS_TEAM_CT)
}
new name[32]
get_user_name(g_TargetPlayer, name, charsmax(name))
set_dhudmessage(200, 0, 100, -1.0, 0.17, 1, 1.0, 3.0, 1.0, 1.0)
show_dhudmessage(0, "|| ................................ ||^n Nemesis Mode ! ^n The Nemesis is %s ^n|| ................................ ||", name)
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
