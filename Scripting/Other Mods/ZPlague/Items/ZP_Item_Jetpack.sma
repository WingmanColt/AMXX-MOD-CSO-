#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <engine>
#include <cstrike>
#include <zp50_colorchat>
#include <zp50_core>

new has_jetpack[33], can_shoot[33], energy[33], hudsync, maxplayers
new sprite_explosion, sprite_beamcylinder
public plugin_init()
{
register_event("DeathMsg","hook_death","a")
register_event("CurWeapon","event_curweapon","be","1=1","2=29")
register_logevent("round_end",2,"1=Round_End")	
register_touch("weapon_jetpack","player","get_jetpack")
register_touch("","info_jetpack_rocket","touch_jetpack")
RegisterHam(Ham_Weapon_SecondaryAttack,"weapon_knife","shoot_jetpack")
RegisterHam(Ham_Player_Jump,"player","fly_jetpack")
register_clcmd("drop","drop_jetpack")
maxplayers = get_maxplayers()
hudsync = CreateHudSyncObj()
}
public plugin_precache()
{
sprite_explosion = precache_model("sprites/ZPlague/zerogxplode2.spr")
sprite_beamcylinder = precache_model("sprites/white.spr")
}
public plugin_natives()
{
register_native("give_item_jetpack", "BuyJet", 1)
}
public BuyJet(id)
{
if(!is_user_alive(id))
return;		
if(has_jetpack[id])
{
zp_colored_print(id, "^x01You have already own a jetpack!")
return
}
new money = zp_ammopacks_get(id) 		
if (money >= 30)
{		
zp_ammopacks_set(id, money - 30)	
has_jetpack[id] = true
can_shoot[id] = true
energy[id] = 200
emit_sound(id,CHAN_AUTO,"items/gunpickup2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
client_cmd(id,"weapon_knife")
entity_set_string(id,EV_SZ_viewmodel,"models/v_egon.mdl")
entity_set_string(id,EV_SZ_weaponmodel,"models/p_egon.mdl")
set_task(1.0,"action_heal_user_jetpack",id)
}else{
zp_colored_print(id, "^x01Not enough AmmoPacks!")
}
}

public drop_jetpack(id) if(get_user_weapon(id) == CSW_KNIFE && has_jetpack[id]) action_drop_user_jetpack(id)

public shoot_jetpack(ent)
{
if(!is_valid_ent(ent)) 
return HAM_IGNORED	
new id = entity_get_edict(ent,EV_ENT_owner)
if(!is_user_alive(id))
return HAM_IGNORED
if(!has_jetpack[id]) 
return HAM_IGNORED

if(!can_shoot[id])
{
client_print(id,print_center,"[NS2] You can't shoot with the jetpack right now. Please wait...")
return HAM_IGNORED
}
action_shoot_user_jetpack(id)
return HAM_IGNORED
}

public fly_jetpack(id)
{
if(!is_user_alive(id))
return HAM_IGNORED		
if(!has_jetpack[id]) 
return HAM_IGNORED

if(!energy[id])
{
client_print(id,print_center,"[NS2] You don't have enough energy to fly.")
return HAM_IGNORED
}

if(get_user_button(id) & IN_DUCK) action_fly_user_jetpack(id)

return HAM_IGNORED
}

public action_heal_user_jetpack(id)
{
if(!is_user_alive(id))
return;		
if(!has_jetpack[id]) 
return;

if(zp_core_is_zombie(id) || zp_class_nemesis_get(id) || zp_class_assassin_get(id) || zp_class_clown_get(id))
{
action_remove_user_jetpack(id)
return;
}

if(entity_get_int(id,EV_INT_flags) & FL_INWATER)
{
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_KILLBEAM)
write_short(id)
message_end()
}

if(entity_get_int(id,EV_INT_flags) & FL_ONGROUND)
{
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_KILLBEAM)
write_short(id)
message_end()

if(energy[id] < 200)
{
energy[id] += 10
if(energy[id] > 200) energy[id] = 200

set_hudmessage(0, 200, 0, -1.0, 0.29, 0, 6.0, 1.0, 0.1, 0.2, -1)
ShowSyncHudMsg(id,hudsync,"Jetpack Energy: [%i / 200]", energy[id])
}
}

set_task(1.0,"action_heal_user_jetpack",id)
}

public action_drop_user_jetpack(id)
{
if(!is_user_alive(id))
return;		
has_jetpack[id] = false
can_shoot[id] = false
if(!zp_core_is_zombie(id))
{
entity_set_string(id,EV_SZ_viewmodel,"models/v_knife.mdl")
entity_set_string(id,EV_SZ_weaponmodel,"models/p_knife.mdl")
}
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_KILLBEAM)
write_short(id)
message_end()

emit_sound(id,CHAN_AUTO,"common/bodydrop2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)

new ent = create_entity("info_target")
if(ent)
{
new Float:origin[3],Float:velocity[3]
entity_get_vector(id,EV_VEC_origin,origin)
velocity_by_aim(id,60,velocity)
origin[0] += velocity[0]
origin[1] += velocity[1]
entity_set_string(ent,EV_SZ_classname,"weapon_jetpack")
entity_set_model(ent,"models/w_egon.mdl")
entity_set_int(ent,EV_INT_solid,SOLID_TRIGGER)
entity_set_int(ent,EV_INT_movetype,MOVETYPE_TOSS)
entity_set_int(ent,EV_INT_iuser1,energy[id])
entity_set_float(ent,EV_FL_gravity,1.0)
entity_set_origin(ent,origin)
}

energy[id] = 0
}

