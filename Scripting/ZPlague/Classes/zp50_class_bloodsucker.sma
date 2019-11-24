#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_colorchat>
#include <zp50_class_zombie>

#define VIP ADMIN_RESERVATION
new const zombieclass1_name[] = "BloodSucker Zombie"
new const zombieclass1_info[] = "Drag Press E \r[VIP Skill]"
new const zombieclass1_models[][] = { "ZP_Blood" }
new const zombieclass1_clawmodels[][] = { "models/ZPlague/Claws/v_knife_sucker.mdl"}
const zombieclass1_health = 3000
const Float:zombieclass1_speed = 1.10
const Float:zombieclass1_gravity = 0.8

new g_ZombieClassID
new g_hooked[33], g_hooksLeft[33], g_unable2move[33], g_drag_i[33]
new Float:g_lastHook[33], ef_sprite[2], Float:g_fHavedmg[33]

public plugin_init()
{
register_logevent("logevent_round_end", 2, "1=Round_End")	
RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1)
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")	
register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
}
public plugin_precache()
{
new index
g_ZombieClassID = zp_class_zombie_register(zombieclass1_name, zombieclass1_info, zombieclass1_health, zombieclass1_speed, zombieclass1_gravity)
for (index = 0; index < sizeof zombieclass1_models; index++)
zp_class_zombie_register_model(g_ZombieClassID, zombieclass1_models[index])
for (index = 0; index < sizeof zombieclass1_clawmodels; index++)
zp_class_zombie_register_claw(g_ZombieClassID, zombieclass1_clawmodels[index])

ef_sprite[0] = PrecacheModel("sprites/ZPlague/zbeam4.spr")
ef_sprite[1] = PrecacheModel("sprites/ZPlague/inf_smoke_y.spr")
}
public client_disconnect(id)
{
if (g_hooked[id])drag_end(id)
if(g_unable2move[id])g_unable2move[id] = false
}
public logevent_round_end(id)
{
drag_end(id)
g_unable2move[id] = false
}

public zp_fw_core_infect_post(id, attacker)
{
if(get_user_flags(id) & VIP)
{	
if (zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID)
{
g_hooksLeft[id] = 3
g_fHavedmg[id] = 0.0;
}
}
}
public zp_fw_core_cure(id, attacker)
{
if (zp_class_zombie_get_current(id) == g_ZombieClassID)
{
if (g_hooked[id])drag_end(id)
if(g_unable2move[id])g_unable2move[id] = false
}
}
public fw_Killed_Post(id)
{
if(!is_user_alive(id))
return;	
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return;		
if(!zp_core_is_zombie(id))
return;
if (zp_class_zombie_get_current(id) == g_ZombieClassID)
{
drag_end(id)
g_unable2move[id] = false
}
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage) // if take damage drag off
{
if(!is_user_alive(victim) || !is_user_alive(attacker))
return HAM_IGNORED	
if(zp_core_is_zombie(attacker) || !zp_core_is_zombie(victim))
return HAM_IGNORED
if (zp_core_is_zombie(victim) && zp_class_zombie_get_current(victim) == g_ZombieClassID)
{
if(g_hooked[victim])	
{
g_fHavedmg[victim] += damage;

if(g_fHavedmg[victim] >= 400.0)
{
g_fHavedmg[victim] -= 400.0;
drag_end(victim)
toxic_explozion(victim)
}
}
}
return HAM_IGNORED;
}

