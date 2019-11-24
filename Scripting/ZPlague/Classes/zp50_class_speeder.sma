#include <amxmodx>
#include <zp50_class_zombie>

// Classic Zombie Attributes
new const zombieclass1_name[] = "Speeder Zombie"
new const zombieclass1_info[] = "Faster"
new const zombieclass1_models[][] = { "ZP_Jumper" }
new const zombieclass1_clawmodels[][] = { "models/ZPlague/Claws/v_knife_speeder.mdl"}
const zombieclass1_health = 2800
const Float:zombieclass1_speed = 1.350
const Float:zombieclass1_gravity = 0.8

new g_ZombieClassID

public plugin_precache()
{
new index
g_ZombieClassID = zp_class_zombie_register(zombieclass1_name, zombieclass1_info, zombieclass1_health, zombieclass1_speed, zombieclass1_gravity)
for (index = 0; index < sizeof zombieclass1_models; index++)
zp_class_zombie_register_model(g_ZombieClassID, zombieclass1_models[index])
for (index = 0; index < sizeof zombieclass1_clawmodels; index++)
zp_class_zombie_register_claw(g_ZombieClassID, zombieclass1_clawmodels[index])
}
