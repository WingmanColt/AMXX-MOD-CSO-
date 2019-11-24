#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define CSW_BASE CSW_FLASHBANG
#define weapon_base "weapon_flashbang"

// FROST 
#define TASK_FROST_REMOVE 100 
#define ID_FROST_REMOVE (taskid - TASK_FROST_REMOVE) 

new const sound[][] =
{
"ZB5/weapons/frost_exp.wav",
"ZB5/weapons/holywater_explosion.wav",
}
new const models[][] =
{
"models/ZB5/Grenades/v_holybomb.mdl",
"models/ZB5/Grenades/v_fgrenade2.mdl",
"sprites/ZB5/holybomb_burn.spr"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud61.spr",
"sprites/weapon_holybomb_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_firebomb_MSBG",
"weapon_holybomb_MSBG"
}

const PEV_NADE_TYPE = pev_iuser1

enum Weapons
{
INVALID = 0,	
HOLY,
FROST
}
enum _:Options
{
Float:DURATION,
FROZEN,
ICE,	
Old
}


new Weapons:g_had[33], g_had2[33][Options], ef_sprite[5], g_MsgSpr
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame 
public plugin_init() 
{
if(!zb5_weapons_secondary())
return;
		
Register_SafetyFunc()	
	
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
register_forward(FM_SetModel, "fw_SetModel")

RegisterHam(Ham_Think, "grenade", "fw_Think")
RegisterHam(Ham_Touch, "grenade", "fw_Touch", 1)

RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)
RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeed_Post", 1)

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

ef_sprite[0] = PrecacheModel("sprites/ZB5/holy_explode.spr")
ef_sprite[1] = PrecacheModel("sprites/ZB5/frost_ex2.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/frost_trail.spr")	
ef_sprite[3] = PrecacheModel("models/glassgibs.mdl")	
ef_sprite[4] = PrecacheModel("sprites/ZB5/_trail_1.spr")			
}
public plugin_natives()
{
register_native("get_weapon_grenade_flash", "Give_Grenade", 1)	
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}	
public zp_fw_round_new()
{
remove_entity_name("ice_cube")
}
public Give_Grenade(id, Item)
{
if(!zb5_weapons_secondary())
return;
	
Reset_Vars(id, 1)
	
fm_give_item(id, weapon_base)
cs_set_user_bpammo(id, CSW_BASE, zb5_had_DoubleGrenade(id) ? 2:1)	

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

switch(Item)
{
case 1:
{
g_had[id] = HOLY
SPR(id,  generic_spr[1])
}
case 2:
{
g_had[id] = FROST
SPR(id,  generic_spr[0])
}
}

Hook_SPR(id)
Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_BASE)
}

