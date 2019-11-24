#include <amxmodx>
#include <ZombieMod5>
#include <infinitygame>

#define PLAYER_ANIM_EXT_A "knife"
#define PLAYER_ANIM_EXT_B "dualpistols"

#define SVDEX_GRENADE "svdex_grenade"
#define SCYTHE_CLASSNAME "mines"
#define SCYTHE_CLASSNAME2 "mines2"

#define TASK_RELOAD 112
#define TASK_STOP 115

#define CSW_BASE CSW_GALIL
#define weapon_base "weapon_galil"

new const sound[][] =
{	
"ZB5/weapons/skull4_shoot1.wav",
"ZB5/weapons/svdex_shoot1.wav",
"ZB5/weapons/svdex_shoot2.wav",
"ZB5/weapons/svdex_exp.wav",
"ZB5/weapons/janus5-1.wav",
"ZB5/weapons/janus5-2.wav",
"ZB5/weapons/janusmk5_change1.wav",
"ZB5/weapons/janusmk5_change2.wav",
"ZB5/weapons/thanatos5-1.wav",
"ZB5/weapons/thanatos5_shootb2_1.wav",
"ZB5/weapons/thanatos5_explode1.wav"
}
new const models[][] =
{
"models/ZB5/Primary/p_skull4.mdl",	
"models/ZB5/Primary/v_skull4_2.mdl",
"models/ZB5/Primary/v_janus5_2.mdl",
"models/ZB5/Primary/v_svdex.mdl",
"models/ZB5/Primary/v_thanatos5.mdl"
}
new const sprites[][] =
{		
"sprites/ZB5/HUD2/640hud36.spr",
"sprites/ZB5/HUD2/640hud87.spr",
"sprites/ZB5/HUD2/640hud36.spr",
"sprites/ZB5/HUD2/640hud98.spr",
"sprites/ZB5/HUD2/640hud100.spr",
"sprites/ZB5/HUD2/640hud125.spr",	
"sprites/weapon_janus5_MSBG.txt",
"sprites/weapon_skull4_MSBG.txt",
"sprites/weapon_svdex2_MSBG.txt",
"sprites/weapon_thanatos5_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_janus5_MSBG",
"weapon_skull4_MSBG",
"weapon_svdex2_MSBG",
"weapon_thanatos5_MSBG"
}
enum Weapons
{
INVALID = 0,	
SKULL4,
SVDEX,
JANUS5,
THANATOS5
}
enum _:Options
{
TMPCLIP,	
RELOAD,	
SHOTS,
SIGNAL,
DUAL,	
MODE,	
AMMO,
Old
}
enum 
{	
MODE_A,
MODE_B,
MODE_S
}
new Weapons:g_had[33], g_had2[33][Options], Float:g_attack1[33], ef_sprite[6], g_weapon[8]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]

public plugin_init() 
{
if(!zb5_weapons_primary())
return

Register_SafetyFunc()
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")

register_think(SCYTHE_CLASSNAME, "fw_Scythe_Think")
register_think(SCYTHE_CLASSNAME2, "fw_Scythe_Think2")
register_touch(SVDEX_GRENADE, "*", "fw_Svdex_Touch")	

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_Item_AddToPlayer_Post", 1)
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_WeaponIdle_Post", 1)

RegisterHam(Ham_Item_PostFrame, weapon_base, "Frame")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload_Post", 1);
RegisterHam(Ham_TakeDamage, "player", "fw_takedmg")
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player")

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
ef_sprite[1] = PrecacheModel("sprites/ZB5/svd_exp.spr")
ef_sprite[2] = PrecacheModel("sprites/ZB5/lv.spr")
ef_sprite[3] = PrecacheModel("sprites/wall_puff1.spr")
ef_sprite[4] = PrecacheModel("sprites/ZB5/thanatos5_explode.spr")
ef_sprite[5] = PrecacheModel("sprites/ZB5/thanatos5_explode2.spr")
PrecacheModel("sprites/ZB5/muzzleflash25.spr")

g_weapon[0] = zb5_register_weapon("SF Gun", "Blaster", WPN_SUBS, LEVEL_SFGUN, 0)
g_weapon[1] = zb5_register_weapon("SF SMG", "Tempest", WPN_SUBS, LEVEL_TEMPSET, 0)
g_weapon[2] = zb5_register_weapon("Dual Kriss", "Hero", WPN_SUBS, LEVEL_DUALKRISS, 0)
g_weapon[3] = zb5_register_weapon("Double Skull-4", "\r(Nightmare)", WPN_RIFLES, LEVEL_SKULL4, 0)
g_weapon[4] = zb5_register_weapon("Thanatos 5", "Rifle", WPN_RIFLES, LEVEL_THANATOS5, 0)
g_weapon[5] = zb5_register_weapon("HK416 Janus5", "Rifle", WPN_RIFLES, LEVEL_JANUS5, 0)
g_weapon[6] = zb5_register_weapon("Thanatos 3", "Wings Rifle", WPN_SUBS, LEVEL_THANATOS3, 0)
g_weapon[7] = zb5_register_weapon("K1ases", "\yDeimos Shadow", WPN_SUBS, LEVEL_K1ASES, 0)
}

