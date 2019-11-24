#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <zp50_core>
#include <zp50_class_zombie>


new const Pain[][] = {"ZPChile/Zombie/pain1.wav","ZPChile/Zombie/pain2.wav","ZPChile/Zombie/pain3.wav"}
new const Death[][] = {"ZPChile/Zombie/death01.wav","ZPChile/Zombie/death02.wav"}
new g_ZombieClassID, bool:longJump[33], Float:g_lastleaptime[33]
new const zombieclass1_name[] = "Hunter Zombie"
new const zombieclass1_info[] = "(LongJump)"
new const zombieclass1_models[][] = { "ZPC_Hunter" }
new const zombieclass1_clawmodels[][] = {"models/ZPChile/Claws/v_knife_hunter.mdl"}
const zombieclass1_health = 4000
const Float:zombieclass1_speed = 1.0
const Float:zombieclass1_gravity = 0.8


public plugin_init() 
{
register_forward(FM_PlayerPreThink, "fw_PlayerPreThink") 
register_forward(FM_EmitSound, "fw_EmitSound")	
}
public plugin_precache()
{
new index
g_ZombieClassID = zp_class_zombie_register(zombieclass1_name, zombieclass1_info, zombieclass1_health, zombieclass1_speed, zombieclass1_gravity)
for (index = 0; index < sizeof zombieclass1_models; index++)
zp_class_zombie_register_model(g_ZombieClassID, zombieclass1_models[index])
for (index = 0; index < sizeof zombieclass1_clawmodels; index++)
zp_class_zombie_register_claw(g_ZombieClassID, zombieclass1_clawmodels[index])
}
public zp_fw_core_infect_post(id)
{
if(zp_class_assassin_get(id) || zp_class_nemesis_get(id))
return		
if (zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID)	
longJump[id] = true	
}
public zp_fw_core_cure(id)
{
longJump[id] = false		
}
public fw_PlayerPreThink(id)
{
if (!is_user_alive(id) && !is_user_connected(id))
return; 	
if(zp_class_nemesis_get(id) && zp_class_assassin_get(id))
return;	
if (!zp_core_is_zombie(id) && zp_class_zombie_get_current(id) != g_ZombieClassID)
return; 

if (allowed_hunterjump(id))
{
static Float:velocity[3];
velocity_by_aim(id, 500, velocity);
velocity[2] = 400.0;
set_pev(id, pev_velocity, velocity);
emit_sound(id, CHAN_VOICE, "ZPChile/Hunter/Jump01.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
g_lastleaptime[id] = get_gametime()
}	
}

allowed_hunterjump(id)
{    
static buttons
buttons = pev(id, pev_button)
if (!(buttons & IN_JUMP) || !(buttons & IN_DUCK))
return false
if (!longJump[id])
return false;
if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 70)
return false
if (get_gametime() - g_lastleaptime[id] < 10.0)
return false

return true;
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if (!is_user_connected(id)) 
return FMRES_IGNORED; 
if(zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID && !zp_class_nemesis_get(id) && !zp_class_assassin_get(id))
{
if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, Pain[random_num(0, sizeof Pain - 1)] , volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, Death[random_num(0, sizeof Death - 1)] , volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
}
return FMRES_IGNORED 
} 
stock fm_get_speed(entity)
{
static Float:velocity[3];
pev(entity, pev_velocity, velocity);

return floatround(vector_length(velocity));
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
