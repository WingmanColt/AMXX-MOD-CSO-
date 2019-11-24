#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define TASK_STOP 1023
#define TASK_SHOOT 10255

#define CSW_BASE CSW_P228
#define weapon_base "weapon_p228"

#define M79_GRENADE "janus1_grenade"
#define BOMB_CLASSNAME "blood_bomb"
#define THANATOS1_GRENADE "thanatos1_grenade"

#define WEAPON_ANIMEXT3 "dualpistols"
#define WEAPON_ANIMEXT2 "onehanded"

new const sound[][] =
{
"ZB5/weapons/infi.wav",
"ZB5/weapons/dde-1.wav",
"ZB5/weapons/skull2-1.wav",
"ZB5/weapons/sapientia-1.wav",	
"ZB5/weapons/balrog1-1.wav",
"ZB5/weapons/balrog1-2.wav",
"ZB5/weapons/vulcanus1-1.wav",
"ZB5/weapons/vulcanus1-2.wav",
"ZB5/weapons/janus1-1.wav",
"ZB5/weapons/janus1-2.wav",
"ZB5/weapons/janus1_exp.wav",
"ZB5/weapons/crimson-1.wav",
"ZB5/weapons/crimson_throw.wav",
"ZB5/weapons/crimson_change.wav",
"ZB5/weapons/thanatos1_shoot1.wav",
"ZB5/weapons/thanatos1_shoot2.wav",
"ZB5/weapons/thanatos11_explode.wav"
}
new const models[][] =
{
"models/ZB5/Pistols/w_balrog1.mdl",	
"models/ZB5/Pistols/v_balrog1.mdl",
"models/ZB5/Pistols/v_ddeagle.mdl",
"models/ZB5/Pistols/v_janus1.mdl",
"models/ZB5/Pistols/v_skull2.mdl",
"models/ZB5/Pistols/v_thanatos1.mdl",
"models/ZB5/Pistols/v_infinityex2.mdl",
"models/ZB5/Pistols/v_sapientia.mdl",
"models/ZB5/Pistols/v_crimson.mdl",
"models/ZB5/Pistols/v_vulcanus1.mdl",
"models/ZB5/Pistols/p_skull2_mode.mdl"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud2.spr",	
"sprites/ZB5/HUD2/640hud43.spr",	
"sprites/ZB5/HUD2/640hud62.spr",
"sprites/ZB5/HUD2/640hud83.spr",
"sprites/ZB5/HUD2/640hud100.spr",
"sprites/ZB5/HUD2/640hud128.spr",
"sprites/ZB5/HUD2/640hud133.spr",
"sprites/ZB5/HUD2/skull2.spr",

"sprites/weapon_balrog1_MSBG.txt",
"sprites/weapon_janus1_MSBG.txt",
"sprites/weapon_skull2_MSBG.txt",
"sprites/weapon_ddeagle_MSBG.txt",
"sprites/weapon_sapientia_MSBG.txt",
"sprites/weapon_infinityex2_MSBG.txt",
"sprites/weapon_thanatos1_MSBG.txt",
"sprites/weapon_crimson_MSBG.txt",
"sprites/weapon_vulcanus1_MSBG.txt",
}
new const generic_spr[][] =
{
"weapon_balrog1_MSBG",
"weapon_janus1_MSBG",
"weapon_skull2_MSBG",
"weapon_ddeagle_MSBG",
"weapon_sapientia_MSBG",
"weapon_infinityex2_MSBG",
"weapon_thanatos1_MSBG",
"weapon_crimson_MSBG",
"weapon_vulcanus1_MSBG"
}
enum Weapons
{
INVALID = 0,
THANATOS1,	
SAPIENTIA,	
VULCANUS1,
INFINITY,
BALROG1,
DDEALGE,
CRIMSON,
SKULL2,	
M79
}

enum _:Options
{
Float:Attack2,
TMPCLIP,
SHOOT2,	
SIGNAL,
SHOTS,
AMMO,	
USED,
MODE,
DUAL,
Old
}

enum 
{	
MODE_A,
MODE_B,
MODE_SIGNAL,
MODE_NO,
}

new Weapons:g_had[33], g_had2[33][Options], ef_sprite[6], g_weapon[8]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]

public plugin_init()
{
if(!zb5_weapons_secondary())
return;

Register_SafetyFunc()			
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")	

register_touch(M79_GRENADE, "*", "fw_Grenade_Touch")
register_touch(THANATOS1_GRENADE, "*", "fw_Thanatos1_Touch")

register_think(BOMB_CLASSNAME, "fw_BombThink")
register_touch(BOMB_CLASSNAME, "*", "fw_BombTouch")

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_item_addtoplayer", 1)
RegisterHam(Ham_TakeDamage, "player", "fw_takedmg")

RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_Weapon_Idle");
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload_Post", 1);
RegisterHam(Ham_Item_PostFrame, weapon_base, "Frame")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload")

register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")

g_weapon[0] = zb5_register_weapon("Dual Infinity", "\yFinal Edition", WPN_PISTOLS, LEVEL_INFINITY, 0)
g_weapon[1] = zb5_register_weapon("Balrog I", "\rDemon Hunter", WPN_PISTOLS, LEVEL_BALROG1, 0)
g_weapon[2] = zb5_register_weapon("Colt Sapientia", "\yHoly Burn", WPN_PISTOLS, LEVEL_SAPIENTIA, 0)
g_weapon[3] = zb5_register_weapon("Janus I", "\yLauncher", WPN_PISTOLS, LEVEL_JANUS1, 1)
g_weapon[4] = zb5_register_weapon("Thanatos I", "\rHunter Weapon", WPN_PISTOLS, LEVEL_THANATOS1, 0)
g_weapon[5] = zb5_register_weapon("Skull II", "\y.50 \rAnti-Zombie", WPN_PISTOLS, LEVEL_SKULL2, 0)
g_weapon[6] = zb5_register_weapon("Blood Hunter", "\rCrimson", WPN_PISTOLS, LEVEL_CRIMSON, 0)
g_weapon[7] = zb5_register_weapon("Vulcanus 1", "\y[HOT]", WPN_PISTOLS, LEVEL_VULCANUS1, 0)
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

ef_sprite[0] = PrecacheModel("sprites/ZB5/ef_balrog1.spr")	
ef_sprite[1] = PrecacheModel("sprites/ZB5/svd_exp.spr")
ef_sprite[2] = PrecacheModel("sprites/laserbeam.spr")
ef_sprite[3] = PrecacheModel("sprites/ZB5/ef2_coilmg.spr")	
ef_sprite[4] = PrecacheModel("sprites/ZB5/ef_thanatos1.spr")	
ef_sprite[5] = PrecacheModel("sprites/ZB5/ef_bloodhunter3.spr")		
}

