#include <amxmodx>
#include <fun>
#include <dhudmessage>
#include <cs_teams_api>
#include <zp50_core>
#include <zp50_gamemodes>

new g_MaxPlayers, cvar_allow_respawn
public plugin_init()
{
zp_gamemodes_register("Assassin vs Sniper")
cvar_allow_respawn = register_cvar("zp_allow4_respawn", "0")
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
if (random_num(1, 20) != 1)
return PLUGIN_HANDLED;
if (GetAliveCount() < 6)
return PLUGIN_HANDLED;
}
return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
new id, alive_count = GetAliveCount()
new sniper_count = floatround(alive_count * 0.5, floatround_ceil)
new assassin_count = alive_count - sniper_count
new iSnipers, iMaxSniper = sniper_count
while (iSnipers< iMaxSniper)
{
id = GetRandomAlive(random_num(1, alive_count))
if (zp_class_sniper_get(id))
continue;
zp_class_sniper_set(id)
iSnipers++
set_user_health(id, floatround(get_user_health(id) * 1.0))
}
new iAssassin, iMaxAssassin = assassin_count
while (iAssassin < iMaxAssassin)
{
id = GetRandomAlive(random_num(1, alive_count))
if (zp_class_sniper_get(id) || zp_class_assassin_get(id))
continue;
zp_class_assassin_set(id)
iAssassin++
set_user_health(id, floatround(get_user_health(id) * 1.0))
}
set_dhudmessage(random_num(50,200), random_num(50,100), 0, -1.0, 0.17, 1, 1.0, 3.0, 1.0, 1.0)
show_dhudmessage(0, "|| ................................ ||^n Assassins VS Snipers ! ^n|| ................................ ||")
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
