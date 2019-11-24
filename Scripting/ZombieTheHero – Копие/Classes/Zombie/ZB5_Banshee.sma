#include <amxmodx>
#include <ZombieMod5>

#define TASK_REMOVE_ILLUSION 2015
#define TASK_CONFUSED_SPR 2016

#define CONFUSSION_CLASSNAME "conf_bomb"
#define BAT_CLASSNAME "witchbat"

new const ZombieSound[][] =
{
"ZB5/zombi_hurt_banshee_1.wav", 
"ZB5/zombi_death_banshee_1.wav",  

"ZB5/zombi_banshee_laugh.wav",
"ZB5/zombi_banshee_pulling_fire.wav",
"ZB5/zombi_banshee_pulling_fail.wav"

}
new const ZombieModel[][] =
{	
"models/player/ZB5_Banshee/ZB5_Banshee.mdl",
"models/ZB5/Claws/v_ZB5_Banshee.mdl"
}

enum _:Options
{
CLASS,
CONFUSING
}

new g_had[33][Options], g_MyBat[33], ef_sprite[2]
new g_class, g_MaxPlayers
new g_IsZombie, g_IsAlive, g_IsConnected

public plugin_init()
{
Register_SafetyFunc()
register_forward(FM_EmitSound, "fw_EmitSound")		
	
register_think(BAT_CLASSNAME, "fw_BatThink")
register_think(CONFUSSION_CLASSNAME, "fw_BombThink")

register_touch(BAT_CLASSNAME, "*", "fw_BatTouch")
register_touch(CONFUSSION_CLASSNAME, "*", "fw_BombTouch")

g_MaxPlayers = get_maxplayers()
g_class = zb5_register_zclass("Banshee", "\y(Bats & Confussion)^n", 0, 1, 3, 6500, 1, 1)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

for(i = 0; i < sizeof(ZombieModel); i++)
PrecacheModel(ZombieModel[i])	

ef_sprite[0] = PrecacheModel("sprites/ZB5/ef_bat.spr")	
ef_sprite[1] = PrecacheModel("sprites/ZB5/zombiebomb_exp.spr")
}
public zp_fw_round_new()
{
remove_entity_name(BAT_CLASSNAME)	
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

cs_set_player_model(id, "ZB5_Banshee")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Banshee.mdl")
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

set_weapons_timeidle(id, CSW_KNIFE, 360.0)
set_player_nextattack(id, 360.0)

set_fov(id, 120)
set_weapon_anim(id, 2)
set_pdata_string(id, (492) * 4, "bat", -1 , 20)

EmitSound(id, CHAN_ITEM, ZombieSound[2])
set_task(1.0, "Summon_Bat", id)
}
public Do_Skill2(id)
{	
set_weapon_anim(id, 8)

set_player_nextattack(id, 0.5)
set_weapons_timeidle(id, CSW_KNIFE, 0.5)
set_pdata_string(id, (492) * 4, "grenade", -1 , 20)

set_fov(id, 100)
Create_Bomb(id)
}
public zb5_zombieskill_reset(id, SkillButton)
{
if(!is_zombie(id))
return
	
switch(SkillButton)
{
case SKILL_E:Reset_Skill(id)
case SKILL_Q:Reset_Skill2(id)	
}	
}
public Reset_Skill(id)
{
if(pev_valid(g_MyBat[id])) Bat_Explosion(g_MyBat[id])
g_MyBat[id] = -1

set_pdata_string(id, (492) * 4, "knife", -1 , 20)
create_fake_attack(id, "knife")

set_player_nextattack(id, 0.25)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_weapon_anim(id, 3)
set_fov(id)
}
public Reset_Skill2(id)
{
set_fov(id)	
set_pdata_string(id, (492) * 4, "knife", -1 , 20)

set_player_nextattack(id, 0.25)
set_weapons_timeidle(id, CSW_KNIFE, 0.25)
}


public Summon_Bat(id)
{
// check
static Float:Origin[3], Float:Angles[3], Float:Vel[3]

pev(id, pev_v_angle, Angles)
Angles[0] *= -1.0
get_position(id, 48.0, 0.0, -6.0, Origin)
VelocityByAim(id, 500, Vel)

// create ent
static Bat; Bat = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Bat)) return

g_MyBat[id] = Bat

