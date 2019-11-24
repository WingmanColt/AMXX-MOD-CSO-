#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_teams_api>
#include <zp50_core>
#include <zp50_gamemodes>

#define TASK_AURA 300
#define ID_AURA (taskid - TASK_AURA)
new g_MaxPlayers,g_TargetPlayer,g_HudSync, cvar_allow_respawn, cvar_respawn_after_last
public plugin_init()
{
new game_mode_id = zp_gamemodes_register("Infection Mode")
zp_gamemodes_set_default(game_mode_id)
cvar_allow_respawn = register_cvar("zp_allow5_respawn", "1")
cvar_respawn_after_last = register_cvar("zp_respawn_after_last_human", "0")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_core_cure_post(id)
{
if(task_exists(id+TASK_AURA))	
remove_task(id+TASK_AURA)	
}
public zp_fw_deathmatch_respawn_pre(id)
{
// Respawning allowed?
if (!get_pcvar_num(cvar_allow_respawn))
return PLUGIN_HANDLED;

// Respawn if only the last human is left?
if (!get_pcvar_num(cvar_respawn_after_last) && zp_core_get_human_count() == 1)
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public client_disconnect(id)remove_task(id+TASK_AURA)
public zp_fw_gamemodes_choose_pre(game_mode_id, skipchecks)
{
if (!skipchecks)
{
// Random chance
if (random_num(1, 1) != 1)
return PLUGIN_HANDLED;

// Min players
if (GetAliveCount() < 0)
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
zp_gamemodes_set_allow_infect()
zp_core_infect(g_TargetPlayer, g_TargetPlayer) // victim = atttacker so that infection sound is played
set_user_health(g_TargetPlayer, floatround(get_user_health(g_TargetPlayer) * 2.0))
PlaySound(g_TargetPlayer, "sound/ZPChile/infected01.wav")
if(zp_core_is_first_zombie(g_TargetPlayer))
set_task(0.1, "aura", g_TargetPlayer+TASK_AURA, _, _, "b")

for (new id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id))
continue;
if (zp_core_is_zombie(id))
continue;
cs_set_player_team(id, CS_TEAM_CT)
}
set_hudmessage(random_num(50,200), 0, 0, -1.0, 0.17, 0, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "The Zombie Arrived!")
}
public aura(taskid)
{
static origin[3]
get_user_origin(ID_AURA, origin)
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(15) // radius
write_byte(100) // r
write_byte(100) // g
write_byte(0) // b
write_byte(2) // life
write_byte(0) // decay rate
message_end()
message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_LAVASPLASH); 
write_coord(origin[0]); 
write_coord(origin[1]); 
write_coord(origin[2]); 
message_end(); 
set_task(10.0, "stop_aura", ID_AURA)
}
public stop_aura(id)remove_task(id+TASK_AURA)
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
stock PlaySound(id, const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(id, "mp3 play ^"sound/%s^"", sound)
else
client_cmd(id, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
