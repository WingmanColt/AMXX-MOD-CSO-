#include <amxmodx>
#include <ZombieMod5>

#define SHOCK_CLASSNAME "deimos_shock"
#define TASK_DASHING 25001

new const ZombieSound[][] =
{
"ZB5/deimos_skill_hit.wav",	
"ZB5/deimos_skill_start.wav",
"ZB5/deimos_skill_dash.wav"
}
new const ZombieModel[][] =
{	
"models/player/ZB5_Deimos/ZB5_Deimos.mdl",	
"models/ZB5/Claws/v_ZB5_Deimos.mdl"
}

enum _:Options
{
CLASS,
Float:POWER
}

const WPN_NOT_DROP = ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))

new g_IsZombie, g_IsAlive, g_IsConnected
new g_had[33][Options], ef_sprite[2],  g_class

public plugin_init()
{	
Register_SafetyFunc()
	
register_think(SHOCK_CLASSNAME, "fw_ShockThink")
register_touch(SHOCK_CLASSNAME, "*", "fw_ShockTouch")

register_forward(FM_EmitSound, "fw_EmitSound")	
register_forward(FM_CmdStart, "fw_CmdStart")

g_class = zb5_register_zclass("Deimos", "\y(Shock & Mahadash)", 0, 0, 1, 7300, 1, 1)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

for(i = 0; i < sizeof(ZombieModel); i++)
PrecacheModel(ZombieModel[i])	

ef_sprite[0] = PrecacheModel("sprites/ZB5/deimosexp.spr")
ef_sprite[1] = PrecacheModel("sprites/laserbeam.spr")	
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

g_had[id][CLASS] = true	
zb5_skill_zombie(id, SKILL_CAN)
zb5_skill_zombie(id, SKILL_CAN_2)

cs_set_player_model(id, "ZB5_Deimos")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Deimos.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
set_weapon_anim(id, 3)
}

public Reset_All(id, full)
{
zb5_zombieskill_reset(id, SKILL_E)
zb5_zombieskill_reset(id, SKILL_Q)

if(full)	
g_had[id][CLASS] = false
}

// SKILL 1
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_alive(id))
return 
if(!is_zombie(id))
return
if(!g_had[id][CLASS])
return

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)	
static OldButton, flags	

OldButton = pev(id, pev_oldbuttons)
flags = pev(id, pev_flags)


if((CurButton & IN_JUMP) && !(flags & FL_ONGROUND) && !(OldButton & IN_JUMP))
g_had[id][POWER] = 200.0
else 
g_had[id][POWER] = 1000.0
}
public zb5_zombieskill(id, SkillButton)
{
if(!g_had[id][CLASS])
return

switch(SkillButton)
{
case SKILL_E:Do_Skill(id)
case SKILL_Q:Do_Skill2(id)
}
}
public Do_Skill(id)
{		
engclient_cmd(id, "weapon_knife")
create_fake_attack(id, "knife")

set_weapons_timeidle(id, CSW_KNIFE, 1.5)
set_player_nextattack(id, 1.5)

EmitSound(id, CHAN_ITEM, ZombieSound[1])

set_fov(id, 120)
set_weapon_anim(id, 8)
set_pev(id, pev_sequence, 10)

set_task(0.9, "Do_Shock", id)
}