set_pev(Bat, pev_classname, BAT_CLASSNAME)
engfunc(EngFunc_SetModel, Bat, "models/ZB5/Items/ZB5_Items_NEW.mdl")
set_pev(Bat, pev_body, 12 - 1)
set_entity_anim(Bat, 11)

set_pev(Bat, pev_mins, Float:{-10.0, -10.0, 0.0})
set_pev(Bat, pev_maxs, Float:{10.0, 10.0, 6.0})

set_pev(Bat, pev_origin, Origin)
set_pev(Bat, pev_fuser2, 7.0)

set_pev(Bat, pev_movetype, MOVETYPE_FLY)
set_pev(Bat, pev_gravity, 0.01)

set_pev(Bat, pev_velocity, Vel)
set_pev(Bat, pev_owner, id)
set_pev(Bat, pev_angles, Angles)
set_pev(Bat, pev_solid, SOLID_TRIGGER)		//store the enitty id

set_pev(Bat, pev_iuser1, 0)
set_pev(Bat, pev_iuser2, 0)

set_pev(Bat, pev_nextthink, get_gametime() + 0.1)
emit_sound(Bat, CHAN_BODY, ZombieSound[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public fw_BatThink(Ent)
{
if(!pev_valid(Ent))
return

static id; id = pev(Ent, pev_owner)
if(!is_alive(id) || !is_zombie(id))
{
Bat_Explosion(Ent)
return
}

static Found, Target, Owner
Found = pev(Ent, pev_iuser1)
Target = pev(Ent, pev_iuser2)
Owner = pev(Ent, pev_owner)

if(Found)
{
if(!is_alive(Target) && is_zombie(id))
{
Bat_Explosion(Ent)
Reset_Skill(Owner)
return
} else {
if(entity_range(id, Target) > 36.0)
{
static Float:Origin[3]; pev(id, pev_origin, Origin)
hook_ent2(Target, Origin, 200.0)
} else {
static Float:Origin[3]; pev(Target, pev_origin, Origin)
set_pev(Ent, pev_origin, Origin)
Reset_Skill(Owner)
Bat_Explosion(Ent)
return
}
}

} else {
static Victim; Victim = FindClosetEnemy(Ent, 1)
if(is_alive(Victim) && entity_range(Victim, Ent) <= 240.0)
{
static Float:Origin[3]; pev(Victim, pev_origin, Origin)

hook_ent2(Ent, Origin, float(400))
Aim_To(Ent, Origin, 2.0, 0)
}
}

if(get_gametime() - 1.0 > pev(Ent, pev_fuser1))
{
set_pev(Ent, pev_fuser2, pev(Ent, pev_fuser2) - 1.0)
set_pev(Ent, pev_fuser1, get_gametime())
}

if(pev(Ent, pev_fuser2) <= 0.0)
{
Reset_Skill(Owner)		
Bat_Explosion(Ent)
return
}

set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
}

public fw_BatTouch(Ent, id)
{
if(!pev_valid(Ent))
return
if(pev(Ent, pev_iuser1))
return

static Float:Origin[3]; pev(Ent, pev_origin, Origin)
static Owner; Owner = pev(Ent, pev_owner)

if(is_alive(id) && !is_zombie(id))
{
set_pev(Ent, pev_iuser1, 1)
set_pev(Ent, pev_iuser2, id)
set_pev(Ent, pev_aiment, id)
} else {
Reset_Skill(Owner)
Bat_Explosion(Ent)
}
}

public Bat_Explosion(Ent)
{
static Float:Origin[3]; pev(Ent, pev_origin, Origin)

// create effect
message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_EXPLOSION) // TE_EXPLOSION
write_coord_f(Origin[0]) // origin x
write_coord_f(Origin[1]) // origin y
write_coord_f(Origin[2]); // origin z
write_short(ef_sprite[0]) // sprites
write_byte(20) // scale in 0.1's
write_byte(20) // framerate
write_byte(14) // flags 
message_end() // message end

EmitSound(Ent, CHAN_BODY, ZombieSound[4])

// Check Owner
static id; id = pev(Ent, pev_owner)

// Shit
set_pev(Ent, pev_nextthink, get_gametime() + 0.05)
set_pev(Ent, pev_flags, FL_KILLME)

// Do
if(!is_alive(id) && !is_zombie(id) && !g_had[id][CLASS])
{
set_pev(Ent, pev_nextthink, get_gametime() + 0.05)
set_pev(Ent, pev_flags, FL_KILLME)
}
}
/// SKILL 2 ///
public Create_Bomb(id)
{
static Float:StartOrigin[3], Float:Angles[3], Float:Velocity[3]

pev(id, pev_v_angle, Angles)
Angles[0] *= -1.0
get_position(id, 48.0, 0.0, 0.0, StartOrigin)
velocity_by_aim(id, 800, Velocity)

static ent; ent = create_entity("info_target")
if(!pev_valid(ent))
return;

set_pev(ent, pev_classname, CONFUSSION_CLASSNAME)

engfunc(EngFunc_SetModel, ent, W_Model2)
set_pev(ent, pev_body, 7 - 1)

set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0})
set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0})

