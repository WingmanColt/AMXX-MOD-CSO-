#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define CSW_BASE CSW_HEGRENADE
#define weapon_base "weapon_hegrenade"

new const sound[][] =
{
"ZB5/weapons/plasmabomb_exp.wav",
"ZB5/weapons/fire_explo.wav"
}
new const models[][] =
{
"models/ZB5/Grenades/v_chaingren.mdl",
"models/ZB5/Grenades/v_firebomb.mdl",
"models/ZB5/Grenades/v_plasma.mdl",
"sprites/ZB5/flame_burn01.spr",
"sprites/ZB5/extra_fire2.spr"
}
new const sprites[][] =
{
//"sprites/ZB5/HUD2/640hud36.spr", already prechached by svdex
"sprites/ZB5/HUD2/640hud112.spr",		
"sprites/ZB5/HUD2/640hud141.spr",

"sprites/weapon_firebomb_MSBG.txt",
"sprites/weapon_chain2_MSBG.txt",
"sprites/weapon_plasmabomb_MSBG.txt",
}
new const generic_spr[][] =
{
"weapon_firebomb_MSBG",
"weapon_chain2_MSBG",
"weapon_plasmabomb_MSBG"
}

const PEV_NADE_TYPE = pev_impulse
const PEV_FLARE_DURATION = pev_flSwimTime

const pev_entteam = pev_iuser2
const pev_victim = pev_iuser3
const pev_work = pev_iuser4
const pev_time = pev_fuser1

enum Weapons
{
INVALID = 0,	
HES,	
FIRE,
CHAIN,
PLASMA
}
enum _:Options
{	
Old
}

new Weapons:g_had[33], g_had2[33][Options], ef_sprite[9]
new g_IsConnected, g_IsAlive, g_PlayerWeapon[33], g_MsgSpr

public plugin_init()
{
if(!zb5_weapons_secondary())
return;
	
Register_SafetyFunc()	
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")

RegisterHam(Ham_Think, "grenade", "fw_Think")
RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)

register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_Touch, "fw_Touch")

g_MsgSpr = get_user_msgid("WeaponList")
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

ef_sprite[1] = PrecacheModel("sprites/ZB5/explosion_1.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/explosion_2.spr")	
ef_sprite[3] = PrecacheModel("sprites/ZB5/fire_explosion_gib.spr")	
ef_sprite[4] = PrecacheModel("sprites/ZB5/explodeup.spr")		
ef_sprite[5] = PrecacheModel("sprites/ZB5/svd_exp.spr")	
ef_sprite[6] = PrecacheModel("sprites/steam1.spr")
ef_sprite[7] = PrecacheModel("sprites/ZB5/blue_explosion.spr")	
ef_sprite[8] = PrecacheModel("sprites/ZB5/zerogxplode-big1.spr")					
}
public plugin_natives()
{
register_native("get_weapon_grenade_he", "Give_Grenade", 1)	
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
	
Reset_Vars(id)	
fm_give_item(id, weapon_base)

switch(Item)
{
case 1:
{
g_had[id] = HES
SPR(id, "weapon_hegrenade")
}
case 2:
{
g_had[id] = FIRE
SPR(id,  generic_spr[0])
}
case 3:
{
g_had[id] = PLASMA
SPR(id,  generic_spr[2])	
}
case 4:
{
g_had[id] = CHAIN
SPR(id,  generic_spr[1])
}
}

if(zb5_had_DoubleGrenade(id))
cs_set_user_bpammo(id, CSW_BASE, 2)	

Hook_SPR(id)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_BASE)
}

