#include <amxmodx>
#include <cstrike>
#include <fun>
#include <zp50_colorchat>

#define MIN_PLAYERS_NUM 2

new g_szBestPlayerName[32]
new g_iBestPlayer
new g_iPlayerDamage[33]
new g_iPlayerKills[33]
new g_iPlayerHeadShots[33]

public plugin_init()
{
register_event("Damage", "eventDamage", "b", "2!0", "3=0", "4!0")
register_event("DeathMsg", "eventDeathMsg", "a", "1>0")
register_logevent("eventRoundEnd", 2, "1=Round_End")
}

public eventDamage(id)
{
if(get_playersnum() >= MIN_PLAYERS_NUM)
{
static iAttacker
iAttacker = get_user_attacker(id)
if(is_user_alive(iAttacker) && cs_get_user_team(iAttacker) != cs_get_user_team(id) && iAttacker != id) g_iPlayerDamage[iAttacker] += read_data(2)
}
}

public eventDeathMsg()
{
if(get_playersnum() >= MIN_PLAYERS_NUM)
{
new iKiller = read_data(1)
if(is_user_alive(iKiller))
{
g_iPlayerKills[iKiller]++
if(read_data(3)) g_iPlayerHeadShots[iKiller]++
}
}
}

public eventRoundEnd()
{
if(get_playersnum() >= MIN_PLAYERS_NUM)
{
g_iBestPlayer = 0
new iPlayers[32], iPlayersNum, iPlayer, i
get_players(iPlayers, iPlayersNum, "ch")
new bool:bDrawKills
for(i = 0; i < iPlayersNum; i++)
{
iPlayer = iPlayers[i]
if(is_user_connected(iPlayer) && g_iPlayerKills[iPlayer] > g_iPlayerKills[g_iBestPlayer]) g_iBestPlayer = iPlayer
}
for(i = 0; i < iPlayersNum; i++)
{
iPlayer = iPlayers[i]
if(is_user_connected(iPlayer) && g_iPlayerKills[iPlayer] == g_iPlayerKills[g_iBestPlayer] && iPlayer != g_iBestPlayer) bDrawKills = true
}
if(bDrawKills)
{
new bool:bDrawHeadShots
for(i = 0; i < iPlayersNum; i++)
{
iPlayer = iPlayers[i]
if(is_user_connected(iPlayer) && g_iPlayerHeadShots[iPlayer] > g_iPlayerHeadShots[g_iBestPlayer]) g_iBestPlayer = iPlayer
}
for(i = 0; i < iPlayersNum; i++)
{
iPlayer = iPlayers[i]
if(is_user_connected(iPlayer) && g_iPlayerHeadShots[iPlayer] == g_iPlayerHeadShots[g_iBestPlayer] && iPlayer != g_iBestPlayer) bDrawHeadShots = true
}
if(bDrawHeadShots)
{
for(i = 0; i < iPlayersNum; i++)
{
iPlayer = iPlayers[i]
if(is_user_connected(iPlayer) && g_iPlayerDamage[iPlayer] > g_iPlayerDamage[g_iBestPlayer]) g_iBestPlayer = iPlayer
}
}
}
if(g_iBestPlayer != 0)
{
get_user_name(g_iBestPlayer, g_szBestPlayerName, 31)
zp_colored_print(0, "^x03 Best player for this round is ^x04 %s", g_szBestPlayerName)
}
for(i = 0; i < iPlayersNum; i++)
{
iPlayer = iPlayers[i]
g_iPlayerKills[iPlayer] = 0
g_iPlayerHeadShots[iPlayer] = 0
g_iPlayerDamage[iPlayer] = 0
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
