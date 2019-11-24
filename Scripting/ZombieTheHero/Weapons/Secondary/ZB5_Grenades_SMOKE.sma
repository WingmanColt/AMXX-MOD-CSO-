#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define CSW_BASE CSW_SMOKEGRENADE
#define weapon_base "weapon_smokegrenade"

// CONFUSED
#define TASK_REMOVE_ILLUSION 2015
#define TASK_CONFUSED_SPR 2016

new const sound[][] =
{
"ZB5/weapons/pump_exp.wav",
"ZB5/weapons/Zombi_Bomb_exp.wav"
}
new const models[][] =
{
"models/ZB5/Grenades/v_pumpkin.mdl",
"models/ZB5/Grenades/v_zombibomb.mdl"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud41.spr",		
"sprites/ZB5/HUD2/640hud49.spr",

"sprites/weapon_knockbomb_MSBG.txt",
"sprites/weapon_pumpkin_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_knockbomb_MSBG",
"weapon_pumpkin_MSBG"
}

const PEV_NADE_TYPE = pev_iuser2
const PEV_FLARE_DURATION = pev_flSwimTime

enum Weapons
{
INVALID = 0,
CONFUSSION,	
FLARE,
JUMP
}
enum _:Options
{
CONFUSING,
FAKE,		
Old
}


new Weapons:g_had[33], g_had2[33][Options], ef_sprite[3], g_maxplayers
new g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33], g_MsgSpr
public plugin_init() 
{
if(!zb5_weapons_secondary())
return;
		
Register_SafetyFunc()	
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
register_forward(FM_SetModel, "fw_SetModel")

RegisterHam(Ham_Think, "grenade", "fw_Think")
RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)

g_MsgSpr = get_user_msgid("WeaponList")
g_maxplayers = get_maxplayers()
}
public plugin_precache()
{
new i	
for(i = 0; i < sizeof(models); i++)
PrecacheModel(models[i])
for(i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])
for(i = 0; i < sizeof(sprites); i++)
PrecacheGeneric(sprites[i])	
for(i = 0; i < sizeof(generic_spr); i++)
register_clcmd(generic_spr[i], "Hook_SPR")

PrecacheModel("sprites/ZB5/zb_confuse.spr")

ef_sprite[0] = PrecacheModel("sprites/ZB5/deimosexp.spr")
ef_sprite[1] = PrecacheModel("sprites/ZB5/zombiebomb_exp.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/_trail_1.spr")			
}
public plugin_natives()
{
register_native("get_weapon_grenade_smoke", "Give_Grenade", 1)	
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}
public Give_Grenade(id, Item)
{
if(!zb5_weapons_secondary())
return;
	
arrayset(_:g_had[id], false, sizeof(g_had[]))
fm_give_item(id, weapon_base)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

switch(Item)
{
case 1:
{
g_had[id] = JUMP
SPR(id,  generic_spr[0])
}
case 2:
{
g_had[id] = CONFUSSION
SPR(id,  generic_spr[0])
}
case 3:
{
g_had[id] = FLARE
SPR(id,  generic_spr[1])
}
}

if(zb5_had_DoubleGrenade(id))
cs_set_user_bpammo(id, CSW_BASE, 2)
	
Hook_SPR(id)
Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_BASE)
}

public Reset_Vars(id)
{
remove_task(id+TASK_REMOVE_ILLUSION)	
remove_task(id+TASK_CONFUSED_SPR)	

arrayset(_:g_had[id], false, sizeof(g_had[]))
arrayset(g_had2[id], false, sizeof(g_had2[]))
}

public Deploy_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static id; id = get_pdata_cbase(Ent, 41, 4)
if(!is_player(id, 1))
return

static SubModel

switch(g_had[id])
{	
case JUMP:
{
SubModel = 7
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_zombibomb.mdl")
}
case CONFUSSION:
{
SubModel = 7
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_zombibomb.mdl")
}
case FLARE:
{
SubModel = 18
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_pumpkin.mdl")
}
}
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
public Event_CurWeapon(id)
{
if(!is_player(id, 1))
return

static CSWID; CSWID = get_player_weapon(id)

static Weapons:had
had = g_had[id] 

if((CSWID == CSW_BASE && g_had2[id][Old] != CSW_BASE) && had != INVALID)
Draw_NewWeapon(id, CSWID)

else if((CSWID == CSW_BASE && g_had2[id][Old] == CSW_BASE) && had != INVALID) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent))
{
g_had2[id][Old] = get_player_weapon(id)
return
}
} 

else if(CSWID != CSW_BASE && g_had2[id][Old] == CSW_BASE) 
Draw_NewWeapon(id, CSWID)

g_had2[id][Old] = get_player_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
if(!is_player(id, 1))
return	

static Weapons:had
had = g_had[id] 

static ent; ent = fm_get_user_weapon_entity(id, CSW_BASE)