public Reset_Vars(id)
{
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
case HES:
{
set_pev(id, pev_viewmodel2, "models/v_hegrenade.mdl")
set_pev(id, pev_weaponmodel2, "models/p_hegrenade.mdl")
}	
case FIRE:
{
SubModel = 6
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_firebomb.mdl")
}
case PLASMA:
{
SubModel = 6
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_plasma.mdl")
}
case CHAIN:
{
SubModel = 6
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_chaingren.mdl")
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
static Weapons:had
had = g_had[id] 

static ent
ent = fm_get_user_weapon_entity(id, CSW_BASE)

if(CSW_ID == CSW_BASE)
{
if(is_valid_ent(ent) && had != INVALID)
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

static Submodel, Sequence;

switch(g_had[id])
{
case FIRE:
{
Submodel = 6;Sequence = 5	
}
case CHAIN:
{
Submodel = 6;Sequence = 5	
}
case PLASMA:
{
Submodel = 6;Sequence = 5	
}
}

engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)	

set_weapons_timeidle(id, CSW_BASE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)
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

static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))
if(equal(Model, "models/w_hegrenade.mdl"))
{
static id; id = pev(ent, pev_owner)

if(!is_player(id, 1))
return FMRES_IGNORED

switch(g_had[id])
{
case HES:
{
engfunc(EngFunc_SetModel, ent, "models/w_hegrenade.mdl")	
set_pev(ent, PEV_NADE_TYPE, HES)
return FMRES_SUPERCEDE
}	
case FIRE:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 5 - 1)
set_pev(ent, PEV_NADE_TYPE, FIRE)
return FMRES_SUPERCEDE
}
case CHAIN:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 17 - 1)
set_pev(ent, PEV_NADE_TYPE, CHAIN)
return FMRES_SUPERCEDE
}
case PLASMA:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 14 - 1)
set_pev(ent, pev_victim, 0)
set_pev(ent, PEV_NADE_TYPE, PLASMA)
return FMRES_SUPERCEDE
}
}
}
return FMRES_IGNORED	
}
public fw_Touch(Grenade, Target)
{
if(!is_valid_ent(Grenade))
return

static ClassName[32]; pev(Grenade, pev_classname, ClassName, sizeof(ClassName))
if(!equal(ClassName, "grenade"))
return

static impulse; impulse = pev(Grenade, PEV_NADE_TYPE)
switch(impulse)
{
case PLASMA:
{
if(is_user_alive(Target)) // Player
{
set_pev(Grenade, pev_movetype, MOVETYPE_FOLLOW)	
set_pev(Grenade, pev_aiment, Target)
set_pev(Grenade, pev_victim, Target)	
} else { // Wall
set_pev(Grenade, pev_movetype, MOVETYPE_NONE)
set_pev(Grenade, pev_velocity, {0.0, 0.0, 0.0})

set_pev(Grenade, pev_rendermode, kRenderTransAdd)
set_pev(Grenade, pev_renderfx, kRenderFxGlowShell)
set_pev(Grenade, pev_renderamt, 100.0)

}
}
}

}
public fw_Think(entity)
{
if (!is_valid_ent(entity)) 
return HAM_IGNORED;

static Float:dmgtime, Float:current_time

pev(entity, pev_dmgtime, dmgtime)
current_time = get_gametime()

if (dmgtime > current_time)
return HAM_IGNORED;

static impulse; impulse = pev(entity, PEV_NADE_TYPE)
switch(impulse)
{
case HES:
{
explode(entity, 2)
return HAM_SUPERCEDE;
}
case FIRE:
{
explode(entity, 2)
return HAM_SUPERCEDE;
}
case CHAIN:
{
chain_explode(entity)

set_task(0.5, "chain_explode", entity)
set_task(1.0, "chain_explode", entity)
set_task(2.0, "chain_remove", entity)

return HAM_SUPERCEDE;
}
case PLASMA:
{
explode(entity, 3)
return HAM_SUPERCEDE;
}
}
return HAM_IGNORED
}

// HE GRENADE
public explode(ent, Mode)
{
if (!is_valid_ent(ent)) 
return;

static Float:originF[3]
pev(ent, pev_origin, originF)

switch(Mode)
{
case 1:
{	
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]+30.0) // z axis
write_short(ef_sprite[7])
write_byte(70) // Scale
write_byte(35) // Frame
write_byte(TE_EXPLFLAG_NOADDITIVE)
message_end();	

Check_AttackDamge(ent, 200.0, 300.0)
}
case 2:
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]+30.0) // z axis
write_short(ef_sprite[1])
write_byte(70) // Scale
write_byte(35) // Frame
write_byte(TE_EXPLFLAG_NOSOUND)
message_end();	

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]) // z axis
write_short(ef_sprite[2])
write_byte(60) // Scale
write_byte(13) // Frame
write_byte(TE_EXPLFLAG_NOSOUND)
message_end();	

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_SPRITETRAIL) // TE ID
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]+70) // z axis
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]) // z axis
write_short(ef_sprite[3]) // Sprite Index
write_byte(80) // Count
write_byte(10) // Life
write_byte(3) // Scale
write_byte(50) // Velocity Along Vector
write_byte(10) // Rendomness of Velocity
message_end();

Make_Dlight(ent, 30, 250, 100, 10, 5, 10)
Check_AttackDamge(ent, 150.0, 400.0)

emit_sound(ent, CHAN_AUTO, "ZB5/weapons/fire_explo.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);	

if(!zbs_is_scenario())
{
static Owner; Owner = pev(ent, pev_owner)
	
static Float:PlayerOrigin[3]
for(new i = 0; i < get_maxplayers(); i++)
{
if(!is_user_alive(i))
continue
if(!zp_core_is_zombie(i))
continue
	
pev(i, pev_origin, PlayerOrigin)
if(get_distance_f(originF, PlayerOrigin) > 150.0)
continue

set_weapon_kick(Owner, i, 5000.0)
Make_ScreenShake(i, 4, 3, 4)
zb5_make_burn(i, Owner, 4.0, 0.7, "sprites/ZB5/flame_burn01.spr")	
}
}
}

