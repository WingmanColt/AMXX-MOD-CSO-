#include <amxmodx>
#include <ZombieMod5>

#define TASK_STUN 1005
#define TASK_REMOVE_STUN 1006

new g_IsZombie, g_IsAlive
new g_had_class[33], g_class, ef_sprite
public plugin_init()
{
Register_SafetyFunc()
		
g_class = zb5_register_class("Gerrard", "\yPrivate Military Contractors", LEVEL_GERRARD)
}
public plugin_precache()
{
PrecacheModel("sprites/ZB5/z4_stun.spr")	
PrecacheSound("ZB5/Zombie_Stun.wav")	
PrecacheSound("ZB5/Stun_Explode.wav")	
		
ef_sprite = PrecacheModel("sprites/ZB5/stun_activate.spr")
} 
public zp_fw_level_post(id)
{
switch(zb5_get_user_level(id))	
{
case 18..33:Get_Class(id)	
}
}
public zb5_class_selected_post(id, class)
{
if(class == g_class)
Get_Class(id)
}
public Get_Class(id)
{	
zb5_remove_class(id)
g_had_class[id] = true	

fm_set_user_health(id, 1000)
fm_set_user_armor(id, 0)
fm_set_user_gravity(id, 1.0)
zb5_set_hspeed(id, 1.150)

get_weapon_grenade_flash(id, 2)
cs_set_player_model(id, "ZB5_Humans1")
set_pev(id, pev_body, 4 - 1)
}

// HUMAN SKILLS //
public zb5_humanskill(id, SkillButton)
{	
if(!is_player(id))
return

switch(SkillButton)
{
case SKILL_E:Do_Skill(id)
}
}
public Do_Skill(id)
{	
new Float:velocity[3]	
entity_get_vector(id,EV_VEC_velocity,velocity)
velocity[2] = 468.328157
entity_set_vector(id,EV_VEC_velocity,velocity)

set_task(1.3, "Do_Stun_2", id)	
}
public Do_Stun_2(id)
{	
new Float:Origin[3], victim, radius
pev(id, pev_origin, Origin)  
victim = -1
	
switch(zb5_skill_human(id, SKILL_PLEVEL))
{	
case 1: radius = 200	
case 2: radius = 250
case 3: radius = 300
case 4: radius = 350
case 5: radius = 400
default: radius = 150
}	

Icon(id, ef_sprite, 5)
emit_sound(id, CHAN_BODY, "ZB5/Stun_Explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, Origin, float(radius))) != 0)
{	
if(!Get_BitVar(g_IsAlive, victim))
continue
if(!Get_BitVar(g_IsZombie, victim))
continue
if(victim == id)
continue

//zb5_AddTofull_Icon(victim, 220.0, 0.3, 5.0, "sprites/ZB5/z4_stun.spr", 5)

emit_sound(victim, CHAN_VOICE, "ZB5/Zombie_Stun.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapon_kick(id, victim, 9000.0)
zb5_set_user_nvg(victim, 0, 0, 0, 1)
	
remove_task(victim+TASK_STUN)
set_task(0.1, "make_stun", victim+TASK_STUN)

remove_task(victim+TASK_REMOVE_STUN)
set_task(6.0, "Remove_Stun", victim+TASK_REMOVE_STUN)
}	
}
public make_stun(id)
{
id -= TASK_STUN

if(!Get_BitVar(g_IsAlive, id))
return;
if(!Get_BitVar(g_IsZombie, id))
return;

Make_ScreenFade(id, 0.1, 0, 0, 0, 250, FADE_IN)
zb5_set_user_nvg(id, 0, 0, 0, 1)	
set_task(0.3, "make_stun", id+TASK_STUN)
}
public Remove_Stun(id)
{	
id -= TASK_REMOVE_STUN	

zb5_set_user_nvg(id, 1, 0, 0, 1)	
remove_task(id+TASK_STUN)
}
stock Icon(id, spr, radius)
{
static Float:origin[3];
pev(id,pev_origin,origin);

message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_EXPLOSION); // TE_EXPLOSION
write_coord(floatround(origin[0])); // origin x
write_coord(floatround(origin[1])); // origin y
write_coord(floatround(origin[2]) + radius); // origin z
write_short(spr); // sprites
write_byte(13); // scale in 0.1's
write_byte(25); // framerate
write_byte(14); // flags 
message_end(); // message end
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
public zb5_class_remove_post(id)g_had_class[id] = false

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
g_had_class[id] = false;	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

Safety_Disconnected(id)
{
g_had_class[id] = false;	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

if(g_had_class[id])	
Get_Class(id)
}
public zp_fw_core_cure_post(id)
{	
UnSet_BitVar(g_IsZombie, id)
Set_BitVar(g_IsAlive, id)

if(g_had_class[id])	
Get_Class(id)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)
g_had_class[id] = false
}
public is_player(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0
if(!g_had_class[id])
return 0
if(Get_BitVar(g_IsZombie, id))
return 0

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/

