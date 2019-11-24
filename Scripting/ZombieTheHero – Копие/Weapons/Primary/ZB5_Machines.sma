#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>
#include <infinitygame>

#define CSW_BASE CSW_M249
#define weapon_base "weapon_m249"

#define CLASSNAME_SCYTHE "scythe"
#define WEAPON_ANIMEXT_KNIFE "knife"
#define WEAPON_ANIMEXT_M134 "m134"

#define TASK_STOP 10132
#define TASK_M134_READY 10133
#define TASK_M134_CANCLICK 10134
#define TASK_M134_RELOADING 10135

#define READY_SPEED 100.0
#define FIRE_SPEED 50.0
#define NORMAL_SPEED 150.0
#define RELOAD_SPEED 70.0

new const sound[][] =
{
"ZB5/weapons/crow7-1.wav",
"ZB5/weapons/janus7-1.wav",	
"ZB5/weapons/janus7-2.wav",	
"ZB5/weapons/mg3-1.wav",
"ZB5/weapons/balrog7-1.wav",
"ZB5/weapons/thanatos7-1.wav",
"ZB5/weapons/thanatos7_scytheshoot.wav",
"ZB5/weapons/thanatos7_scythereload.wav",
"ZB5/weapons/sfmg-1.wav",
"ZB5/weapons/sfmg_changea.wav",
"ZB5/weapons/sfmg_changeb.wav",
"ZB5/weapons/skull8-1.wav",
"ZB5/weapons/skull8_knife1.wav",
"ZB5/weapons/skull8_knife2.wav",
"ZB5/weapons/m134ex-1.wav",
"ZB5/weapons/m134_spinup.wav",
"ZB5/weapons/m134_spindown.wav"
}
new const models[][] =
{	
"models/ZB5/Primary/v_crow7.mdl",
"models/ZB5/Primary/v_janus7.mdl",	
"models/ZB5/Primary/v_skull8.mdl",
"models/ZB5/Primary/v_mg3.mdl",
"models/ZB5/Primary/v_thantos7.mdl",
"models/ZB5/Primary/v_avalanche.mdl",
"models/ZB5/Primary/v_balrog7_2.mdl",
"models/ZB5/Primary/v_m134ex_new.mdl"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud2.spr",	
"sprites/ZB5/HUD2/640hud7.spr",
"sprites/ZB5/HUD2/640hud28.spr",
"sprites/ZB5/HUD2/640hud62.spr",
"sprites/ZB5/HUD2/640hud71.spr",	
"sprites/ZB5/HUD2/640hud76.spr",	
"sprites/ZB5/HUD2/640hud89.spr",
"sprites/ZB5/HUD2/640hud91.spr",		
"sprites/ZB5/HUD2/640hud117.spr",
"sprites/weapon_balrog7_MSBG.txt",
"sprites/weapon_avalanche_MSBG.txt",
"sprites/weapon_mg3_MSBG.txt",
"sprites/weapon_skull8_MSBG.txt",
"sprites/weapon_thanatos7_MSBG.txt",
"sprites/weapon_janus7_MSBG.txt",
"sprites/weapon_crow7_MSBG.txt",
"sprites/weapon_m134ex_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_balrog7_MSBG",
"weapon_avalanche_MSBG",
"weapon_mg3_MSBG.",
"weapon_skull8_MSBG",
"weapon_thanatos7_MSBG",
"weapon_janus7_MSBG",
"weapon_crow7_MSBG",
"weapon_m134ex_MSBG"
}
enum _:HitType
{
HIT_NOTHING = 0,
HIT_ENEMY,
HIT_WALL
}
enum Weapons
{
INVALID = 0,	
M134Hero,
Balrog7,
MG3,
Skull8,
Thanatos7,
Avalanche,
Crow7,
Janus7
}
enum _:Options
{	
Float:ATTACK1,	
CAN_SHOOT,	
TMPCLIP,
RELOAD,
SHOTS,
MODE,
Old
}
enum _:M134EX
{
CANCLICK,
ATTACK,
RELOAD,
READY,
SHOOT
}
enum 
{	
MODE_A,
MODE_B,
MODE_S
}
new Weapons:g_had[33], g_had2[33][Options], g_special[33][M134EX], ef_sprite[5], g_weapon[8]

new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]
public plugin_init()
{
if(!zb5_weapons_primary())
return
	
Register_SafetyFunc()	
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")	

register_touch(CLASSNAME_SCYTHE, "*", "fw_Touch")
register_think(CLASSNAME_SCYTHE, "fw_Think")

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_item_addtoplayer", 1)
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_WeaponIdle_Post", 1)
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload_Post", 1);

RegisterHam(Ham_Item_PostFrame, weapon_base, "Frame")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload")
RegisterHam(Ham_TakeDamage, "player", "fw_takedmg")

register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")

g_weapon[0] = zb5_register_weapon("MG3", "Rheinmetall", WPN_MACHINES, LEVEL_MG3, 0)
g_weapon[1] = zb5_register_weapon("SKULL8", "Machine", WPN_MACHINES, LEVEL_SKULL8, 0)
g_weapon[2] = zb5_register_weapon("SFMG", "Avalanche", WPN_MACHINES, LEVEL_SFMG, 0)
g_weapon[3] = zb5_register_weapon("Crow 7", "Predator", WPN_MACHINES, LEVEL_CROW7, 0)
g_weapon[4] = zb5_register_weapon("Balrog-VII", "Machine", WPN_MACHINES, LEVEL_BALROG7, 0)
g_weapon[5] = zb5_register_weapon("Thanatos7", "Machine", WPN_MACHINES, LEVEL_THANATOS7, 0)
g_weapon[6] = zb5_register_weapon("Janus7", "Machine", WPN_MACHINES, LEVEL_JANUS7, 0)
g_weapon[7] = zb5_register_weapon("M134", "Predator", WPN_MACHINES, LEVEL_M134Hero, 0)
}