public Had_DDEAGLE(id)return g_had[id] == DDEALGE

public plugin_natives()
{
register_native("get_weapon_pistol", "Get_Pistol", 1)
register_native("zb5_had_ddeagle", "Had_DDEAGLE", 1)
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}

public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0]) Get_Pistol(id, 3)
else if(wpnid == g_weapon[1]) Get_Pistol(id, 2)
else if(wpnid == g_weapon[2]) Get_Pistol(id, 4)
else if(wpnid == g_weapon[3]) Get_Pistol(id, 6)
else if(wpnid == g_weapon[4]) Get_Pistol(id, 5)
else if(wpnid == g_weapon[5]) Get_Pistol(id, 7)
else if(wpnid == g_weapon[6]) Get_Pistol(id, 8)
else if(wpnid == g_weapon[7]) Get_Pistol(id, 9)
}
public Get_Pistol(id, Weapon)
{
if(!zb5_weapons_secondary())
return;
	
drop_weapons(id, 2);
Reset_All(id, 1)

fm_give_item(id, weapon_base)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

switch(Weapon)
{
case 1:
{	
g_had[id] = DDEALGE
cs_set_weapon_ammo(Ent, 28)
SPR(id, "weapon_ddeagle_MSBG")
}
case 2:
{	
g_had[id] = BALROG1
cs_set_weapon_ammo(Ent, 10)
SPR(id, "weapon_balrog1_MSBG")
}
case 3:
{	
g_had[id] = INFINITY
cs_set_weapon_ammo(Ent, 40)
SPR(id, "weapon_infinityex2_MSBG")
}
case 4:
{	
g_had[id] = SAPIENTIA
cs_set_weapon_ammo(Ent, 7)
SPR(id, "weapon_sapientia_MSBG")
}
case 5:
{	
g_had[id] = THANATOS1
cs_set_weapon_ammo(Ent, 12)
SPR(id, "weapon_thanatos1_MSBG")
}
case 6:
{	
g_had[id] = M79
cs_set_weapon_ammo(Ent, 0)
SPR(id, "weapon_janus1_MSBG")
}
case 7:
{	
g_had[id] = SKULL2
g_had2[id][MODE] = MODE_A

cs_set_weapon_ammo(Ent, 20)
SPR(id, "weapon_skull2_MSBG")
}
case 8:
{	
g_had[id] = CRIMSON
g_had2[id][MODE] = MODE_NO

cs_set_weapon_ammo(Ent, 30)
SPR(id, "weapon_crimson_MSBG")
}
case 9:
{	
g_had[id] = VULCANUS1
g_had2[id][MODE] = MODE_A

cs_set_weapon_ammo(Ent, 24)
SPR(id, "weapon_vulcanus1_MSBG")
}
}
Hook_SPR(id)
Draw_NewWeapon(id, CSW_BASE)
Deploy_Post(Ent)
zp_fw_restock_ammo(id)
}
public zp_fw_restock_ammo(id)
{	
static Weapons:had 	
had  = g_had[id]	

if(had == INVALID) 
return;

static Clip

switch(had)
{
case DDEALGE:Clip = zb5_had_StrongLife(id)? 250: 200
case INFINITY:Clip = zb5_had_StrongLife(id)? 250: 200
case SKULL2:Clip = zb5_had_StrongLife(id)? 250: 200
case BALROG1:Clip = zb5_had_StrongLife(id)? 70: 50
case THANATOS1:Clip = zb5_had_StrongLife(id)? 200: 150
case SAPIENTIA:Clip = zb5_had_StrongLife(id)? 120: 80
case CRIMSON:Clip = zb5_had_StrongLife(id)? 250: 200
case VULCANUS1:Clip = zb5_had_StrongLife(id)? 250: 200
case M79:
{
g_had2[id][AMMO] = zb5_had_StrongLife(id)? 15: 10

if(get_player_weapon(id) == CSW_BASE)
update_ammo(id)	
}
}

cs_set_user_bpammo(id, CSW_BASE, Clip)
}
public Reset_All(id, mode)
{	
update_specialammo(id, g_had2[id][AMMO], 0)		
arrayset(_:g_had2[id], false, sizeof(g_had2[]));

if(mode)
arrayset(_:g_had[id], false, sizeof(g_had[]));	
}

public Deploy_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static id; id = get_pdata_cbase(Ent, 41, 4)
if(get_pdata_cbase(id, 373) != Ent)
return
		
static Weapons:had
had = g_had[id] 

if(had == INVALID)
return;

static SubModel

