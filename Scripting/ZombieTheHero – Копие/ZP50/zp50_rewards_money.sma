#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
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

public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)

register_message(g_MsgMoney, "message_money")
g_MaxPlayers = get_maxplayers()
g_MsgMoney = get_user_msgid("Money")
}

public zp_fw_core_infect_post(id, attacker)
{
if (is_user_connected(attacker) && attacker != id && 100 > 0)
cs_set_user_money(attacker, min(cs_get_user_money(attacker) + 100, MAX_MONEY))
}

public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return;

if (zp_GameStart() && !zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{
if (2.0 > 0)
{
g_DamageDealtToHumans[attacker] += damage

new how_many_rewards = floatround(g_DamageDealtToHumans[attacker] / 30, floatround_floor)
if (how_many_rewards > 0)
{
if(zp_core_is_vip(attacker) && zp_core_is_admin(attacker))
{
cs_set_user_money(attacker, min(cs_get_user_money(attacker) + (60 * how_many_rewards), MAX_MONEY))
g_DamageDealtToHumans[attacker] -= 60 * how_many_rewards
}
else
{
cs_set_user_money(attacker, min(cs_get_user_money(attacker) + (40 * how_many_rewards), MAX_MONEY))
g_DamageDealtToHumans[attacker] -= 40 * how_many_rewards
}
}
}
}
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (victim == attacker || !is_user_connected(attacker))
return;

g_MsgMoneyBlockStatus = get_msg_block(g_MsgMoney)
set_msg_block(g_MsgMoney, BLOCK_SET)

g_MoneyBeforeKill[attacker] = cs_get_user_money(attacker)
}

public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
if (victim == attacker || !is_user_connected(attacker))
return;

set_msg_block(g_MsgMoney, g_MsgMoneyBlockStatus)

if (zp_core_is_zombie(victim))
cs_set_user_money(attacker, min(g_MoneyBeforeKill[attacker] + 200, MAX_MONEY))
else cs_set_user_money(attacker, min(g_MoneyBeforeKill[attacker] + 100, MAX_MONEY))
}

public zp_fw_core_spawn_post(id)
{
cs_set_user_money(id, min(cs_get_user_money(id) + g_MoneyBeforeKill[id], MAX_MONEY))
}

public message_money(msg_id, msg_dest, msg_entity)
{
if (!is_user_connected(msg_entity))
return;

if (get_msg_arg_int(2) == 0 && g_MoneyAtRoundStart[msg_entity] != NO_DATA)
{
fm_cs_set_user_money(msg_entity, g_MoneyAtRoundStart[msg_entity])
set_msg_arg_int(1, get_msg_argtype(1), g_MoneyAtRoundStart[msg_entity])
g_MoneyAtRoundStart[msg_entity] = NO_DATA
}
}
public client_disconnected(id)
{
g_MoneyAtRoundStart[id] = NO_DATA
g_MoneyRewarded[id] = NO_DATA

g_DamageDealtToZombies[id] = 0.0
g_DamageDealtToHumans[id] = 0.0
}
stock fm_cs_set_user_money(id, value)
{
if (pev_valid(id) != PDATA_SAFE)
return;

set_pdata_int(id, OFFSET_CSMONEY, value)
}