public plugin_precache()
{	
PrecacheModel("sprites/ZB5/muz_sfmg.spr")	
ef_sprite[0] = PrecacheModel("sprites/ZB5/muz_balrog7.spr")
ef_sprite[1] = PrecacheModel("sprites/ZB5/setrum_garis.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/muzzleflash6.spr")	
ef_sprite[3] = PrecacheModel("sprites/ZB5/muzzleflash7.spr")	
ef_sprite[4] = PrecacheModel("sprites/ZB5/ef_balrog1.spr")

new i
for(i = 0; i < sizeof(models); i++)
PrecacheModel(models[i])
for(i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])
for(i = 0; i < sizeof(sprites); i++)
PrecacheGeneric(sprites[i])
for(i = 0; i < sizeof(generic_spr); i++)
register_clcmd(generic_spr[i], "Hook_SPR")
}
public plugin_natives()
{
register_native("get_weapon_machine", "Get_Machine", 1)
register_native("remove_all_machines", "Reset_All", 1)
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}


public zb5_weapon_selected_post(id, wpnid)
{	
if(wpnid == g_weapon[0]) Get_Machine(id, 2)
else if(wpnid == g_weapon[1]) Get_Machine(id, 5)
else if(wpnid == g_weapon[2]) Get_Machine(id, 4)
else if(wpnid == g_weapon[3]) Get_Machine(id, 6)
else if(wpnid == g_weapon[4]) Get_Machine(id, 1)
else if(wpnid == g_weapon[5]) Get_Machine(id, 3)
else if(wpnid == g_weapon[6]) Get_Machine(id, 7)
else if(wpnid == g_weapon[7]) Get_Machine(id, 8)
}
public Get_Machine(id, Machine)
{
if(!zb5_weapons_primary())
return
			
drop_weapons(id, 1)
remove_weapon_chainsaw(id, 1)
Reset_All(id, 1, 1)

fm_give_item(id, weapon_base)	

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) 
return

switch(Machine)
{
case 1: 
{
g_had[id] = Balrog7
cs_set_weapon_ammo(Ent, 120)
SPR(id, "weapon_balrog7_MSBG")
}
case 2: 
{
g_had[id] = MG3
cs_set_weapon_ammo(Ent, 200)
SPR(id, "weapon_mg3_MSBG")
}
case 3: 
{
g_had[id] = Thanatos7
cs_set_weapon_ammo(Ent, 120)
SPR(id, "weapon_thanatos7_MSBG")
}
case 4: 
{
g_had[id] = Avalanche
cs_set_weapon_ammo(Ent, 200)
SPR(id, "weapon_avalanche_MSBG")
}
case 5: 
{
g_had[id] = Skull8
cs_set_weapon_ammo(Ent, 120)
SPR(id, "weapon_skull8_MSBG")
}
case 6: 
{
g_had[id] = Crow7
cs_set_weapon_ammo(Ent, 100)
SPR(id, "weapon_crow7_MSBG")
}
case 7: 
{
g_had[id] = Janus7
cs_set_weapon_ammo(Ent, 200)
SPR(id, "weapon_janus7_MSBG")
}
case 8: 
{
g_had[id] = M134Hero
cs_set_weapon_ammo(Ent, 200)
SPR(id, "weapon_m134ex_MSBG")
}
}	

Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_BASE)	
zp_fw_restock_ammo(id)
}

public zp_fw_restock_ammo(id)
{	
static Weapons:had 	
had  = g_had[id]	

if(had == INVALID) 
return;

cs_set_user_bpammo(id, CSW_BASE, zb5_had_StrongLife(id) ? 250 : 200)
}
public Reset_All(id, RM134, All)
{
arrayset(g_had2[id], false, sizeof(g_had2[]))	

if(RM134)
{
if(!All)	
Remove_M134(id, 0)
else
Remove_M134(id, 1)
}

if(All)
arrayset(_:g_had[id], false, sizeof(g_had[]))	
}
public Remove_M134(id, full)
{
if(full)
g_had[id] = INVALID	

remove_task(id+TASK_M134_CANCLICK)
remove_task(id+TASK_M134_RELOADING)
remove_task(id+TASK_M134_READY)
remove_task(id+TASK_STOP)

zb5_reset_hspeed(id)
arrayset(g_special[id], false, sizeof(g_special[]))
}
public Deploy_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static id; id = get_pdata_cbase(Ent, 41, 4)
if(!is_player(id, 1))
return
	
