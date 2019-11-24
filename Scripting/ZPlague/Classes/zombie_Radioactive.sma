#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <zp50_class_zombie>
#include <zp50_grenade_frost>

#define VIP ADMIN_RESERVATION

new g_ZombieClassID, g_msgDeathMsg, g_msgScreenFade
new const zombieclass1_name[] = "RadioActive Zombie"
new const zombieclass1_info[] = "Killer \r[VIP Skill]"
new const zombieclass1_models[][] = { "ZP_Swarm" }
new const zombieclass1_clawmodels[][] = { "models/ZPlague/Claws/v_knife_swarm.mdl"}
const zombieclass1_health = 3000
const Float:zombieclass1_speed = 1.2
const Float:zombieclass1_gravity = 0.8

public plugin_init()
{
register_forward(FM_Touch, "fwd_touch")
g_msgDeathMsg = get_user_msgid("DeathMsg")
g_msgScreenFade = get_user_msgid("ScreenFade")
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

public zp_fw_core_infect_post(id, infector)
{
if(get_user_flags(id) & VIP)
{		
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return

if (zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID)
{	
radius_damage(id)
aura(id)
}
}
}

public aura(attacker)
{
if(!is_user_alive(attacker))
return	
if(zp_class_nemesis_get(attacker) || zp_class_assassin_get(attacker))
return;	
if (!zp_core_is_zombie(attacker) && zp_class_zombie_get_current(attacker) != g_ZombieClassID)
return;	

// Retrieve player origin
static iOrigin[3]            
get_user_origin(attacker, iOrigin)

// Colored Aura
message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
write_byte(TE_DLIGHT) // TE id
write_coord(iOrigin[0]) // x
write_coord(iOrigin[1]) // y
write_coord(iOrigin[2]) // z
write_byte(10) // radius
write_byte(100) // r
write_byte(255) // g
write_byte(0)  // b 
write_byte(2) // life
write_byte(0) // decay rate
message_end()

set_task(0.1, "aura", attacker)
}

public fwd_touch(victim, attacker)
{
if(!is_user_alive(attacker))
return	
if(zp_class_nemesis_get(attacker) || zp_class_assassin_get(attacker))
return;	
if (!zp_core_is_zombie(attacker) && zp_class_zombie_get_current(attacker) != g_ZombieClassID)
return;	

set_msg_block(g_msgDeathMsg, BLOCK_SET)
ExecuteHamB(Ham_Killed, victim, attacker, 0); // set last param to 2 if you want victim to gib
set_msg_block(g_msgDeathMsg, BLOCK_NOT)
make_deathmsg(attacker, victim, 1, "none");
zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + 2)
}

public radius_damage(id)
{
if(!is_user_alive(id))
return	
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return;	
if (!zp_core_is_zombie(id) && zp_class_zombie_get_current(id) != g_ZombieClassID)
return;	

static Float:iOrigin[3], player
pev(id, pev_origin, iOrigin)

player = -1
while((player = engfunc(EngFunc_FindEntityInSphere, player, iOrigin, 250.0)) != 0)
{
if(player != id && is_user_alive(player) && !zp_core_is_zombie(player)) 
{
set_hudmessage(0, 200, 0, -1.00, 0.30, 1, 0.0, 2.0)
show_hudmessage(player, "!!!! WARNING !!!!^nRadiation Detected^n!!!! WARNING !!!!")

message_begin (MSG_ONE_UNRELIABLE, g_msgScreenFade, {0,0,0}, player)
write_short(1 * 2024)
write_short(1 * 1524)
write_short(0x0001)
write_byte(0)
write_byte(200)
write_byte(0)
write_byte(150)
message_end()

if(get_user_health(player) > 5) fm_set_user_health(player, get_user_health(player) - 5)
if(get_user_health(id) < zombieclass1_health * 2) fm_set_user_health(id, get_user_health(id) + 25)
}
}

set_task(2.0, "radius_damage", id)
}