#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>
#include <infinitygame>

#define CSW_BASE CSW_MP5NAVY
#define weapon_base "weapon_mp5navy"

#define K1A_CLASSNAME "k1ases"
#define PLASMABALL_CLASSNAME "plasmaball"

#define THANATOS3_SCYTHE_WIND_CLASSNAME	"scythe_thanatos3_wind_attack"
#define THANATOS3_SCYTHE_CLASSNAME	"scythe_thanatos3"
#define PLAYER_ANIM_EXT_B "dualpistols_1"

new const sound[][] =
{
"ZB5/weapons/plasmagun_exp.wav",	
"ZB5/weapons/sfsmg-1.wav",	
"ZB5/weapons/dmp7-1.wav",
"ZB5/weapons/k1a-1.wav",
"ZB5/weapons/plasmagun-1.wav",
"ZB5/weapons/thanatos3-1.wav",
"ZB5/weapons/thanatos3_knife_hit.wav",
"ZB5/weapons/thanatos3_knife_swish.wav",
"ZB5/weapons/thanatos3_fly_shoot.wav"
}
new const models[][] =
{
"models/ZB5/Primary/v_dmp7a1.mdl",
"models/ZB5/Primary/v_plasma.mdl",		
"models/ZB5/Primary/v_thanatos3.mdl",
"models/ZB5/Primary/v_sfsmg.mdl",
"models/ZB5/Primary/v_k1ases.mdl",	
"sprites/ZB5/plasmaball.spr"	
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud65.spr",
"sprites/ZB5/HUD2/640hud110.spr",
"sprites/ZB5/HUD2/640hud137.spr",			
"sprites/weapon_dmp7a1_2_MSBG.txt",
"sprites/weapon_sfsmg_MSBG.txt",
"sprites/weapon_plasmagun_MSBG.txt",
"sprites/weapon_thanatos3_MSBG.txt",
"sprites/weapon_k1a_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_dmp7a1_2_MSBG",
"weapon_sfsmg_MSBG",
"weapon_plasmagun_MSBG",
"weapon_thanatos3_MSBG",
"weapon_k1a_MSBG"
}
enum Weapons
{
INVALID = 0,	
DMP7A1,
PLASMA,
TEMPSET,
THANATOS3,
K1A
}

enum _:Options
{
Float:ATTACK1,
Float:DAMAGE_T,		
TMPCLIP,
SHOTS,	
AMMO,
DUAL,
MODE,
Old
}

enum
{
MODE_NORMAL1 = 0,
MODE_WINGS_1,
MODE_WINGS_2,
MODE_WINGS_3
}

new Weapons:g_had[33], g_had2[33][Options], ef_sprite[3]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]
new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

public plugin_init() 
{
if(!zb5_weapons_primary())
return
		
Register_SafetyFunc()	
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")

register_touch(K1A_CLASSNAME, "*", "fw_K1a_Touch")

register_think(PLASMABALL_CLASSNAME, "fw_Think_Plasma")
register_touch(PLASMABALL_CLASSNAME, "*", "fw_Touch")

register_think(THANATOS3_SCYTHE_WIND_CLASSNAME, "fw_Scythe_Wind_Think")
register_touch(THANATOS3_SCYTHE_CLASSNAME, "*", "fw_Touch_Scythe")

RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_Item_AddToPlayer_Post", 1)
RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload_Post", 1);
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fwWeaponIdle")

RegisterHam(Ham_Item_PostFrame, weapon_base, "Frame")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload")
RegisterHam(Ham_TakeDamage, "player", "fw_takedmg")

register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")
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

ef_sprite[0] = PrecacheModel("sprites/laserbeam.spr")
ef_sprite[1] = PrecacheModel("sprites/ZB5/plasmabomb.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/deimosexp.spr")

PrecacheModel("sprites/ZB5/muz_sfmg.spr")
PrecacheModel("sprites/ZB5/muzzleflash27.spr")
}
public plugin_natives()
{
register_native("get_weapon_subgun", "Get_Subgun", 1)	
register_native("had_weapon_plasma", "Had_Plasma", 1)	
register_native("zb5_had_dmp7a1", "Had_DMP7A1", 1)
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}
public Had_DMP7A1(id)return g_had[id] == DMP7A1
public Had_Plasma(id)return g_had[id] == PLASMA
public zp_fw_round_start_post()remove_entity_name("scythe_thanatos3_wind_attack")

