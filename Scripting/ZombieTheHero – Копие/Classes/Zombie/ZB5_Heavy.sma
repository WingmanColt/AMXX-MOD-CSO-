#include <amxmodx>
#include <ZombieMod5>

#define TRAP_CLASSNAME "heavy_trap"

new const ZombieSound[][] =
{
"ZB5/zombi_hurt_heavy_1.wav",
"ZB5/zombi_hurt_heavy_2.wav",

"ZB5/heavy_trapsetup.wav",
"ZB5/trapped_male.wav",
"ZB5/heavy_death.wav",
}
new const ZombieModel[][] =
{	
"models/player/ZB5_Heavy/ZB5_Heavy.mdl",
"models/ZB5/Claws/v_ZB5_Heavy.mdl",
"models/ZB5/Items/zombie_trap.mdl",
"sprites/ZB5/trap.spr"
}

new g_IsZombie, g_IsAlive, g_IsConnected, g_Count
new g_had_class[33], g_class, g_MaxPlayers

public plugin_init()
{
Register_SafetyFunc()

register_touch(TRAP_CLASSNAME, "player", "fw_TrapTouch")
register_think(TRAP_CLASSNAME, "fw_TrapThink")

register_forward(FM_CmdStart, "fw_CmdStart")	
register_forward(FM_EmitSound, "fw_EmitSound")	

g_MaxPlayers = get_maxplayers()
g_class = zb5_register_zclass("Heavy Zombie", "\y(Make Trap)^n", 0, 1, 0, 8000, 1, 0)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

for(i = 0; i < sizeof(ZombieModel); i++)
PrecacheModel(ZombieModel[i])		
}

public zp_fw_round_new()
{
g_Count = 0	
remove_entity_name(TRAP_CLASSNAME)
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

cs_set_player_model(id, "ZB5_Heavy")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Heavy.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
set_weapon_anim(id, 3)
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
if(g_Count < 4)
{	
set_fov(id, 110)
Create_Trap(id)
++g_Count
} 
if(g_Count == 4) 
client_print(id, print_center, "4 Traps Avaliable, Please Wait !!!")	
}

Create_Trap(id)
{	
static ent; ent = create_entity("info_target")
if(!is_valid_ent(ent)) 
return 

static Float:Origin[3]; 
entity_get_vector(id, EV_VEC_origin, Origin)
entity_set_origin(ent, Origin)
	
entity_set_string(ent, EV_SZ_classname, TRAP_CLASSNAME)
entity_set_model(ent, ZombieModel[2])

entity_set_int(ent,EV_INT_movetype, MOVETYPE_PUSHSTEP)
entity_set_int(ent,EV_INT_solid, SOLID_TRIGGER)

entity_set_float(ent, EV_FL_gravity, 1.0)
set_entity_anim(ent, 0)

entity_set_edict(ent, EV_ENT_owner, id)
entity_set_int(ent, EV_INT_iuser1, 0)
entity_set_int(ent, EV_INT_iuser2, 0)
entity_set_float(ent, EV_FL_fuser1, get_gametime() + 50.0)

entity_set_vector(ent,EV_VEC_mins, Float:{-20.0, -20.0, -0.0})
entity_set_vector(ent,EV_VEC_maxs, Float:{20.0, 20.0, 30.0})
drop_to_floor(ent)

set_rendering(ent, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 100)
EmitSound(id, CHAN_AUTO, ZombieSound[2])
set_fov(id)

entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01)
}
public fw_TrapTouch(ent, id)
{
if(!is_valid_ent(ent) || !is_alive(id))
return
if(is_zombie(id))
return
if(entity_get_int(ent, EV_INT_iuser1))
return

entity_set_int(ent, EV_INT_iuser1, 1)
entity_set_int(ent, EV_INT_iuser2, id)
entity_set_float(ent, EV_FL_fuser2, get_gametime() + 10.0)

static Float:Origin[3];
entity_get_vector(id, EV_VEC_origin, Origin); Origin[2] -= 26.0
entity_set_origin(ent, Origin)

// Trap
Trap_User(id)
EmitSound(ent, CHAN_AUTO, ZombieSound[3])

set_rendering(ent)
set_entity_anim(ent, 1)
}

public fw_TrapThink(ent)
{
if(!is_valid_ent(ent))
return

static id; id = entity_get_int(ent, EV_INT_iuser2)

if(!entity_get_int(ent, EV_INT_iuser1))
{
static Float:Time1; Time1 = entity_get_float(ent, EV_FL_fuser1)
if(Time1 < get_gametime())
{
--g_Count	
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)
entity_set_int(ent, EV_INT_flags, FL_KILLME)
return
} 

static Target; Target = FindClosetEnemy(ent)

if(is_alive(Target))
{
static Float:Origin[3]; entity_get_vector(Target, EV_VEC_origin, Origin)
hook_ent2(ent, Origin, 50.0)
}
} else {
static Float:Time2; Time2 = entity_get_float(ent, EV_FL_fuser2)
if(Time2 < get_gametime())
{
if(is_alive(id) && !is_zombie(id))
Release_Player(id)

--g_Count
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)
entity_set_int(ent, EV_INT_flags, FL_KILLME)
return
} else {

if(!is_alive(id) || (is_alive(id) && is_zombie(id)))
{
--g_Count	
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)
entity_set_int(ent, EV_INT_flags, FL_KILLME)
return
} 
else if(is_alive(id) && !is_zombie(id)) 
{
cs_reset_player_maxspeed(id)	
cs_set_player_maxspeed_auto(id, 0.1)
set_pev(id, pev_gravity, 10.0)	
}
}
}

entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01)
}
public Trap_User(id)
{
if(!is_alive(id))
return
if(is_zombie(id))
return	

cs_reset_player_maxspeed(id)	
cs_set_player_maxspeed_auto(id, 0.1)
set_pev(id, pev_gravity, 10.0)	

zb5_AddTofull_Icon(id, 220.0, 0.5, 10.0, "sprites/ZB5/trap.spr", 1)
Make_ScreenShake(id, 1, 1, 1)
}

public Release_Player(id)
{
zb5_reset_hspeed(id)
set_pev(id, pev_gravity, 0.9)	
}
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if(!is_alive(id))
return FMRES_IGNORED; 
if(!is_zombie(id))
return FMRES_IGNORED; 
if(!g_had_class[id])
return FMRES_IGNORED; 

if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, ZombieSound[random_num(0, 1)], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, ZombieSound[4], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
return FMRES_IGNORED 
} 
///////////// STOCK ///////////////////


stock FindClosetEnemy(ent)
{
static indexid; indexid = 0	
static Float:current_dis; current_dis = 4980.0

for(new i = 0; i <= g_MaxPlayers; i++)
{
if((is_alive(i) && !is_zombie(i)) && entity_range(ent, i) < current_dis)
{
current_dis = entity_range(ent, i)
indexid = i
}			
}	

return indexid
}

stock hook_ent2(ent, Float:VicOrigin[3], Float:speed)
{
static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time

pev(ent, pev_origin, EntOrigin)

distance_f = get_distance_f(EntOrigin, VicOrigin)
fl_Time = distance_f / speed

fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
}


/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
public zb5_zclass_remove_post(id)g_had_class[id] = false

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
g_had_class[id] = false
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
g_had_class[id] = false
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
{
Set_BitVar(g_IsZombie, id)

if(g_had_class[id])	
Get_Class(id)
}else g_had_class[id] = false
}
public zp_fw_core_cure_post(id)
{
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
if(g_had_class[id])	
Create_Trap(id)	
	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)

if(g_had_class[id])	
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