public plugin_natives()
{
register_native("get_weapon_rifle", "Get_Rifle", 1)	
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}
public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0]) get_weapon_scope(id, 3)
else if(wpnid == g_weapon[1]) get_weapon_subgun(id, 3)
else if(wpnid == g_weapon[2]) get_weapon_scope(id, 4)
else if(wpnid == g_weapon[3]) Get_Rifle(id, 1)
else if(wpnid == g_weapon[4]) Get_Rifle(id, 2)
else if(wpnid == g_weapon[5]) Get_Rifle(id, 4)
else if(wpnid == g_weapon[6]) get_weapon_subgun(id, 4)
else if(wpnid == g_weapon[7]) get_weapon_subgun(id, 5)
}
public Get_Rifle(id, Weapon)
{
if(!zb5_weapons_primary())
return

drop_weapons(id, 1);	
Reset_All(id)

fm_give_item(id, weapon_base)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

switch(Weapon)	
{
case 1:
{
g_had[id] = SKULL4
cs_set_weapon_ammo(Ent, 48)		
SPR(id, "weapon_skull4_MSBG")	
}
case 2:
{
g_had[id] = THANATOS5
cs_set_weapon_ammo(Ent, 30)
SPR(id, "weapon_thanatos5_MSBG")	
}
case 3:
{
g_had[id] = SVDEX
cs_set_weapon_ammo(Ent, 20)
SPR(id, "weapon_svdex2_MSBG")		
}
case 4:
{
g_had[id] = JANUS5
cs_set_weapon_ammo(Ent, 35)
SPR(id, "weapon_janus5_MSBG")
}
}

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
case SVDEX:
{
Clip = zb5_had_StrongLife(id)? 250: 200
g_had2[id][AMMO] = zb5_had_StrongLife(id)? 10: 5
}
default:Clip = zb5_had_StrongLife(id)? 250: 200
}