public Get_Subgun(id, Weapon)
{	
if(!zb5_weapons_primary())
return
	
drop_weapons(id, 1)
Reset_All(id)
fm_give_item(id, weapon_base)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

switch(Weapon)
{
case 1:
{
g_had[id] = DMP7A1
cs_set_weapon_ammo(Ent, 80)	
SPR(id, "weapon_dmp7a1_2_MSBG")
}
case 2:
{
g_had[id] = PLASMA
cs_set_weapon_ammo(Ent, 45)	
SPR(id, "weapon_plasmagun_MSBG")
IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash27.spr", 0.20)
}
case 3:
{
g_had[id] = TEMPSET
cs_set_weapon_ammo(Ent, 40)	
SPR(id, "weapon_sfsmg_MSBG")
IG_Muzzleflash_Set(id, "sprites/ZB5/muz_sfmg.spr", 0.20)
}
case 4:
{
g_had[id] = THANATOS3
cs_set_weapon_ammo(Ent, 50)	
SPR(id, "weapon_thanatos3_MSBG")
}
case 5:
{
g_had[id] = K1A
SPR(id, "weapon_k1a_MSBG")
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

public Reset_All(id)
{
reset_weapons_recoil(id)
update_specialammo(id, g_had2[id][AMMO], 0)	

arrayset(_:g_had[id], false, sizeof(g_had[]));
arrayset(_:g_had2[id], false, sizeof(g_had2[]));	
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
case DMP7A1:
{
SubModel = 5
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_dmp7a1.mdl")
}
case PLASMA:
{
SubModel = 15
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_plasma.mdl")
}
case TEMPSET:
{
SubModel = 22
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_sfsmg.mdl")
}
case K1A:
{
SubModel = 29
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_k1ases.mdl")
}
case THANATOS3:
{
SubModel = 12
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_thanatos3.mdl")
}
}

set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
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
case DMP7A1:
{
set_pdata_string(id, (492) * 4, PLAYER_ANIM_EXT_B, -1 , 20)
Submodel = 5;Sequence = 4	
}
case PLASMA:
{
Submodel = 15;Sequence = 13
}
case TEMPSET:
{
Submodel = 22;Sequence = 21
}
case K1A:
{
Submodel = 29;Sequence = 27
}
case THANATOS3:
{
g_had2[id][MODE] = MODE_NORMAL1
g_had2[id][SHOTS] = 0

set_weapon_anim(id, 18)
update_specialammo(id, g_had2[id][AMMO], 0)
g_had2[id][AMMO] = 0

Submodel = 12;Sequence = 10
}
}

engfunc(EngFunc_SetModel, ent, P_Model)	
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)	
set_weapons_timeidle(id, CSW_BASE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)
}
} else {

if(is_valid_ent(ent)) 
set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 

update_specialammo(id, g_had2[id][AMMO], 0)		
}
}

public fw_SetModel(entity, model[])
{
if(!is_valid_ent(entity))
return FMRES_IGNORED

static Classname[32]
pev(entity, pev_classname, Classname, sizeof(Classname))

if(!equal(Classname, "weaponbox"))
return FMRES_IGNORED

static iOwner; iOwner = pev(entity, pev_owner)

if(!equal(model, "models/w_mp5.mdl"))
return FMRES_IGNORED;

static weapon; weapon = find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

static Weapons:had
had = g_had[iOwner] 

switch(had)
{
case DMP7A1:
{
set_pev(weapon, pev_impulse, DMP7A1)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 6 - 1)
Reset_All(iOwner)	
return FMRES_SUPERCEDE
}
case PLASMA:
{
set_pev(weapon, pev_impulse, PLASMA)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 17 - 1)
Reset_All(iOwner)	
return FMRES_SUPERCEDE
}
case TEMPSET:
{
set_pev(weapon, pev_impulse, TEMPSET)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 15 - 1)
Reset_All(iOwner)	
return FMRES_SUPERCEDE
}
case THANATOS3:
{
set_pev(weapon, pev_impulse, THANATOS3)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 21 - 1)
Reset_All(iOwner)	
return FMRES_SUPERCEDE
}
case K1A:
{
set_pev(weapon, pev_impulse, K1A)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(weapon, pev_iuser4, g_had2[iOwner][AMMO])
set_pev(entity, pev_body, 19 - 1)
Reset_All(iOwner)	
return FMRES_SUPERCEDE
}
}

