#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_class_zombie>

#define TASK_AURA 747454
#define ID_AURA (taskid - TASK_AURA)
new const zombieclass1_name[] = "Swarm Zombie"
new const zombieclass1_info[] = "Killer"
new const zombieclass1_models[][] = { "ZP_Swarm" }
new const zombieclass1_clawmodels[][] = { "models/ZPlague/Claws/v_knife_swarm.mdl"}
const zombieclass1_health = 3000
const Float:zombieclass1_speed = 1.2
const Float:zombieclass1_gravity = 0.8

new g_ZombieClassID
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1)
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
public client_disconnect(id)remove_task(id+TASK_AURA)
public zp_fw_core_infect_post(id, attacker)
{		
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return;		
if (zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID)
{			
set_task(1.5, "aura", id+TASK_AURA, _, _, "b")	
}	
}
public zp_fw_core_infect(id, attacker)
{
if (zp_class_zombie_get_current(id) == g_ZombieClassID)
remove_task(id+TASK_AURA)
}
public zp_fw_core_cure(id, attacker)
{
if (zp_class_zombie_get_current(id) == g_ZombieClassID)
remove_task(id+TASK_AURA)
}
public fw_Killed_Post(id)
{
if(!is_user_alive(id))
return;
if (zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID)
{	
remove_task(id+TASK_AURA)
}
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (zp_class_zombie_get_current(attacker) == g_ZombieClassID && !zp_core_is_zombie(victim))
{
if(!zp_class_sniper_get(victim) && !zp_class_survivor_get(victim))
{	
if (inflictor == attacker)
{
ExecuteHamB(Ham_Killed, victim, attacker, 0)
return HAM_HANDLED;
}
}
}

return HAM_IGNORED;
}
public aura(taskid)
{	
if(!is_user_alive(ID_AURA))
return;		
static origin[3]
get_user_origin(ID_AURA, origin)
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(15) // radius
write_byte(0) // r
write_byte(0) // g
write_byte(random_num(100,250)) // b
write_byte(3) // life
write_byte(5) // decay rate
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