cs_set_user_bpammo(id, CSW_BASE, Clip)
}
public Reset_All(id)
{
remove_task(id+TASK_STOP)

arrayset(g_had2[id], false, sizeof(g_had2[]));
arrayset(_:g_had[id], false, sizeof(g_had[]));
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
case SKULL4:
{
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_skull4_2.mdl")
set_pev(id, pev_weaponmodel2, "models/ZB5/Primary/p_skull4.mdl")
}
case THANATOS5:
{
SubModel = 30

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_thanatos5.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case SVDEX:
{
SubModel = 7

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_svdex.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
case JANUS5:
{
SubModel = 17

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_janus5_2.mdl")
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
case SKULL4:
{
set_pev(id, pev_weaponmodel2, "models/ZB5/Primary/p_skull4.mdl")
set_pdata_string(id, (492) * 4, PLAYER_ANIM_EXT_B, -1 , 20)
}
case THANATOS5:
{
set_weapon_anim(id, !g_had2[id][MODE] ? 12 : 13)
Submodel = 30;Sequence = 28	
engfunc(EngFunc_SetModel, ent, P_Model2)	
}
case SVDEX:
{
set_weapon_anim(id, !g_had2[id][MODE] ? 3 : 7)
g_had2[id][RELOAD] = false

Submodel = 7;Sequence = 6
engfunc(EngFunc_SetModel, ent, P_Model)	
}
case JANUS5:
{
switch(g_had2[id][MODE])
{
case MODE_A:set_weapon_anim(id, 2)	
case MODE_B:
{
set_weapon_anim(id, 7)
IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash25.spr", 0.05)
}
case MODE_S:set_weapon_anim(id, 14)
}
Submodel = 17;Sequence = 16	
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
return FMRES_IGNORED

static Classname[32]
pev(entity, pev_classname, Classname, sizeof(Classname))

if(!equal(Classname, "weaponbox"))
return FMRES_IGNORED

if(!equal(model, "models/w_galil.mdl"))
return FMRES_IGNORED;

static weapon; weapon = find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

static iOwner; iOwner = pev(entity, pev_owner)

static Weapons:had
had = g_had[iOwner] 

switch(had)
{
case SKULL4:
{
set_pev(weapon, pev_impulse, SKULL4)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 16 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case SVDEX:
{
set_pev(entity, pev_solid, SOLID_NOT)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case JANUS5:
{
set_pev(weapon, pev_impulse, JANUS5)
engfunc(EngFunc_SetModel, entity, W_Model2)
set_pev(entity, pev_body, 8 - 1)	
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case THANATOS5:
{
set_pev(weapon, pev_impulse, THANATOS5)
engfunc(EngFunc_SetModel, entity, W_Model2)
set_pev(entity, pev_body, 16 - 1)
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
case SKULL4:
{
Reset_All(id)
g_had[id] = SKULL4

SPR(id, "weapon_skull4_MSBG")
set_pev(ent, pev_impulse, 0)
}
case JANUS5:
{
Reset_All(id)

g_had[id] = JANUS5
SPR(id, "weapon_janus5_MSBG")

set_pev(ent, pev_impulse, 0)
}
case THANATOS5:
{
Reset_All(id)

g_had[id] = THANATOS5
SPR(id, "weapon_thanatos5_MSBG")

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

static Weapons:had, Float:get_idle 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_BASE || had == INVALID)
return HAM_SUPERCEDE

get_idle = get_pdata_float(weapon, m_flTimeWeaponIdle)
if(get_idle > 10.0)
{
switch(had)
{
case JANUS5:
{
switch(g_had2[id][MODE])
{
case MODE_A:set_weapon_anim(id, 0)	
case MODE_B:set_weapon_anim(id, 6)
case MODE_S:set_weapon_anim(id, 12)
}
}
case SVDEX:set_weapon_anim(id, !g_had2[id][MODE] ? 0 : 4)
case THANATOS5:set_weapon_anim(id, !g_had2[id][MODE] ? 0 : 1)
}
}
return HAM_IGNORED
}

public fw_PlaybackEvent(flags, id, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
if(!is_player(id, 0))
return FMRES_IGNORED	

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had == INVALID)	
return FMRES_IGNORED

if(had == THANATOS5)	
return FMRES_IGNORED

switch(had)
{
case SKULL4:
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

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skull4_shoot1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_player_nextattack(id, 0.1985)
Make_PunchAngle(id, 3.0, 0.0)
}
case JANUS5:
{	
switch(g_had2[id][MODE])
{	
case MODE_A:
{	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus5-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.070)
set_weapons_recoil(id, 0.9)
set_weapon_anim(id, 3)
}
case MODE_B:
{		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus5-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_weapon_anim(id, random_num(8,10))
set_player_nextattack(id, 0.030)
set_weapons_recoil(id, 1.1)
IG_Muzzleflash_Activate(id)
}
case MODE_S:
{	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janus5-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(id, 0.060)
set_weapons_recoil(id, 1.1)
set_weapon_anim(id, 4)
}
}
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);	
}
}
engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
return FMRES_SUPERCEDE
}
public Stop_Special(id)
{
id -= TASK_STOP

if(!is_player(id, 1))
return
if(g_had[id] != JANUS5)
return;

set_weapons_unlimited_clip(id, 0)
set_weapons_headshot(id, 0)	

set_player_nextattack(id, 1.0)
set_weapons_timeidle(id, CSW_BASE, 1.0)

set_weapon_anim(id, g_had2[id][MODE] == MODE_S ? 2 : 11)	

if(g_had2[id][MODE] == MODE_B)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janusmk5_change2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	

g_had2[id][MODE] = MODE_A
}

public fw_takedmg(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_player(attacker, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[attacker] 

if(get_player_weapon(attacker) != CSW_BASE || had == INVALID)	
return HAM_IGNORED;

if (damage_type & (1<<24))
return HAM_IGNORED;	

static Float:Damage, Float:Jump

static target, body
get_user_aiming(attacker, target, body)

switch(had)
{
case THANATOS5:Damage = float(get_damage_body(body, 1.2))	
case SKULL4:
{	
Damage = float(get_damage_body(body, 2.0))
Jump = 50.0
}
case SVDEX:
{	
Damage = float(get_damage_body(body, random_float(10.0, 15.0)))
Jump = 30.0
}
case JANUS5:
{
switch(g_had2[attacker][MODE])
{
case MODE_A:Damage = float(get_damage_body(body, 1.0))
case MODE_B:
{
Damage = float(get_damage_body(body, 1.5))
Jump = 30.0
beam_effect(victim)
}	
}
}
}
set_weapon_knockback(attacker, victim, Jump)
SetHamParamFloat(4, damage * Damage)

return HAM_HANDLED
}
public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
if(!is_player(Attacker, 0))
return HAM_IGNORED	

static Weapons:had
had = g_had[Attacker] 

if(get_player_weapon(Attacker) != CSW_BASE || had != JANUS5)	
return HAM_IGNORED;

if(!zbs_is_scenario())
{
if(g_had2[Attacker][MODE] == MODE_A)
{	
if(Get_BitVar(g_IsZombie, Victim)) 
{
g_had2[Attacker][SHOTS]++
CheckCharge(Attacker)
}
}
}else{
g_had2[Attacker][SHOTS]++
CheckCharge(Attacker)	
}
return HAM_IGNORED
}
CheckCharge(id)
{
if(g_had2[id][SHOTS] >= 57)
{
g_had2[id][SHOTS] = 0	
g_had2[id][MODE] = MODE_S

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/janusmk5_change1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	

remove_task(id+TASK_STOP)
set_task(7.0, "Stop_Special", id+TASK_STOP)
}
}

public Frame(weapon_entity) 
{
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED;

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)	
static Button; Button = (pev(id, pev_button) & IN_ATTACK2 && flNextAttack <= 0.0)

if(Button)
{
switch(had)
{
case SVDEX:
{	
if(g_had2[id][AMMO] > 0)
{	
set_weapons_timeidle(id, CSW_BASE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, !g_had2[id][MODE]? 8:9)
update_ammo(id, g_had2[id][MODE]? 1:0)
g_had2[id][MODE] = (g_had2[id][MODE]? MODE_A : MODE_B)
}
}
case JANUS5:
{	
if(g_had2[id][MODE] == MODE_S)
{	
cs_set_weapon_ammo(weapon_entity, cs_get_weapon_ammo(weapon_entity) + 2)	
set_weapons_timeidle(id, CSW_BASE, 1.0)
set_player_nextattack(id, 1.0)

set_weapons_unlimited_clip(id, 1)
set_weapons_headshot(id, 1)
set_weapon_anim(id, 5)

g_had2[id][MODE] = MODE_B
IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash25.spr", 0.05)

remove_task(id+TASK_STOP)
set_task(10.0, "Stop_Special", id+TASK_STOP)	
}
}
case THANATOS5:
{
if(g_had2[id][MODE] == MODE_A && cs_get_weapon_ammo(weapon_entity) > 20)
{	
set_weapons_timeidle(id, CSW_BASE, 5.0)
set_player_nextattack(id, 5.0)
set_weapon_anim(id, 11)
g_had2[id][MODE] = MODE_B
cs_set_weapon_ammo(weapon_entity, cs_get_weapon_ammo(weapon_entity) -20)	
}	
}
}
}
static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)
static fInReload; fInReload  = get_pdata_int(weapon_entity, 54, 4)

if( fInReload && flNextAttack <= 0.0 )
{	
static c,j
switch(had)
{
case SKULL4:c = 48
case SVDEX:c = 20
case JANUS5:c = 35
case THANATOS5:c = 30
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
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED;

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
case SKULL4:c = 48
case SVDEX:c = 20
case JANUS5:c = 35
case THANATOS5:c = 30
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
return HAM_IGNORED;

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

if (g_had2[id][TMPCLIP] == -1)
return HAM_IGNORED;

static Float:time2
switch(had)
{
case SKULL4:
{
time2 = 3.4
set_weapon_anim(id, 1)
}
case SVDEX:
{
time2 = 4.2
set_weapon_anim(id, 2)
g_had2[id][RELOAD] = true 
set_task(3.8, "StopReload", id)
}
case THANATOS5:
{
time2 = 3.5
set_weapon_anim(id, g_had2[id][MODE] ? 10: 9)
}
case JANUS5:
{
time2 = 3.2
set_weapon_anim(id, g_had2[id][MODE] == MODE_S ? 13: 1)
}
}

set_pdata_int(weapon_entity, m_iClip, g_had2[id][TMPCLIP], WEAP_LINUX_XTRA_OFF)
set_pdata_float(weapon_entity, m_flTimeWeaponIdle, time2, WEAP_LINUX_XTRA_OFF)
set_pdata_float(id, m_flNextAttack, time2, PLAYER_LINUX_XTRA_OFF)
set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)

return HAM_IGNORED;
}
public StopReload(id)
{
if(!is_player(id, 1))
return

g_had2[id][RELOAD] = false	
}
// SVDEX Grenade
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

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)
static Float:CurTime; CurTime = get_gametime()

if(get_pdata_float(id, 83, 5) > 0.0) 
return FMRES_IGNORED	

switch(had)
{
case THANATOS5:
{		
if(CurButton & IN_ATTACK)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(cs_get_weapon_ammo(ent) <= 0)
return FMRES_IGNORED

if(g_had2[id][MODE] == MODE_B)
Handle_Shoot_THANATOS5(id)
else 
{	
if(CurTime - 0.1 > g_attack1[id])
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos5-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
Make_PunchAngle(id, 0.5, 0.0)
set_weapon_anim(id, random_num(2,4))
ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
g_attack1[id] = CurTime
}	
}
}
}
case JANUS5:
{
if(g_had2[id][MODE] != MODE_B)
return FMRES_IGNORED

if(CurButton & IN_RELOAD)
{
CurButton &= ~IN_RELOAD
set_uc(uc_handle, UC_Buttons, CurButton)
}	
}

case SVDEX:
{	
if(g_had2[id][RELOAD])
return FMRES_IGNORED

if(CurButton & IN_ATTACK)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(cs_get_weapon_ammo(ent) <= 0)
return FMRES_IGNORED

if(g_had2[id][MODE] == MODE_B)
{
if(g_had2[id][AMMO] <= 0)
return FMRES_IGNORED	

if(CurTime - 2.0 > g_attack1[id])
{
Handle_Shoot(id)
g_attack1[id] = CurTime
}
}
else
{
if(CurTime - 0.370 > g_attack1[id])
{
ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/svdex_shoot1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_weapon_anim(id, 1)
set_player_nextattack(id, 0.400)
Make_PunchAngle(id, 2.0, 0.0)
g_attack1[id] = CurTime
}
}
}
if(g_had2[id][MODE] == MODE_B)
{
if(CurButton & IN_RELOAD)
{
CurButton &= ~IN_RELOAD
set_uc(uc_handle, UC_Buttons, CurButton)
}
}
}
}
return FMRES_HANDLED;
}
// THANATOS5 GUN
public Handle_Shoot_THANATOS5(id)
{	
set_player_nextattack(id, 3.0)	
set_weapons_timeidle(id, CSW_BASE, 3.0)

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos5_shootb2_1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_weapon_anim(id, 7)
g_had2[id][MODE] = MODE_A

Create_Scythe(id)
Make_PunchAngle(id, 10.0, 0.0)
Make_Sprite(id, ef_sprite[3], 9, 20, 40, 10, -10)

set_task(1.0, "Anim", id)
}
public Anim(id)
{
if(!is_player(id, 1))
return

if(get_player_weapon(id) != CSW_BASE || g_had[id] != THANATOS5)
return;

set_weapon_anim(id, 8)	
}


