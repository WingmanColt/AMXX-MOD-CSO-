#include <amxmodx>
#include <zp50_core>
#include <zp50_gamemodes>

new g_AntidotesTaken, g_GameModeInfectionID, g_GameModeMultiID
public plugin_init()
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
}
public plugin_cfg()
{
g_GameModeInfectionID = zp_gamemodes_get_id("Infection Mode")
g_GameModeMultiID = zp_gamemodes_get_id("Multiple Infection Mode")
}
public plugin_natives()
{
register_native("give_item_antidote", "Get_Antidote", 1)
}
public Get_Antidote(id)
{
new current_mode = zp_gamemodes_get_current()
if (current_mode != g_GameModeInfectionID && current_mode != g_GameModeMultiID)
return;

if (!zp_core_is_zombie(id))
return;

if (zp_core_get_zombie_count() == 1)
return;

if (g_AntidotesTaken >= 1)
return;

new money = zp_ammopacks_get(id) 		
if (money >= 15)
{		
zp_ammopacks_set(id, money - 15)		
zp_core_cure(id, id)
g_AntidotesTaken++
}else{
client_print(id, print_chat, "[ZP] Not enough AmmoPacks!")
}
}
public event_round_start()g_AntidotesTaken = 0