if(CSW_ID == CSW_BASE)
{
if(is_valid_ent(ent) && had != INVALID)
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

static Submodel, Sequence;

switch(g_had[id])
{
case JUMP:
{
Submodel = 7;Sequence = 6	
}
case CONFUSSION:
{
Submodel = 7;Sequence = 6
}
case FLARE:
{
Submodel = 18;Sequence = 17
}
}

engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)	
}
} else {
if(is_valid_ent(ent)) 
set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 			
}
}

public fw_SetModel(ent, const Model[])
{
if(!is_valid_ent(ent))
return FMRES_IGNORED

static Float:dmgtime
pev(ent, pev_dmgtime, dmgtime)

static id; id = pev(ent, pev_owner)
static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))

if(!equal(Model, "models/w_smokegrenade.mdl"))
return FMRES_IGNORED;	

if (dmgtime == 0.0)
return FMRES_IGNORED;	

switch(g_had[id])
{	
case JUMP:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 7 - 1)
set_pev(ent, PEV_NADE_TYPE, JUMP)
return FMRES_SUPERCEDE
}
case CONFUSSION:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 7 - 1)
set_pev(ent, PEV_NADE_TYPE, CONFUSSION)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(ef_sprite[2]) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(200) // r
write_byte(100) // g
write_byte(50) // b
write_byte(100) // brightness
message_end()
return FMRES_SUPERCEDE
}
case FLARE:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 9 - 1)
set_pev(ent, PEV_NADE_TYPE, FLARE)

fm_set_rendering(ent, kRenderFxGlowShell, 180, 160, 80, kRenderNormal, 16);
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(ef_sprite[2]) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(180) // r
write_byte(160) // g
write_byte(80) // b
write_byte(100) // brightness
message_end()
return FMRES_SUPERCEDE
}
}

return FMRES_IGNORED	
}

public fw_Think(entity)
{
if (!is_valid_ent(entity)) 
return HAM_IGNORED;

static Float:dmgtime, Float:current_time, duration

pev(entity, pev_dmgtime, dmgtime)
duration = pev(entity, PEV_FLARE_DURATION)
current_time = get_gametime()

if (dmgtime > current_time)
return HAM_IGNORED;

static impulse; impulse = pev(entity, PEV_NADE_TYPE)
switch(impulse)
{
case JUMP:
{
explode2(entity, 0)
return HAM_SUPERCEDE;
}
case CONFUSSION:
{
explode2(entity, 1)
return HAM_SUPERCEDE;
}
case FLARE:
{
if (duration > 0)
{
if (duration == 1)
{
engfunc(EngFunc_RemoveEntity, entity)
return HAM_SUPERCEDE;
}
fm_set_rendering(entity, kRenderFxGlowShell, 180, 160, 80, kRenderNormal, 16);
flare_lighting(entity, duration)
set_pev(entity, PEV_FLARE_DURATION, --duration)
set_pev(entity, pev_dmgtime, current_time + 2.0)
}
else if ((pev(entity, pev_flags) & FL_ONGROUND) && fm_get_speed(entity) < 10)
{
emit_sound(entity, CHAN_AUTO, "ZB5/weapons/pump_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
set_pev(entity, PEV_FLARE_DURATION, 1 + 150/2)
set_pev(entity, pev_dmgtime, current_time + 0.1)
static Float:originF[3]
pev(entity, pev_origin, originF)
}
else
{
set_pev(entity, pev_dmgtime, current_time + 0.5)
}
}
}
return HAM_IGNORED;
}
public explode2(ent, Mode)
{
if (!is_valid_ent(ent)) 
return;

static Float:Origin[3]
pev(ent, pev_origin, Origin)

switch(Mode)
{
case 0:
{	
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 16.0)
write_short(ef_sprite[1])
write_byte(30)
write_byte(20)
write_byte(14)
message_end()

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_PARTICLEBURST) // TE id
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 16.0)
write_short(40) // radius
write_byte(0) // color
write_byte(2) // duration (will be randomized a bit)
message_end()

EmitSound(ent, CHAN_AUTO, "ZB5/weapons/Zombi_Bomb_exp.wav")

static Float:MaxKB
for(new i = 0; i < g_maxplayers; i++)
{
if(!is_player(i, 1))
continue
if(entity_range(ent, i) > float(300))
continue

MaxKB = float(1200) - (entity_range(ent, i) * (float(1000) / float(300)))
HookEnt(i, Origin, MaxKB)

if(!Get_BitVar(g_IsZombie, i))
{
Make_ScreenShake(i, 5, 2, 5)	
ExecuteHamB(Ham_TakeDamage, i, 0, i, 10.0, DMG_SLASH)
	
static Float:Angles[3]
pev(i, pev_v_angle, Angles)

Angles[0] += random_float(-50.0, 50.0)
Angles[0] = float(clamp(floatround(Angles[0]), -180, 180))

Angles[1] += random_float(-50.0, 50.0)
Angles[1] = float(clamp(floatround(Angles[1]), -180, 180))

set_pev(i, pev_fixangle, 1)
set_pev(i, pev_v_angle, Angles)
}

}
}
case 1:
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 16.0)
write_short(ef_sprite[0])
write_byte(20)	// scale in 0.1's
write_byte(30)	// framerate
write_byte(TE_DECALHIGH|TE_EXPLFLAG_NOSOUND)// flags
message_end()  

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_PARTICLEBURST) // TE id
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 16.0)
write_short(30) // radius
write_byte(0) // color
write_byte(1) // duration (will be randomized a bit)
message_end()

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, Origin[0]) // x
engfunc(EngFunc_WriteCoord, Origin[1]) // y
engfunc(EngFunc_WriteCoord, Origin[2]) // z
write_byte(20) // radius	
write_byte(100); // r
write_byte(200); // g
write_byte(0); // b
write_byte(2) //life
write_byte(1) //decay rate
message_end()