return FMRES_IGNORED;
}
public fw_Item_AddToPlayer_Post(ent, id)
{
if(!is_valid_ent(ent))
return 

static impulse; impulse = pev(ent, pev_impulse)
switch(impulse)
{
case DMP7A1:
{
Reset_All(id)

g_had[id] = DMP7A1
SPR(id, "weapon_dmp7a1_2_MSBG")

set_pev(ent, pev_impulse, 0)
}
case PLASMA:
{
Reset_All(id)

g_had[id] = PLASMA
SPR(id, "weapon_plasmagun_MSBG")

IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash27.spr", 0.20)
set_pev(ent, pev_impulse, 0)
}
case TEMPSET:
{
Reset_All(id)

g_had[id] = TEMPSET
SPR(id, "weapon_sfsmg_MSBG")

IG_Muzzleflash_Set(id, "sprites/ZB5/muz_sfmg.spr", 0.20)
set_pev(ent, pev_impulse, 0)
}
case THANATOS3:
{
Reset_All(id)

g_had[id] = THANATOS3
SPR(id, "weapon_thanatos3_MSBG")

set_pev(ent, pev_impulse, 0)
}
case K1A:
{
Reset_All(id)

g_had[id] = K1A
g_had2[id][AMMO] = pev(ent, pev_iuser4)

SPR(id, "weapon_k1a_MSBG")
set_pev(ent, pev_impulse, 0)
}
}

}

public fw_PlaybackEvent(flags, id, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
if(!is_player(id, 0))
return FMRES_IGNORED	

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had == INVALID)	
return FMRES_IGNORED

switch(had)
{
case DMP7A1:
{
if(g_had2[id][DUAL]) 
{
set_weapon_anim(id, 3)
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side					
Play_AttackAnimation(id, 0)
}
else 
{
set_weapon_anim(id, 4)
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
Play_AttackAnimation(id, 1)
}
g_had2[id][DUAL] = !g_had2[id][DUAL] ? 1 : 0

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dmp7-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_player_nextattack(id, 0.080)
Make_PunchAngle(id, 5.0, 0.0)
}
case TEMPSET:
{
IG_Muzzleflash_Activate(id);		
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/sfsmg-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(id, random_num(3,5))
set_player_nextattack(id, 0.070)
Make_PunchAngle(id, 2.0, 1.0)
}
case K1A:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/k1a-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(id, random_num(3,5))
set_player_nextattack(id, 0.070)

g_had2[id][SHOTS]++
if(g_had2[id][SHOTS] == 15)
{	
update_specialammo(id, g_had2[id][AMMO], 0)	
g_had2[id][AMMO]++
update_specialammo(id, g_had2[id][AMMO], 1)
g_had2[id][SHOTS] = 0
}
}
case THANATOS3:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos3-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		

switch(g_had2[id][MODE])
{
case MODE_WINGS_1: set_weapon_anim(id, 5)
case MODE_WINGS_2: set_weapon_anim(id, 6)
case MODE_WINGS_3: set_weapon_anim(id, 7)
default:set_weapon_anim(id, 4)
}
g_had2[id][SHOTS]++
if(g_had2[id][SHOTS] == 15)
Thanatos3_Change_Mode(id)
}
}
engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
return FMRES_SUPERCEDE
}
public Play_AttackAnimation(id, Right)
{
static iAnimDesired, szAnimation[64]
static iFlags; iFlags =  entity_get_int(id, EV_INT_flags)

if(!Right)	
formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", PLAYER_ANIM_EXT_B);
else 
formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot2_%s" : "ref_shoot2_%s", PLAYER_ANIM_EXT_B);

if((iAnimDesired = lookup_sequence(id, szAnimation)) == -1)
iAnimDesired = 0;

entity_set_int(id, EV_INT_sequence, iAnimDesired)
}
public fw_takedmg(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_player(attacker, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[attacker] 

if(get_player_weapon(attacker) != CSW_BASE || had == INVALID)	
return HAM_IGNORED;

if(had == PLASMA)
return HAM_IGNORED;

if (damage_type & (1<<24))
return HAM_IGNORED;

static Float:Damage
switch(had)
{
case DMP7A1:Damage = 4.0
case TEMPSET:Damage = 1.5
case K1A:Damage = 1.4
case THANATOS3:Damage = 1.8
}
SetHamParamFloat(4, damage * Damage)
return HAM_HANDLED
}
public fwWeaponIdle(ent)
{
if (!is_valid_ent(ent))
return HAM_IGNORED

static id; id = get_pdata_cbase(ent, 41, 4)

if(!is_player(id, 1))
return HAM_IGNORED

if(get_pdata_float(ent, m_flTimeWeaponIdle, 4) <= 0.0)
{
if (g_had[id] != THANATOS3)
return HAM_IGNORED

switch(g_had2[id][MODE])
{
case MODE_WINGS_1: set_weapon_anim(id, 1)
case MODE_WINGS_2: set_weapon_anim(id, 2)
case MODE_WINGS_3: set_weapon_anim(id, 3)
default:set_weapon_anim(id, 0)
}
set_pdata_float(ent, m_flTimeWeaponIdle, 20.0, 4)

return HAM_SUPERCEDE
}

return HAM_IGNORED
}

public Frame(weapon_entity) 
{
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)
static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)
static fInReload; fInReload  = get_pdata_int(weapon_entity, 54, 4)
static Button; Button = (entity_get_int(id, EV_INT_button) & IN_ATTACK2 && flNextAttack <= 0.0)

