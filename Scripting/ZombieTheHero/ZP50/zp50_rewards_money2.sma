#include <amxmodx>
#include <cstrike>
#include <ZombieMod5>

#define MAXPLAYERS 32
#define NO_DATA -1

const PDATA_SAFE = 2
const OFFSET_CSMONEY = 115

new g_MaxPlayers
new g_MsgMoney, g_MsgMoneyBlockStatus
new g_MoneyAtRoundStart[MAXPLAYERS+1] = { NO_DATA , ...}
new g_MoneyRewarded[MAXPLAYERS+1] = { NO_DATA , ...}
new g_MoneyBeforeKill[MAXPLAYERS+1]
new Float:g_DamageDealtToZombies[MAXPLAYERS+1]
new Float:g_DamageDealtToHumans[MAXPLAYERS+1]

new g_IsAlive, g_IsConnected, g_IsZombie
public plugin_init()
{
Register_SafetyFunc()
	
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)

register_message(g_MsgMoney, "message_money")
g_MaxPlayers = get_maxplayers()
g_MsgMoney = get_user_msgid("Money")
}

public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
if (zp_GameEnd() || !zp_GameStart())
return	
if (victim == attacker || !is_player(attacker, 1))
return;
if (Get_BitVar(g_IsZombie, attacker))
return
if (!Get_BitVar(g_IsZombie, victim))
return
static GET; GET = cs_get_user_money(attacker)
if (2.0 > 0)
{
g_DamageDealtToHumans[attacker] += damage

new how_many_rewards = floatround(g_DamageDealtToHumans[attacker] / 30, floatround_floor)
if (how_many_rewards > 0)
{
if(zp_core_is_vip(attacker) && zp_core_is_admin(attacker))
{
cs_set_user_money(attacker, min(GET + (60 * how_many_rewards), 50000))
g_DamageDealtToHumans[attacker] -= 60 * how_many_rewards
}
else
{
cs_set_user_money(attacker, min(GET + (40 * how_many_rewards), 50000))
g_DamageDealtToHumans[attacker] -= 40 * how_many_rewards
}
}
}
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (victim == attacker || !Get_BitVar(g_IsConnected, attacker))
return;

g_MsgMoneyBlockStatus = get_msg_block(g_MsgMoney)
set_msg_block(g_MsgMoney, BLOCK_SET)
}

public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
if (victim == attacker || !Get_BitVar(g_IsConnected, attacker))
return;

set_msg_block(g_MsgMoney, g_MsgMoneyBlockStatus)
}
/*public zp_fw_gamemodes_end()
{	
if (!zp_core_get_players_count(1, 1))
{
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!Get_BitVar(g_IsConnected, id))
continue;

g_MoneyRewarded[id] = 100
}
}
}*/

public message_money(msg_id, msg_dest, msg_entity)
{
if (!Get_BitVar(g_IsConnected,msg_entity))
return;

if (get_msg_arg_int(2) == 0 && g_MoneyAtRoundStart[msg_entity] != NO_DATA)
{
fm_cs_set_user_money(msg_entity, g_MoneyAtRoundStart[msg_entity])
set_msg_arg_int(1, get_msg_argtype(1), g_MoneyAtRoundStart[msg_entity])
g_MoneyAtRoundStart[msg_entity] = NO_DATA
}
}

stock fm_cs_set_user_money(id, value)
{
if (pev_valid(id) != PDATA_SAFE)
return;

set_pdata_int(id, OFFSET_CSMONEY, value)
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_MoneyAtRoundStart[id] = NO_DATA
g_MoneyRewarded[id] = NO_DATA

g_DamageDealtToZombies[id] = 0.0
g_DamageDealtToHumans[id] = 0.0
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

//cs_set_user_money(id, g_MoneyAtRoundStart[id])
}
public zp_fw_round_new()
{
for (new id = 1; id <= g_MaxPlayers; id++)
{
if (!Get_BitVar(g_IsAlive, id))
continue;

g_MoneyAtRoundStart[id] = min(cs_get_user_money(id) + g_MoneyRewarded[id], 50000)
cs_set_user_money(id, g_MoneyAtRoundStart[id])
}	
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

//cs_set_user_money(id, g_MoneyAtRoundStart[id])
}
public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id, attacker)
{
if(zp_core_is_zombie(id))
{
Set_BitVar(g_IsZombie, id)
g_MoneyAtRoundStart[id] = min(cs_get_user_money(id) + g_MoneyRewarded[id], 50000)
}
if (Get_BitVar(g_IsConnected, attacker) && attacker != id && 100 > 0)
cs_set_user_money(attacker, min(cs_get_user_money(attacker) + 100, 50000))
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
