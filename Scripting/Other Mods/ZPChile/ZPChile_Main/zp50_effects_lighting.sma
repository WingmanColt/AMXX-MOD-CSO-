#include <amxmodx>
#include <fakemeta>
#include <zp50_gamemodes>
#include <zp50_core_const>

#define TASK_THUNDER 100
#define TASK_THUNDER_LIGHTS 200
#define LIGHTS_MAX_LENGTH 32
new Array:g_thunder_lights, cvar_lighting
new g_ThunderLightIndex, g_ThunderLightMaxLen
new g_ThunderLight[LIGHTS_MAX_LENGTH]
new const thunder_lights[][] = { "ijklmnonmlkjihgfedcb" , "klmlkjihgfedcbaabcdedcb" , "bcdefedcijklmlkjihgfedcb" }
new const thunder_sounds[][] = { "ZPlague/Thunder/thunder1.wav", "ZPlague/Thunder/thunder2.wav", "ZPlague/Thunder/thunder3.wav", "ZPlague/Thunder/thunder4.wav", "ZPlague/Thunder/thunder6.wav" }
public plugin_init()
{
cvar_lighting = register_cvar("zp_lighting3", "a")	
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
public plugin_cfg()
{	
set_task(1.0, "lighting_task", _, _, _, "b")
}
public lighting_task()
{
new lighting[2]
get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))	
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
PlaySoundToClients(const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "mp3 play ^"sound/%s^"", sound)
else
client_cmd(0, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
