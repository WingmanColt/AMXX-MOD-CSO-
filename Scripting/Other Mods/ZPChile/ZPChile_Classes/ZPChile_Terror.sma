#include <amxmodx>
#include <fakemeta>
#include <zp50_class_zombie>

new const Pain[][] = {"ZPChile/Zombie/pain1.wav","ZPChile/Zombie/pain2.wav","ZPChile/Zombie/pain3.wav"}
new const Death[][] = {"ZPChile/Zombie/death01.wav","ZPChile/Zombie/death02.wav"}
new g_ZombieClassID
new const zombieclass1_name[] = "Terror Zombie"
new const zombieclass1_info[] = "Normal"
new const zombieclass1_models[][] = { "ZPC_ZTerror" }
new const zombieclass_clawmodels[][] = { "models/ZPChile/Claws/v_knife_terror.mdl" }
const zombieclass1_health = 4500
const Float:zombieclass1_speed = 1.2
const Float:zombieclass1_gravity = 0.9

public plugin_init() 
{
register_forward(FM_EmitSound, "fw_EmitSound")	
}
public plugin_precache()
{
new index
g_ZombieClassID = zp_class_zombie_register(zombieclass1_name, zombieclass1_info, zombieclass1_health, zombieclass1_speed, zombieclass1_gravity)
for (index = 0; index < sizeof zombieclass1_models; index++)
zp_class_zombie_register_model(g_ZombieClassID, zombieclass1_models[index])
for (index = 0; index < sizeof zombieclass_clawmodels; index++)
zp_class_zombie_register_claw(g_ZombieClassID, zombieclass_clawmodels[index])
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
