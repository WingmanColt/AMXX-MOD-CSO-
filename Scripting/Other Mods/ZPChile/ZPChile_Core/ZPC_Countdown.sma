#include <amxmodx>
#include <fakemeta>
#include <zp50_gamemodes>

#define ID_START (taskid - TASK_START)
enum (+= 100)
{
TASK_START = 2000
}
new g_time, g_countdown, g_hud
public plugin_init() 
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
register_event("TextMsg", "event_game_restart", "a", "2=#Game_will_restart_in")
g_hud = CreateHudSyncObj(1)
}
public event_round_start(id)
{		
remove_task(id+TASK_START)
set_task(5.0, "warning", id)
set_task(10.0, "start", id+TASK_START)
g_time = 10
g_countdown = 9
}
public warning(id)
{
remove_task(id)	
PlaySound(id, "sound/ZPChile/warning.wav")
set_task(1.0, "evacuate", id)	
}
public evacuate(id) 
{
remove_task(id)	
PlaySound(id, "ZPChile/evacuate_area.wav")
}
public start(id)
{    		
id -= TASK_START
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
ShowSyncHudMsg(id, g_hud, "Infection transformado: %i Second(s)", g_time)
}
if(g_time <= 6)
{
set_hudmessage(200, 150, 0, -1.0, 0.125, 0, 0.0, 1.0)
ShowSyncHudMsg(id, g_hud, "Infection transformado: %i Second(s)", g_time)
}
if(g_time < 4)
{
set_hudmessage(200, 0, 0, -1.0, 0.125, 0, 0.0, 1.0)
ShowSyncHudMsg(id, g_hud, "Infection transformado: %i Second(s)", g_time)
}
--g_time;

if(g_time >= 1)
{
set_task(1.0, "start", id+TASK_START)
}
}  
public zp_fw_gamemodes_start(id)remove_task(id+TASK_START)
public zp_fw_gamemodes_end(id) remove_task(id+TASK_START)
public event_game_restart(id) remove_task(id+TASK_START)
stock PlaySound(id, const sound[])
{
client_cmd(id, "spk ^"%s^"", sound)
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