static Weapons:had
had = g_had[id] 

if(had == INVALID)
return;

static SubModel

switch(had)
{
case Balrog7:
{
SubModel = 16

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_balrog7_2.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)	
}
case MG3:
{
SubModel = 15

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_mg3.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)		
}
case Thanatos7:
{
SubModel = 10

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_thantos7.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
case Avalanche:
{
SubModel = 14

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_avalanche.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)		
}
case Skull8:
{
SubModel = 0

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_skull8.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)		
}
case Crow7:
{
SubModel = 25

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_crow7.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
case Janus7:
{
SubModel = 26

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_janus7.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
case M134Hero:
{
SubModel = 20

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_m134ex_new.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
}
}
public Event_CurWeapon(id)
{
if(!is_player(id, 1))
return

static CSWID; CSWID = get_player_weapon(id)
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)

static Weapons:had
had = g_had[id] 

if((CSWID == CSW_BASE && g_had2[id][Old] != CSW_BASE) && had != INVALID)
{
Draw_NewWeapon(id, CSWID)
}
else if((CSWID == CSW_BASE && g_had2[id][Old] == CSW_BASE) && had != INVALID) 
{
if(!is_valid_ent(Ent))
{
g_had2[id][Old] = get_player_weapon(id)
return
}

switch(had)
{
case Avalanche:
{
if(g_had2[id][MODE] == MODE_B)
{
if(!is_valid_ent(Ent)) 
return

set_pdata_float(Ent, 46, 0.07, 4)
set_pdata_float(Ent, 47, 0.07, 4)	
}
}
case M134Hero:
{
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_M134, -1 , 20)

if(g_special[id][ATTACK] || g_special[id][SHOOT])
set_pev(id, pev_maxspeed, FIRE_SPEED)
else set_pev(id, pev_maxspeed, NORMAL_SPEED)
}
}

} 
g_had2[id][Old] = get_player_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
if(!is_player(id, 1))
return
	
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

switch(had)
{
case Balrog7:
{
Submodel = 16;Sequence = 15	
engfunc(EngFunc_SetModel, ent, P_Model2)	
}
case MG3:
{
Submodel = 15;Sequence = 14
engfunc(EngFunc_SetModel, ent, P_Model2)		
}
case Thanatos7:
{
set_weapon_anim(id, !g_had2[id][MODE] ? 11 : 12)

Submodel = 10;Sequence = 19
engfunc(EngFunc_SetModel, ent, P_Model)
}
case Avalanche:
{
IG_Muzzleflash_Set(id, !g_had2[id][MODE] ? "sprites/ZB5/muz_sfmg.spr" : "sprites/ZB5/muzzleflash16.spr", 0.20)
set_weapon_anim(id, !g_had2[id][MODE] ? 2 : 8)

Submodel = 14;Sequence = 13
engfunc(EngFunc_SetModel, ent, P_Model2)		
}
case Skull8:
{
set_weapon_anim(id, 4)

Submodel = 0;Sequence = 0
engfunc(EngFunc_SetModel, ent, P_Model2)		
}
case Crow7:
{
set_weapon_anim(id, 6)

Submodel = 25;Sequence = 24
engfunc(EngFunc_SetModel, ent, P_Model)
}
case Janus7:
{
switch(g_had2[id][MODE])
{
case MODE_A:set_weapon_anim(id, 2)
case MODE_B:set_weapon_anim(id, 8)	
case MODE_S:set_weapon_anim(id, 14)
}
	
Submodel = 26;Sequence = 25
engfunc(EngFunc_SetModel, ent, P_Model)
}
case M134Hero:
{
Remove_M134(id, 0)

Submodel = 20;Sequence = 17
engfunc(EngFunc_SetModel, ent, P_Model)
set_pev(id, pev_maxspeed, NORMAL_SPEED)
}
}

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

public fw_SetModel(entity, model[])
{
if(!is_valid_ent(entity))
return FMRES_IGNORED;

static szClassName[33]
pev(entity, pev_classname, szClassName, charsmax(szClassName))

if(!equal(szClassName, "weaponbox"))
return FMRES_IGNORED;

static id; id = pev(entity, pev_owner)

if(!equal(model, "models/w_m249.mdl"))
return FMRES_IGNORED;

static weapon; weapon = fm_find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

static Weapons:had 	
had  = g_had[id]	

switch(had)
{
case Balrog7:
{
set_pev(weapon, pev_impulse, Balrog7)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 3 - 1)
Reset_All(id, 0, 1)		
return FMRES_SUPERCEDE
}
case MG3:
{
set_pev(weapon, pev_impulse, MG3)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 9 - 1)
Reset_All(id, 0, 1)			
return FMRES_SUPERCEDE
}
case Thanatos7:
{
set_pev(weapon, pev_impulse, Thanatos7)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 26 - 1)
Reset_All(id, 0, 1)	
return FMRES_SUPERCEDE
}
case Skull8:
{
set_pev(weapon, pev_impulse, Skull8)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 20 - 1)
Reset_All(id, 0, 1)			
return FMRES_SUPERCEDE
}
case Avalanche:
{
set_pev(weapon, pev_impulse, Avalanche)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 23 - 1)
Reset_All(id, 0, 1)	
return FMRES_SUPERCEDE
}
case Crow7:
{
set_pev(weapon, pev_impulse, Crow7)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 13 - 1)
Reset_All(id, 0, 1)			
return FMRES_SUPERCEDE
}
case Janus7:
{
set_pev(weapon, pev_impulse, Janus7)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 18 - 1)
Reset_All(id, 0, 1)		
return FMRES_SUPERCEDE
}
case M134Hero:
{
set_pev(weapon, pev_impulse, M134Hero)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 22 - 1)
Reset_All(id, 1, 1)		
return FMRES_SUPERCEDE
}
}
return FMRES_IGNORED;
}

