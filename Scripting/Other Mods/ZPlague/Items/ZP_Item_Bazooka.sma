#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <zp50_colorchat>
#include <zp50_core>

new has_jetpack[33], can_shoot[33], maxplayers
new sprite_explosion, sprite_beamcylinder
public plugin_init()
{
register_event("DeathMsg","hook_death","a")
register_logevent("round_end",2,"1=Round_End")	
register_event("CurWeapon","event_curweapon","be","1=1","2=29")
register_touch("weapon_jetpack","player","get_jetpack")
register_touch("","info_jetpack_rocket","touch_jetpack")
RegisterHam(Ham_Weapon_PrimaryAttack,"weapon_knife","shoot_jetpack")
register_clcmd("drop","drop_jetpack")
maxplayers = get_maxplayers()
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
public client_connect(id)has_jetpack[id] = false
public client_disconnect(id)has_jetpack[id] = false
public BuyJet(id)
{
if(has_jetpack[id])
{
zp_colored_print(id, "^x01You have already own a RPG!")
return
}
new money = zp_ammopacks_get(id) 		
if (money >= 40)
{		
zp_ammopacks_set(id, money - 40)	
has_jetpack[id] = true
can_shoot[id] = true
emit_sound(id,CHAN_AUTO,"items/gunpickup2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
client_cmd(id,"weapon_knife")
entity_set_string(id,EV_SZ_viewmodel,"models/v_rpg.mdl")
entity_set_string(id,EV_SZ_weaponmodel,"models/p_rpg.mdl")
set_weapon_anim(id, 5)
}else{
zp_colored_print(id, " ^x01Not enough AmmoPacks!")
}
}
public zp_fw_core_infect_post(id)
{
if(zp_core_is_zombie(id))	
{
if(has_jetpack[id])
action_drop_user_jetpack(id)
}
}
public round_end()remove_entity_name("weapon_jetpack")
public action_remove_user_jetpack(id)
{
if(has_jetpack[id] && get_user_weapon(id) == CSW_KNIFE) action_drop_user_jetpack(id)
has_jetpack[id] = false
can_shoot[id] = false
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_KILLBEAM)
write_short(id)
message_end()
}

public hook_death()
{
new id = read_data(2)
action_remove_user_jetpack(id)
}

public event_curweapon(id)
{
if(has_jetpack[id] && !zp_core_is_zombie(id))
{
entity_set_string(id,EV_SZ_viewmodel,"models/v_rpg.mdl")
entity_set_string(id,EV_SZ_weaponmodel,"models/p_rpg.mdl")
}
}

public drop_jetpack(id) if(get_user_weapon(id) == CSW_KNIFE && has_jetpack[id]) action_drop_user_jetpack(id)

public shoot_jetpack(ent)
{
new id = entity_get_edict(ent,EV_ENT_owner)
if(!has_jetpack[id]) return HAM_IGNORED

if(!can_shoot[id])
{
set_weapon_anim(id, 3)	
client_print(id,print_center,"[NS2] You can't shoot with the rpg right now. Please wait...")
return HAM_IGNORED
}
set_weapon_anim(id, 3)
action_shoot_user_jetpack(id)
return HAM_IGNORED
}
public action_drop_user_jetpack(id)
{
remove_task(id)
set_weapon_anim(id, 4)
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
entity_set_model(ent,"models/w_rpg.mdl")
entity_set_int(ent,EV_INT_solid,SOLID_TRIGGER)
entity_set_int(ent,EV_INT_movetype,MOVETYPE_TOSS)
entity_set_float(ent,EV_FL_gravity,1.0)
entity_set_origin(ent,origin)
}
}

public action_shoot_user_jetpack(id)
{
can_shoot[id] = false
emit_sound(id,CHAN_AUTO,"weapons/rocketfire1.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)

new ent = create_entity("info_target")
if(ent)
{
new Float:origin[3],Float:velocity[3],Float:angles[3]
entity_get_vector(id,EV_VEC_origin,origin)
velocity_by_aim(id,60,velocity)
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
entity_set_int(ent,EV_INT_effects,entity_get_int(ent,EV_INT_effects) | EF_LIGHT)
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
set_weapon_anim(id, 2)
set_task(10.0,"action_reload_user_jetpack",id)
}

public action_reload_user_jetpack(id)
{
if(!is_user_connected(id) || !has_jetpack[id]) return
can_shoot[id] = true
client_print(id,print_center,"[NS2] Your rpg has been reloaded. Now you can shoot again!")
}

public get_jetpack(ent,id)
{
if(has_jetpack[id] || zp_core_is_zombie(id) || zp_class_nemesis_get(id) || zp_class_assassin_get(id)) return
remove_task(id)
set_weapon_anim(id, 7)
has_jetpack[id] = true
can_shoot[id] = false
emit_sound(id,CHAN_AUTO,"items/gunpickup2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
client_cmd(id,"weapon_knife")
entity_set_string(id,EV_SZ_viewmodel,"models/v_rpg.mdl")
entity_set_string(id,EV_SZ_weaponmodel,"models/p_rpg.mdl")
set_task(15.0,"action_reload_user_jetpack",id)
remove_entity(ent)
}
public touch_jetpack(world,ent)
{
if(!is_valid_ent(ent)) return

new Float:origin[3], origin_int[3], owner = entity_get_edict(ent,EV_ENT_owner)
entity_get_vector(ent,EV_VEC_origin,origin)

FVecIVec(origin,origin_int)

new id = -1
while((id = find_ent_in_sphere(id,origin,float(150))) != 0)
{
if(!is_user_connected(owner)) break

if(1 <= id <= maxplayers)
{
if(!zp_core_is_zombie(id) && !zp_class_nemesis_get(id) && !zp_class_assassin_get(id) && !zp_class_clown_get(id)) continue
ExecuteHamB(Ham_TakeDamage,id, owner,owner, float(500), DMG_ALWAYSGIB)
static Float:flVictimOrigin[3], Float:flDistance, Float:flSpeed, Float:flNewSpeed, Float:flVelocity[3]
entity_get_vector(id, EV_VEC_origin, flVictimOrigin)
flDistance = get_distance_f(origin, flVictimOrigin)
flSpeed = 700.0
flNewSpeed = flSpeed * (1.0 - (flDistance / 150.0))
GetSpeedVector(origin, flVictimOrigin, flNewSpeed, flVelocity)
entity_set_vector(id, EV_VEC_velocity, flVelocity)
} else {
if(!is_valid_ent(id)) continue

new classname[15]
entity_get_string(id,EV_SZ_classname,classname,14)
if(!equal(classname,"func_breakable")) continue
ExecuteHamB(Ham_TakeDamage,id, owner,owner, float(500), DMG_ALWAYSGIB)
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
stock set_weapon_anim(id, anim)
{
if(!is_user_alive(id))
return

set_pev(id, pev_weaponanim, anim)

message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
write_byte(anim)
write_byte(pev(id, pev_body))
message_end()
}
GetSpeedVector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
new_velocity[0] = origin2[0] - origin1[0]
new_velocity[1] = origin2[1] - origin1[1]
new_velocity[2] = origin2[2] - origin1[2]
new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
new_velocity[0] *= num
new_velocity[1] *= num
new_velocity[2] *= num

return 1
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