static j,c
switch(had)
{
case DMP7A1:c = 80
case PLASMA:c = 45
case TEMPSET:c = 40
case THANATOS3:c = 50
case K1A:
{
if(Button && g_had2[id][AMMO] > 0)
{
set_weapon_anim(id, 6)	
set_task(0.3, "K1A_Shoot", id)	

set_weapons_timeidle(id, CSW_BASE, 2.0)
set_player_nextattack(id, 2.0)
}	

c = 30
}
}

if(fInReload && flNextAttack <= 0.0)
{		
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
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

g_had2[id][TMPCLIP] = -1;

static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)

if (iBpAmmo <= 0)
return HAM_SUPERCEDE;

static c
switch(had)
{
case DMP7A1:c = 80
case PLASMA:c = 45
case TEMPSET:c = 40
case THANATOS3:c = 50
case K1A:c = 30
}	

if (iClip >= c)
return HAM_SUPERCEDE;

g_had2[id][TMPCLIP] = iClip;

return HAM_IGNORED;
}
public Reload_Post(weapon_entity) 
{
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

if (g_had2[id][TMPCLIP] == -1)
return HAM_IGNORED;

static Float:time2
switch(had)
{
case DMP7A1:time2 = 3.4
case PLASMA:time2 = 3.5 
case TEMPSET:time2 = 3.0
case THANATOS3:
{
time2 = 3.0

switch(g_had2[id][MODE])
{
case MODE_WINGS_1: set_weapon_anim(id, 12)
case MODE_WINGS_2: set_weapon_anim(id, 13)
case MODE_WINGS_3: set_weapon_anim(id, 14)
default:set_weapon_anim(id, 11)
}
}
case K1A:time2 = 3.0
default:set_weapon_anim(id, 1)
}	

set_pdata_int(weapon_entity, m_iClip, g_had2[id][TMPCLIP], WEAP_LINUX_XTRA_OFF)
set_pdata_float(weapon_entity, m_flTimeWeaponIdle, time2, WEAP_LINUX_XTRA_OFF)
set_pdata_float(id, m_flNextAttack, time2, PLAYER_LINUX_XTRA_OFF)
set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)
return HAM_IGNORED;
}

public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED;

static Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_BASE || had != THANATOS3 && had != PLASMA)
return FMRES_IGNORED;

static ent; ent = find_ent_by_owner(-1, weapon_base, id)
if(!is_valid_ent(ent))
return FMRES_IGNORED

static PressedButton 
PressedButton = get_uc(uc_handle, UC_Buttons)

if(get_pdata_float(id, 83, 5) > 0.0) 
return FMRES_IGNORED

