#include <amxmodx>
#include <cstrike>
#include <ZombieMod5>

const PDATA_SAFE = 2
const OFFSET_CSDEATHS = 444

public plugin_init()
{
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")	
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (victim == attacker || !is_user_connected(attacker))
return;

if (zp_core_is_zombie(attacker) && 1 > 1)
{
UpdateFrags(attacker, victim, 1 - 1, 0, 0)
}
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
message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
write_byte(attacker) // id
write_short(pev(attacker, pev_frags)) // frags
write_short(cs_get_user_deaths(attacker)) // deaths
write_short(0) // class?
write_short(_:cs_get_user_team(attacker)) // team
message_end()

message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
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
if (pev_valid(id) != PDATA_SAFE)
return;

set_pdata_int(id, OFFSET_CSDEATHS, value)
}
