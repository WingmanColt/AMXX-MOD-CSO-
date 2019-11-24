#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cs_teams_api>
#include <zp50_core>
#include <zp50_gamemodes>

new g_MaxPlayers,g_HudSync, cvar_allow_respawn
public plugin_init()
{
zp_gamemodes_register("Multiple Infection Mode")
cvar_allow_respawn = register_cvar("zp_allow6_respawn", "1")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
if (!get_pcvar_num(cvar_allow_respawn))
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
if (random_num(1, 20) != 1)
return PLUGIN_HANDLED;

// Min players
if (alive_count < 0)
return PLUGIN_HANDLED;

// Min zombies
if (zombie_count < 2)
return PLUGIN_HANDLED;
}
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
ShowSyncHudMsg(0, g_HudSync, "More zombie comes...")
PlaySound2("sound/ZPChile/ZPC_Multi_Round.wav")	
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
PlaySound2(const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "mp3 play ^"sound/%s^"", sound)
else
client_cmd(0, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