switch(had)
{
case PLASMA:
{
if(PressedButton & IN_ATTACK)
{
PressedButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, PressedButton)

if(cs_get_weapon_ammo(ent) <= 0 || get_pdata_int(ent, 54, 4))
return FMRES_IGNORED

if(get_gametime() - 0.200 > g_had2[id][ATTACK1])
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/plasmagun-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	

set_weapon_anim(id, random_num(3,4))
Make_PunchAngle(id, 0.0, 3.0)

IG_Muzzleflash_Activate(id)
cs_set_weapon_ammo(ent, cs_get_weapon_ammo(ent) -1)

Create_PlasmaBall(id)
g_had2[id][ATTACK1] = get_gametime()
}

}
}
case THANATOS3:
{
if(PressedButton & IN_ATTACK2 && g_had2[id][AMMO] != 0)
{
if(get_pdata_float(id, 83, 5) > 0.0)
return FMRES_IGNORED

PressedButton &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, PressedButton)

static Float:Origin[3]
switch(g_had2[id][MODE])
{
case MODE_WINGS_1:
{
set_weapon_anim(id, 8)
get_position(id, 2.0, 0.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 0.0)
set_task(0.1, "Special_Shoot_Wings_2", id)
}
case MODE_WINGS_2:
{
set_weapon_anim(id, 9)
get_position(id, 2.0, 0.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 0.0)

set_task(0.1, "Special_Shoot_Wings_2", id)
set_task(0.2, "Special_Shoot_Wings_3", id)
set_task(0.3, "Special_Shoot_Wings_4", id)

}
case MODE_WINGS_3:
{
set_weapon_anim(id, 10)
get_position(id, 2.0, 0.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 0.0)

set_task(0.1, "Special_Shoot_Wings_2", id)
set_task(0.2, "Special_Shoot_Wings_3", id)
set_task(0.3, "Special_Shoot_Wings_4", id)
set_task(0.4, "Special_Shoot_Wings_5", id)
set_task(0.5, "Special_Shoot_Wings_6", id)
}
}

set_task(0.6, "Reset_Mode", id)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos3_fly_shoot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_player_nextattack(id, 2.0)
set_weapons_timeidle(id, CSW_BASE, 2.0)

Make_PunchAngle(id, 4.0, 0.0)
update_specialammo(id, g_had2[id][AMMO], 0)
g_had2[id][AMMO] = 0
}
}
}
return FMRES_HANDLED
}
//// THANATOS 3 SYSTEM ////
public Thanatos3_Change_Mode(id)
{
if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || g_had[id] != THANATOS3)
return;

switch(g_had2[id][MODE])
{
case MODE_NORMAL1:
{
g_had2[id][SHOTS] = 0

update_specialammo(id, g_had2[id][AMMO], 0)
g_had2[id][AMMO] = 1
update_specialammo(id, g_had2[id][AMMO], 1)

set_weapon_anim(id, 15)
}
case MODE_WINGS_1:
{
g_had2[id][SHOTS] = 0

update_specialammo(id, g_had2[id][AMMO], 0)
g_had2[id][AMMO] = 2
update_specialammo(id, g_had2[id][AMMO], 1)

set_weapon_anim(id, 16)
}
case MODE_WINGS_2:
{
g_had2[id][SHOTS] = 0

update_specialammo(id, g_had2[id][AMMO], 0)
g_had2[id][AMMO] = 3
update_specialammo(id, g_had2[id][AMMO], 1)

set_weapon_anim(id, 17)
}
}

switch(g_had2[id][MODE])
{
case MODE_NORMAL1: g_had2[id][MODE] = MODE_WINGS_1
case MODE_WINGS_1: g_had2[id][MODE] = MODE_WINGS_2
case MODE_WINGS_2: g_had2[id][MODE] = MODE_WINGS_3
}

set_player_nextattack(id, 0.1)
set_weapons_timeidle(id, CSW_BASE, 0.1)
}
public Special_Shoot_Wings_2(id)
{
static Float:Origin[3]

switch(g_had2[id][MODE])
{
case MODE_WINGS_1:
{
get_position(id, 0.0, 12.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 12.0)
}
case MODE_WINGS_2:
{
get_position(id, 0.0, -12.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, -12.0)
}
case MODE_WINGS_3:
{
get_position(id, 0.0, -24.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, -24.0)
}
}
}

public Special_Shoot_Wings_3(id)
{
static Float:Origin[3]
switch(g_had2[id][MODE])
{
case MODE_WINGS_2:
{
get_position(id, 0.0, 12.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 12.0)
}
case MODE_WINGS_3:
{
get_position(id, 0.0, -12.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, -12.0)
}
}
}