public fw_item_addtoplayer(ent, id)
{
if(!is_valid_ent(ent))
return 

static impulse; impulse = pev(ent, pev_impulse)
switch(impulse)
{
case Balrog7:
{
Reset_All(id, 0, 1)	

g_had[id] = Balrog7	
SPR(id, "weapon_balrog7_MSBG")

set_pev(ent, pev_impulse, 0)
}
case MG3:
{	
Reset_All(id, 0, 1)

g_had[id] = MG3
SPR(id, "weapon_mg3_MSBG")

set_pev(ent, pev_impulse, 0)
}
case Thanatos7:
{
Reset_All(id, 0, 1)	

g_had[id] = Thanatos7	
SPR(id, "weapon_thanatos7_MSBG")

set_pev(ent, pev_impulse, 0)
}
case Skull8:
{
Reset_All(id, 0, 1)	

g_had[id] = Skull8
SPR(id, "weapon_skull8_MSBG")

set_pev(ent, pev_impulse, 0)
}
case Avalanche:
{
Reset_All(id, 0, 1)

g_had[id] = Avalanche
SPR(id, "weapon_avalanche_MSBG")

set_pev(ent, pev_impulse, 0)
}
case Crow7:
{	
Reset_All(id, 0, 1)	

g_had[id] = Crow7
SPR(id, "weapon_crow7_MSBG")

set_pev(ent, pev_impulse, 0)
}
case Janus7:
{	
Reset_All(id, 0, 1)	

g_had[id] = Janus7
SPR(id, "weapon_janus7_MSBG")

set_pev(ent, pev_impulse, 0)
}
case M134Hero:
{	
Reset_All(id, 1, 1)

g_had[id] = M134Hero
SPR(id, "weapon_m134ex_MSBG")

set_pev(ent, pev_impulse, 0)
}
}
}

public fw_WeaponIdle_Post(weapon)
{
if(!is_valid_ent(weapon))
return HAM_IGNORED

static id; id = get_pdata_cbase(weapon, 41, 4)

if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_BASE || had == INVALID)
return HAM_IGNORED

static Float:get_idle 
get_idle = get_pdata_float(weapon, m_flTimeWeaponIdle)

if(get_idle > 10.0)
{
switch(had)
{
case Janus7:
{	
switch(g_had2[id][MODE])
{
case MODE_A:set_weapon_anim(id, 0)
case MODE_B:set_weapon_anim(id, 7)	
case MODE_S:set_weapon_anim(id, 12)
}
}	
case Avalanche:set_weapon_anim(id, !g_had2[id][MODE] ? 0 : 6)
case Thanatos7:set_weapon_anim(id, !g_had2[id][MODE] ? 0 : 2)
}
}
return HAM_IGNORED
}
public fw_takedmg(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_player(attacker, 1))
return HAM_IGNORED
if (damage_type & (1<<24))
return HAM_IGNORED;

static Weapons:had 	
had  = g_had[attacker]	

if(get_user_weapon(attacker) != CSW_BASE || had == INVALID)	
return HAM_IGNORED;

static target, body, Float:Damage
get_user_aiming(attacker, target, body)

switch(had)
{
case Balrog7:Damage = float(get_damage_body(body, random_float(1.0, 1.3)))	
case MG3:Damage = float(get_damage_body(body, 1.0))	
case Thanatos7:Damage = float(get_damage_body(body, 1.2))	
case Skull8:Damage = 1.1
case Crow7:Damage = 1.5
case Janus7:Damage = float(get_damage_body(body, 1.7))	
case M134Hero:Damage = float(get_damage_body(body, random_float(1.0, 3.0)))	
case Avalanche:Damage = (g_had2[attacker][MODE]? 1.0 : 1.5)
}

SetHamParamFloat(4, damage * Damage)
return HAM_HANDLED
}

public fwPlaybackEvent(flags, id, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
if(!is_player(id, 1))
return FMRES_IGNORED	

static  Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_BASE || had == INVALID)
return FMRES_IGNORED

