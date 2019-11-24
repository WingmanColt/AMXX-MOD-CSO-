#include <amxmodx>
#include <fun>
#include <cs_teams_api>
#include <zp50_deathmatch>
#include <zp50_gamemodes>

#define TASK_AMB 11132
new cvar_biohazard_allow_respawn, g_MaxPlayers,g_HudSync
public plugin_init()
{
zp_gamemodes_register("Biohazard Mode")
register_logevent("logevent_round_end", 2, "1=Round_End")
cvar_biohazard_allow_respawn = register_cvar("zp_biohazard_allow_respawn", "1")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
if (!get_pcvar_num(cvar_biohazard_allow_respawn))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public zp_fw_gamemodes_choose_pre(game_mode_id, skipchecks)
{
new alive_count = GetAliveCount()

if (!skipchecks)
{
// Random chance
if (random_num(1, 30) != 1)
return PLUGIN_HANDLED;

// Min players
if (alive_count < 0)
return PLUGIN_HANDLED;
}
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
zp_gamemodes_set_allow_infect()
new iZombies, id, alive_count = GetAliveCount()
new iMaxZombies = floatround(alive_count * 0.10, floatround_ceil)
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
if (!is_user_alive(id))
continue;

if (zp_class_carlito_get(id) || zp_core_is_zombie(id))
continue;

cs_set_player_team(id, CS_TEAM_CT)
}
client_cmd(0, "stopsound")
set_hudmessage(0, random_num(50,200), 0, -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "Now, Gameplay is Biohazard!")
PlaySound("ZPlague/Infect/zombie_infect7.wav")		
remove_task(TASK_AMB)
set_task(5.0, "ambience", TASK_AMB)	
}
public ambience(id)
{
id -= TASK_AMB
client_cmd(id, "stopsound")
PlaySound("ZPlague/Ambience/ambience.wav")
set_task(18.0, "ambience", id+TASK_AMB, _, _, "b")
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
PlaySound(const sound[])
{
client_cmd(0, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