public Create_Scythe(id)
{
new iEnt = create_entity("info_target")
if(!is_valid_ent(iEnt))
return;

static Float:Origin[3], Float:Angles[3], Float:TargetOrigin[3], Float:Velocity[3]

get_weapon_attachment(id, Origin, 40.0)
get_position(id, 1024.0, 6.0, 0.0, TargetOrigin)

pev(id, pev_v_angle, Angles)
Angles[0] *= -1.0

// set info for ent
set_pev(iEnt, pev_movetype, MOVETYPE_PUSHSTEP)
entity_set_string(iEnt, EV_SZ_classname, SCYTHE_CLASSNAME)

engfunc(EngFunc_SetModel, iEnt, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(iEnt,EV_INT_body, 6 - 1)

set_pev(iEnt, pev_mins, Float:{-1.0, -1.0, -1.0})
set_pev(iEnt, pev_maxs, Float:{1.0, 1.0, 1.0})
set_pev(iEnt, pev_origin, Origin)
set_pev(iEnt, pev_gravity, 1.0)
set_pev(iEnt, pev_angles, Angles)
set_pev(iEnt, pev_solid, SOLID_TRIGGER)
set_pev(iEnt, pev_owner, id)	
set_pev(iEnt, pev_iuser2, 0)
set_pev(iEnt, pev_fuser1, get_gametime() + 1.5)

get_speed_vector(Origin, TargetOrigin, 900.0, Velocity)
set_pev(iEnt, pev_velocity, Velocity)	

set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)

// Animation
set_pev(iEnt, pev_animtime, get_gametime())
set_pev(iEnt, pev_framerate, 2.0)
set_pev(iEnt, pev_sequence, 4)


// Make a Beam
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(iEnt) // entity
write_short(ef_sprite[0]) // sprite
write_byte(20)  // life
write_byte(2)  // width
write_byte(100) // r
write_byte(10);  // g
write_byte(200);  // b
write_byte(100); // brightness
message_end();
}