EmitSound(ent, CHAN_AUTO, "ZB5/weapons/Zombi_Bomb_exp.wav")

static Float:PlayerOrigin[3]
for(new i = 0; i < g_maxplayers; i++)
{
if(!is_player(i, 1))
continue
if(Get_BitVar(g_IsZombie, i))
continue
if(g_had2[i][CONFUSING])
continue	

pev(i, pev_origin, PlayerOrigin)
if(get_distance_f(Origin, PlayerOrigin) > 200.0)
continue

g_had2[i][CONFUSING] = true
zb5_AddTofull_Icon(i, 220.0, 0.5, 10.0, "sprites/ZB5/zb_confuse.spr", 6)

remove_task(i+TASK_CONFUSED_SPR)
set_task(0.5, "makespr", i+TASK_CONFUSED_SPR)

remove_task(i+TASK_REMOVE_ILLUSION)
set_task(10.0, "remove_confuse", i+TASK_REMOVE_ILLUSION)	
}
}
}

engfunc(EngFunc_RemoveEntity, ent)
}

flare_lighting(entity, duration)
{
if(!is_valid_ent(entity))
return;	

static Float:origin[3]
pev(entity, pev_origin, origin)

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
write_byte(TE_DLIGHT) // TE id
engfunc(EngFunc_WriteCoord, origin[0]) // x
engfunc(EngFunc_WriteCoord, origin[1]) // y
engfunc(EngFunc_WriteCoord, origin[2]) // z
write_byte(20) // radius	
write_byte(180) // r
write_byte(160) // g
write_byte(80) // b
write_byte(21) //life
write_byte((duration < 2) ? 3 : 0) //decay rate
message_end()
}

public makespr(id)
{
id -= TASK_CONFUSED_SPR

if(!is_player(id, 1))
return

Make_ScreenShake(id, 3, 1, 3)
Make_ScreenFade(id, 0.1, 0, 0, 0, 250, FADE_IN)

remove_task(id+TASK_CONFUSED_SPR)
set_task(0.7, "makespr", id+TASK_CONFUSED_SPR)
}

public remove_confuse(id)
{
id -= TASK_REMOVE_ILLUSION
if(!is_player(id, 1))
return

g_had2[id][CONFUSING] = false
remove_task(id+TASK_CONFUSED_SPR)
}
// STOCKS
stock HookEnt(ent, Float:VicOrigin[3], Float:speed)
{
static Float:fl_Velocity[3]
static Float:EntOrigin[3]

pev(ent, pev_origin, EntOrigin)
static Float:distance_f
distance_f = get_distance_f(EntOrigin, VicOrigin)

static Float:fl_Time; fl_Time = distance_f / speed

fl_Velocity[0] = ((EntOrigin[0] - VicOrigin[0]) / fl_Time) * 1.5
fl_Velocity[1] = ((EntOrigin[1] - VicOrigin[1]) / fl_Time) * 1.5
fl_Velocity[2] = (EntOrigin[2] - VicOrigin[2]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
}

// SPR
SPR(id, const name[])
{
message_begin(MSG_ONE, g_MsgSpr, {0,0,0}, id)
write_string(name) 
write_byte(13)
write_byte(1)
write_byte(-1)
write_byte(-1)
write_byte(3)
write_byte(3)
write_byte(9)
write_byte(24)
message_end()	
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_putinserver(id)Safety_Connected(id)
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_weapon_remove_post(id)Reset_Vars(id)

Register_SafetyFunc()
{
register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")

RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
Reset_Vars(id)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
Reset_Vars(id)
}

public Safety_CurWeapon(id)
{
if(!Get_BitVar(g_IsAlive, id))
return

static CSW; CSW = read_data(2)
if(g_PlayerWeapon[id] != CSW) g_PlayerWeapon[id] = CSW
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

Reset_Vars(id)
ham_strip_weapon(id, weapon_base)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_Vars(id)
ham_strip_weapon(id, weapon_base)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_Vars(id)
ham_strip_weapon(id, weapon_base)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsAlive, id)
Set_BitVar(g_IsZombie, id)
Reset_Vars(id)
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}

return 1
}
public get_player_weapon(id)
{
if(!Get_BitVar(g_IsAlive, id))
return 0

return g_PlayerWeapon[id]
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/