public action_shoot_user_jetpack(id)
{
if(!is_user_alive(id))
return;	
	
can_shoot[id] = false
emit_sound(id,CHAN_AUTO,"weapons/rocketfire1.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
new ent = create_entity("info_target")
if(ent)
{
new Float:origin[3],Float:velocity[3],Float:angles[3]
entity_get_vector(id,EV_VEC_origin,origin)
velocity_by_aim(id,20,velocity)
origin[0] += velocity[0]
origin[1] += velocity[1]
velocity[0] = 0.0
velocity[1] = 0.0
velocity_by_aim(id,1500,velocity)
entity_set_string(ent,EV_SZ_classname,"info_jetpack_rocket")
entity_set_model(ent,"models/rpgrocket.mdl")
entity_set_int(ent,EV_INT_solid,SOLID_BBOX)
entity_set_int(ent,EV_INT_movetype,MOVETYPE_FLY)
entity_set_size(ent,Float:{-0.5,-0.5,-0.5},Float:{0.5,0.5,0.5})
entity_set_vector(ent,EV_VEC_velocity,velocity)
vector_to_angle(velocity,angles)
entity_set_vector(ent,EV_VEC_angles,angles)
entity_set_edict(ent,EV_ENT_owner,id)
entity_set_origin(ent,origin)
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(ent)
write_short(sprite_beamcylinder)
write_byte(5)
write_byte(5)
write_byte(100)
write_byte(100)
write_byte(100)
write_byte(100)
message_end()
}
set_task(10.0,"action_reload_user_jetpack",id)
}

public action_fly_user_jetpack(id)
{
if(!is_user_alive(id))
return;		
new Float:velocity[3]
velocity_by_aim(id,300,velocity)
velocity[2] += float(300)
entity_set_vector(id,EV_VEC_velocity,velocity)

energy[id] -= 1
if(energy[id] < 1) energy[id] = 0

set_hudmessage(200, 0, 0, -1.0, 0.29, 0, 6.0, 1.0, 0.1, 0.2, -1)
ShowSyncHudMsg(id,hudsync,"Jetpack Energy: [%i / 200]", energy[id])
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_KILLBEAM)
write_short(id)
message_end()
}

public action_reload_user_jetpack(id)
{
if(!is_user_alive(id))
return;		
if(!has_jetpack[id]) 
return
can_shoot[id] = true
client_print(id,print_center,"[NS2] Your jetpack has been reloaded. Now you can shoot again!")
}

public get_jetpack(ent,id)
{
if(!is_valid_ent(ent)) 
return;	
if(!is_user_alive(id))
return;			
if(has_jetpack[id] || zp_core_is_zombie(id) || zp_class_nemesis_get(id) || zp_class_assassin_get(id)) 
return
has_jetpack[id] = true
can_shoot[id] = false
energy[id] = entity_get_int(ent,EV_INT_iuser1)
emit_sound(id,CHAN_AUTO,"items/gunpickup2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
client_cmd(id,"weapon_knife")
entity_set_string(id,EV_SZ_viewmodel,"models/v_egon.mdl")
entity_set_string(id,EV_SZ_weaponmodel,"models/p_egon.mdl")
set_task(10.0,"action_reload_user_jetpack",id)
set_task(1.0,"action_heal_user_jetpack",id)
remove_entity(ent)
}

public touch_jetpack(world,ent)
{
if(!is_valid_ent(ent)) 
return

new Float:origin[3], origin_int[3], owner = entity_get_edict(ent,EV_ENT_owner)
entity_get_vector(ent,EV_VEC_origin,origin)

FVecIVec(origin,origin_int)

new id = -1
while((id = find_ent_in_sphere(id,origin,float(150))) != 0)
{
if(!is_user_connected(owner)) break

if(1 <= id <= maxplayers)
{
if(!zp_core_is_zombie(id) && !zp_class_nemesis_get(id) && !zp_class_assassin_get(id)) continue
ExecuteHamB(Ham_TakeDamage,id, owner,owner, float(900), DMG_ALWAYSGIB)
} else {
if(!is_valid_ent(id)) continue

new classname[15]
entity_get_string(id,EV_SZ_classname,classname,14)

if(!equal(classname,"func_breakable")) continue

ExecuteHamB(Ham_TakeDamage,id, owner,owner, float(900), DMG_ALWAYSGIB)
}
}

message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origin_int)
write_byte(TE_EXPLOSION)
write_coord(origin_int[0])
write_coord(origin_int[1])
write_coord(origin_int[2]+30)
write_short(sprite_explosion)
write_byte(floatround(150 * 0.5))
write_byte(20)
write_byte(TE_EXPLFLAG_NOSOUND)
message_end()

emit_sound(ent, CHAN_AUTO, "ZPlague/bazooka_stone_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
remove_entity(ent)
}

public hook_death()
{
new id = read_data(2)
if(is_user_connected(id))
action_remove_user_jetpack(id)
}

public action_remove_user_jetpack(id)
{	
if(!is_user_alive(id))
return;		
if(has_jetpack[id] && get_user_weapon(id) == CSW_KNIFE) action_drop_user_jetpack(id)

has_jetpack[id] = false
can_shoot[id] = false
energy[id] = 0

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_KILLBEAM)
write_short(id)
message_end()
}

public event_curweapon(id)
{
if(!is_user_alive(id))
return;	
if(has_jetpack[id] && !zp_core_is_zombie(id))
{
entity_set_string(id,EV_SZ_viewmodel,"models/v_egon.mdl")
entity_set_string(id,EV_SZ_weaponmodel,"models/p_egon.mdl")
}
}

public round_end()
{
remove_entity_name("weapon_jetpack")
for(new i=1;i<maxplayers;i++)
{
if(is_user_connected(i))
{
has_jetpack[i] = false
can_shoot[i] = false
energy[i] = 0
}
}
}

public client_connect(id) has_jetpack[id] = false
public client_disconnect(id) has_jetpack[id] = false
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
