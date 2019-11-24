#include <amxmodx>
#include <fakemeta>
#include <zp50_gamemodes>

#define TASK_COUNT 52522
new g_time, g_countdown, g_hud
public plugin_init() 
{
register_event("30", "event_intermission", "a")	
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
register_event("TextMsg", "event_game_restart", "a", "2=#Game_will_restart_in")
g_hud = CreateHudSyncObj(1)
}
public event_round_start(id)
{			
remove_task(id+TASK_COUNT)	
set_task(5.0, "zombie_countdown", id+TASK_COUNT)
g_time = 10
g_countdown = 9	
}

public zombie_countdown(id)
{    		
id -= TASK_COUNT
new const speak[10][] = 
{ 
"ZPlague/count/1.wav", 
"ZPlague/count/2.wav", 
"ZPlague/count/3.wav", 
"ZPlague/count/4.wav", 
"ZPlague/count/5.wav", 
"ZPlague/count/6.wav", 
"ZPlague/count/7.wav", 
"ZPlague/count/8.wav", 
"ZPlague/count/9.wav", 
"ZPlague/count/10.wav" 
}
PlaySound(id, speak[g_countdown])
g_countdown--
if(g_time > 6)
{
set_hudmessage(0, 200, 0, -1.0, 0.125, 0, 0.0, 1.0)
ShowSyncHudMsg(id, g_hud, "Infection after: %i Second(s)", g_time)
}
if(g_time <= 6)
{
set_hudmessage(200, 150, 0, -1.0, 0.125, 0, 0.0, 1.0)
ShowSyncHudMsg(id, g_hud, "Infection after: %i Second(s)", g_time)
}
if(g_time < 4)
{
set_hudmessage(200, 0, 0, -1.0, 0.125, 0, 0.0, 1.0)
ShowSyncHudMsg(id, g_hud, "Infection after: %i Second(s)", g_time)
}
--g_time;

if(g_time >= 1)
{
set_task(1.0, "zombie_countdown", id+TASK_COUNT)
}
}  
public zp_fw_gamemodes_start(id)remove_task(TASK_COUNT)	
public event_game_restart(id)remove_task(id+TASK_COUNT)
public event_intermission(id)remove_task(id+TASK_COUNT)
stock PlaySound(id, const sound[])
{
client_cmd(id, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