public Do_Shock(id)
{	
set_fov(id)
Create_Light(id)
}
public zb5_zombieskill_reset(id, SkillButton)
{
if(!is_zombie(id))
return
	
switch(SkillButton)
{
case SKILL_Q:remove_task(id+TASK_DASHING)
}	
}
public Create_Light(id)
{
static Float:StartOrigin[3], Float:Angles[3], Float:Velocity[3]

entity_get_vector(id, EV_VEC_angles, Angles)
Angles[0] *= -1.0

velocity_by_aim(id, 1300, Velocity)
get_position(id, 48.0, 0.0, 0.0, StartOrigin)

static ent; ent = create_entity("info_target")
if(!is_valid_ent(ent))
return;

entity_set_string(ent, EV_SZ_classname, SHOCK_CLASSNAME)
entity_set_model(ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")

entity_set_int(ent, EV_INT_body, 9 - 1)
entity_set_int(ent, EV_INT_sequence, 7)

entity_set_vector(ent,EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(ent,EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

StartOrigin[2] += (pev(id, pev_flags) & FL_DUCKING) == 0 ? 35.0 : 25.0

entity_set_origin(ent, StartOrigin)
entity_set_vector(ent, EV_VEC_angles, Angles)

entity_set_int(ent,EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(ent,EV_INT_solid, SOLID_TRIGGER)

entity_set_float(ent, EV_FL_gravity, 0.01)
entity_set_edict(ent, EV_ENT_owner, id)
entity_set_vector(ent, EV_VEC_velocity, Velocity)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMENTPOINT)
write_short(ent)	// start entity
write_coord_f(StartOrigin[0])
write_coord_f(StartOrigin[1])
write_coord_f(StartOrigin[2])
write_short(ef_sprite[1])	// sprite index
write_byte(0)	// starting frame
write_byte(0)	// frame rate in 0.1's
write_byte(30)	// life in 0.1's
write_byte(10)	// line width in 0.1's
write_byte(0)	// noise amplitude in 0.01's
write_byte(255)
write_byte(212)
write_byte(0)
write_byte(255)	// brightness
write_byte(0)	// scroll speed in 0.1's
message_end()

entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.05)	
}

public fw_ShockThink(Ent)
{
if(!is_valid_ent(Ent))
return;

static id; id = entity_get_edict(Ent,EV_ENT_owner)

static distance
switch(zb5_get_zombie_info(id, EVO_LV))
{
case HOST:distance = 1000
case ORIGIN:distance = 1500
case NORMAL:distance = 700
}
if(!is_alive(id) || !is_zombie(id) || entity_range(Ent, id) >= distance)
{
static Float:Origin[3]
entity_get_vector(Ent, EV_VEC_origin, Origin)
Shock_Explosion(Ent, Origin)

entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.05)
entity_set_int(Ent,EV_INT_flags, FL_KILLME)

return
}

entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.05)	
}

public fw_ShockTouch(Ent, id)
{
if(!is_valid_ent(Ent))
return

static Float:Origin[3]; entity_get_vector(Ent, EV_VEC_origin, Origin)

if(is_alive(id) && !is_zombie(id) && !zp_core_is_hero(id))
{
Shock_Explosion(Ent, Origin)

static CSW, WeaponName[32]
CSW = get_user_weapon(id)

if(!(WPN_NOT_DROP & (1<<CSW)) && get_weaponname(CSW, WeaponName, charsmax(WeaponName)))
engclient_cmd(id, "drop", WeaponName)

if(!zb5_get_user_nvg(id))
Make_ScreenFade(id, 1.0, 255, 212, 0, 255, FADE_IN)

set_pdata_float(id, 108, 0.8)
Make_ScreenShake(id, 3, 1, 3)
PlaySound(id, ZombieSound[2])
} else Shock_Explosion(Ent, Origin)

entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.05)
entity_set_int(Ent,EV_INT_flags, FL_KILLME)
}

public Shock_Explosion(Ent, Float:Origin[3])
{
EmitSound(Ent, CHAN_AUTO, "ZB5/weapons/Zombi_Bomb_exp.wav")

// create effect
message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_EXPLOSION) // TE_EXPLOSION
write_coord_f(Origin[0]) // origin x
write_coord_f(Origin[1]) // origin y
write_coord_f(Origin[2]); // origin z
write_short(ef_sprite[0]) // sprites
write_byte(20) // scale in 0.1's
write_byte(30) // framerate
write_byte(14) // flags 
message_end() // message end