public Reset_Vars(id, all)
{
if(all)	
arrayset(_:g_had[id], false, sizeof(g_had[]))

arrayset(g_had2[id], false, sizeof(g_had2[]))
ice_entity(id, 0)
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
case HOLY:
{
SubModel = 6
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_holybomb.mdl")
}
case FROST:
{
SubModel = 6
set_pev(id, pev_viewmodel2, "models/ZB5/Grenades/v_fgrenade2.mdl")
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
case HOLY:
{
Submodel = 8;Sequence = 7	
}
case FROST:
{
Submodel = 27;Sequence = 5	
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

static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))
if(equal(Model, "models/w_flashbang.mdl"))
{
static id; id = pev(ent, pev_owner)

switch(g_had[id])
{	
case HOLY:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 6 - 1)
set_pev(ent, PEV_NADE_TYPE, HOLY)

//set_pev(ent, pev_iuser1, id)
set_pev(ent, pev_dmgtime, get_gametime()+9999999.0)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(ef_sprite[4]) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(50) // r
write_byte(150) // g
write_byte(200) // b
write_byte(200) // brightness
message_end()

return FMRES_SUPERCEDE
}
case FROST:
{
engfunc(EngFunc_SetModel, ent, W_Model2)	
set_pev(ent, pev_body, 4 - 1)
set_pev(ent, PEV_NADE_TYPE, FROST)
set_pev(ent, pev_dmgtime, get_gametime()+9999999.0)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(ef_sprite[2]) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(50) // r
write_byte(150) // g
write_byte(200) // b
write_byte(200) // brightness
message_end()

return FMRES_SUPERCEDE
}
}
}
return FMRES_IGNORED	
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
case HOLY:
{
explode(entity, 0)
return HAM_SUPERCEDE;
}
case FROST:
{
explode(entity, 1)
return HAM_SUPERCEDE;
}
}
return HAM_IGNORED;
}
public fw_Touch(ent, id)
{
if (!is_valid_ent(ent)) 
return HAM_IGNORED;

static impulse; impulse = pev(ent, PEV_NADE_TYPE)
switch(impulse)
{
case HOLY:
{
explode(ent, 0)
return HAM_SUPERCEDE;
}
case FROST:
{
explode(ent, 1)
return HAM_SUPERCEDE;
}
}
return HAM_IGNORED;
}
// HE GRENADE
public explode(ent, Mode)
{
if (!is_valid_ent(ent)) 
return;

static Owner; Owner = pev(ent, pev_owner)	
static Float:PlayerOrigin[3]

static Float:origin[3]
pev(ent, pev_origin, origin)

static ExpFlag; ExpFlag = 0
ExpFlag |= 2
ExpFlag |= 4
ExpFlag |= 8
ExpFlag |= TE_DECALHIGH

switch(Mode)
{
case 0:
{	
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, origin[0])
engfunc(EngFunc_WriteCoord, origin[1])
engfunc(EngFunc_WriteCoord, origin[2] + 35.0)
write_short(ef_sprite[0])
write_byte(40)	// scale in 0.1's
write_byte(25)	// framerate
write_byte(ExpFlag)	// flags
message_end()  

emit_sound(ent, CHAN_WEAPON, "ZB5/weapons/holywater_explosion.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Dlight(ent, 20, 0, 150, 240, 5, 15)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, 150.0)) != 0)
{	
if(!is_valid_ent(Victim))
continue	

do_attack(Owner, Victim, 0, 500.0, 1)
}
if(!zbs_is_scenario())
{
for(new i = 0; i < get_maxplayers(); i++)
{
if (!Get_BitVar(g_IsZombie, i))
continue;
	
pev(i, pev_origin, PlayerOrigin)
if(get_distance_f(origin, PlayerOrigin) > 150.0)
continue

Make_ScreenShake(i, 4, 3, 4)
zb5_make_burn(i, Owner, 4.0, 0.7, "sprites/ZB5/holybomb_burn.spr")	
}
}
}
case 1:
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, origin[0])
engfunc(EngFunc_WriteCoord, origin[1])
engfunc(EngFunc_WriteCoord, origin[2] + 35.0)
write_short(ef_sprite[1])
write_byte(40)	// scale in 0.1's
write_byte(25)	// framerate
write_byte(ExpFlag)	// flags
message_end()  

Make_Dlight(ent, 20, 0, 150, 240, 5, 15)
emit_sound(ent, CHAN_WEAPON, "ZB5/weapons/frost_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

for(new i = 0; i < get_maxplayers(); i++)
{
if (!Get_BitVar(g_IsZombie, i))
continue;
	
pev(i, pev_origin, PlayerOrigin)
if(get_distance_f(origin, PlayerOrigin) > 150.0)
continue
	
set_freeze(i) 	
}
}
}
engfunc(EngFunc_RemoveEntity, ent)
}

