#include <amxmodx>
#include <fun>
#include <dhudmessage>
#include <cs_teams_api>
#include <zp50_gamemodes>
#include <zp50_core>

new g_MaxPlayers, cvar_allow_respawn
public plugin_init()
{
zp_gamemodes_register("Plague Mode")
cvar_allow_respawn = register_cvar("zp_allow8_respawn", "0")
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
new alive_count = GetAliveCount()

if (!skipchecks)
{
// Random chance
if (random_num(1, 16) != 1)
return PLUGIN_HANDLED;

// Min players
if (alive_count < 8)
return PLUGIN_HANDLED;
}
if (alive_count < 2 + 3)
return PLUGIN_HANDLED;
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
new id, alive_count = GetAliveCount()
new survivor_count = 3
new nemesis_count = 1
new zombie_count = floatround((alive_count - (nemesis_count + survivor_count)) * 0.20, floatround_ceil)

// Turn specified amount of players into Survivors
new iSurvivors, iMaxSurvivors = survivor_count
while (iSurvivors < iMaxSurvivors)
{
// Choose random guy
id = GetRandomAlive(random_num(1, alive_count))

// Already a survivor?
if (zp_class_survivor_get(id))
continue;

// If not, turn him into one
zp_class_survivor_set(id)
iSurvivors++

// Apply survivor health multiplier
set_user_health(id, floatround(get_user_health(id) * 1.0))
}

// Turn specified amount of players into Nemesis
new iNemesis, iMaxNemesis = nemesis_count
while (iNemesis < iMaxNemesis)
{
// Choose random guy
id = GetRandomAlive(random_num(1, alive_count))

// Already a survivor or nemesis?
if (zp_class_survivor_get(id) || zp_class_nemesis_get(id))
continue;

// If not, turn him into one
zp_class_nemesis_set(id)
iNemesis++

// Apply nemesis health multiplier
set_user_health(id, floatround(get_user_health(id) * 1.0))
}
new iZombies, iMaxZombies = zombie_count
while (iZombies < iMaxZombies)
{
id = GetRandomAlive(random_num(1, alive_count))
if (zp_class_survivor_get(id) || zp_core_is_zombie(id))
continue;
zp_core_infect(id, 0)
iZombies++
}
for (id = 1; id <= g_MaxPlayers; id++)
{
// Not alive
if (!is_user_alive(id))
continue;

if (zp_class_survivor_get(id) || zp_core_is_zombie(id))
continue;

cs_set_player_team(id, CS_TEAM_CT)
}

set_dhudmessage(0, random_num(50,100), random_num(50,200), -1.0, 0.17, 1, 1.0, 3.0, 1.0, 1.0)
show_dhudmessage(0, "|| ................................ ||^n Plague Mode Started ! ^n|| ................................ ||")
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