switch(had)
{
case Balrog7:
{
if(g_had2[id][SHOTS] >= 10)
{
effect(id)	
set_weapon_anim(id, 2)
emit_sound(id, CHAN_ITEM, "ZB5/weapons/balrog11_charge.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
g_had2[id][SHOTS] = 0
}	
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog7-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.109)
set_weapon_anim(id, 1)
g_had2[id][SHOTS]++
}
case MG3:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/mg3-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.090)
set_weapon_anim(id, random_num(1,2))
}
case Thanatos7:
{
zb5_make_shell(id, 3,-5.0, 15.0, 8.0, 10.0, 50.0, 3);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos7-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.090)
set_weapon_anim(id, !g_had2[id][MODE] ? 5 : 6)
}
case Skull8:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3)	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skull8-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.090)
set_weapon_anim(id, random_num(1,2))
}
case Avalanche:
{
if(!g_had2[id][MODE])
{	
set_player_nextattack(id, 0.090)
set_weapon_anim(id, random_num(3,4))
}
else 
{
set_player_nextattack(id, 0.020)
set_weapon_anim(id, random_num(9,10))
}	
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/sfmg-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
IG_Muzzleflash_Activate(id)	
}
case Crow7:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/crow7-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.090)
set_weapon_anim(id, random_num(1,2))
}
case Janus7:
{
if(g_had2[id][MODE] == MODE_B)
return FMRES_IGNORED

if(g_had2[id][SHOTS] < 180)g_had2[id][SHOTS]++
else if(g_had2[id][SHOTS] >= 180)
{
g_had2[id][SHOTS] = 0	
g_had2[id][MODE] = MODE_S

remove_task(id+TASK_STOP)
set_task(6.0, "Stop_Special", id+TASK_STOP)
}

zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus7-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.100)
set_weapon_anim(id, g_had2[id][MODE] != MODE_S ? 4 : 5)	
}
}

engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)	
return FMRES_SUPERCEDE
}

public effect(Attacker)
{	
static Float:originF[3], Float:Origin[3]
get_position(Attacker, 30.0, 13.0, -23.0, Origin)	

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION) 
engfunc(EngFunc_WriteCoord, Origin[0]) 
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[0]) 
write_byte(5)
write_byte(25)
write_byte(10)
message_end()

fm_get_aim_origin(Attacker, originF)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION) 
engfunc(EngFunc_WriteCoord, originF[0]) 
engfunc(EngFunc_WriteCoord, originF[1])
engfunc(EngFunc_WriteCoord, originF[2]+60.0)
write_short(ef_sprite[4]) 
write_byte(8) //scale
write_byte(40) //frame
write_byte(0) 
message_end() 

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, originF, 100.0)) != 0)
{
if(Attacker == Victim)
continue;

do_attack(Attacker, Victim, 0, 200.0, 1)
}
}
public Stop_Special(id)
{
id -= TASK_STOP

if(!is_player(id, 1))
return
if(g_had[id] != Janus7)
return;

set_player_nextattack(id, 1.0)
set_weapons_timeidle(id, CSW_BASE, 1.0)
set_weapon_anim(id, g_had2[id][MODE] == MODE_S ? 0 : 11)	
g_had2[id][MODE] = MODE_A
}
// RELOAD MACHINES
public Frame(weapon_entity) 
{
if (!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static  Weapons:had 	
had  = g_had[id]	

if(had == INVALID)
return HAM_IGNORED;

static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)	
static Button; Button = (entity_get_int(id, EV_INT_button) & IN_ATTACK2 && flNextAttack <= 0.0)


if(Button)
{
switch(had)
{
case Skull8: Skull8_Attack_Knife(id, weapon_entity, pev(id, pev_button))	
case Avalanche:
{	
set_player_nextattack(id, 3.0)
set_weapons_timeidle(id, CSW_BASE, 3.0)	
set_weapon_anim(id, !g_had2[id][MODE] ? 5 : 11)
g_had2[id][MODE] = (g_had2[id][MODE]? MODE_A : MODE_B)	
IG_Muzzleflash_Set(id, !g_had2[id][MODE] ? "sprites/ZB5/muz_sfmg.spr" : "sprites/ZB5/muzzleflash16.spr", 0.20)	
}
case Thanatos7:
{		
if(!g_had2[id][MODE])
{	
set_weapon_anim(id, 10)
set_player_nextattack(id, 4.0)
set_weapons_timeidle(id, CSW_BASE, 4.0)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos7_scythereload.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}
else
{	
Scythe_Shoot(id)	
set_weapon_anim(id, 9)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos7_scytheshoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

set_player_nextattack(id, 4.0)
set_weapons_timeidle(id, CSW_BASE, 4.0)

static Float:Origin[3]
Origin[0] = random_float(-2.5, -5.0)
set_pev(id, pev_punchangle, Origin)
}
g_had2[id][MODE] = (g_had2[id][MODE]? MODE_A : MODE_B)	
}
}
}

static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)
static fInReload; fInReload  = get_pdata_int(weapon_entity, 54, 4)

if( fInReload && flNextAttack <= 0.0 )
{
static c, j
switch(had)
{
case Balrog7:c = 120
case Thanatos7:c = 120
case Skull8:c = 120
case Crow7:c = 100
case MG3:c = 200
case Avalanche:c = 200
case Janus7:c = 200
case M134Hero:c = 200
}

j = min(c - iClip, iBpAmmo)
set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
cs_set_user_bpammo(id, CSW_BASE, iBpAmmo-j);
set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
fInReload = 0
}