public Special_Shoot_Wings_4(id)
{
static Float:Origin[3]
switch(g_had2[id][MODE])
{
case MODE_WINGS_2:
{
get_position(id, 0.0, 24.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 24.0)
}
case MODE_WINGS_3:
{
get_position(id, 0.0, 12.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 12.0)
}
}
}

public Special_Shoot_Wings_5(id)
{
static Float:Origin[3]
get_position(id, 0.0, 12.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 12.0)
}

public Special_Shoot_Wings_6(id)
{
static Float:Origin[3]
get_position(id, 0.0, 36.0, 0.0, Origin)
Special_Shoot_Wings(id, Origin, 36.0)
}

public Reset_Mode(id)
{
if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || g_had[id] != THANATOS3)
return

g_had2[id][MODE] = MODE_NORMAL1
g_had2[id][SHOTS] = 0

g_had2[id][AMMO] = 0
update_specialammo(id, g_had2[id][AMMO], 0)
}

public Special_Shoot_Wings(id, Float:StartOrigin[3], Float:New_Target)
{
static Float:TargetOrigin[3], Float:angles[3], Float:angles_fix[3]
entity_get_vector(id, EV_VEC_angles, angles)

static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent))
return;

angles_fix[0] = 450.0 - angles[0]
angles_fix[1] = angles[1]
angles_fix[2] = angles[2]

entity_set_string(Ent, EV_SZ_classname, THANATOS3_SCYTHE_CLASSNAME)
entity_set_model(Ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")

entity_set_int(Ent,EV_INT_body, 8 - 1)
entity_set_int(Ent,EV_INT_sequence, 6)

entity_set_int(Ent,EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(Ent,EV_INT_solid, SOLID_BBOX)
entity_set_edict(Ent, EV_ENT_owner, id)

entity_set_vector(Ent,EV_VEC_mins, Float:{-0.1, -0.1, -0.1})
entity_set_vector(Ent,EV_VEC_maxs, Float:{0.1, 0.1, 0.1})

entity_set_origin(Ent, StartOrigin)
entity_set_vector(Ent, EV_VEC_angles, angles_fix)

entity_set_float(Ent, EV_FL_gravity, 0.01)
entity_set_float(Ent, EV_FL_frame, 0.0)

// Animation
entity_set_float(Ent, EV_FL_animtime, get_gametime())
entity_set_float(Ent, EV_FL_framerate, 1.0)
entity_set_int(Ent, EV_INT_sequence, 0)

static Float:Velocity[3]
fm_get_aim_origin(id, TargetOrigin)
TargetOrigin[1] += New_Target

get_speed_vector(StartOrigin, TargetOrigin, 2000.0, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // Temporary entity ID
write_short(Ent) // Entity
write_short(ef_sprite[0]) // Sprite index
write_byte(4) // Life
write_byte(2) // Line width
write_byte(65)
write_byte(69)
write_byte(121)
write_byte(255) // Alpha
message_end()

entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.01) 
}

public fw_Touch_Scythe(Ent, Id)
{
if(!is_valid_ent(Ent))
return

static Float:originF[3]; entity_get_vector(Ent, EV_VEC_origin, originF)
static Owner; Owner = entity_get_edict(Ent, EV_ENT_owner)

Check_AttackDamge(Owner, Ent, 20.0, random_float(10.0,20.0))

if(Get_BitVar(g_IsZombie, Id))
{
Scythe_Wind_Attack(Id, Owner)
emit_sound(Id, CHAN_BODY, "ZB5/weapons/thanatos3_knife_hit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}
else
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_DECAL)
write_coord_f(originF[0])
write_coord_f(originF[1])
write_coord_f(originF[2])
write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
write_short(Ent)
message_end()

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_WORLDDECAL)
write_coord_f(originF[0])
write_coord_f(originF[1])
write_coord_f(originF[2])
write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
message_end()
}

remove_entity(Ent)
}

public Scythe_Wind_Attack(id, attacker)
{
static iEnt; iEnt = create_entity("info_target")
if(!is_valid_ent(iEnt)) 
return;

static Float:MyOrigin[3], Float:New_Origin[3]
entity_get_vector(id, EV_VEC_origin, MyOrigin)

New_Origin[0] = -10.5
New_Origin[1] = 0.5 // 2
New_Origin[2] = 5.0	

MyOrigin[0] += New_Origin[0]
MyOrigin[1] += New_Origin[1]
MyOrigin[2] += New_Origin[2]

entity_set_string(iEnt, EV_SZ_classname, THANATOS3_SCYTHE_WIND_CLASSNAME)
entity_set_model(iEnt, "models/ZB5/Items/ZB5_Items_NEW.mdl")

entity_set_int(iEnt, EV_INT_body, 5 - 1)
entity_set_int(iEnt, EV_INT_sequence, 3)

entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW)