public Create_ScytheSystem(id, Ent, Next)
{
if(!is_valid_ent(Ent))
return;	

static Float:Origin[4][3]
static Float:Start[3]; entity_get_vector(Ent, EV_VEC_origin, Start)

get_position(Ent, 100.0, 0.0, 100.0, Origin[0])
get_position(Ent, -100.0, 0.0, 100.0, Origin[1])
get_position(Ent, 0.0, -100.0, 100.0, Origin[2])
get_position(Ent, 0.0, 100.0, 100.0, Origin[3])

for(new i = 0; i < 4; i++)
Create_Mine(id, Start, Origin[i], Next)
}

public Create_Mine(id, Float:Origin[3], Float:TargetOrigin[3], Next)
{
new iEnt = create_entity("info_target")

if(!is_valid_ent(iEnt))
return;

static Float:Velocity[3]

// set info for ent
set_pev(iEnt, pev_movetype, MOVETYPE_PUSHSTEP)
entity_set_string(iEnt, EV_SZ_classname, SCYTHE_CLASSNAME2)
engfunc(EngFunc_SetModel, iEnt, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(iEnt,EV_INT_body, 6 - 1)

set_pev(iEnt, pev_mins, Float:{-1.0, -1.0, -1.0})
set_pev(iEnt, pev_maxs, Float:{1.0, 1.0, 1.0})
set_pev(iEnt, pev_origin, Origin)
set_pev(iEnt, pev_gravity, 1.0)
set_pev(iEnt, pev_solid, SOLID_TRIGGER)
set_pev(iEnt, pev_owner, id)	

set_pev(iEnt, pev_iuser2, Next)
set_pev(iEnt, pev_fuser1, get_gametime() + 1.5)

get_speed_vector(Origin, TargetOrigin, 250.0, Velocity)
set_pev(iEnt, pev_velocity, Velocity)	

set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)

// Animation
set_pev(iEnt, pev_animtime, get_gametime())
set_pev(iEnt, pev_framerate, 2.0)
set_pev(iEnt, pev_sequence, 4)

// Make a Beam
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(iEnt) // entity
write_short(ef_sprite[0]) // sprite
write_byte(10)  // life
write_byte(2)  // width
write_byte(120) // r
write_byte(20);  // g
write_byte(200);  // b
write_byte(100); // brightness
message_end();
}