return HAM_IGNORED;
}

public Reload(weapon_entity) 
{
if (!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static  Weapons:had 	
had  = g_had[id]	

if(had == INVALID)
return HAM_IGNORED;

g_had2[id][TMPCLIP] = -1;

static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)

if (iBpAmmo <= 0)
return HAM_SUPERCEDE;

static c
switch(had)
{
case Balrog7:c = 120
case Thanatos7:c = 120
case Skull8:c = 120
case Crow7:c = 100
case MG3:c = 200
case Avalanche:c = 200
case Janus7:c = 200
case M134Hero:c = 200
}

if (iClip >= c)
return HAM_SUPERCEDE;

g_had2[id][TMPCLIP] = iClip;

return HAM_IGNORED;
}
public Reload_Post(weapon_entity) 
{
if (!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static  Weapons:had 	
had  = g_had[id]	

if(had == INVALID)
return HAM_IGNORED;

if (g_had2[id][TMPCLIP] == -1)
return HAM_IGNORED;

static Float:time2, anim
switch(had)
{
case Balrog7:
{
time2 = 4.4
anim = 3
}
case Thanatos7:
{
anim = !g_had2[id][MODE] ? 7 : 8
time2 = 4.4
}
case Skull8:
{
time2 = 4.4
anim = 3
}
case MG3:
{
time2 = 4.4
anim = 3
}
case Janus7:
{
time2 = 4.6
anim = g_had2[id][MODE] == MODE_S ? 13 : 1
}
case Crow7:
{
anim = 3	
time2 = 4.0
set_task(1.5, "Reload_Crow7", id)
}
case Avalanche:
{
anim = !g_had2[id][MODE] ? 1 : 7
time2 = 4.4
}
case M134Hero:
{
time2 = 4.8
anim = 3

g_special[id][ATTACK] = false
g_special[id][SHOOT] = false
g_special[id][RELOAD] = true
set_pev(id, pev_maxspeed, RELOAD_SPEED)

remove_task(id+TASK_M134_RELOADING)
set_task(4.9, "task_reloaded", id+TASK_M134_RELOADING)
}
}

set_pdata_int(weapon_entity, m_iClip, g_had2[id][TMPCLIP], WEAP_LINUX_XTRA_OFF)
set_pdata_float(weapon_entity, m_flTimeWeaponIdle, time2, WEAP_LINUX_XTRA_OFF)
set_pdata_float(id, m_flNextAttack, time2, PLAYER_LINUX_XTRA_OFF)
set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)
set_weapon_anim(id, anim)

return HAM_IGNORED;
}
public Reload_Crow7(id)
{
if(!is_player(id, 1))
return;

if(get_player_weapon(id) != CSW_BASE || g_had[id] != Crow7)
return;	

set_weapon_anim(id, 4)
}

////////// SKULL-8 ATTACK /////////////
public Skull8_Attack_Knife(id, iEnt, iButton)
{
if(!is_valid_ent(iEnt))
return

if(get_pdata_float(id, 83, 4) > 0.0)
return

static  attcking; attcking = pev(iEnt, pev_iuser1)
static anim; anim = pev(iEnt, pev_iuser2)

if(get_pdata_float(iEnt, 46, 5) <= 0.0 && iButton & IN_ATTACK2 && iButton & ~IN_ATTACK)
{
anim = 1 - anim
set_pev(iEnt, pev_iuser2, anim)
set_pev(iEnt, pev_iuser1, 1)
set_weapon_anim(id, anim ? 5 : 6)

set_pdata_float(iEnt, 48, 1.76, 4)
set_pdata_float(iEnt, 46, 1.76)
set_pdata_float(id, 83, 0.84, 5)
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_KNIFE, -1 , 20)
}

if(attcking)
{	
Check_AttackDamge(id, id, 150.0, 500.0, 1)

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skullaxe_wall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

set_pev(iEnt, pev_iuser1, 0)
set_pdata_float(iEnt, 48, 0.92, 4)
set_pdata_float(id, 83, 0.92, 5)
}
}

