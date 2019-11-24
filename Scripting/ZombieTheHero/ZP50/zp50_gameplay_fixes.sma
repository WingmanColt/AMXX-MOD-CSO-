#include <amxmodx>
#include <cs_teams_api>
#include <ZombieMod5>

#define MENUCODE_TEAMSELECT 1
const STATIONARY_USING = 2
const OFFSET_CSMENUCODE = 205
new g_MaxPlayers, name[32]

public plugin_init()
{
register_message(get_user_msgid("Health"), "message_health")
	
RegisterHam(Ham_Use, "func_tank", "fw_UseStationary")
RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary")
RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary")
RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary")
RegisterHam(Ham_Use, "func_pushable", "fw_UsePushable")

g_MaxPlayers = get_maxplayers()
}
/*
public client_disconnected(leaving_player)
{
if (!is_user_alive(leaving_player))
return;

if (GetAliveCount() == 1)
return;

new id

// Prevent empty teams when no game mode is in progress
if (!zp_GameStart())
{
// Last Terrorist
if ((cs_get_user_team(leaving_player) == CS_TEAM_T) && (GetAliveTCount() == 1))
{
// Find replacement and move him to T team
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) {  }
cs_set_player_team(id, CS_TEAM_T)
}
// Last CT
else if ((cs_get_user_team(leaving_player) == CS_TEAM_CT) && (GetAliveCTCount() == 1))
{
// Find replacement and move him to CT team
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) { }
cs_set_player_team(id, CS_TEAM_CT)
}
}
// Prevent no zombies/humans after game mode started
else
{
// Last Zombie
if (zp_core_is_zombie(leaving_player) && zp_core_get_players_count(1, 1) == 1)
{
// Find replacement
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) {  }

get_user_name(id, name, charsmax(name))
client_print(0, print_chat, "The last zombie has left, %s is the new zombie.", name)
//zp_core_infect(id, id)
zp_core_respawn_as_zombie(id, true)
cs_set_user_team(id,CS_TEAM_T)
ExecuteHamB(Ham_CS_RoundRespawn, id)
}
// Last Human
else if (!zp_core_is_zombie(leaving_player) && zp_core_get_players_count(1, 2) == 1)
{

// Find replacement
while ((id = GetRandomAlive(random_num(1, GetAliveCount()))) == leaving_player ) {  }
get_user_name(id, name, charsmax(name))
client_print(0, print_chat, "The last zombie has left, %s is the new human.", name)
//zp_core_cure(id, id)
zp_core_respawn_as_zombie(id, false)
cs_set_user_team(id,CS_TEAM_CT)
ExecuteHamB(Ham_CS_RoundRespawn, id)
}
}
}
*/
public zp_fw_game_start()
{
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_alive(id))
continue;

if (get_pdata_int(id, OFFSET_CSMENUCODE) == MENUCODE_TEAMSELECT)
set_pdata_int(id, OFFSET_CSMENUCODE, 0)
}
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
public message_health(msg_id, msg_dest, id)
{
if(!is_user_connected(id))
return;
	
static health
health = get_user_health(id)

//// Don't bother
if(health < 1) 
return

static Float:NewHealth, RealHealth, Health

if(zp_core_is_zombie(id))
{
switch(zb5_get_zombie_info(id, EVO_LV))
{	
case ORIGIN:NewHealth = (float(health) / float(14000)) * 250.0	
case HOST:NewHealth = (float(health) / float(12000)) * 200.0
case NORMAL:NewHealth = (float(health) / zb5_get_zombie_info(id, HEALTH)) * 100.0
} 
} else NewHealth = (float(health) / float(1000)) * 100.0

RealHealth = floatround(NewHealth)
Health = clamp(RealHealth, 1, 255)

set_msg_arg_int(1, get_msg_argtype(1), Health)
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
