#include <amxmodx>
#include <fun>
#include <cs_teams_api>
#include <zp50_deathmatch>
#include <zp50_gamemodes>

#define TASK_AMB 12523
new cvar_cc_allow_respawn, g_MaxPlayers,g_HudSync
public plugin_init()
{
zp_gamemodes_register("Clown vs Carlito")
register_logevent("logevent_round_end", 2, "1=Round_End")
cvar_cc_allow_respawn = register_cvar("zp_cc_allow_respawn", "0")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
if (!get_pcvar_num(cvar_cc_allow_respawn))
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
if (zp_class_carlito_get(id))
continue;
zp_class_carlito_set(id)
iSnipers++
set_user_health(id, floatround(get_user_health(id) * 1.0))
}
new iAssassin, iMaxAssassin = assassin_count
while (iAssassin < iMaxAssassin)
{
id = GetRandomAlive(random_num(1, alive_count))
if (zp_class_carlito_get(id) || zp_class_clown_get(id))
continue;
zp_class_clown_set(id)
iAssassin++
set_user_health(id, floatround(get_user_health(id) * 1.0))
}
set_hudmessage(random_num(50, 200), 50, random_num(50, 200), -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "Clown vs Carlito...")
client_cmd(0, "stopsound")	
remove_task(TASK_AMB)
set_task(1.0, "ambience", TASK_AMB)	
}
public ambience(id)
{
id -= TASK_AMB
client_cmd(id, "stopsound")
PlaySound("ZPlague/Ambience/clown_amb.mp3")
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