public fw_Scythe_Think(Ent)
{
if(!is_valid_ent(Ent))
return

static Float:fTimeRemove; pev(Ent, pev_fuser1, fTimeRemove)
static ID; ID = pev(Ent, pev_owner)
	
if (get_gametime() >= fTimeRemove)
{
Thanatos5_Explose(Ent, ID)
Create_ScytheSystem(ID, Ent, 1)
remove_entity(Ent)
return
}

set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
}

public fw_Scythe_Think2(Ent, id)
{
if(!is_valid_ent(Ent))
return

static Float:fTimeRemove; pev(Ent, pev_fuser1, fTimeRemove)
static Next; Next = pev(Ent, pev_iuser2)
static ID; ID = pev(Ent, pev_owner)

if (get_gametime() >= fTimeRemove)
{
Thanatos5_Explose(Ent, ID)

if(Next)
Create_ScytheSystem(ID, Ent, 0)

remove_entity(Ent)
return
}

set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
}

public Thanatos5_Explose(Ent, ID)
{
if(!is_valid_ent(Ent))
return

static Float:Origin[3]; 
entity_get_vector(Ent, EV_VEC_origin, Origin)

message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[4])	// sprite index
write_byte(7)	// scale in 0.1's
write_byte(20)	// framerate
write_byte(TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NODLIGHTS)	// flags
message_end()