// FROST SYSTEM
set_freeze(victim) 
{ 	
if (g_had2[victim][FROZEN]) 
return; 
	
if (!Get_BitVar(g_IsZombie, victim))
return; 

g_had2[victim][FROZEN] = true

zb5_set_user_nvg(victim, 0, 0, 0, 1)
ice_entity(victim, 1)	

Make_ScreenFade(victim, 4.0, 0, 0, 200, 200, FADE_STAYOUT)
ExecuteHamB(Ham_Player_ResetMaxSpeed, victim) 

if(task_exists(victim+TASK_FROST_REMOVE))remove_task(victim+TASK_FROST_REMOVE)
set_task(4.0, "remove_freeze", victim+TASK_FROST_REMOVE) 
} 
public remove_freeze(taskid) 
{ 
g_had2[ID_FROST_REMOVE][FROZEN] = false
ExecuteHamB(Ham_Player_ResetMaxSpeed, ID_FROST_REMOVE) 

zb5_set_user_nvg(ID_FROST_REMOVE, 1, 1, 0, 1)
ice_entity(ID_FROST_REMOVE, 0)

// Get player's origin 
static origin[3] 
get_user_origin(ID_FROST_REMOVE, origin) 

// Glass shatter 
message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
write_byte(TE_BREAKMODEL) // TE id 
write_coord(origin[0]) // x 
write_coord(origin[1]) // y 
write_coord(origin[2]+24) // z 
write_coord(16) // size x 
write_coord(16) // size y 
write_coord(16) // size z 
write_coord(random_num(-50, 50)) // velocity x 
write_coord(random_num(-50, 50)) // velocity y 
write_coord(25) // velocity z 
write_byte(10) // random velocity 
write_short(ef_sprite[3]) // model 
write_byte(10) // count 
write_byte(25) // life 
write_byte(0x01) // flags 
message_end() 
} 
// Ham Trace Attack Forward
public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], trace, damage_type)
{
// Non-player damage or self damage
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

// Block damage while frozen, as it makes killing zombies too easy
if (g_had2[victim][FROZEN])
return HAM_SUPERCEDE;

return HAM_IGNORED;
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
// Non-player damage or self damage
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

// Block damage while frozen, as it makes killing zombies too easy
if (g_had2[victim][FROZEN])
return HAM_SUPERCEDE;

return HAM_IGNORED;
}
public fw_ResetMaxSpeed_Post(id) 
{ 
// Dead or not frozen 
if (!is_user_alive(id) || !g_had2[id][FROZEN]) 
return; 

// Prevent from moving 
fm_set_user_maxspeed(id, 1.0) 
} 

stock ice_entity(id, status) 
{
if(status)
{
static ent, Float:o[3]
if(!Get_BitVar(g_IsZombie, id))
{
ice_entity(id, 0)
return
}

if(is_valid_ent(g_had2[id][ICE]))
{
if((g_had2[id][ICE], pev_iuser3) != id)
{
if(!Get_BitVar(g_IsZombie, id)) 
remove_entity(g_had2[id][ICE])
}
else
{
pev(id, pev_origin, o)
if(pev(id, pev_flags) & FL_DUCKING ) 
o[2] -= 15.0
else 
o[2] -= 35.0
entity_set_origin(g_had2[id][ICE], o)
return
}
}

pev(id,pev_origin, o)
o[2] -= 35.0

ent = create_entity("info_target")
g_had2[id][ICE] = ent

set_pev( ent, pev_classname, "ice_cube")
entity_set_model(ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")

set_pev(ent, pev_body, 3 - 1)
set_pev(ent, pev_sequence, 1)

entity_set_int(ent,EV_INT_movetype, MOVETYPE_NONE)
entity_set_int(ent,EV_INT_solid, SOLID_BBOX)

dllfunc(DLLFunc_Spawn, ent)
entity_set_origin(ent, o)

set_pev( ent, pev_iuser3, id )
set_pev( ent, pev_team, 6969 )

entity_set_size(ent, Float:{ -3.0, -3.0, -3.0 }, Float:{ 3.0, 3.0, 3.0 } )
set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 255)
}
else
{
if(is_valid_ent(g_had2[id][ICE]))
{
remove_entity(g_had2[id][ICE])
g_had2[id][ICE] = -1
}
}
}
// SPR
SPR(id, const name[])
{
message_begin(MSG_ONE, g_MsgSpr, {0,0,0}, id)
write_string(name) 
write_byte(11)
write_byte(2)
write_byte(-1)
write_byte(-1)
write_byte(3)
write_byte(2)
write_byte(25)
write_byte(24)
message_end()		
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_weapon_remove_post(id)Reset_Vars(id, 1)

public client_putinserver(id)
{
Safety_Connected(id)

if(!g_HamBot && is_user_bot(id))
{
g_HamBot = 1
set_task(0.1, "Register_SafetyFuncBot", id)
}
}

Register_SafetyFunc()
{
register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")

RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

public Register_SafetyFuncBot(id)
{
RegisterHamFromEntity(Ham_Spawn, id, "fw_Safety_Spawn_Post", 1)
RegisterHamFromEntity(Ham_Killed, id, "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0

Reset_Vars(id, 1)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0

Reset_Vars(id, 1)
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
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

Reset_Vars(id, 0)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_Vars(id, 0)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_Vars(id, 1)
ham_strip_weapon(id, weapon_base)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)

Reset_Vars(id, 1)
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(Get_BitVar(g_IsZombie, id))
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
