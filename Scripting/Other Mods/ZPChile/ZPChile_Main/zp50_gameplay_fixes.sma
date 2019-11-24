#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <cs_teams_api>
#include <zp50_gamemodes>
#include <zp50_colorchat>

#define CLASSNAME_MAX_LENGTH 32
#define MENUCODE_TEAMSELECT 1
new const gameplay_ents[][] = { "func_vehicle", "item_longjump" }
new Array:g_gameplay_ents
const STATIONARY_USING = 2
const OFFSET_CSMENUCODE = 205
new g_MaxPlayers, g_fwSpawn, g_GameModeStarted
public plugin_init()
{
RegisterHam(Ham_Use, "func_tank", "fw_UseStationary")
RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary")
RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary")
RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary")
RegisterHam(Ham_Use, "func_pushable", "fw_UsePushable")
register_forward(FM_ClientKill, "fw_ClientKill")
unregister_forward(FM_Spawn, g_fwSpawn)
register_message(get_user_msgid("Health"), "message_health")
register_clcmd("chooseteam", "clcmd_changeteam")
register_clcmd("jointeam", "clcmd_changeteam")
g_MaxPlayers = get_maxplayers()
}
public plugin_precache()
{
g_gameplay_ents = ArrayCreate(CLASSNAME_MAX_LENGTH, 1)
new index
if (ArraySize(g_gameplay_ents) == 0)
{
for (index = 0; index < sizeof gameplay_ents; index++)
ArrayPushString(g_gameplay_ents, gameplay_ents[index])
}
g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
}
public clcmd_changeteam(id)
{
if (g_GameModeStarted && is_user_alive(id))
{
return PLUGIN_HANDLED;
}
return PLUGIN_CONTINUE;
}
public fw_Spawn(entity)
{
// Invalid entity
if (!pev_valid(entity))
return FMRES_IGNORED;

// Get classname
new classname[32], objective[32], size = ArraySize(g_gameplay_ents)
pev(entity, pev_classname, classname, charsmax(classname))

// Check whether it needs to be removed
new index
for (index = 0; index < size; index++)
{
ArrayGetString(g_gameplay_ents, index, objective, charsmax(objective))

if (equal(classname, objective))
{
engfunc(EngFunc_RemoveEntity, entity)
return FMRES_SUPERCEDE;
}
}

return FMRES_IGNORED;
}
public client_disconnect(leaving_player)
{
if (!is_user_alive(leaving_player))
return;

if (GetAliveCount() == 1)
return;

new id

// Prevent empty teams when no game mode is in progress
if (!g_GameModeStarted)
{
// Last Terrorist
if ((cs_get_user_team(leaving_player) == CS_TEAM_T) && (GetAliveTCount() == 1))
{
// Find replacement and move him to T team
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) { /* keep looping */ }
cs_set_player_team(id, CS_TEAM_T)
}
// Last CT
else if ((cs_get_user_team(leaving_player) == CS_TEAM_CT) && (GetAliveCTCount() == 1))
{
// Find replacement and move him to CT team
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) { /* keep looping */ }
cs_set_player_team(id, CS_TEAM_CT)
}
}
// Prevent no zombies/humans after game mode started
else
{
// Last Zombie
if (zp_core_is_zombie(leaving_player) && zp_core_get_zombie_count() == 1)
{
// Only one CT left, don't leave an empty CT team
if (zp_core_get_human_count() == 1 && GetCTCount() == 1)
return;

// Find replacement
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) { /* keep looping */ }

new name[32]
get_user_name(id, name, charsmax(name))
zp_colored_print(0, "The last zombie has left, %s is the new zombie.", name)
if (zp_class_nemesis_get(leaving_player))
{
zp_class_nemesis_set(id)
set_user_health(id, get_user_health(leaving_player))
}
else if (zp_class_assassin_get(leaving_player))
{
zp_class_assassin_set(id)
set_user_health(id, get_user_health(leaving_player))
}
else
zp_core_infect(id, id)
}
// Last Human
else if (!zp_core_is_zombie(leaving_player) && zp_core_get_human_count() == 1)
{
// Only one T left, don't leave an empty T team
if (zp_core_get_zombie_count() == 1 && GetTCount() == 1)
return;

// Find replacement
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) { /* keep looping */ }

new name[32]
get_user_name(id, name, charsmax(name))
zp_colored_print(0, "The last zombie has left, %s is the new human.", name)

if (zp_class_survivor_get(leaving_player))
{
zp_class_survivor_set(id)
set_user_health(id, get_user_health(leaving_player))
}
else if (zp_class_sniper_get(leaving_player))
{
zp_class_sniper_set(id)
set_user_health(id, get_user_health(leaving_player))
}
else
zp_core_cure(id, id)
}
}
}

public zp_fw_gamemodes_start()
{
g_GameModeStarted = true
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id))
continue;
if (get_pdata_int(id, OFFSET_CSMENUCODE) == MENUCODE_TEAMSELECT)
set_pdata_int(id, OFFSET_CSMENUCODE, 0)
}
}

public zp_fw_gamemodes_end()
{
g_GameModeStarted = false
}

public fw_UseStationary(entity, caller, activator, use_type)
{
if (!pev_valid(entity))
return FMRES_IGNORED;
	
if (use_type == STATIONARY_USING && is_user_alive(caller) && zp_core_is_zombie(caller))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}
public fw_UsePushable()
{
return HAM_IGNORED;
}

public fw_ClientKill()
{
if (g_GameModeStarted)
return FMRES_SUPERCEDE;

return FMRES_IGNORED;
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity)
{
// Get player's health
new health = get_msg_arg_int(1)

// Don't bother
if (health < 256) return;

// Check if we need to fix it
if (health % 256 == 0)
set_user_health(msg_entity, get_user_health(msg_entity) + 1)

// HUD can only show as much as 255 hp
set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// Get Alive CTs -returns number of CTs alive-
GetAliveCTCount()
{
new iCTs, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT)
iCTs++
}

return iCTs;
}

// Get Alive Ts -returns number of Ts alive-
GetAliveTCount()
{
new iTs, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T)
iTs++
}

return iTs;
}

// Get CTs -returns number of CTs connected-
GetCTCount()
{
new iCTs, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_CT)
iCTs++
}

return iCTs;
}

// Get Ts -returns number of Ts connected-
GetTCount()
{
new iTs, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_T)
iTs++
}

return iTs;
}

// Get Alive Count -returns alive players number-
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

// Get Random Alive -returns index of alive player number target_index -
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
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