case 3:
{
static ExpFlag; ExpFlag = 0
ExpFlag |= 2
ExpFlag |= 4
ExpFlag |= 8
ExpFlag |= TE_DECALHIGH

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]) // z axis
write_short(ef_sprite[7])
write_byte(70) // Scale
write_byte(35) // Frame
write_byte(ExpFlag)
message_end();	

Make_Dlight(ent, 30, 0, 50, 200, 2, 10)
Check_AttackDamge(ent, 300.0, 500.0)
emit_sound(ent, CHAN_AUTO, "ZB5/weapons/plasmabomb_exp.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
if(!zbs_is_scenario())
{		
static Target; Target = pev(ent, pev_victim)
if(is_valid_ent(Target))
{
static Float:Origin[3];
pev(Target, pev_origin, Origin)

Hook_Ent(ent, Origin, 200.0)
}
}
}
}
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_WORLDDECAL)
engfunc(EngFunc_WriteCoord, originF[0]) // x
engfunc(EngFunc_WriteCoord, originF[1]) // y
engfunc(EngFunc_WriteCoord, originF[2]) // z
write_byte(random_num(46, 48))
message_end()	

message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_SMOKE)
engfunc(EngFunc_WriteCoord, originF[0]) // x
engfunc(EngFunc_WriteCoord, originF[1]) // y
engfunc(EngFunc_WriteCoord, originF[2]) // z
write_short(ef_sprite[6]) // Sprite Index
write_byte(30)	// scale in 0.1's 
write_byte(10)	// framerate 
message_end()

engfunc(EngFunc_RemoveEntity, ent)
}
public chain_explode(ent)
{
if (!is_valid_ent(ent)) 
return;

static Float:originF[3]
pev(ent, pev_origin, originF)

message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]) // z axis
write_short(ef_sprite[4])
write_byte(50) // Scale
write_byte(25) // Frame
write_byte(0)
message_end();	

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_WORLDDECAL)
engfunc(EngFunc_WriteCoord, originF[0]) // x
engfunc(EngFunc_WriteCoord, originF[1]) // y
engfunc(EngFunc_WriteCoord, originF[2]) // z
write_byte(random_num(46, 48))
message_end()	

message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_SMOKE)
engfunc(EngFunc_WriteCoord, originF[0]) // x
engfunc(EngFunc_WriteCoord, originF[1]) // y
engfunc(EngFunc_WriteCoord, originF[2]) // z
write_short(ef_sprite[6]) // Sprite Index
write_byte(30)	// scale in 0.1's 
write_byte(10)	// framerate 
message_end()

static Float:Velocity[3]
Velocity[0] = random_float(200.0, 600.0)
Velocity[1] = random_float(0.0, 0.0)
Velocity[2] = random_float(100.0, 150.0)
set_pev(ent, pev_velocity, Velocity)

Check_AttackDamge(ent, 300.0, 600.0)
emit_sound(ent, CHAN_AUTO, "weapons/hegrenade-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);		
}
public chain_remove(ent)
{
if (!is_valid_ent(ent)) 
return;

engfunc(EngFunc_RemoveEntity, ent)	
}

public Check_AttackDamge(Ent, Float:Ratio, Float:ZombieDamage)
{	
if(!is_valid_ent(Ent))
return

static Attacker; Attacker = pev(Ent, pev_owner)
if(!is_player(Attacker, 0))
return	

static Float:origin[3]
pev(Ent, pev_origin, origin)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, Ratio)) != 0)
{
if(Attacker == Victim)
continue;

do_attack(Attacker, Victim, 0, ZombieDamage, 1)
}
}
stock Hook_Ent(ent, Float:VicOrigin[3], Float:speed)
{
if(!is_valid_ent(ent))
return

static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time

pev(ent, pev_origin, EntOrigin)
distance_f = get_distance_f(EntOrigin, VicOrigin)
fl_Time = distance_f / speed

fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
}
// SPR
SPR(id, const name[])
{
message_begin(MSG_ONE, g_MsgSpr, {0,0,0}, id)
write_string(name) 
write_byte(12)
write_byte(1)
write_byte(-1)
write_byte(-1)
write_byte(3)
write_byte(1)
write_byte(4)
write_byte(24)
message_end()		
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
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

g_PlayerWeapon[id] = 0
Reset_Vars(id)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)

g_PlayerWeapon[id] = 0
Reset_Vars(id)
}

public Safety_CurWeapon(id)
{
if(!is_player(id, 1))
return

static CSW; CSW = read_data(2)
if(g_PlayerWeapon[id] != CSW) g_PlayerWeapon[id] = CSW
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
Reset_Vars(id)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)	
Reset_Vars(id)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
	
Reset_Vars(id)
ham_strip_weapon(id, weapon_base)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

UnSet_BitVar(g_IsAlive, id)
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
if(!is_player(id, 1))
return 0

return g_PlayerWeapon[id]
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/

