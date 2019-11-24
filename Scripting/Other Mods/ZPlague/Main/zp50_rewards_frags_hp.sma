#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <cs_teams_api>
#include <zp50_core>

// CS Player PData Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_CSDEATHS = 444
new g_MsgScoreInfo
public plugin_init()
{
g_MsgScoreInfo = get_user_msgid("ScoreInfo")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (victim == attacker || !is_user_connected(attacker))
return;

UpdateFrags(attacker, victim, 1 - 1, 0, 0)
}

public zp_fw_core_infect_post(id, attacker)
{
if (is_user_connected(attacker) && attacker != id)
{
UpdateFrags(attacker, id, 1, 1, 1)
}
}

UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
if (scoreboard)
{
message_begin(MSG_BROADCAST, g_MsgScoreInfo)
write_byte(attacker) // id
write_short(pev(attacker, pev_frags)) // frags
write_short(cs_get_user_deaths(attacker)) // deaths
write_short(0) // class?
write_short(_:cs_get_user_team(attacker)) // team
message_end()

message_begin(MSG_BROADCAST, g_MsgScoreInfo)
write_byte(victim) // id
write_short(pev(victim, pev_frags)) // frags
write_short(cs_get_user_deaths(victim)) // deaths
write_short(0) // class?
write_short(_:cs_get_user_team(victim)) // team
message_end()
}
}
stock fm_cs_set_user_deaths(id, value)
{
// Prevent server crash if entity's private data not initalized
if (pev_valid(id) != PDATA_SAFE)
return;

set_pdata_int(id, OFFSET_CSDEATHS, value)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
