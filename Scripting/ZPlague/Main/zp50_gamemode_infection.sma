#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_teams_api>
#include <zp50_deathmatch>
#include <zp50_gamemodes>

#define TASK_AMB 1141
new g_MaxPlayers, g_TargetPlayer, g_HudSync
new cvar_infection_allow_respawn, cvar_respawn_after_last_human
public plugin_init()
{
new game_mode_id = zp_gamemodes_register("Infection Mode")
zp_gamemodes_set_default(game_mode_id)
register_logevent("logevent_round_end", 2, "1=Round_End")
cvar_infection_allow_respawn = register_cvar("zp_infection_allow_respawn", "1")
cvar_respawn_after_last_human = register_cvar("zp_respawn_after_last_human", "0")
g_HudSync = CreateHudSyncObj()
g_MaxPlayers = get_maxplayers()
}
public zp_fw_deathmatch_respawn_pre(id)
{
// Respawning allowed?
if (!get_pcvar_num(cvar_infection_allow_respawn))
return PLUGIN_HANDLED;

// Respawn if only the last human is left?
if (!get_pcvar_num(cvar_respawn_after_last_human) && zp_core_get_human_count() == 1)
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public zp_fw_gamemodes_choose_pre(game_mode_id, skipchecks)
{
if (!skipchecks)
{
// Random chance
if (random_num(1, 1) != 1)
return PLUGIN_HANDLED;

// Min players
if (GetAliveCount() < 2)
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
infection_explode(g_TargetPlayer)
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id))
continue;
if (zp_core_is_zombie(id))
continue;
cs_set_player_team(id, CS_TEAM_CT)
}
client_cmd(0, "stopsound")	
set_hudmessage(random_num(50,150), random_num(50,100), random_num(50,100), -1.0, 0.17, 0, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "Come My Children!")
PlaySound(0, "ZPlague/Zombie_Coming.wav")
remove_task(TASK_AMB)
set_task(5.0, "ambience", TASK_AMB)			
}
infection_explode(ent)
{
if(!pev_valid(ent))
return;	
if(zp_core_get_human_count() == 1)
return;
static origin[3]
pev(ent, pev_origin, origin)
new victim = -1

while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 70.0)) != 0)
{
if (!is_user_alive(victim) || zp_core_is_zombie(victim))
continue;

zp_core_infect(victim, victim)
}
}
public ambience(id)
{
id -= TASK_AMB
client_cmd(id, "stopsound")
PlaySound(id, "ZPlague/Ambience/fear1_ambience.mp3")
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
