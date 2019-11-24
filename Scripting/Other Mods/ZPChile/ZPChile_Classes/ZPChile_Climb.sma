#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <zp50_core>
#include <zp50_class_zombie>

#define STR_T 33
#define fm_get_user_button(%1) pev(%1, pev_button)	
#define fm_get_entity_flags(%1) pev(%1, pev_flags)
new const Pain[][] = {"ZPChile/Zombie/pain1.wav","ZPChile/Zombie/pain2.wav","ZPChile/Zombie/pain3.wav"}
new const Death[][] = {"ZPChile/Zombie/death01.wav","ZPChile/Zombie/death02.wav"}
new g_ZombieClassID, bool:g_WallClimb[33], Float:g_wallorigin[32][3]
new const zombieclass1_name[] = "HeadCrab Zombie"
new const zombieclass1_info[] = "(Climb Skill)"
new const zombieclass1_models[][] = { "ZPC_Climb" }
new const zombieclass1_clawmodels[][] = {"models/ZPChile/Claws/v_knife_climb.mdl"}
const zombieclass1_health = 1000
const Float:zombieclass1_speed = 1.2
const Float:zombieclass1_gravity = 0.7
public plugin_init() 
{
register_forward(FM_EmitSound, "fw_EmitSound")	
register_forward(FM_Touch, "fwd_touch")
register_forward(FM_PlayerPreThink, "fwd_playerprethink")
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
g_WallClimb[id] = true	
}
public zp_fw_core_cure(id, attacker)g_WallClimb[id] = false	
public fwd_touch(id, world)
{
if(!is_user_alive(id) || !g_WallClimb[id] || !pev_valid(id))
return FMRES_IGNORED

new player = STR_T
if (!player)
return FMRES_IGNORED

new classname[STR_T]
pev(world, pev_classname, classname, (STR_T))

if(equal(classname, "worldspawn") || equal(classname, "func_wall") || equal(classname, "func_breakable"))
pev(id, pev_origin, g_wallorigin[id])

return FMRES_IGNORED
}

public wallclimb(id, button)
{
if(zp_class_assassin_get(id) && zp_class_nemesis_get(id))
return FMRES_IGNORED
	
static Float:origin[3]
pev(id, pev_origin, origin)

if(get_distance_f(origin, g_wallorigin[id]) > 25.0)
return FMRES_IGNORED  // if not near wall

if(fm_get_entity_flags(id) & FL_ONGROUND)
return FMRES_IGNORED

if(button & IN_FORWARD)
{
static Float:velocity[3]
velocity_by_aim(id, 120, velocity)
fm_set_user_velocity(id, velocity)
}
else if(button & IN_BACK)
{
static Float:velocity[3]
velocity_by_aim(id, -120, velocity)
fm_set_user_velocity(id, velocity)
}
return FMRES_IGNORED
}	

public fwd_playerprethink(id) 
{
if(zp_class_assassin_get(id) && zp_class_nemesis_get(id))
return FMRES_IGNORED
	
if(!g_WallClimb[id] || !zp_core_is_zombie(id)) 
return FMRES_IGNORED

new button = fm_get_user_button(id)

if((button & IN_USE) && zp_class_zombie_get_current(id) == g_ZombieClassID) //Use button = climb
wallclimb(id, button)
else if((button & IN_JUMP) && button & IN_DUCK && zp_class_zombie_get_current(id) == g_ZombieClassID) //Jump + Duck = climb
wallclimb(id, button)

return FMRES_IGNORED
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
stock fm_set_user_velocity(entity, const Float:vector[3]) {
set_pev(entity, pev_velocity, vector);

return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
