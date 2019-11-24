#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <zp50_class_zombie>

#define TASK_SKILL4_TIME_REMOVE 8345843
#define TASK_SKILL4_TIME_WAIT 53495734

new g_can_skill4[33], g_skill4[33], idclass, 
g_hud_skill4, g_current_time4[33], g_mx

new const zombieclass_name[] = "Venom Zombie"
new const zombieclass_info[] = "(\r-G- -> \yHarden Guard)"
new const zombieclass_models[][] = { "ZB5_Boomer" }
new const zombieclass_clawmodels[][] = { "models/ZB5/Claws/v_ZB5_Boomer.mdl" }
const zombieclass_health = 6300
const Float:zombieclass_speed = 1.10
const Float:zombieclass_gravity = 0.8
const Float:zombieclass_knockback = 0.8


public plugin_init()
{
register_forward(FM_EmitSound, "fw_EmitSound")
register_clcmd("drop", "cmd_drop")	
g_hud_skill4 = CreateHudSyncObj(5)
g_mx = get_maxplayers()
set_task(1.0, "change_time5", _, _, _, "b")
}

public plugin_precache()
{
new index
idclass = zp_class_zombie_register(zombieclass_name, zombieclass_info, zombieclass_health, zombieclass_speed, zombieclass_gravity)
zp_class_zombie_register_kb(idclass, zombieclass_knockback)
for (index = 0; index < sizeof zombieclass_models; index++)
zp_class_zombie_register_model(idclass, zombieclass_models[index])
for (index = 0; index < sizeof zombieclass_clawmodels; index++)
zp_class_zombie_register_claw(idclass, zombieclass_clawmodels[index])	
}

public client_putinserver(id)
{
if(!is_user_bot(id))
set_task(1.0, "show_skill4", id, _, _, "b")
}

public show_skill4(id)
{
if(is_user_alive(id) && zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == idclass)
{
show_hud4(id)
}
}

public show_hud4(id)
{
static Float:percent, percent2

percent = (float(g_current_time4[id]) / (5.0 + 20.0)) * 100.0
percent2 = clamp(floatround(percent), 1, 100)

if(percent2 > 0 && percent2 < 50)
{
set_hudmessage(200, 0, 0, -1.0, 0.125, 0, 1.5, 1.5)
ShowSyncHudMsg(id, g_hud_skill4, "[G] - Hard Defense (%i%%)", percent2)
} else if(percent2 >= 50 && percent < 100) {
set_hudmessage(200, 200, 0, -1.0, 0.125, 0, 1.5, 1.5)
ShowSyncHudMsg(id, g_hud_skill4, "[G] - Hard Defense (%i%%)", percent2)
} else if(percent2 >= 100) {
set_hudmessage(200, 200, 200, -1.0, 0.125, 0, 1.5, 1.5)
ShowSyncHudMsg(id, g_hud_skill4, "[G] - Hard Defense (Ready)")
}	
}

public change_time()
{
for(new i = 0; i < g_mx; i++)
{
g_current_time4[i]++
}
}

public zp_fw_core_infect_post(id)
{
if(zp_class_zombie_get_current(id) == idclass)
{
g_can_skill4[id] = 1
g_skill4[id] = 0
g_current_time4[id] = 100
}
}

// ================================== Skill: Harden ================================
public cmd_drop(id)
{
if(is_user_alive(id) && zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == idclass)
skill4(id)
}

public skill4(id)
{
if(g_can_skill4[id] && !g_skill4[id])
{
g_can_skill4[id] = 0
g_skill4[id] = 1
g_current_time4[id] = 0

set_task(5.0, "stop_skill4", id+TASK_SKILL4_TIME_REMOVE)
}
}

public stop_skill4(id)
{
id -= TASK_SKILL4_TIME_REMOVE

if(is_user_alive(id) && zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == idclass)
{
g_can_skill4[id] = 0
g_skill4[id] = 0
set_task(20.0, "reset_skill4", id+TASK_SKILL4_TIME_WAIT)
}
}

public reset_skill4(id)
{
id -= TASK_SKILL4_TIME_WAIT

if(is_user_alive(id) && zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == idclass)
{

g_can_skill4[id] = 1
g_skill4[id] = 0

g_current_time4[id] = 100
}	
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if (!is_user_connected(id)) 
return FMRES_IGNORED; 
if (idclass == zp_class_zombie_get_current(id) && zp_core_is_zombie(id))
{
if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, Venom_Pain[random_num(0, sizeof Venom_Pain - 1)] , volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, "ZB5/Z-Virus/boomer_death.wav", volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
}
return FMRES_IGNORED 
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