public drag_start(id) // starts drag, checks if player is Smoker, checks cvars
{		
if(!is_user_alive(id))
return PLUGIN_HANDLED		
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return PLUGIN_HANDLED				
if (zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID)
{
if (!is_user_alive(id)) {
zp_colored_print(id, " ^x03You can't drag if you are dead!")			
return PLUGIN_HANDLED
}
if(get_user_flags(id) & VIP)
{
if (g_hooksLeft[id] <= 0) {
zp_colored_print(id, " ^x03You can't drag anymore!")			
return PLUGIN_HANDLED
}		
}else{
if (g_hooksLeft[id] <= 0) {
zp_colored_print(id, " ^x03Only VIPS allow to drag!")			
return PLUGIN_HANDLED
}
}
if (get_gametime() - g_lastHook[id] < 5) {
zp_colored_print(id, " ^x03Wait %.f0 sec. to drag again!",5 - (get_gametime() - g_lastHook[id]))			
return PLUGIN_HANDLED
}

new hooktarget, body
get_user_aiming(id, hooktarget, body)

if (is_user_alive(hooktarget)) {
if (!zp_core_is_zombie(hooktarget))
{
g_hooked[id] = hooktarget
emit_sound(hooktarget, CHAN_BODY, "ZPlague/Smoker_drag.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
}
else
{
if (0.0 == 1.0)
{
g_hooked[id] = hooktarget
emit_sound(hooktarget, CHAN_BODY, "ZPlague/Smoker_drag.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
}
else
{
zp_colored_print(id, " ^x03You can't drag teammates!")			
return PLUGIN_HANDLED
}
}

new parm[2]
parm[0] = id
parm[1] = hooktarget

set_task(0.1, "smoker_reelin", id, parm, 2, "b")
harpoon_target(parm)

g_hooksLeft[id]--
zp_colored_print(id, " ^x03You can drag player to youself %d time%s", g_hooksLeft[id], (g_hooksLeft[id] < 2) ? "" : "s")
g_drag_i[id] = true

if(1.0 == 1.0)
g_unable2move[hooktarget] = true

if(1.0 == 2.0)
g_unable2move[id] = true

if(1.0 == 3.0)
{
g_unable2move[hooktarget] = true
g_unable2move[id] = true
}
} else {
g_hooked[id] = 33
noTarget(id)
g_drag_i[id] = true
g_hooksLeft[id]--
zp_colored_print(id, " ^x03You can drag player to youself %d time%s", g_hooksLeft[id], (g_hooksLeft[id] < 2) ? "" : "s")
}
}
else
return PLUGIN_HANDLED
return PLUGIN_CONTINUE
}

public smoker_reelin(parm[]) // dragging player to smoker
{
new id = parm[0]
new victim = parm[1]

if (!g_hooked[id] || !is_user_alive(victim))
{
drag_end(id)
return
}

new Float:fl_Velocity[3]
new idOrigin[3], vicOrigin[3]

get_user_origin(victim, vicOrigin)
get_user_origin(id, idOrigin)

new distance = get_distance(idOrigin, vicOrigin)

if (distance > 1) {
new Float:fl_Time = distance / 160.0

fl_Velocity[0] = (idOrigin[0] - vicOrigin[0]) / fl_Time
fl_Velocity[1] = (idOrigin[1] - vicOrigin[1]) / fl_Time
fl_Velocity[2] = (idOrigin[2] - vicOrigin[2]) / fl_Time
} else {
fl_Velocity[0] = 0.0
fl_Velocity[1] = 0.0
fl_Velocity[2] = 0.0
}

entity_set_vector(victim, EV_VEC_velocity, fl_Velocity) //<- rewritten. now uses engine
}

public drag_end(id) // drags end function
{
if(!is_user_alive(id))
return 
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return;		

g_hooked[id] = 0
beam_remove(id)
remove_task(id)

if (g_drag_i[id])
g_lastHook[id] = get_gametime()

g_drag_i[id] = false
g_unable2move[id] = false
g_fHavedmg[id] = 0.0;
}
public toxic_explozion(id)
{
static Float:originF[3]
pev(id, pev_origin, originF)
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
write_byte( TE_FIREFIELD);
engfunc(EngFunc_WriteCoord, originF[0]+15.0);
engfunc(EngFunc_WriteCoord, originF[1]);
engfunc(EngFunc_WriteCoord, originF[2]);
write_short(2);
write_short(ef_sprite[1]);
write_byte(5);
write_byte(TEFIRE_FLAG_ALPHA|TEFIRE_FLAG_SOMEFLOAT|TEFIRE_FLAG_LOOP);
write_byte(1);
message_end();	
}
public fw_PlayerPreThink(id)
{
if(!is_user_alive(id))
return FMRES_IGNORED
if(zp_class_nemesis_get(id) || zp_class_assassin_get(id))
return FMRES_IGNORED	 

new button = get_user_button(id)
new oldbutton = get_user_oldbutton(id)

if (zp_core_is_zombie(id) && zp_class_zombie_get_current(id) == g_ZombieClassID)
{
if (!(oldbutton & IN_USE) && (button & IN_USE))
drag_start(id)

if ((oldbutton & IN_USE) && !(button & IN_USE))
drag_end(id)
}

if (!g_drag_i[id]) 
{
g_unable2move[id] = false
}
return PLUGIN_CONTINUE
}
public harpoon_target(parm[]) 
{
new id = parm[0]
new hooktarget = parm[1]

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(8)	// TE_BEAMENTS
write_short(id)
write_short(hooktarget)
write_short(ef_sprite[0])	// sprite index
write_byte(0)	// start frame
write_byte(0)	// framerate
write_byte(200)	// life
write_byte(8)	// width
write_byte(1)	// noise
write_byte(155)	// r, g, b
write_byte(155)	// r, g, b
write_byte(55)	// r, g, b
write_byte(100)	// brightness
write_byte(10)	// speed
message_end()
}
public noTarget(id)
{
if(!is_user_alive(id))
return 	

new endorigin[3]
get_user_origin(id, endorigin, 3)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMENTPOINT); // TE_BEAMENTPOINT
write_short(id)
write_coord(endorigin[0])
write_coord(endorigin[1])
write_coord(endorigin[2])
write_short(ef_sprite[0]) // sprite index
write_byte(0)	// start frame
write_byte(0)	// framerate
write_byte(200)	// life
write_byte(8)	// width
write_byte(1)	// noise
write_byte(155)	// r, g, b
write_byte(155)	// r, g, b
write_byte(55)	// r, g, b
write_byte(100)	// brightness
write_byte(0)	// speed
message_end()
}

public beam_remove(id) 
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(99)	
write_short(id)	
message_end()
}
