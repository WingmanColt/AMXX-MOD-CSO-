#include <amxmodx>
#include <cstrike>
#include <zp50_deathmatch>
#include <zp50_gamemodes>

#define TASK_AMB 1143
new cvar_swarm_allow_respawn, g_MaxPlayers,g_HudSync
public plugin_init()
{
zp_gamemodes_register("Swarm Mode")
register_logevent("logevent_round_end", 2, "1=Round_End")
cvar_swarm_allow_respawn = register_cvar("zp_swarm_allow_respawn", "0")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
if (!get_pcvar_num(cvar_swarm_allow_respawn))
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
if (random_num(1, 20) != 1)
return PLUGIN_HANDLED;

// Min players
if (GetAliveCount() < 2)
return PLUGIN_HANDLED;
}

// Game mode allowed
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
// Not alive
if (!is_user_alive(id))
continue;
if (cs_get_user_team(id) != CS_TEAM_T)
continue;
zp_core_infect(id, 0)
}
set_hudmessage(random_num(50,250), random_num(50,250), random_num(50,250), -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "The Killer Zombies... || Swarm Mode!")
PlaySound2("sound/ZPlague/Round/swarm_round.mp3")
client_cmd(0, "stopsound")	
remove_task(TASK_AMB)
set_task(15.0, "ambience", TASK_AMB)			
}
public ambience(id)
{
id -= TASK_AMB
client_cmd(id, "stopsound")
PlaySound2("sound/ZPlague/Ambience/fear2_ambience.mp3")
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
PlaySound2(const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "mp3 play ^"%s^"", sound)
else
client_cmd(0, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