set_pev(ent, pev_origin, StartOrigin)
set_pev(ent, pev_angles, Angles)

set_pev(ent, pev_movetype, MOVETYPE_TOSS)
set_pev(ent, pev_solid, SOLID_BBOX)

set_pev(ent, pev_velocity, Velocity)
set_pev(ent, pev_owner, id)
set_pev(ent, pev_gravity, 0.01)

set_pev(ent, pev_nextthink, get_gametime() + 0.05)	
}
public fw_BombThink(Ent)
{
if(!pev_valid(Ent))
return;

static id; id = pev(Ent, pev_owner)

if(!is_alive(id) || !is_zombie(id) || entity_range(Ent, id) >= 400)
{
static Float:Origin[3]
pev(Ent, pev_origin, Origin)
Shock_Explosion(Ent, Origin)

set_weapon_anim(id, 3)
set_pdata_string(id, (492) * 4, "knife", -1 , 20)

set_pev(Ent, pev_nextthink, get_gametime() + 0.05)
set_pev(Ent, pev_flags, FL_KILLME)

return
}

set_pev(Ent, pev_nextthink, get_gametime() + 0.05)	
}

public fw_BombTouch(Ent, id)
{
if(!pev_valid(Ent))
return

static Float:Origin[3]; 
pev(Ent, pev_origin, Origin)

Shock_Explosion(Ent, Origin)

for(new i = 0; i < g_MaxPlayers; i++)
{
if(!is_alive(i))
continue
if(is_zombie(i))
continue
if(entity_range(Ent, i) > 240.0)
continue

Make_ScreenShake(i, 5, 5, 5)
g_had[i][CONFUSING] = true
zb5_AddTofull_Icon(i, 220.0, 0.5, 10.0, "sprites/ZB5/zb_confuse.spr", 6)

if(task_exists(id+TASK_CONFUSED_SPR))remove_task(id+TASK_CONFUSED_SPR)
set_task(0.5, "makespr", id+TASK_CONFUSED_SPR)

if(task_exists(id+TASK_REMOVE_ILLUSION))remove_task(id+TASK_REMOVE_ILLUSION)
set_task(10.0, "remove_confuse", id+TASK_REMOVE_ILLUSION)
}

set_pev(Ent, pev_nextthink, get_gametime() + 0.05)
set_pev(Ent, pev_flags, FL_KILLME)
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
write_short(ef_sprite[1]) // sprites
write_byte(20) // scale in 0.1's
write_byte(30) // framerate
write_byte(14) // flags 
message_end() // message end

engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_PARTICLEBURST) // TE id
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 16.0)
write_short(30) // radius
write_byte(0) // color
write_byte(1) // duration (will be randomized a bit)
message_end()
}
public makespr(id)
{
id -= TASK_CONFUSED_SPR

if(!is_alive(id) || is_zombie(id))
return

Make_ScreenFade(id, 0.1, 0, 0, 0, 250, FADE_STAYOUT)

remove_task(id+TASK_CONFUSED_SPR)
set_task(0.7, "makespr", id+TASK_CONFUSED_SPR)
}

public remove_confuse(id)
{
id -= TASK_REMOVE_ILLUSION

g_had[id][CONFUSING] = false
remove_task(id+TASK_CONFUSED_SPR)
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

if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, ZombieSound[0], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, ZombieSound[1], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
return FMRES_IGNORED 
} 