switch(had)
{
case DDEALGE:
{
SubModel = 3
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_ddeagle.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case BALROG1:
{
SubModel = 2
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_balrog1.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case INFINITY:
{
SubModel = 4
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_infinityex2.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case SAPIENTIA:
{
SubModel = 21
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_sapientia.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case THANATOS1:
{
SubModel = 20
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_thanatos1.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case M79:
{
SubModel = 19
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_janus1.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case SKULL2:
{
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_skull2.mdl")
set_pev(id, pev_weaponmodel2, "models/ZB5/Pistols/p_skull2_mode.mdl")
}
case CRIMSON:
{
SubModel = 23
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_crimson.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case VULCANUS1:
{
SubModel = 22
set_pev(id, pev_viewmodel2, "models/ZB5/Pistols/v_vulcanus1.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
}

}
public event_CurWeapon(id)
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

switch(had)
{
case DDEALGE:
{
set_weapon_anim(id, 6)
	
Submodel = 3;Sequence = 2	
engfunc(EngFunc_SetModel, ent, P_Model2)
}
case BALROG1:
{	
g_had2[id][MODE] = MODE_A	
set_weapon_anim(id, 5)	

Submodel = 2;Sequence = 1
engfunc(EngFunc_SetModel, ent, P_Model2)
}
case INFINITY:
{
set_weapon_anim(id, 8)
	
Submodel = 4;Sequence = 3
engfunc(EngFunc_SetModel, ent, P_Model2)
}
case SAPIENTIA:
{
set_weapon_anim(id, 5)
	
Submodel = 21;Sequence = 20
engfunc(EngFunc_SetModel, ent, P_Model2)
}
case THANATOS1:
{
set_weapon_anim(id, g_had2[id][MODE]? 11:10)
update_specialammo(id, g_had2[id][AMMO], g_had2[id][AMMO] > 0 ? 1 : 0)
	
Submodel = 20;Sequence = 4
engfunc(EngFunc_SetModel, ent, P_Model2)
}
case M79:
{
update_ammo(id)	

switch(g_had2[id][MODE])
{
case MODE_A:set_weapon_anim(id, 1)	
case MODE_B:set_weapon_anim(id, 7)	
case MODE_SIGNAL:set_weapon_anim(id, 12)	
}
	
Submodel = 19;Sequence = 18
engfunc(EngFunc_SetModel, ent, P_Model2)
}
case SKULL2:
{
set_weapon_anim(id, g_had2[id][MODE]? 8:2)
set_pev(id, pev_weaponmodel2, "models/ZB5/Pistols/p_skull2_mode.mdl")
}
case CRIMSON:
{
switch(g_had2[id][MODE])
{
case MODE_NO:set_weapon_anim(id, 19)	
case MODE_A:set_weapon_anim(id, 20)
case MODE_B:set_weapon_anim(id, 21)
case MODE_SIGNAL:set_weapon_anim(id, 22)	
}
	
Submodel = 23;Sequence = 21
engfunc(EngFunc_SetModel, ent, P_Model2)
}
case VULCANUS1:
{
switch(g_had2[id][MODE])
{
case MODE_A:set_weapon_anim(id, 12)	
case MODE_B:set_weapon_anim(id, 2)
}
Submodel = 22;Sequence = 19
engfunc(EngFunc_SetModel, ent, P_Model2)
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

static iOwner; iOwner = pev(entity, pev_owner)

if(equal(model, "models/w_p228.mdl"))
{
static weapon
weapon = find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

static Weapons:had
had = g_had[iOwner] 

switch(had)
{
case DDEALGE:
{		
set_pev(weapon, pev_impulse, DDEALGE)
engfunc(EngFunc_SetModel, entity, W_Model2)	
set_pev(entity, pev_body, 1 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
case BALROG1:
{	
set_pev(weapon, pev_impulse, BALROG1)
engfunc(EngFunc_SetModel, entity, "models/ZB5/Pistols/w_balrog1.mdl")
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
case INFINITY:
{
set_pev(weapon, pev_impulse, INFINITY)
engfunc(EngFunc_SetModel, entity, W_Model2)
set_pev(entity, pev_body, 2 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}

case SAPIENTIA:
{		
set_pev(weapon, pev_impulse, SAPIENTIA)
engfunc(EngFunc_SetModel, entity, W_Model)	
set_pev(entity, pev_body, 12 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
case THANATOS1:
{	
set_pev(weapon, pev_impulse, THANATOS1)
engfunc(EngFunc_SetModel, entity, W_Model2)
set_pev(entity, pev_body, 15 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
case M79:
{
set_pev(weapon, pev_impulse, M79)
engfunc(EngFunc_SetModel, entity, W_Model2)
set_pev(weapon, pev_iuser4, g_had2[iOwner][AMMO])
set_pev(entity, pev_body, 10 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
case SKULL2:
{		
set_pev(weapon, pev_impulse, SKULL2)
engfunc(EngFunc_SetModel, entity, W_Model2)	
set_pev(entity, pev_body, 11 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
case CRIMSON:
{		
set_pev(weapon, pev_impulse, CRIMSON)
engfunc(EngFunc_SetModel, entity, W_Model2)	
set_pev(entity, pev_body, 13 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
case VULCANUS1:
{		
set_pev(weapon, pev_impulse, VULCANUS1)
engfunc(EngFunc_SetModel, entity, W_Model2)	
set_pev(entity, pev_body, 12 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}
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
case DDEALGE:
{
Reset_All(id, 1)
g_had[id] = DDEALGE

SPR(id, "weapon_ddeagle_MSBG")
set_pev(ent, pev_impulse, 0)	
}
case BALROG1:
{
Reset_All(id, 1)
g_had[id] = BALROG1

SPR(id, "weapon_balrog1_MSBG")
set_pev(ent, pev_impulse, 0)
}
case INFINITY:
{
Reset_All(id, 1)	
g_had[id] = INFINITY

SPR(id, "weapon_infinityex2_MSBG")
set_pev(ent, pev_impulse, 0)	
}
case SAPIENTIA:
{
Reset_All(id, 1)
g_had[id] = SAPIENTIA

SPR(id, "weapon_sapientia_MSBG")
set_pev(ent, pev_impulse, 0)	
}
case THANATOS1:
{
Reset_All(id, 1)
g_had[id] = THANATOS1

SPR(id, "weapon_thanatos1_MSBG")
set_pev(ent, pev_impulse, 0)
}
case M79:
{
Reset_All(id, 1)

g_had[id] = M79
g_had2[id][AMMO] = pev(ent, pev_iuser4)

SPR(id, "weapon_janus1_MSBG")
set_pev(ent, pev_impulse, 0)
}
case SKULL2:
{
Reset_All(id, 1)

g_had[id] = SKULL2
g_had2[id][MODE] = MODE_A

SPR(id, "weapon_janus1_MSBG")
set_pev(ent, pev_impulse, 0)	
}
case CRIMSON:
{
Reset_All(id, 1)

g_had[id] = CRIMSON
g_had2[id][MODE] = MODE_NO

SPR(id, "weapon_thanatos1_MSBG")
set_pev(ent, pev_impulse, 0)
}
case VULCANUS1:
{
Reset_All(id, 1)

g_had[id] = VULCANUS1
g_had2[id][MODE] = MODE_A

SPR(id, "weapon_vulcanus1_MSBG")
set_pev(ent, pev_impulse, 0)
}
}

}
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED

static ent; ent = find_ent_by_owner(-1, weapon_base, id)
if(!is_valid_ent(ent))
return FMRES_IGNORED

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had == INVALID)	
return FMRES_IGNORED

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)	
static Float:CurTime; CurTime = get_gametime()
static ammo; ammo = cs_get_weapon_ammo(ent)

if(get_pdata_float(id, 83, 5) > 0.0 || get_pdata_int(ent, 54, 4)) 
return FMRES_IGNORED

switch(had)
{
case VULCANUS1:
{
if(CurButton & IN_ATTACK && g_had2[id][MODE] == MODE_B)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(ammo <= 0)
return FMRES_IGNORED
		
if(CurTime - 1.0 > g_had2[id][Attack2])
{	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/vulcanus1-2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_PunchAngle(id, 1.0, 0.0)
set_weapon_anim(id, 3)
	
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side

ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
g_had2[id][Attack2] = CurTime
}	
}
}
case SKULL2:
{
if(CurButton & IN_ATTACK && g_had2[id][MODE] == MODE_B)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(ammo <= 0)
return FMRES_IGNORED
		
if(CurTime - 0.180 > g_had2[id][Attack2])
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skull2-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
set_weapons_recoil(id, 1.4)
Make_PunchAngle(id, 3.0, 0.0)

Play_AttackAnimation(id, g_had2[id][DUAL]? 1:0)
set_weapon_anim(id, g_had2[id][DUAL]? 6:5)
	
if(g_had2[id][DUAL]) 
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
else  zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
g_had2[id][DUAL] = !g_had2[id][DUAL] ? 1 : 0

ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
g_had2[id][Attack2] = CurTime
}	
}
}
case INFINITY:
{
if(CurButton & IN_ATTACK2)
{
CurButton &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, CurButton)

if(ammo <= 0)
return FMRES_IGNORED

g_had2[id][MODE] = MODE_B	

if(CurTime - 0.120 > g_had2[id][Attack2])
{
if(g_had2[id][DUAL]) 
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
else zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side

Make_PunchAngle(id, 0.0, 4.0)
set_weapons_recoil(id, 1.0)
Play_AttackAnimation(id, g_had2[id][DUAL]? 1:0)

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/infi.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
set_weapon_anim(id, g_had2[id][SHOOT2]? random_num(11,12):random_num(9, 10))

g_had2[id][DUAL] = !g_had2[id][DUAL] ? 1 : 0
ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
g_had2[id][Attack2] = CurTime
}	
}else g_had2[id][MODE] = MODE_A
}

case M79:
{
if(CurButton & IN_ATTACK)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(g_had2[id][AMMO] <= 0)
return FMRES_IGNORED

Handle_Shoot(id)
}
if(!g_had2[id][USED] && CurButton & IN_ATTACK2 && (g_had2[id][MODE] == MODE_SIGNAL))
{
CurButton &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, CurButton)

set_weapons_timeidle(id, CSW_BASE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, 5)

g_had2[id][MODE] = MODE_B
g_had2[id][USED] = true

if(task_exists(id+TASK_STOP))remove_task(id+TASK_STOP)
set_task(7.0, "Stop_Special", id+TASK_STOP)	
}
}
}

return FMRES_HANDLED
}


public fwPlaybackEvent(flags, id, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{		
if(!is_player(id, 0))
return FMRES_IGNORED	

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had == INVALID)	
return FMRES_IGNORED		

switch(had)
{
case VULCANUS1:
{
if(g_had2[id][MODE] != MODE_A)
return FMRES_IGNORED
	
if(g_had2[id][DUAL]) 
{
set_weapon_anim(id, random_num(7,8))
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
Play_AttackAnimation(id, 0)
}
else 
{
set_weapon_anim(id, random_num(9,10))
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
Play_AttackAnimation(id, 1)
}
g_had2[id][DUAL] = !g_had2[id][DUAL] ? 1 : 0
	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/vulcanus1-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
Make_PunchAngle(id, 3.0, 0.0)
set_weapons_recoil(id, 1.5)
}	
case DDEALGE:
{
if(g_had2[id][DUAL]) 
{
set_weapon_anim(id, 2)
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
Play_AttackAnimation(id, 0)
}
else 
{
set_weapon_anim(id, 3)
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
Play_AttackAnimation(id, 1)
}
g_had2[id][DUAL] = !g_had2[id][DUAL] ? 1 : 0
	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dde-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
Make_PunchAngle(id, 4.0, 0.0)
set_weapons_recoil(id, 1.0)
}
case BALROG1:
{
switch(g_had2[id][MODE])
{
case MODE_A:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog1-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_weapon_anim(id, 2)
set_weapons_recoil(id, 1.0)
set_player_nextattack(id, 0.190)	
}
case MODE_B:
{
g_had2[id][MODE] = MODE_A	
set_weapons_timeidle(id, CSW_BASE, 2.5)
set_player_nextattack(id, 2.5)

set_weapon_anim(id, 3)	
Make_PunchAngle(id, 10.0, 0.0)
create_Smoke(id)

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog1-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}
}
}
case INFINITY:
{
if(g_had2[id][MODE] != MODE_A)
return FMRES_IGNORED

if(g_had2[id][DUAL]) 
{
set_weapon_anim(id, random_num(3,4))
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
Play_AttackAnimation(id, 0)
}
else 
{
set_weapon_anim(id, random_num(5,6))
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
Play_AttackAnimation(id, 1)
}
g_had2[id][DUAL] = !g_had2[id][DUAL] ? 1 : 0

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/infi.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapons_recoil(id, 1.0)
Make_PunchAngle(id, 4.0, 0.0)
}
case SAPIENTIA:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/sapientia-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side

set_weapon_anim(id, random_num(1,2))
set_weapons_recoil(id, 1.5)
Make_PunchAngle(id, 5.0, 0.0)
}
case SKULL2:
{
if(g_had2[id][MODE] == MODE_B)
return FMRES_IGNORED
	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skull2-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side

set_weapons_recoil(id, 1.2)
Make_PunchAngle(id, 8.0, 0.0)

set_weapon_anim(id, 3)
set_player_nextattack(id, 0.350)
set_weapons_timeidle(id, CSW_BASE, 0.350)
}
case THANATOS1:
{
switch(g_had2[id][MODE])
{
case MODE_A:
{
if(g_had2[id][SHOTS] < 16)
{
set_weapon_anim(id, 2)
set_weapons_recoil(id, 1.5)
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos1_shoot1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
g_had2[id][SHOTS]++
}
else
{
set_weapons_timeidle(id, CSW_BASE, 2.5)
set_player_nextattack(id, 2.5)
set_weapon_anim(id, 9)

g_had2[id][MODE] = MODE_B
g_had2[id][SHOTS] = 0
}	
}
case MODE_B:
{
g_had2[id][MODE] = MODE_A
	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos1_shoot2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapon_anim(id, 4)
set_weapons_recoil(id, 1.0)

set_weapons_timeidle(id, CSW_BASE, 2.0)
set_player_nextattack(id, 2.0)

Make_PunchAngle(id, 10.0, 0.0)
Make_Thanatos1(id)
}
}	
}
case CRIMSON:
{
switch(g_had2[id][MODE])
{
case MODE_NO:
{
set_weapon_anim(id, 7)

if(g_had2[id][SHOTS] >= 8)
g_had2[id][MODE] = MODE_A
}	
case MODE_A:
{
set_weapon_anim(id, 8)

if(g_had2[id][SHOTS] >= 16)
g_had2[id][MODE] = MODE_B
}
case MODE_B:
{
set_weapon_anim(id, 9)

if(g_had2[id][SHOTS] >= 24)
g_had2[id][MODE] = MODE_SIGNAL
}
case MODE_SIGNAL:set_weapon_anim(id, 10)	
}

if(g_had2[id][SHOTS] < 24)
g_had2[id][SHOTS]++

set_weapons_recoil(id, 1.0)
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
Play_AttackAnimation(id, 0)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/crimson-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
}
}
engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
return FMRES_SUPERCEDE
}

public fw_takedmg(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_player(attacker, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[attacker] 

if(get_player_weapon(attacker) != CSW_BASE || had == INVALID)	
return HAM_IGNORED;

if(had == M79)	
return HAM_IGNORED;

if (damage_type & (1<<24))
return HAM_IGNORED;

static Float:Damage, Float:Jump, Float:Jump2

switch(had)
{
case BALROG1:Damage = 2.0	
case CRIMSON:Damage = 3.0
case INFINITY:Damage = g_had2[attacker][MODE]? 1.5 : 2.0	
case DDEALGE:
{
Damage = 3.5
Jump = 50.0
}
case THANATOS1:
{
Damage = 3.0
Jump = 20.0
}
case SKULL2:
{
switch(g_had2[attacker][MODE])
{
case MODE_A:
{
Damage = 4.0
Jump = 100.0
}
case MODE_B:Damage = 2.5
}
}
case SAPIENTIA:
{
Damage = 3.0
Make_SapientiaEffect(victim)
zb5_make_burn(victim, attacker, 2.0, 0.6, "sprites/ZB5/holybomb_burn.spr")	
}
case VULCANUS1:
{
Damage = (g_had2[attacker][MODE]? 8.0 : 2.0)
Jump2 = (g_had2[attacker][MODE]? 100.0 : 0.0)
}
}

SetHamParamFloat(4, damage * Damage)
set_weapon_kick(attacker, victim, Jump2)
set_weapon_knockback(attacker, victim, Jump)
return HAM_HANDLED
}
public Frame(weapon_entity) 
{
if (!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED;

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED;

static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)
static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)
static fInReload; fInReload  = get_pdata_int(weapon_entity, 54, 4)
static Button; Button = (pev(id, pev_button) & IN_ATTACK2 && flNextAttack <= 0.0)
static j,d

switch(had)
{
case DDEALGE:d = 28
case INFINITY:d = 40
case SAPIENTIA:d = 7
case CRIMSON:
{
d = 30

if(Button && g_had2[id][MODE] != MODE_NO)
{	
switch(g_had2[id][MODE])
{
case MODE_A:set_weapon_anim(id, 12)
case MODE_B:set_weapon_anim(id, 13)
case MODE_SIGNAL:set_weapon_anim(id, 14)	
}

set_weapons_timeidle(id, CSW_BASE, 2.0)
set_player_nextattack(id, 2.0)

Throw_Grenade(id)
}
}
case SKULL2:
{	
if(Button)
{	
set_weapons_timeidle(id, CSW_BASE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, g_had2[id][MODE]? 10:9)	
g_had2[id][MODE] = (g_had2[id][MODE]? MODE_A: MODE_B)
}
d = 20
}
case THANATOS1:
{		
d = 12
}
case BALROG1:
{
if(Button)
{	
set_weapons_timeidle(id, CSW_BASE, g_had2[id][MODE]? 1.0:2.5)
set_player_nextattack(id, g_had2[id][MODE]? 1.0:2.5)
set_weapon_anim(id, g_had2[id][MODE]? 7:6)	
g_had2[id][MODE] = (g_had2[id][MODE]? MODE_A: MODE_B)
}	
d = 10	
}
case VULCANUS1:
{
if(Button)
{	
set_weapons_timeidle(id, CSW_BASE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, g_had2[id][MODE]? 13:14)	
g_had2[id][MODE] = (g_had2[id][MODE]? MODE_A : MODE_B)
}	
d = 24
}
}

if(fInReload && flNextAttack <= 0.0)
{
j = min(d - iClip, iBpAmmo)

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
return HAM_IGNORED;

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED;

g_had2[id][TMPCLIP] = -1;

static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)

if (iBpAmmo <= 0)
return HAM_SUPERCEDE;

static d
switch(had)
{
case DDEALGE:d = 28
case INFINITY:d = 40
case BALROG1:d = 10	
case SAPIENTIA:d = 7
case THANATOS1:d = 12
case SKULL2:d = 20
case CRIMSON:d = 30
case VULCANUS1:d = 24
}

if (iClip >= d)
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
return HAM_IGNORED;

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED;

if (g_had2[id][TMPCLIP] == -1)
return HAM_IGNORED;

static Float:time2
switch(had)
{
case DDEALGE:
{
set_weapon_anim(id, 5) 
time2 = 4.3
}
case SAPIENTIA:
{
time2 = 2.7
set_weapon_anim(id, 4)
}
case BALROG1:
{
time2 = 2.7
set_weapon_anim(id, g_had2[id][MODE]?8:4)
g_had2[id][MODE] = false
}
case THANATOS1:
{
time2 = 2.5
set_weapon_anim(id, g_had2[id][MODE]?8:7)
}
case SKULL2:
{
set_weapon_anim(id, g_had2[id][MODE]?7:1)
time2 = (g_had2[id][MODE]? 3.3: 2.3)		
}
case INFINITY:
{
time2 = 4.3
set_weapon_anim(id, 7)
g_had2[id][SHOOT2] = (g_had2[id][SHOOT2]? true : false)
}
case CRIMSON:
{
time2 = 2.5

switch(g_had2[id][MODE])
{
case MODE_NO:set_weapon_anim(id, 15)	
case MODE_A:set_weapon_anim(id, 16)
case MODE_B:set_weapon_anim(id, 17)
case MODE_SIGNAL:set_weapon_anim(id, 18)	
}
}
case VULCANUS1:
{
time2 = 3.5
set_weapon_anim(id, g_had2[id][MODE]?1:11)
}
}

set_pdata_int(weapon_entity, m_iClip, g_had2[id][TMPCLIP], WEAP_LINUX_XTRA_OFF)
set_pdata_float(weapon_entity, m_flTimeWeaponIdle, time2, WEAP_LINUX_XTRA_OFF)
set_pdata_float(id, m_flNextAttack, time2, PLAYER_LINUX_XTRA_OFF)
set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)
return HAM_IGNORED;
}
public fw_Weapon_Idle(const iItem, const iPlayer)
{
ExecuteHamB(Ham_Weapon_ResetEmptySound, iItem);
if (get_pdata_int(iItem, 48, 4) > 0.0)
{
return;
}
static Weapons:had 	
had  = g_had[iPlayer]	

switch(had)
{
case BALROG1:
{
if(g_had2[iPlayer][MODE])
set_weapon_anim(iItem, 1)
}
case THANATOS1:
{
if(g_had2[iPlayer][MODE])
set_weapon_anim(iItem, 1)
}
case SKULL2:
{
if(g_had2[iPlayer][MODE])
set_weapon_anim(iItem, 4)
}
case M79:
{
switch(g_had2[iPlayer][MODE])
{
case MODE_A:set_weapon_anim(iItem, 0)
case MODE_B:set_weapon_anim(iItem, 6)
case MODE_SIGNAL:set_weapon_anim(iItem, 11)
}	
}
case CRIMSON:
{
switch(g_had2[iPlayer][MODE])
{
case MODE_NO:set_weapon_anim(iItem, 0)	
case MODE_A:set_weapon_anim(iItem, 1)
case MODE_B:set_weapon_anim(iItem, 2)
case MODE_SIGNAL:set_weapon_anim(iItem, 3)
}	
}
case VULCANUS1:
{
switch(g_had2[iPlayer][MODE])
{
case MODE_A:set_weapon_anim(iItem, 5)
case MODE_B:set_weapon_anim(iItem, 0)
}	
}
}
set_pdata_float(iItem, 48, 5.46, 4);
}
public Make_SapientiaEffect(id)
{
static Float:Origin[3], Float:Add_Point
pev(id, pev_origin, Origin)

if(!(pev(id, pev_flags) & FL_DUCKING))
Add_Point = 30.0
else
Add_Point = 19.0

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord,Origin[0])
engfunc(EngFunc_WriteCoord,Origin[1])
engfunc(EngFunc_WriteCoord,Origin[2] + Add_Point)
write_short(ef_sprite[3])
write_byte(4) // scale in 0.1's
write_byte(30) // framerate
write_byte(14)
message_end()
}
public create_Smoke(id)
{	
static Float:fStart[3], Float:originF[3], target, body

fm_get_aim_origin(id, originF)
get_user_aiming(id, target, body)

pev(id, pev_origin, fStart)	
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION) 
engfunc(EngFunc_WriteCoord, originF[0]) 
engfunc(EngFunc_WriteCoord, originF[1])
engfunc(EngFunc_WriteCoord, originF[2]+60.0)
write_short(ef_sprite[0]) 
write_byte(10) //scale
write_byte(9) //frame
write_byte(TE_EXPLFLAG_NOSOUND) 
message_end()

Check_AttackDamge(target, id, 100.0, 400.0)
}
// BLOOD GRENADE SYSTEM
public Throw_Grenade(id)
{
static Float:StartOrigin[3], Float:Angles[3], Float:Velocity[3]

pev(id, pev_v_angle, Angles)
Angles[0] *= -1.0
get_position(id, 48.0, 0.0, 0.0, StartOrigin)
velocity_by_aim(id, 1200, Velocity)

static ent; ent = create_entity("info_target")
if(!is_valid_ent(ent))
return;

entity_set_string(ent, EV_SZ_classname, BOMB_CLASSNAME)

entity_set_model(ent, W_Model2)
entity_set_int(ent,EV_INT_body, 18 - 1)

entity_set_vector(ent,EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(ent,EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(ent, StartOrigin)
entity_set_vector(ent, EV_VEC_angles, Angles)

entity_set_int(ent,EV_INT_movetype, MOVETYPE_TOSS)
entity_set_int(ent,EV_INT_solid, SOLID_BBOX)

entity_set_vector(ent, EV_VEC_velocity, Velocity) 
entity_set_int(ent,EV_INT_iuser1, id)
entity_set_float(ent,EV_FL_gravity, 0.01)

entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1) 	
}
public fw_BombThink(Ent)
{
if(!is_valid_ent(Ent))
return;

static id; id = entity_get_int(Ent, EV_INT_iuser1)

if(!Get_BitVar(g_IsAlive, id) || entity_range(Ent, id) >= 200)
{
Shock_Explosion(Ent)
entity_set_int(Ent,EV_INT_flags, FL_KILLME)
return
}

entity_set_float(Ent, EV_FL_nextthink, get_gametime() + 0.1)	
}

public fw_BombTouch(Ent, id)
{
if(!is_valid_ent(Ent))
return

Shock_Explosion(Ent)
entity_set_int(Ent,EV_INT_flags, FL_KILLME)
}
public Shock_Explosion(Ent)
{
static Float:Origin[3]
entity_get_vector(Ent, EV_VEC_origin, Origin)

static id; id = entity_get_int(Ent, EV_INT_iuser1)
	
EmitSound(Ent, CHAN_AUTO, "ZB5/weapons/holywater_explosion.wav")

// create effect
message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_EXPLOSION) // TE_EXPLOSION
write_coord_f(Origin[0]) // origin x
write_coord_f(Origin[1]) // origin y
write_coord_f(Origin[2] + 20.0); // origin z
write_short(ef_sprite[5]) // sprites

switch(g_had2[id][MODE])
{
case MODE_A:write_byte(30) // scale in 0.1's
case MODE_B:write_byte(60) // scale in 0.1's
case MODE_SIGNAL:write_byte(90) // scale in 0.1's
}
write_byte(30) // framerate
write_byte(14) // flags 
message_end() // message end

message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_PARTICLEBURST) // TE id
write_coord_f(Origin[0]) // origin x
write_coord_f(Origin[1]) // origin y
write_coord_f(Origin[2] + 16.0); // origin z
write_short(80) // radius
write_byte(248) // color
write_byte(3) // duration (will be randomized a bit)
message_end()

for(new i = 0; i < get_maxplayers(); i++)
{
if(!Get_BitVar(g_IsAlive, i))
continue
if(entity_range(Ent, i) > 240.0)
continue
if(!Get_BitVar(g_IsZombie, i))
continue

Make_ScreenShake(i, 4, 2, 4)	
}

if(is_valid_ent(id))
{
switch(g_had2[id][MODE])
{
case MODE_A:Check_AttackDamge(Ent, id, 50.0, 100.0) 
case MODE_B:Check_AttackDamge(Ent, id, 100.0, 200.0) 
case MODE_SIGNAL:Check_AttackDamge(Ent, id, 150.0, 300.0) 	
}

g_had2[id][MODE] = MODE_NO
g_had2[id][SHOTS] = 0

Draw_NewWeapon(id, CSW_BASE)
}
}


// JANUS 1 SYSTEM
public Handle_Shoot(id)
{	
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) 
return;

if(g_had2[id][MODE] == MODE_A)
{			
if(get_gametime() - 3.0 > g_had2[id][Attack2])
{
if(g_had2[id][AMMO] <= 0) 
{
set_weapon_anim(id, 3)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus1-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

if(g_had2[id][AMMO] <= 5) 
{	
g_had2[id][MODE] = MODE_SIGNAL	

if(!task_exists(id+TASK_STOP))
set_task(6.0, "Stop_Special", id+TASK_STOP)	
}
else
{
g_had2[id][MODE] = MODE_A	
	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus1-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapons_timeidle(id, CSW_BASE, 3.0)
set_player_nextattack(id, 3.0)
set_weapon_anim(id, g_had2[id][MODE] == MODE_SIGNAL ? 4 : 2)
}
g_had2[id][AMMO]--
update_ammo(id)

Make_PunchAngle(id, 6.0, 0.0)
Make_Grenade(id)

g_had2[id][Attack2] = get_gametime()
}
}

if(g_had2[id][MODE] == MODE_B)
{	
if(get_gametime() - 0.4 > g_had2[id][Attack2])
{	
set_weapon_anim(id, random_num(8, 9))
set_weapons_timeidle(id, CSW_BASE, 0.4)
set_player_nextattack(id, 0.4)

Make_Grenade(id)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus1-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

ExecuteHamB(Ham_Weapon_PrimaryAttack, Ent)
g_had2[id][Attack2] = get_gametime()	
}
}
}
public Stop_Special(id)
{
id -= TASK_STOP

if(!is_player(id, 1))
return

static Weapons:had
had = g_had[id] 

if(had != M79)	
return

switch(g_had2[id][MODE])
{
case MODE_B:
{
g_had2[id][MODE] = MODE_A

if(get_player_weapon(id) == CSW_BASE)
{
set_player_nextattack(id, 1.0)
set_weapons_timeidle(id, CSW_BASE, 1.0)
set_weapon_anim(id, 10)	
}
}
case MODE_SIGNAL:
{
g_had2[id][MODE] = MODE_A

if(get_player_weapon(id) == CSW_BASE)
{
set_player_nextattack(id, 1.0)
set_weapons_timeidle(id,CSW_BASE, 1.0)
set_weapon_anim(id, 2)	
}
}
}
}

public Make_Grenade(id)
{
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent)) return

static Float:Origin[3], Float:Angles[3]

get_position(id, 50.0, 10.0, 0.0, Origin)
entity_get_vector(id, EV_VEC_angles, Angles)

entity_set_string(Ent, EV_SZ_classname,  M79_GRENADE)
entity_set_model(Ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(Ent, EV_INT_body, 1 - 1)

entity_set_int(Ent, EV_INT_movetype, MOVETYPE_TOSS)
entity_set_int(Ent, EV_INT_solid, SOLID_BBOX)
entity_set_int(Ent, EV_INT_effects, 2)

entity_set_vector(Ent,EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(Ent,EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_int(Ent, EV_INT_iuser1, id)
entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, Angles)

static Float:Velocity[3]
VelocityByAim(id, 780, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 

Make_PunchAngle(id, 10.0, 0.0)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(Ent) // entity
write_short(ef_sprite[2]) // sprite
write_byte(10)  // life
write_byte(3)  // width
write_byte(200) // r
write_byte(200)  // g
write_byte(200)  // b
write_byte(100) // brightness
message_end()	
}
public fw_Grenade_Touch(Ent)
{
if(!is_valid_ent(Ent))
return

Grenade_Explosion(Ent)
}
public Grenade_Explosion(Ent)
{	
if (!is_valid_ent(Ent))
return;

static Float:Origin[3], TE_FLAG
entity_get_vector(Ent, EV_VEC_origin, Origin)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND

message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
write_byte(TE_EXPLOSION)
write_coord_f(Origin[0])
write_coord_f(Origin[1])
write_coord_f(Origin[2] + 30.0)
write_short(ef_sprite[1])
write_byte(25)
write_byte(40)
write_byte(TE_FLAG)
message_end()		

static Owner; Owner = entity_get_int(Ent, EV_INT_iuser1)
Check_AttackDamge(Ent, Owner, 250.0, 400.0)

emit_sound(Ent, CHAN_BODY, "ZB5/weapons/janus1_exp.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

remove_entity(Ent)
}

// THANATOS 1 SPECIAL
public Make_Thanatos1(id)
{
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent)) return

static Float:Origin[3], Float:Angles[3]
get_position(id, 50.0, 10.0, 0.0, Origin)
entity_get_vector(id, EV_VEC_angles, Angles)

entity_set_string(Ent, EV_SZ_classname,  THANATOS1_GRENADE)
entity_set_model(Ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(Ent, EV_INT_body, 8 - 1)
entity_set_int(Ent, EV_INT_sequence, 6)

entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(Ent, EV_INT_solid, SOLID_BBOX)
entity_set_int(Ent, EV_INT_effects, 2)

entity_set_vector(Ent,EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(Ent,EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_int(Ent, EV_INT_iuser1, id)
entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, Angles)

static Float:Velocity[3]
VelocityByAim(id, 1800, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(Ent) // entity
write_short(ef_sprite[2]) // sprite
write_byte(10)  // life
write_byte(3)  // width
write_byte(100) // r
write_byte(10)  // g
write_byte(200)  // b
write_byte(100) // brightness
message_end()	

Make_PunchAngle(id, 10.0, 0.0)

update_specialammo(id, g_had2[id][AMMO], 0)
g_had2[id][AMMO]--
update_specialammo(id, g_had2[id][AMMO], g_had2[id][AMMO] > 0 ? 1 : 0)
}
public fw_Thanatos1_Touch(Ent, id)
{
if(!is_valid_ent(Ent))
return

Thanatos1_Explosion(Ent)
}
public Thanatos1_Explosion(Ent)
{	
if (!is_valid_ent(Ent))
return;

static Float:Origin[3], TE_FLAG
entity_get_vector(Ent, EV_VEC_origin, Origin)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
write_coord_f(Origin[0])
write_coord_f(Origin[1])
write_coord_f(Origin[2] + 20.0)
write_short(ef_sprite[4])
write_byte(15)
write_byte(10)
write_byte(TE_FLAG)
message_end()		

emit_sound(Ent, CHAN_AUTO, "ZB5/weapons/thanatos11_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

static Owner; Owner = entity_get_int(Ent, EV_INT_iuser1)
Check_AttackDamge(Ent, Owner, 150.0, 150.0)

remove_entity(Ent)
}


// STOCK
public Check_AttackDamge(Ent, Attacker, Float:Ratio, Float:ZombieDamage)
{
if(!is_valid_ent(Ent) && !is_player(Attacker, 0))
return
	
static Float:origin[3]
entity_get_vector(Ent, EV_VEC_origin, origin)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, Ratio)) != 0)
{
if(Attacker == Victim)
continue;

do_attack(Attacker, Victim, 0, ZombieDamage, 1)
}
}
public Play_AttackAnimation(id, Right)
{
static iAnimDesired, szAnimation[64]
static iFlags; iFlags = pev(id, pev_flags)

if(!Right)	
formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", WEAPON_ANIMEXT3);
else 
formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot2_%s" : "ref_shoot2_%s", WEAPON_ANIMEXT3);

if((iAnimDesired = lookup_sequence(id, szAnimation)) == -1)
iAnimDesired = 0;

set_pev(id, pev_sequence, iAnimDesired)
}

public update_ammo(id)
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
write_byte(1)
write_byte(CSW_BASE)
write_byte(-1)
message_end()

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, id)
write_byte(9)
write_byte(g_had2[id][AMMO])
message_end()
}

stock SPR(id, const weapon[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
write_string(weapon)
write_byte(9)
write_byte(52)
write_byte(-1)
write_byte(-1)
write_byte(1)
write_byte(3)
write_byte(1)
write_byte(0)
message_end() 
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_weapon_remove_post(id)Reset_All(id, 1)

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
Reset_All(id, 1)

Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
}

Safety_Disconnected(id)
{
Reset_All(id, 1)

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

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

if(g_had[id] == DDEALGE)
{
g_had[id] = INVALID
ham_strip_weapon(id, weapon_base)
}

Reset_All(id, 1)
}
public zp_fw_core_cure_post(id)
{	
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id, 1)
}

public fw_Safety_Killed_Post(id)
{
Reset_All(id, 1)

UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)

Reset_All(id, 1)
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

