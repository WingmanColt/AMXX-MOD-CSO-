#include <amxmodx>
#include <cstrike>
#include <zp50_gamemodes>

new g_MaxPlayers,g_HudSync, cvar_allow_respawn
public plugin_precache()
{
zp_gamemodes_register("Swarm Mode")
cvar_allow_respawn = register_cvar("zp_allow11_respawn", "0")
g_HudSync = CreateHudSyncObj()
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
if (random_num(1, 11) != 1)
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
ShowSyncHudMsg(0, g_HudSync, "Soldiers they are Killers... || Swarm Mode!")
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