message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_PARTICLEBURST) // TE id
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 16.0)
write_short(30) // radius
write_byte(0) // color
write_byte(1) // duration (will be randomized a bit)
message_end()
}

/// SKILL 2 ///
public Do_Skill2(id)
{	
engclient_cmd(id, "weapon_knife")

create_fake_attack(id, "knife")
set_player_nextattack(id, 1.8)

remove_task(id+TASK_DASHING)
set_task(0.75, "Mahadashing", id+TASK_DASHING)
set_task(1.5, "Mahadash_End", id+TASK_DASHING)

set_fov(id, 100)
}
public Mahadashing(id)
{
id -= TASK_DASHING

if(!is_alive(id))
return 
if(!is_zombie(id))
return
if(!g_had[id][CLASS])
return

static Float:Origin[3], Float:Target[3], Float:Vel[3]

entity_get_vector(id, EV_VEC_origin, Origin)
get_position(id, 640.0, 0.0, 0.0, Target)

get_speed_vector(Origin, Target, g_had[id][POWER], Vel)
entity_set_vector(id, EV_VEC_velocity, Vel)

EmitSound(id, CHAN_ITEM, ZombieSound[2])
zb5_set_zombie_info(id, SPEED, 0, 500.0)
zb5_set_zombie_info(id, GRAVITY, 0, 0.5)

static Float:PlayerOrigin[3]
for(new i = 0; i < get_maxplayers(); i++)
{
if(!is_alive(i))
continue
if(is_zombie(i))
continue
	
entity_get_vector(i, EV_VEC_origin, PlayerOrigin)	
if(get_distance_f(Origin, PlayerOrigin) > 100.0)
continue

ExecuteHamB(Ham_TakeDamage, i, 0, id, float(100), DMG_BLAST)
set_weapon_kick(id, i, 5000.0)
Make_ScreenShake(i, 4,  4,  4)	
}
}
public Mahadash_End(id)
{
id -= TASK_DASHING

if(!is_alive(id))
return 
if(!is_zombie(id))
return
if(!g_had[id][CLASS])
return

zb5_set_zombie_info(id, RESET_SPEED)
zb5_set_zombie_info(id,  RESET_GRAVITY)	

set_player_nextattack(id, 0.75)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_weapon_anim(id, 3)

static Float:Origin[3]
entity_get_vector(id, EV_VEC_origin, Origin)

static Float:PlayerOrigin[3]
for(new i = 0; i < get_maxplayers(); i++)
{
if(!is_alive(i))
continue
if(is_zombie(i))
continue
	
entity_get_vector(i, EV_VEC_origin, PlayerOrigin)	
if(get_distance_f(Origin, PlayerOrigin) > 50.0)
continue

ExecuteHamB(Ham_TakeDamage, i, 0, id, float(100), DMG_BLAST)
set_weapon_kick(id, i, 5000.0)
Make_ScreenShake(i, 4,  4,  4)	
}
}
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if(!is_alive(id))
return FMRES_IGNORED;
if(!is_zombie(id))
return FMRES_IGNORED;
if(!g_had[id][CLASS])
return FMRES_IGNORED;

new const ZombieSound2[][] =
{
"ZB5/zombi_hurt_01.wav",
"ZB5/zombi_hurt_02.wav",

"ZB5/zombi_death_1.wav", 
"ZB5/zombi_death_2.wav"
}
if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, ZombieSound2[random_num(0, 1)], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, ZombieSound2[random_num(2, 3)], volume, attn, flags, pitch) 
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
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
}

Safety_Disconnected(id)
{
Reset_All(id, 1)
UnSet_BitVar(g_IsConnected, id)
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

if(g_had[id][CLASS])	
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

if(g_had[id][CLASS])	
Get_Class(id)
}
is_alive(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0

return 1
}
is_zombie(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsZombie, id))
return 0

return 1
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
