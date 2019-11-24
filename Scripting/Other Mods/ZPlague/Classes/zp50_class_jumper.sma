#include <amxmodx>
#include <engine>
#include <zp50_class_zombie>

// Classic Zombie Attributes
new const zombieclass1_name[] = "Jumper Zombie"
new const zombieclass1_info[] = "2 Jumps"
new const zombieclass1_models[][] = { "ZP_Speeder" }
new const zombieclass1_clawmodels[][] = { "models/ZPlague/Claws/v_knife_speeder.mdl"}
const zombieclass1_health = 2800
const Float:zombieclass1_speed = 1.1
const Float:zombieclass1_gravity = 0.8

new g_ZombieClassID
new jumpnum[33], bool:dojump[33], g_jumps, chache_g_jumps
public plugin_init()
{
g_jumps = register_cvar("zp_vip_jumps", "1")
chache_g_jumps = get_pcvar_num(g_jumps)
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
public client_PreThink(id)
{
if(!is_user_alive(id))
return PLUGIN_CONTINUE
if(zp_class_carlito_get(id) || zp_class_survivor_get(id) || zp_class_sniper_get(id))
return PLUGIN_CONTINUE	
if(zp_class_nemesis_get(id) || zp_class_clown_get(id) || zp_class_assassin_get(id))
return PLUGIN_CONTINUE		
if(!g_jumps || zp_class_zombie_get_current(id) != g_ZombieClassID) 
return PLUGIN_CONTINUE

static nbut, obut, fflags
nbut= get_user_button(id)
obut = get_user_oldbutton(id)
fflags = get_entity_flags(id)

if((nbut & IN_JUMP) && !(fflags & FL_ONGROUND) && !(obut & IN_JUMP))
{
if(jumpnum[id] < chache_g_jumps && zp_core_is_zombie(id))
{
dojump[id] = true
jumpnum[id]++
return PLUGIN_CONTINUE
}
}
if((nbut & IN_JUMP) && (fflags & FL_ONGROUND))
{
jumpnum[id] = 0
return PLUGIN_CONTINUE
}

return PLUGIN_CONTINUE
}
public client_PostThink(id)
{
if(!is_user_alive(id))
return PLUGIN_CONTINUE
if(zp_class_carlito_get(id) || zp_class_survivor_get(id) || zp_class_sniper_get(id))
return PLUGIN_CONTINUE	
if(zp_class_nemesis_get(id) || zp_class_clown_get(id) || zp_class_assassin_get(id))
return PLUGIN_CONTINUE	
if(!get_pcvar_num(g_jumps) || zp_class_zombie_get_current(id) != g_ZombieClassID) 
return PLUGIN_CONTINUE

if(dojump[id] == true)
{
static Float:velocity[3]	
entity_get_vector(id,EV_VEC_velocity,velocity)
velocity[2] = random_float(265.0,285.0)
entity_set_vector(id,EV_VEC_velocity,velocity)
dojump[id] = false
return PLUGIN_CONTINUE
}
return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