message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[5])	// sprite index
write_byte(6)	// scale in 0.1's
write_byte(20)	// framerate
write_byte(TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NODLIGHTS)	// flags
message_end()

Check_AttackDamge(Ent, ID, 100.0, random_float(300.0, 500.0))
emit_sound(Ent, CHAN_BODY, "ZB5/weapons/thanatos5_explode1.wav", VOL_NORM, ATTN_NONE, 0, PITCH_NORM)
//remove_entity(Ent)
}

// SVDEX LAUNCHER SYSTEM
public Handle_Shoot(id)
{	
if(g_had2[id][AMMO] > 1)
set_weapon_anim(id, 5)
else 
{
set_weapon_anim(id, 6)
set_task(1.0, "Change", id)
}

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/svdex_shoot2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_weapons_timeidle(id, CSW_BASE, 2.5)
set_player_nextattack(id, 2.5)

Make_PunchAngle(id, 10.0, 0.0)
Make_Grenade(id)
Make_Sprite(id, ef_sprite[3], 9, 20, 40, 10, -10)

g_had2[id][AMMO]--
update_ammo(id, 0)
}
public Change(id)
{
if(!is_player(id, 1))
return
if(get_user_weapon(id) != CSW_BASE || g_had[id] != SVDEX)
return

update_ammo(id, 1)
set_weapon_anim(id, 9)	
set_weapons_timeidle(id, CSW_BASE, 3.2)
set_player_nextattack(id, 3.2)
g_had2[id][MODE] = MODE_A	
}

public Make_Grenade(id)
{
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent))
return;

static Float:Origin[3], Float:Angles[3]
get_position(id, 50.0, 10.0, 0.0, Origin)
entity_get_vector(id, EV_VEC_angles, Angles)

entity_set_int(Ent,EV_INT_movetype, MOVETYPE_TOSS)
entity_set_int(Ent,EV_INT_solid, SOLID_BBOX)

entity_set_string(Ent,EV_SZ_classname, SVDEX_GRENADE)

entity_set_model(Ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(Ent,EV_INT_body, 1 - 1)

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, Angles)
entity_set_int(Ent,EV_INT_iuser1, id)

