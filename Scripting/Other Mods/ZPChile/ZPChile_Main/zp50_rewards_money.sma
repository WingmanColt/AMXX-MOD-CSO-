#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_gamemodes>
#define LIBRARY_NEMESIS "zp50_class_nemesis"
#include <zp50_class_nemesis>
#define LIBRARY_ASSASSIN "zp50_class_assassin"
#include <zp50_class_assassin>
#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>
#define LIBRARY_SNIPER "zp50_class_sniper"
#include <zp50_class_sniper>

#define MAXPLAYERS 32
#define CS_MONEY_LIMIT 100000
#define NO_DATA -1

// CS Player PData Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_CSMONEY = 115

new g_MaxPlayers
new g_GameRestarting
new g_MsgMoney, g_MsgMoneyBlockStatus

new g_MoneyAtRoundStart[MAXPLAYERS+1] = { NO_DATA , ...}
new g_MoneyRewarded[MAXPLAYERS+1] = { NO_DATA , ...}
new g_MoneyBeforeKill[MAXPLAYERS+1]

new Float:g_DamageDealtToZombies[MAXPLAYERS+1]
new Float:g_DamageDealtToHumans[MAXPLAYERS+1]

public plugin_init()
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
register_event("TextMsg", "event_game_restart", "a", "2=#Game_will_restart_in")
register_event("TextMsg", "event_game_restart", "a", "2=#Game_Commencing")
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
g_MsgMoney = get_user_msgid("Money")
register_message(g_MsgMoney, "message_money")
g_MaxPlayers = get_maxplayers()
}

public plugin_natives()
{
set_module_filter("module_filter")
set_native_filter("native_filter")
}
public module_filter(const module[])
{
if (equal(module, LIBRARY_NEMESIS) || equal(module, LIBRARY_ASSASSIN) || equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
if (!trap)
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}

public zp_fw_core_infect_post(id, attacker)
{
// Reward money to zombies infecting humans?
if (is_user_connected(attacker) && attacker != id && 200 > 0)
cs_set_user_money(attacker, min(cs_get_user_money(attacker) + 200, CS_MONEY_LIMIT))
}

// Ham Take Damage Post Forward
public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
// Non-player damage or self damage
if (victim == attacker || !is_user_alive(attacker))
return;

// Ignore money rewards for Nemesis?
if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(attacker))
return;

// Ignore money rewards for Assassin?
if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(attacker))
return;

// Ignore money rewards for Survivor?
if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(attacker))
return;

// Ignore money rewards for Sniper?
if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(attacker))
return;

if (!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{
if (15.0 > 0)
{
// Store damage dealt
g_DamageDealtToHumans[attacker] += damage

// Give rewards according to damage dealt
new how_many_rewards = floatround(g_DamageDealtToHumans[attacker] / 20, floatround_floor)
if (how_many_rewards > 0)
{
cs_set_user_money(attacker, min(cs_get_user_money(attacker) + (15 * how_many_rewards), CS_MONEY_LIMIT))
g_DamageDealtToHumans[attacker] -= 20 * how_many_rewards
}
}
}
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
// Non-player kill or self kill
if (victim == attacker || !is_user_connected(attacker))
return;

// Block CS money message before the kill
g_MsgMoneyBlockStatus = get_msg_block(g_MsgMoney)
set_msg_block(g_MsgMoney, BLOCK_SET)

// Save attacker's money before the kill
g_MoneyBeforeKill[attacker] = cs_get_user_money(attacker)
}

// Ham Player Killed Post Forward
public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
// Non-player kill or self kill
if (victim == attacker || !is_user_connected(attacker))
return;

// Restore CS money message block status
set_msg_block(g_MsgMoney, g_MsgMoneyBlockStatus)

// Ignore money rewards for Nemesis?
if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(attacker))
{
cs_set_user_money(attacker, g_MoneyBeforeKill[attacker])
return;
}

// Ignore money rewards for Assassin?
if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(attacker))
{
cs_set_user_money(attacker, g_MoneyBeforeKill[attacker])
return;
}

// Ignore money rewards for Survivor?
if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(attacker))
{
cs_set_user_money(attacker, g_MoneyBeforeKill[attacker])
return;
}

// Ignore money rewards for Sniper?
if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(attacker))
{
cs_set_user_money(attacker, g_MoneyBeforeKill[attacker])
return;
}

// Reward money to attacker for the kill
if (zp_core_is_zombie(victim))
cs_set_user_money(attacker, min(g_MoneyBeforeKill[attacker] + 400, CS_MONEY_LIMIT))
else
cs_set_user_money(attacker, min(g_MoneyBeforeKill[attacker] + 300, CS_MONEY_LIMIT))
}

public event_round_start()
{
// Don't reward money after game restart event
if (g_GameRestarting)
{
g_GameRestarting = false
return;
}

// Save player's money at round start, plus our custom money rewards
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_connected(id) || g_MoneyRewarded[id] == NO_DATA)
continue;

g_MoneyAtRoundStart[id] = min(cs_get_user_money(id) + g_MoneyRewarded[id], CS_MONEY_LIMIT)
g_MoneyRewarded[id] = NO_DATA
}
}

public zp_fw_gamemodes_end()
{
// Determine round winner and money rewards
if (!zp_core_get_zombie_count())
{
// Human team wins
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_connected(id))
continue;

if (zp_core_is_zombie(id))
g_MoneyRewarded[id] = 300
else
g_MoneyRewarded[id] = 1000
}
}
else if (!zp_core_get_human_count())
{
// Zombie team wins
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_connected(id))
continue;

if (zp_core_is_zombie(id))
g_MoneyRewarded[id] = 1000
else
g_MoneyRewarded[id] = 300
}
}
else
{
// No one wins
new id
for (id = 1; id <= g_MaxPlayers; id++)
{
if (!is_user_connected(id))
continue;

g_MoneyRewarded[id] = 300
}
}
}

public message_money(msg_id, msg_dest, msg_entity)
{
if (!is_user_connected(msg_entity))
return;

// If arg 2 = 0, this is CS giving round win money or start money
if (get_msg_arg_int(2) == 0 && g_MoneyAtRoundStart[msg_entity] != NO_DATA)
{
fm_cs_set_user_money(msg_entity, g_MoneyAtRoundStart[msg_entity])
set_msg_arg_int(1, get_msg_argtype(1), g_MoneyAtRoundStart[msg_entity])
g_MoneyAtRoundStart[msg_entity] = NO_DATA
}
}

public event_game_restart()
{
g_GameRestarting = true
}

public client_disconnect(id)
{
// Clear saved money after disconnecting
g_MoneyAtRoundStart[id] = NO_DATA
g_MoneyRewarded[id] = NO_DATA

// Clear damage after disconnecting
g_DamageDealtToZombies[id] = 0.0
g_DamageDealtToHumans[id] = 0.0
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
// Prevent server crash if entity's private data not initalized
if (pev_valid(id) != PDATA_SAFE)
return;

set_pdata_int(id, OFFSET_CSMONEY, value)
}