// THANATOS 7 
public Scythe_Shoot(id)
{	
static iEnt; iEnt = create_entity("info_target")
if(!is_valid_ent(iEnt))
return;

static Float:Origin[3], Float:Angles[3], Float:TargetOrigin[3], Float:Velocity[3]

get_weapon_attachment(id, Origin, 40.0)
get_position(id, 1024.0, 0.0, 0.0, TargetOrigin)

entity_get_vector(id, EV_VEC_angles, Angles)
Angles[0] *= -1.0

// set info for ent
entity_set_string(iEnt, EV_SZ_classname, CLASSNAME_SCYTHE)
entity_set_model(iEnt, "models/ZB5/Items/ZB5_Items_NEW.mdl")

entity_set_int(iEnt, EV_INT_body, 7 - 1)	
set_entity_anim(iEnt, 5)

entity_set_vector(iEnt, EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(iEnt, EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(iEnt, Origin)
entity_set_float(iEnt, EV_FL_gravity, 0.01)
entity_set_vector(iEnt, EV_VEC_angles, Angles)

entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER)
	
entity_set_int(iEnt,EV_INT_iuser1, get_user_team(id))	
entity_set_int(iEnt,EV_INT_iuser2, 0)	
entity_set_edict(iEnt, EV_ENT_owner, id)	

entity_set_float(iEnt, EV_FL_fuser1, get_gametime() + 10.0) 
entity_set_float(iEnt, EV_FL_frame,  0.0) 

get_speed_vector(Origin, TargetOrigin, 1000.0, Velocity)
entity_set_vector(iEnt, EV_VEC_velocity, Velocity) 

entity_set_float(iEnt, EV_FL_nextthink, halflife_time() + 0.1) 
}


public fw_Touch(Ent, id)
{
if(!is_valid_ent(Ent))
return;

if(entity_get_int(Ent,EV_INT_iuser2))
return;

entity_set_vector(Ent, EV_VEC_mins, Float:{-40.0, -40.0, -40.0})
entity_set_vector(Ent, EV_VEC_maxs, Float:{40.0, 40.0, 40.0})

entity_set_int(Ent,EV_INT_iuser2, 1)	
entity_set_int(Ent, EV_INT_movetype, MOVETYPE_NONE)

set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
}

public fw_Think(Ent)
{
if(!is_valid_ent(Ent))
return;

static Float:Time; Time = entity_get_float(Ent, EV_FL_fuser1)

if(Time <= get_gametime())
{
entity_set_int(Ent,EV_INT_flags, FL_KILLME)	
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.1) 
return
}

static Owner; Owner = entity_get_edict(Ent,EV_ENT_owner)
Check_AttackDamge(Ent, Owner, 50.0, random_float(10.0, 70.0), 0)	

set_entity_anim(Ent, 5)	
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.1) 
}
/// M134 EX SYSTEM ///
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED	

static Weapons:had 	

had = g_had[id]	
if(get_player_weapon(id) != CSW_BASE || had == INVALID)
return FMRES_IGNORED

static ent; ent = find_ent_by_owner(-1, weapon_base, id)
if(!is_valid_ent(ent))
return FMRES_IGNORED

static buttons; buttons = get_uc(uc_handle, UC_Buttons)

switch(had)
{
case M134Hero:use_m134_attack(id, uc_handle, ent, buttons)
case Janus7:use_janus7_attack(id, uc_handle, ent, buttons)
}
return FMRES_HANDLED
}
use_m134_attack(id, uc_handle, ent, buttons)
{	
static Weapons:had; had = g_had[id]
	
if(get_player_weapon(id) != CSW_BASE || had != M134Hero)	
return 

if(get_pdata_float(id, 83, 5) > 0.0 || get_pdata_int(ent, 54, 4)) 
return

if(cs_get_weapon_ammo(ent) <= 0)
return;

if(g_special[id][RELOAD])
return

static Float:CurTime; CurTime = get_gametime()

static szClip, szAmmo
get_user_weapon(id, szClip, szAmmo)

if (buttons & IN_ATTACK)
{
if (!g_special[id][CANCLICK] && !g_special[id][READY] && !g_special[id][SHOOT])
{
buttons &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, buttons)

set_player_nextattack(id, 1.0)
set_weapons_timeidle(id, CSW_BASE, 1.0)
set_pev(id, pev_maxspeed, READY_SPEED)
set_weapon_anim(id, 5)

g_special[id][READY] = true
remove_task(id+TASK_M134_READY)
set_task(1.0, "task_m134_create_shoot", id+TASK_M134_READY)

g_special[id][CANCLICK] = true
remove_task(id+TASK_M134_CANCLICK)
set_task(1.0, "task_m134_remove_canclick", id+TASK_M134_CANCLICK)
}
if (!g_special[id][READY] && g_special[id][SHOOT] && !g_special[id][RELOAD] && szClip)
{
if(CurTime - 0.09 > g_had2[id][ATTACK1])
{
set_player_nextattack(id, 0.06)
set_weapon_anim(id, random_num(1,2))
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/m134ex-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

Make_ScreenShake(id, 2, 1, 2)	
zb5_make_shell(id, 1, -5.0, 15.0, -3.0, -10.0, -50.0, 3);
zb5_make_shell(id, 2, -5.0, 15.0, 8.0, 10.0, 50.0, 3);

Make_Sprite(id, ef_sprite[2], 3, 90, 32, 5, -19)
Make_Sprite(id, ef_sprite[3], 3, 90, 32, 5, -19)

ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)	
g_had2[id][ATTACK1] = CurTime
}
}
}
else if (szClip)
{	
if (g_special[id][READY] || g_special[id][SHOOT])
{
g_special[id][READY] = false
g_special[id][SHOOT] = false

remove_task(id+TASK_M134_READY)
set_weapon_anim(id, 6)

set_weapons_timeidle(id,CSW_BASE, 1.1)
set_pev(id, pev_maxspeed, NORMAL_SPEED)
}

if (buttons & IN_RELOAD) set_player_nextattack(id, 0.0)
}
}
public task_m134_create_shoot(id)
{
id -= TASK_M134_READY

if(!is_player(id, 1))
{  
remove_task(id+TASK_M134_READY);  
return;  
}  

g_special[id][READY] = false
g_special[id][SHOOT] = true
}
public task_m134_remove_canclick(id)
{
id -= TASK_M134_CANCLICK

if(!is_player(id, 1))
{  
remove_task(id+TASK_M134_CANCLICK);  
return;  
}  
g_special[id][CANCLICK] = false
}