stock hook_ent2(ent, Float:VicOrigin[3], Float:speed)
{
static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time

pev(ent, pev_origin, EntOrigin)

distance_f = get_distance_f(EntOrigin, VicOrigin)
fl_Time = distance_f / speed

fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
}
public Aim_To(iEnt, Float:vTargetOrigin[3], Float:flSpeed, Style)
{
if(!pev_valid(iEnt))	
return

if(!Style)
{
static Float:Vec[3], Float:Angles[3]
pev(iEnt, pev_origin, Vec)

Vec[0] = vTargetOrigin[0] - Vec[0]
Vec[1] = vTargetOrigin[1] - Vec[1]
Vec[2] = vTargetOrigin[2] - Vec[2]
engfunc(EngFunc_VecToAngles, Vec, Angles)
Angles[0] = Angles[2] = 0.0 

set_pev(iEnt, pev_v_angle, Angles)
set_pev(iEnt, pev_angles, Angles)
} else {
new Float:f1, Float:f2, Float:fAngles, Float:vOrigin[3], Float:vAim[3], Float:vAngles[3];
pev(iEnt, pev_origin, vOrigin);
xs_vec_sub(vTargetOrigin, vOrigin, vOrigin);
xs_vec_normalize(vOrigin, vAim);
vector_to_angle(vAim, vAim);

if (vAim[1] > 180.0) vAim[1] -= 360.0;
if (vAim[1] < -180.0) vAim[1] += 360.0;

fAngles = vAim[1];
pev(iEnt, pev_angles, vAngles);

if (vAngles[1] > fAngles)
{
f1 = vAngles[1] - fAngles;
f2 = 360.0 - vAngles[1] + fAngles;
if (f1 < f2)
{
vAngles[1] -= flSpeed;
vAngles[1] = floatmax(vAngles[1], fAngles);
}
else
{
vAngles[1] += flSpeed;
if (vAngles[1] > 180.0) vAngles[1] -= 360.0;
}
}
else
{
f1 = fAngles - vAngles[1];
f2 = 360.0 - fAngles + vAngles[1];
if (f1 < f2)
{
vAngles[1] += flSpeed;
vAngles[1] = floatmin(vAngles[1], fAngles);
}
else
{
vAngles[1] -= flSpeed;
if (vAngles[1] < -180.0) vAngles[1] += 360.0;
}		
}

set_pev(iEnt, pev_v_angle, vAngles)
set_pev(iEnt, pev_angles, vAngles)
}
}

public FindClosetEnemy(ent, can_see)
{
static indexid; indexid = 0	
static Float:current_dis; current_dis = 4960.0

for(new i = 1 ;i <= g_MaxPlayers; i++)
{
if(can_see)
{
if(is_user_alive(i) && !zp_core_is_zombie(i) && can_see_fm(ent, i) && entity_range(ent, i) < current_dis)
{
current_dis = entity_range(ent, i)
indexid = i
}
} else {
if(is_user_alive(i) && !zp_core_is_zombie(i) && entity_range(ent, i) < current_dis)
{
current_dis = entity_range(ent, i)
indexid = i
}			
}
}	

return indexid
}

public bool:can_see_fm(entindex1, entindex2)
{
if (!entindex1 || !entindex2)
return false

if (pev_valid(entindex1) && pev_valid(entindex1))
{
new flags = pev(entindex1, pev_flags)
if (flags & EF_NODRAW || flags & FL_NOTARGET)
{
return false
}

new Float:lookerOrig[3]
new Float:targetBaseOrig[3]
new Float:targetOrig[3]
new Float:temp[3]

pev(entindex1, pev_origin, lookerOrig)
pev(entindex1, pev_view_ofs, temp)
lookerOrig[0] += temp[0]
lookerOrig[1] += temp[1]
lookerOrig[2] += temp[2]

pev(entindex2, pev_origin, targetBaseOrig)
pev(entindex2, pev_view_ofs, temp)
targetOrig[0] = targetBaseOrig [0] + temp[0]
targetOrig[1] = targetBaseOrig [1] + temp[1]
targetOrig[2] = targetBaseOrig [2] + temp[2]

engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
{
return false
} 
else 
{
new Float:flFraction
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2]
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2] - 17.0
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
}
}
}
}
return false
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