entity_set_origin(iEnt, MyOrigin)
entity_set_edict(iEnt, EV_ENT_owner, attacker)
entity_set_edict(iEnt, EV_ENT_aiment, id)

entity_set_float(iEnt, EV_FL_framerate, 5.0)
entity_set_int(iEnt, EV_INT_sequence, 0)
entity_set_float(iEnt, EV_FL_scale, 10.0)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // Temporary entity ID
write_short(iEnt) // Entity
write_short(ef_sprite[0]) // Sprite index
write_byte(5) // Life
write_byte(2) // Line width
write_byte(65)
write_byte(69)
write_byte(121)
write_byte(100) // Alpha
message_end()

entity_set_float(iEnt, EV_FL_animtime, get_gametime())
entity_set_float(iEnt, EV_FL_fuser1, get_gametime() + 5.0)
entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)
}

public fw_Scythe_Wind_Think(iEnt)
{
if(!is_valid_ent(iEnt))
return;

static victim
victim = pev(iEnt, pev_aiment)

if(!Get_BitVar(g_IsZombie, victim))
{
remove_entity(iEnt)
return;
}
/*else
{
static Damage
	
if(get_gametime() - 0.5 > g_had2[victim][DAMAGE_T])
{
switch(is_valid_ent(iEnt))
{
case 2:Damage = random_num(10,50);
case 4:Damage = random_num(50,100);
case 6:Damage = random_num(100,150);
}

Check_AttackDamge(Owner, iEnt, 1.0, float(Damage))
emit_sound(victim, CHAN_BODY, "ZB5/weapons/thanatos3_knife_swish.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_pev(iEnt, pev_fuser2, get_gametime())
g_had2[victim][DAMAGE_T] = get_gametime()
}
}*/

static Float:fTimeRemove
pev(iEnt, pev_fuser1, fTimeRemove)

if (get_gametime() >= fTimeRemove)
{
remove_entity(iEnt)
return;
}

set_entity_anim(iEnt, 3)
entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.01)
}
///// PLASMA BALL SYSTEM /////
public Create_PlasmaBall(id)
{
static Float:StartOrigin[3], Float:TargetOrigin[3], Float:MyVelocity[3], Float:VecLength

get_position(id, 48.0, 10.0, -5.0, StartOrigin)
get_position(id, 1024.0, 0.0, 0.0, TargetOrigin)

entity_get_vector(id, EV_VEC_velocity, MyVelocity) 

VecLength = vector_length(MyVelocity)

if(VecLength)
{
TargetOrigin[0] += random_float(-16.0, 16.0); TargetOrigin[1] += random_float(-16.0, 16.0); TargetOrigin[2] += random_float(-16.0, 16.0)
}else{
TargetOrigin[0] += random_float(-8.0, 8.0); TargetOrigin[1] += random_float(-8.0, 8.0); TargetOrigin[2] += random_float(-8.0, 8.0)
}

static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent))
return;

entity_set_string(Ent, EV_SZ_classname, PLASMABALL_CLASSNAME)
entity_set_model(Ent, "sprites/ZB5/plasmaball.spr")

entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(Ent, EV_INT_solid, SOLID_BBOX)

entity_set_int(Ent, EV_INT_rendermode, kRenderTransAdd)
entity_set_float(Ent, EV_FL_renderamt, random_float(50.0, 100.0))

entity_set_int(Ent, EV_INT_iuser1, id)	
entity_set_float(Ent, EV_FL_scale, random_float(0.1, 0.25))

entity_set_vector(Ent, EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(Ent, EV_VEC_maxs, Float:{1.0, 1.0, 1.0})
entity_set_origin(Ent, StartOrigin)

entity_set_float(Ent, EV_FL_fuser1, get_gametime() + 3.0) 
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.1) 

