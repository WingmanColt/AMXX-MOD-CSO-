#include <amxmodx>
#include <fakemeta>
#include <zp50_core>
#include <zp50_gamemodes>
#include <zp50_core_const>

#define LIGHTS_MAX_LENGTH 32
#define TASK_THUNDER 100
#define TASK_THUNDER_LIGHTS 200
#define ID_COUNTDOWN (taskid - TASK_COUNTDOWN)
#define ID_DARKNESS (taskid - TASK_DARKNESS)
enum (+= 100)
{
TASK_COUNTDOWN = 2000,
TASK_DARKNESS
}

new Array:g_thunder_lights, g_GameModeBiohazardID
new cvar_lighting, cvar_lighting2, cvar_lighting3
new g_ThunderLightIndex, g_ThunderLightMaxLen, g_hud
new g_ThunderLight[LIGHTS_MAX_LENGTH], g_GameModeAssassinID
new g_darkness, g_can_darkness

new const thunder_lights[][] = { "zazccb", "iaiaiabc", "ijklmnonmlkjihgfedcb" , "klmlkjihgfedcbaabcdedcb" , "bcdefedcijklmlkjihgfedcb" }
new const thunder_sounds[][] = { "ZPlague/Thunder/thunder41.wav", "ZPlague/Thunder/thunder51.wav", "ZPlague/Thunder/thunder61.wav","ZPlague/Thunder/thunder71.wav","ZPlague/Thunder/thunder81.wav"}
public plugin_init()
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")	
cvar_lighting = register_cvar("zp_lighting", "b")
cvar_lighting2 = register_cvar("zp_lighting2", "c")
cvar_lighting3 = register_cvar("zp_lighting3", "a")	
g_hud = CreateHudSyncObj()
}
public plugin_precache()
{
g_thunder_lights = ArrayCreate(LIGHTS_MAX_LENGTH, 1)
if (ArraySize(g_thunder_lights) == 0)
{
for (new index = 0; index < sizeof thunder_lights; index++)
ArrayPushString(g_thunder_lights, thunder_lights[index])
}
	
for(new i = 0; i < sizeof(thunder_sounds); i++)
precache_sound(thunder_sounds[i])	
}
public plugin_natives()
{	
register_native("zp_darkness", "native_dark", 1)
}
public plugin_cfg()
{
g_GameModeAssassinID = zp_gamemodes_get_id("Assassin Mode")
g_GameModeBiohazardID = zp_gamemodes_get_id("Biohazard Mode")	
set_task(1.0, "lighting_task", _, _, _, "b")
set_task(400.0, "before_darkness", _, _, TASK_DARKNESS, "b")
}
public event_round_start(id)
{		
if(task_exists(id+TASK_DARKNESS))	
remove_task(id+TASK_DARKNESS)
if(task_exists(id+TASK_COUNTDOWN))	
remove_task(id+TASK_COUNTDOWN)
g_darkness = false
g_can_darkness = false
}
public zp_fw_gamemodes_start()g_can_darkness = true
public zp_fw_gamemodes_end()g_can_darkness = false
public lighting_task()
{
new lighting[2], map[33]
get_mapname(map, 31)	
if((zp_gamemodes_get_current() == g_GameModeAssassinID)||(zp_gamemodes_get_current() == g_GameModeBiohazardID))
{
get_pcvar_string(cvar_lighting3, lighting, charsmax(lighting))	
}else{
if(!g_darkness)
{	
get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))	
if(equal(map, "zm_AandD_extended") || equal(map, "zm_army_tn_beta3") || equal(map, "zm_brambor") || equal(map, "zp_winter_town") || equal(map, "zm_toxic_house2")
|| equal(map, "zm_forested") || equal(map, "zm_firezone") || equal(map, "zm_cbble_kamp") || equal(map, "zm_decline2k"))get_pcvar_string(cvar_lighting2, lighting, charsmax(lighting))	
}else{
get_pcvar_string(cvar_lighting3, lighting, charsmax(lighting))	
}
}
if (90.0 > 0.0 && !task_exists(TASK_THUNDER) && !task_exists(TASK_THUNDER_LIGHTS))
{
g_ThunderLightIndex = 0
ArrayGetString(g_thunder_lights, random_num(0, ArraySize(g_thunder_lights) - 1), g_ThunderLight, charsmax(g_ThunderLight))
g_ThunderLightMaxLen = strlen(g_ThunderLight)
PlaySoundToClients(thunder_sounds[random_num(0, sizeof thunder_sounds - 1)])	
set_task(90.0, "thunder_task", TASK_THUNDER)
}
if (!task_exists(TASK_THUNDER_LIGHTS)) engfunc(EngFunc_LightStyle, 0, lighting)
}

// Thunder task
public thunder_task()
{
if (g_ThunderLightIndex == 0)
{	
set_task(0.1, "thunder_task", TASK_THUNDER_LIGHTS, _, _, "b")
}
new lighting[2]
lighting[0] = g_ThunderLight[g_ThunderLightIndex]
engfunc(EngFunc_LightStyle, 0, lighting)
g_ThunderLightIndex++
if (g_ThunderLightIndex >= g_ThunderLightMaxLen)
{
remove_task(TASK_THUNDER_LIGHTS)
lighting_task()
}
}
public before_darkness(taskid)  
{  	
if(!is_user_alive(ID_DARKNESS) && zp_gamemodes_get_current() == g_GameModeAssassinID || zp_gamemodes_get_current() == g_GameModeBiohazardID)
{  
remove_task(taskid);  
return;  
}  
if(g_darkness && !g_can_darkness)
return; 
PlaySoundToClients("ZPlague/wolf.wav")
set_hudmessage(150, 100, 0, -1.0, 0.125, 0, 0.0, 5.0)
ShowSyncHudMsg(0, g_hud, "5 Seconds ramaning for the night fight !")
set_task(5.0, "start", ID_DARKNESS+TASK_COUNTDOWN) 
}  
public start(taskid)
{    	
if(!is_user_alive(ID_COUNTDOWN) && g_darkness && !g_can_darkness && zp_gamemodes_get_current() == g_GameModeAssassinID || zp_gamemodes_get_current() == g_GameModeBiohazardID)
{  
remove_task(ID_COUNTDOWN);  
return;  
}  	

set_hudmessage(random_num(50,200), random_num(50,200), 0, -1.0, 0.125, 0, 0.0, 5.0)
ShowSyncHudMsg(0, g_hud, "|| ................................ ||^n DARKNESS MODE ! ^n|| ................................ ||")
g_darkness = true
g_can_darkness = false
}  
public native_dark() return g_darkness
PlaySoundToClients(const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "mp3 play ^"sound/%s^"", sound)
else
client_cmd(0, "spk ^"%s^"", sound)
}
