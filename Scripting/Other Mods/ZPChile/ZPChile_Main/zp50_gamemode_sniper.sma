#include <amxmodx>
#include <dhudmessage>
#include <zp50_gamemodes>
#include <zp50_core>

new g_MaxPlayers, g_TargetPlayer, cvar_allow_respawn
public plugin_precache()
{
zp_gamemodes_register("Sniper Mode")
cvar_allow_respawn = register_cvar("zp_allow9_respawn", "0")
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
if (random_num(1, 16) != 1)
return PLUGIN_HANDLED;

// Min players
if (GetAliveCount() < 3)
return PLUGIN_HANDLED;
}

// Game mode allowed
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_post(game_mode_id, target_player)
{
// Pick player randomly?
g_TargetPlayer = (target_player == RANDOM_TARGET_PLAYER) ? GetRandomAlive(random_num(1, GetAliveCount())) : target_player
}

public zp_fw_gamemodes_start()
{
// Turn player into sniper
zp_class_sniper_set(g_TargetPlayer)

// Turn the remaining players into zombies
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
// Not alive
if (!is_user_alive(id))
continue;

// sniper or already a zombie
if (zp_class_sniper_get(id) || zp_core_is_zombie(id))
continue;

zp_core_infect(id)
}

set_dhudmessage(120, 100, 0, -1.0, 0.17, 1, 1.0, 3.0, 1.0, 1.0)
show_dhudmessage(0, "|| ................................ ||^n Sniper Started ! ^n|| ................................ ||")
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
