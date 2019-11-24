#include <amxmodx>
#include <ZombieMod5>

#define TASK_BERSERK_SOUND 1003

new const ZombieSound[][] =
{
"ZB5/zombi_hurt_01.wav",
"ZB5/zombi_hurt_02.wav",

"ZB5/zombi_death_1.wav", 
"ZB5/zombi_death_2.wav",

"ZB5/zombi_pressure.wav",
"ZB5/zombi_pre_idle_1.wav",
"ZB5/zombi_pre_idle_2.wav"
}
new const ZombieModel[][] =
{	
"models/player/ZB5_Regular_NEW/ZB5_Regular_NEW.mdl",
"models/ZB5/Claws/v_ZB5_Regular.mdl"
}

new g_had_class[33], g_class, g_IsZombie
public plugin_init()
{
Register_SafetyFunc()	
register_forward(FM_EmitSound, "fw_EmitSound")	

g_class = zb5_register_zclass("Regular", "\y(FastRun)", 0, 0, 2, 5000, 1, 0)
}
public plugin_natives()
{
register_native("zb5_get_regular", "Get_Class", 1)
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
Reset_All(id, 1)

g_had_class[id] = true	
zb5_skill_zombie(id, SKILL_CAN)

cs_set_player_model(id, "ZB5_Regular_NEW")
set_pev(id, pev_body, 1 -1)

cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Regular.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
set_weapon_anim(id, 3)
}

public Reset_All(id, full)
{
if(full)
g_had_class[id] = false

zb5_zombieskill_reset(id, SKILL_E)
}

// SKILL 1
public zb5_zombieskill(id, SkillButton)
{
if(!g_had_class[id])
return

switch(SkillButton)
{
case SKILL_E:Do_Skill(id)
}
}
public Do_Skill(id)
{		
static Float:Speed, Float:Gravity	
switch(zb5_get_zombie_info(id, EVO_LV))
{
case ORIGIN: 
{
Speed = 370.0; Gravity = 0.6
}
case HOST: 
{
Speed = 360.0; Gravity = 0.7
}
case NORMAL: 
{
Speed = 330.0; Gravity = 0.8
}
}

set_rendering(id)
set_rendering(id, kRenderFxGlowShell, 253, 3, 0, kRenderNormal, 0)

set_fov(id, 115)
EmitSound(id, CHAN_AUTO, ZombieSound[4])

zb5_set_zombie_info(id, SPEED, 0, Speed)
zb5_set_zombie_info(id, GRAVITY, 0, Gravity)

set_task(2.0, "Berserk_HeartBeat", id+TASK_BERSERK_SOUND, _, _, "b")
}
public zb5_zombieskill_reset(id, SkillButton)
{
if(!is_zombie(id))
return
	
switch(SkillButton)
{
case SKILL_E:
{
remove_task(id+TASK_BERSERK_SOUND)

set_fov(id)
set_rendering(id)

zb5_set_zombie_info(id, RESET_SPEED)
zb5_set_zombie_info(id,  RESET_GRAVITY)	
}
}	
}
public Berserk_HeartBeat(id)
{
id -= TASK_BERSERK_SOUND

if(!is_zombie(id))
return 

Make_ScreenShake(id, 2, 2, 2)
Make_Elight(id, 10, 200, 10, 10, 15, 15)
EmitSound(id, CHAN_AUTO, ZombieSound[random_num(5, 6)])
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
}

Safety_Disconnected(id)
{
Reset_All(id, 1)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

UnSet_BitVar(g_IsZombie, id)

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
if(!Get_BitVar(g_IsZombie, id))
return 0
if(!g_had_class[id])
return 0

return 1
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