static Float:Velocity[3]
VelocityByAim(id, 800, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // Temporary entity ID
write_short(Ent) // Entity
write_short(ef_sprite[0]) // Sprite index
write_byte(15) // Life
write_byte(4) // Line width
write_byte(100)
write_byte(100)
write_byte(100)
write_byte(150) // Alpha
message_end() 
}
public fw_Svdex_Touch(ent, id)
{
if(!is_valid_ent(ent))
return
if(entity_get_int(ent,EV_INT_movetype) == MOVETYPE_NONE)
return

static Float:Origin[3]
entity_get_vector(ent, EV_VEC_origin, Origin)

// Explosion
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 30.0)
write_short(ef_sprite[1])
write_byte(50)
write_byte(40)
write_byte(TE_EXPLFLAG_NOSOUND)
message_end()	

static id; id = entity_get_int(ent, EV_INT_iuser1)
Check_AttackDamge(ent, id, 150.0, random_float(100.0,300.0))

emit_sound(ent, CHAN_WEAPON, "ZB5/weapons/svdex_exp.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
remove_entity(ent)
}

public Check_AttackDamge(Ent, Attacker, Float:Ratio, Float:ZombieDamage)
{
if(!is_valid_ent(Ent))
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

public update_ammo(id, reset)
{
static ent; ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(ent)) 
return;

if(reset == 0)
{
set_pev(ent, pev_iuser3, cs_get_user_bpammo(id, CSW_BASE))
set_pev(ent, pev_iuser4, cs_get_weapon_ammo(ent))
}

static dest	
if(!id) 
dest = MSG_BROADCAST;
else 
dest = MSG_ONE_UNRELIABLE;

message_begin(dest, get_user_msgid("CurWeapon"), _, id)
write_byte(1)
write_byte(CSW_BASE)
write_byte(reset == 1 ? pev(ent, pev_iuser4) : -1)
message_end()

message_begin(dest, get_user_msgid("AmmoX"), _, id)
write_byte(4)
write_byte(reset == 1 ? pev(ent, pev_iuser4) : g_had2[id][AMMO])
message_end()
}
stock SPR(id, const weapon[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
write_string(weapon)
write_byte(4)
write_byte(90)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(17)
write_byte(14)
write_byte(0)
message_end()
}

stock get_damage_body(body, Float:damage) 
{
switch(body) 
{
case HIT_HEAD: damage *= 3.0
case HIT_STOMACH: damage *= 2.3
case HIT_CHEST: damage *= 2.5
case HIT_LEFTARM: damage *= 1.70
case HIT_RIGHTARM: damage *= 1.75
case HIT_LEFTLEG: damage *= 1.70
case HIT_RIGHTLEG: damage *= 1.75
default: damage *= 1.0
}
return floatround(damage)
}
Play_AttackAnimation(id, Right)
{
static iAnimDesired, szAnimation[64]
static iFlags; iFlags = pev(id, pev_flags)

if(!Right)	
formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", PLAYER_ANIM_EXT_B);
else 
formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot2_%s" : "ref_shoot2_%s", PLAYER_ANIM_EXT_B);

if((iAnimDesired = lookup_sequence(id, szAnimation)) == -1)
iAnimDesired = 0;

set_pev(id, pev_sequence, iAnimDesired)
}
beam_effect(id)
{
static Float:origin[3]
pev(id, pev_origin, origin)

engfunc(EngFunc_MessageBegin, MSG_ALL, SVC_TEMPENTITY, origin, 0)
write_byte(TE_BEAMCYLINDER) // TE id
engfunc(EngFunc_WriteCoord, origin[0]) // x
engfunc(EngFunc_WriteCoord, origin[1]) // y
engfunc(EngFunc_WriteCoord, origin[2]) // z
engfunc(EngFunc_WriteCoord, origin[0]) // x axis
engfunc(EngFunc_WriteCoord, origin[1]) // y axis
engfunc(EngFunc_WriteCoord, origin[2]+130.0) // z axis
write_short(ef_sprite[2]) // sprite
write_byte(0) // startframe
write_byte(0) // framerate
write_byte(2) // life
write_byte(20) // width
write_byte(0) // noise
write_byte(200) // red
write_byte(200) // green
write_byte(200) // blue
write_byte(100) // brightness
write_byte(0) // speed
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

if(g_had[id] == SVDEX)	
{
g_had[id] = INVALID
ham_strip_weapon(id, weapon_base)	
}

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

Reset_All(id)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id)
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

Set_BitVar(g_IsZombie, id)

Reset_All(id)
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
