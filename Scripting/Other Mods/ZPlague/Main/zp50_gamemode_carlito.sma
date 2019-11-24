#include <amxmodx>
#include <zp50_gamemodes>
#include <zp50_deathmatch>

#define TASK_AMB 11363
new cvar_carlito_allow_respawn, g_MaxPlayers,g_TargetPlayer,g_HudSync
public plugin_init()
{
zp_gamemodes_register("Carlito Mode")
register_logevent("logevent_round_end", 2, "1=Round_End")
cvar_carlito_allow_respawn = register_cvar("zp_carlito_allow_respawn", "0")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
if (!get_pcvar_num(cvar_carlito_allow_respawn))
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
if (GetAliveCount() < 3)
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
zp_class_carlito_set(g_TargetPlayer)
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id))
continue;
if (zp_class_carlito_get(id) || zp_core_is_zombie(id))
continue;
zp_core_infect(id)
}
set_hudmessage(0, 150, 10, -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "Carlito Human Is Here!")
PlaySound2("sound/ZPlague/Round/carlito_round.mp3")
client_cmd(0, "stopsound")	
remove_task(TASK_AMB)
set_task(20.0, "ambience", TASK_AMB)	
}
public ambience(id)
{
id -= TASK_AMB
client_cmd(id, "stopsound")
PlaySound2("sound/ZPlague/Ambience/carlito_ambience.mp3")
set_task(200.0, "ambience", id+TASK_AMB, _, _, "b")
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
PlaySound2(const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "mp3 play ^"%s^"", sound)
else
client_cmd(0, "spk ^"%s^"", sound)
}