public task_reloaded(id)
{
id -= TASK_M134_RELOADING

if(!is_player(id, 1))
{  
remove_task(id+TASK_M134_RELOADING);  
return;  
}   

g_special[id][RELOAD] = false
set_pev(id, pev_maxspeed, NORMAL_SPEED)
}
// JANUS 7 SYSTEM
use_janus7_attack(id, uc_handle, ent, buttons)
{	
static Weapons:had; had = g_had[id]
	
if(get_player_weapon(id) != CSW_BASE || had != Janus7)	
return 

if(get_pdata_float(id, 83, 5) > 0.0 || get_pdata_int(ent, 54, 4)) 
return

static Float:CurTime; CurTime = get_gametime()

static Float:flAim[3]
fm_get_aim_origin(id, flAim)

switch(g_had2[id][MODE])
{
case MODE_B:
{
if (buttons & IN_ATTACK && g_had2[id][CAN_SHOOT])
{
buttons &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, buttons)

if(CurTime - 0.1 > g_had2[id][ATTACK1])
{	
set_weapon_anim(id, random_num(9,10))

message_begin(MSG_BROADCAST, SVC_TEMPENTITY )
write_byte(TE_BEAMENTPOINT)
write_short(id| 0x1000)
engfunc(EngFunc_WriteCoord, flAim[0])
engfunc(EngFunc_WriteCoord, flAim[1])
engfunc(EngFunc_WriteCoord, flAim[2])
write_short(ef_sprite[1])
write_byte(0) // framerate
write_byte(0) // framerate
write_byte(2) // life
write_byte(50)  // width
write_byte(10)// noise
write_byte(250)// r, g, b
write_byte(190)// r, g, b
write_byte(0)// r, g, b
write_byte(255)	// brightness
write_byte(255)	// speed
message_end()

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus7-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
Check_AttackDamge(id, id, 300.0, 50.0, 1)

g_had2[id][ATTACK1] = CurTime
}
}
if (buttons & IN_RELOAD)
{
buttons &= ~IN_RELOAD
set_uc(uc_handle, UC_Buttons, buttons)
}
}
case MODE_S:
{
if (buttons & IN_ATTACK2)
{	
buttons &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, buttons)

set_weapon_anim(id, 6)
set_player_nextattack(id, 2.0)
set_weapons_timeidle(id, CSW_BASE, 2.0)

g_had2[id][MODE] = MODE_B
g_had2[id][CAN_SHOOT] = false

remove_task(id+TASK_STOP)
set_task(10.0, "Stop_Special", id+TASK_STOP)

set_task(2.0, "Can_Shoot", id)
}		
}
}
}
public Can_Shoot(id)
{
if(g_had[id] != Janus7)
return;

g_had2[id][CAN_SHOOT] = true
}

public Check_AttackDamge(Ent, Attacker, Float:Ratio, Float:ZombieDamage, View)
{
if(!is_valid_ent(Ent) && !is_player(Attacker, 0))
return
	
static Float:origin[3]
pev(Ent, pev_origin, origin)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, Ratio)) != 0)
{	
if(Attacker == Victim)
continue;

static Float:Origin[3]
pev(Victim, pev_origin, Origin)

if(View)
{
if(!is_in_viewcone(Attacker, Origin, 1))
continue
}

do_attack(Attacker, Victim, 0, ZombieDamage, 1)
}
}

stock SPR(id, const weapon[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
write_string(weapon)
write_byte(3)
write_byte(200)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(4)
write_byte(20)
write_byte(CSW_M249)
message_end()
}

stock get_damage_body(body, Float:damage) 
{
switch(body) 
{
case HIT_HEAD: damage *= 2.5
case HIT_STOMACH: damage *= 2.0
case HIT_CHEST: damage *= 2.0
case HIT_LEFTARM: damage *= 1.70
case HIT_RIGHTARM: damage *= 1.75
case HIT_LEFTLEG: damage *= 1.70
case HIT_RIGHTLEG: damage *= 1.75
default: damage *= 1.0
}
return floatround(damage)
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_weapon_remove_post(id)Reset_All(id, 1, 1)

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
Reset_All(id, 1, 1)

Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
}

Safety_Disconnected(id)
{
Reset_All(id, 1, 1)

UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
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

Reset_All(id, 1, 0)
Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)
}
public zp_fw_core_cure_post(id)
{
Reset_All(id, 1, 0)	
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
Reset_All(id, 1, 1)
	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Reset_All(id, 1, 1)

Set_BitVar(g_IsZombie, id)
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

