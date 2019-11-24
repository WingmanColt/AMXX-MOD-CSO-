#include <amxmodx>
#include <ZombieMod5>

new const ZombieSound[][] =
{
"ZB5/zombi_hurt_female_1.wav", 
"ZB5/zombi_hurt_female_2.wav",

"ZB5/zombi_death_female_1.wav",
"ZB5/zombi_death_female_2.wav",

"ZB5/zombi_pressure_female.wav",
"ZB5/zombi_end_female.wav",
"ZB5/zombi_female_scream.wav",
}
new const ZombieModel[][] =
{	
"models/player/ZB5_Light/ZB5_Light.mdl",
"models/ZB5/Claws/v_ZB5_Light.mdl",
"models/ZB5/Claws/v_ZB5_Light2.mdl"
}

new g_had_class[33], g_class
new g_IsZombie, g_IsAlive

public plugin_init()
{
Register_SafetyFunc()
register_forward(FM_EmitSound, "fw_EmitSound")		
g_class = zb5_register_zclass("Light Zombie", "\y(Invisible & Leap)", 0, 1, 3, 2500, 1, 1)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

for(i = 0; i < sizeof(ZombieModel); i++)
PrecacheModel(ZombieModel[i])		
}

public zb5_zclass_selected_post(id, class)
{
if(class == g_class)
Get_Class(id)
}

public Get_Class(id)
{	
zb5_remove_zclass(id)

g_had_class[id] = true	
zb5_skill_zombie(id, SKILL_CAN)
zb5_skill_zombie(id, SKILL_CAN_2)

cs_set_player_model(id, "ZB5_Light")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Light.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
set_weapon_anim(id, 3)
}
public Reset_All(id, full)
{
zb5_zombieskill_reset(id, SKILL_E)

if(full)
g_had_class[id] = false	
}
public zb5_zombieskill(id, SkillButton)
{
if(!g_had_class[id])
return

switch(SkillButton)
{
case SKILL_E:Do_Skill(id)
case SKILL_Q:Do_Skill2(id)
}
}

// SKILL 1
public Do_Skill(id)
{		
static Float:Speed, Float:Gravity	
switch(zb5_get_zombie_info(id, EVO_LV))
{
case ORIGIN: 
{
Speed = 240.0; Gravity = 0.800
}
case HOST: 
{
Speed = 220.0; Gravity = 0.820
}
default: 
{
Speed = 200.0; Gravity = 0.840
}
}


set_fov(id, 100)
fm_set_rendering(id)
fm_set_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 16)

EmitSound(id, CHAN_AUTO, ZombieSound[4])
cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Light2.mdl")

zb5_set_zombie_info(id, SPEED, 0, Speed)
zb5_set_zombie_info(id, GRAVITY, 0, Gravity)
}

public zb5_zombieskill_reset(id, SkillButton)
{
if(!is_zombie(id))
return
	
switch(SkillButton)
{
case SKILL_E:Reset_Skill(id)
}	
}
public Reset_Skill(id)
{
set_fov(id)
fm_set_rendering(id)

zb5_set_zombie_info(id, RESET_SPEED)
zb5_set_zombie_info(id,  RESET_GRAVITY)	

cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Light.mdl")	
EmitSound(id, CHAN_AUTO, ZombieSound[5])
}

/// SKILL 2 ///
public Do_Skill2(id)
{	
if(pev(id, pev_flags) & FL_DUCKING)
return	

static Leap	
switch(zb5_get_zombie_info(id, EVO_LV))
{
case ORIGIN:Leap = 400
case HOST:Leap = 500
default:Leap = 300
}

static Float:velocity[3]
velocity_by_aim(id, Leap, velocity)
velocity[2] = float(Leap)
set_pev(id, pev_velocity, velocity)

EmitSound(id, CHAN_AUTO, ZombieSound[6])
set_fov(id, 100)
}
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if(!is_zombie(id))
return FMRES_IGNORED; 

if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, ZombieSound[random_num(0, 1)], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, ZombieSound[random_num(2, 3)], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
return FMRES_IGNORED 
} 

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
public zb5_zclass_remove_post(id)Reset_All(id, 1)

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Reset_All(id, 1)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
}

Safety_Disconnected(id)
{
Reset_All(id, 1)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
{
Reset_All(id, 0)
Set_BitVar(g_IsZombie, id)

if(g_had_class[id])	
Get_Class(id)
}else Reset_All(id, 1)
}
public zp_fw_core_cure_post(id)
{
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
Reset_All(id, 0)

UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Reset_All(id, 0)

Set_BitVar(g_IsZombie, id)

if(g_had_class[id])	
Get_Class(id)
}
is_zombie(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0
if(!Get_BitVar(g_IsZombie, id))
return 0
if(!g_had_class[id])
return 0

return 1
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