static Float:Velocity[3]
get_speed_vector(StartOrigin, TargetOrigin, 1200.0, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity)
}
public fw_Think_Plasma(Ent)
{
if(!is_valid_ent(Ent))
return

static Float:RenderAmt; RenderAmt = entity_get_float(Ent,EV_FL_renderamt)

RenderAmt += 50.0
RenderAmt = float(clamp(floatround(RenderAmt), 0, 255))

entity_set_float(Ent, EV_FL_renderamt, RenderAmt)
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.1) 
}
public fw_Touch(ent, id)
{
if(!is_valid_ent(ent))
return
if(entity_get_int(ent, EV_INT_movetype) == MOVETYPE_NONE)
return

static Float:Origin[3], TE_FLAG
entity_get_vector(ent, EV_VEC_origin, Origin)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND
TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[1])
write_byte(7)
write_byte(40)
write_byte(TE_FLAG)
message_end()	

static Owner; Owner = entity_get_int(ent,EV_INT_iuser1)
Check_AttackDamge(Owner, ent, 50.0, random_float(10.0, 70.0))

emit_sound(ent, CHAN_AUTO, "ZB5/weapons/plasmagun_exp.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
remove_entity(ent)
}


///// DEIMOS SYSTEM ////
public K1A_Shoot(id)
{
if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || g_had[id] != K1A)
return

Make_K1A(id)	
}

public Make_K1A(id)
{
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent))
return;

static Float:Velocity[3], Float:Origin[3], Float:Angles[3]

get_position(id, 50.0, 10.0, 0.0, Origin)
entity_get_vector(id, EV_VEC_angles, Angles)

entity_set_string(Ent,EV_SZ_classname, K1A_CLASSNAME)
entity_set_model(Ent,"models/ZB5/Items/ZB5_Items_NEW.mdl")

entity_set_int(Ent, EV_INT_body, 9 -1)
entity_set_int(Ent, EV_INT_sequence, 7)

entity_set_edict(Ent, EV_ENT_owner, id);
entity_set_int(Ent,EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(Ent,EV_INT_solid, SOLID_BBOX)

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, Angles)

VelocityByAim(id, 1200, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 

emit_sound(Ent, CHAN_AUTO, "ZB5/deimos_skill_start.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // Temporary entity ID
write_short(Ent) // Entity
write_short(ef_sprite[2]) // Sprite index
write_byte(25) // Life
write_byte(10) // Line width
write_byte(255)
write_byte(212)
write_byte(0)
write_byte(250)	// brightness
message_end()

Make_PunchAngle(id, 10.0, 0.0)

update_specialammo(id, g_had2[id][AMMO], 0)
g_had2[id][AMMO]--
update_specialammo(id, g_had2[id][AMMO], g_had2[id][AMMO] > 0 ? 1 : 0)
}
public fw_K1a_Touch(Ent, id)
{
if(!is_valid_ent(Ent))
return

K1A_Explosion(Ent)
}
public K1A_Explosion(Ent)
{	
if (!is_valid_ent(Ent))
return;

static Float:Origin[3], TE_FLAG
entity_get_vector(Ent, EV_VEC_origin, Origin)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[2])
write_byte(40)
write_byte(30)
write_byte(14)
message_end()

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_PARTICLEBURST) // TE id
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 16.0)
write_short(30) // radius
write_byte(0) // color
write_byte(1) // duration (will be randomized a bit)
message_end()

emit_sound(Ent, CHAN_AUTO, "ZB5/deimos_skill_hit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

static attacker; attacker = entity_get_edict(Ent, EV_ENT_owner)
Check_AttackDamge(attacker, Ent, 150.0, 300.0)

remove_entity(Ent)
}

public Check_AttackDamge(Attacker, Ent, Float:Ratio, Float:ZombieDamage)
{
if(!is_valid_ent(Ent) && !is_player(Attacker, 0))
return

static Float:origin[3]
entity_get_vector(Ent, EV_VEC_origin, origin)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, 100.0)) != 0)
{
if(Attacker == Victim)
continue;

do_attack(Attacker, Victim, 0, ZombieDamage, 1)
}
}
stock SPR(id, const weapon[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
write_string(weapon)
write_byte(10)
write_byte(120)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(7)
write_byte(19)
write_byte(0)
message_end()
}

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_weapon_remove_post(id)Reset_All(id)

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
Reset_All(id)

Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

g_PlayerWeapon[id] = 0
}

Safety_Disconnected(id)
{
Reset_All(id)

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
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
Reset_All(id)

UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Reset_All(id)

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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
