#include <amxmodx>
#include <ZombieMod5>

#define DEVICE_CLASSNAME "demonic_spirit"

new const ZombieSound2[][] =
{
"ZB5/zombi_hurt_01.wav",
"ZB5/zombi_hurt_02.wav",

"ZB5/zombi_death_1.wav", 
"ZB5/zombi_death_2.wav"
}

new const ZombieSound[][] =
{
"ZB5/Zombie/voodoo_device_activate.wav",
"ZB5/Zombie/voodoo_device_loop.wav",

"ZB5/zombie_heal_male.wav",
"ZB5/zombie_heal_female.wav"
}
new const ZombieModel[][] =
{	
"models/ZB5/Claws/v_ZB5_Healer2.mdl",
"models/ZB5/Items/demonic_spirit.mdl",
"sprites/ZB5/zb_restore_health.spr",
"sprites/ZB5/zb_restore_health3.spr"
}

new g_IsZombie, g_IsAlive, g_IsConnected
new g_had_class[33], g_class, g_MaxPlayers

public plugin_init()
{	
Register_SafetyFunc()
	
register_think(DEVICE_CLASSNAME, "fw_DeviceThink")
register_touch(DEVICE_CLASSNAME, "player", "fw_DeviceTouch")	
register_forward(FM_EmitSound, "fw_EmitSound")	

g_MaxPlayers = get_maxplayers()
g_class = zb5_register_zclass("Voodoo", "\y(Recovery & Device)", 0, 0, 2, 7000, 1, 1)
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
remove_entity_name(DEVICE_CLASSNAME)	
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

cs_set_player_model(id, "ZB5_Regular_NEW")
set_pev(id, pev_body, 3 -1)

cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Healer2.mdl")
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
case SKILL_Q:Do_Skill2(id)
}
}
public Do_Skill(id)
{		
static Float:originF[3]
pev(id, pev_origin, originF)

static Float:PlayerOrigin[3]
for(new i = 1; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue 
if(!zp_core_is_zombie(i))
continue
	
pev(i, pev_origin, PlayerOrigin)
if(get_distance_f(originF, PlayerOrigin) > 200.0)
continue

if(i == id)
{
Make_Elight(id, 10, 10, 200, 10, 15, 15)	
zb5_AddTofull_Icon(id, 220.0, 1.5, 2.3, "sprites/ZB5/zb_restore_health.spr", 24)
}else zb5_AddTofull_Icon(i, 220.0, 0.8, 3.0, "sprites/ZB5/zb_restore_health3.spr", 20)

fm_set_user_health(i, clamp(get_user_health(i) + 1000, 1, zb5_get_zombie_info(i, MAXHEALTH)))
fm_set_user_armor(i, clamp(get_user_armor(i) + 100, 1, 900))

if(!zb5_get_user_nvg(i))
Make_ScreenFade(i, 1.0, 10, 200, 10, 50, FADE_IN)

EmitSound(i, CHAN_AUTO, zb5_get_zombie_info(i, FEMALE) ? ZombieSound[3] : ZombieSound[2])
}
}

/// SKILL 2 ///
public Do_Skill2(id)
{
static iEnt; iEnt = find_ent_by_class(0, DEVICE_CLASSNAME) 
if(is_valid_ent(iEnt))
{	
client_print(id, print_center, "Already spawned Heal Arena !")	
return;
}else Create_EvilDevice(id)
}

public Create_EvilDevice(id)
{	
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent)) 
return

entity_set_string(Ent,EV_SZ_classname, DEVICE_CLASSNAME)
entity_set_model(Ent, ZombieModel[1])

entity_set_int(Ent,EV_INT_movetype, MOVETYPE_PUSHSTEP)
entity_set_int(Ent,EV_INT_solid, SOLID_TRIGGER)
entity_set_float(Ent, EV_FL_gravity, 1.0)

entity_set_int(Ent, EV_INT_iuser1, 0);
entity_set_edict(Ent, EV_ENT_owner, id);
entity_set_float(Ent, EV_FL_fuser1, get_gametime() + 20.0)

entity_set_vector(Ent, EV_VEC_mins, Float:{-10.0, -10.0, 0.0})
entity_set_vector(Ent, EV_VEC_maxs, Float:{10.0, 10.0, 16.0})

static Float:Origin[3]; get_position(id, 48.0, 0.0, 0.0, Origin)
entity_set_origin(Ent, Origin)

EmitSound(Ent, CHAN_AUTO, ZombieSound[0])
entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.5) 
}

public fw_DeviceThink(Ent)
{
if(!is_valid_ent(Ent)) 
return

if(!entity_get_int(Ent, EV_INT_iuser1))
{
entity_set_int(Ent, EV_INT_iuser1, 1)

entity_set_vector(Ent, EV_VEC_mins, Float:{-160.0, -160.0, 0.0})
entity_set_vector(Ent, EV_VEC_maxs, Float:{160.0, 160.0, 64.0})

entity_set_float(Ent, EV_FL_animtime, get_gametime())
entity_set_float(Ent, EV_FL_framerate, 1.0)
entity_set_int(Ent, EV_INT_sequence, 1)
}

static Float:Time; Time = entity_get_float(Ent, EV_FL_fuser1)
if(Time < get_gametime())
{
entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.1)
entity_set_int(Ent, EV_INT_flags, FL_KILLME)
return
} 

static Float:Time2; Time2 = entity_get_float(Ent, EV_FL_fuser2)
if(get_gametime() - 5.0 > Time2)
{
EmitSound(Ent, CHAN_ITEM, ZombieSound[1])
entity_set_float(Ent, EV_FL_fuser2, get_gametime())
} 

entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.1) 
}

public fw_DeviceTouch(Ent, id)
{
if(!is_valid_ent(Ent)) 
return	
if(!is_alive(id))
return 
if(!is_zombie(id))
return

static Float:HealTime_1, Float:HealTime_2
if(get_gametime() - 1.0 > HealTime_1)
{
fm_set_user_health(id, clamp(get_user_health(id) + 500, 1, zb5_get_zombie_info(id, MAXHEALTH)))
fm_set_user_armor(id, clamp(get_user_armor(id) + 50, 1, 900))
HealTime_1 = get_gametime()
}

if(get_gametime() - 3.0 > HealTime_2)
{
if(!zb5_get_user_nvg(id))	
Make_ScreenFade(id, 1.0, 10, 200, 10, 50, FADE_IN)
EmitSound(id, CHAN_ITEM, zb5_get_zombie_info(id, FEMALE) ? ZombieSound[3] : ZombieSound[2])
HealTime_2 = get_gametime()
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
if(!g_had_class[id])
return FMRES_IGNORED; 

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
}

Safety_Disconnected(id)
{
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
