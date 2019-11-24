#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zombie_scenario>

#define TASK_HUD 556122
new g_had_emergency1[33], g_had_emergency2[33]  
public plugin_init()
{
RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn", 1);	
}	
public client_putinserver(id)
{
g_had_emergency1[id] = true
g_had_emergency2[id] = true
}
public fw_PlayerSpawn(id)
{
if(!is_user_alive(id))
return
set_task(0.1,"HUD",id, _, _,"b")
}
public HUD(id)
{
if(is_user_alive(id))
{		
static Text[128]	
if(g_had_emergency1[id] && !g_had_emergency2[id])
{
formatex(Text, sizeof(Text), "30%% Health UP - [5] ^n[1 times]")	
}
else if(g_had_emergency2[id] && !g_had_emergency1[id])
{
formatex(Text, sizeof(Text), "^n^n^n100%% Health UP - [6] ^n[3 times]")	
}
else if(g_had_emergency2[id] && g_had_emergency1[id])
{
formatex(Text, sizeof(Text), "30%% Health UP - [5] ^n[1 times]^n^n^n100%% Health UP - [6] ^n[3 times]")	
}
set_hudmessage(50, 150, 0, 0.01, 0.18, 0, 1.0, 1.0)
show_hudmessage(0, Text, id)
}
else
{
return
}
}
