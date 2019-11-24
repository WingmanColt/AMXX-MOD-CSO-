#include <amxmodx>
#include <ZombieMod5>
#include <infinitygame>

#define CSW_BASE CSW_AUG
#define weapon_base "weapon_aug"
#define WEAPON_ANIMEXT3 "dualpistols_1"

new const sound[][] =
{
"ZB5/weapons/ak47buff-2.wav",	
"ZB5/weapons/m4a1buff-1.wav",	
"ZB5/weapons/m4a1buff-2.wav",	
"ZB5/weapons/cv47-1.wav",
"ZB5/weapons/crow5-1.wav",
"ZB5/weapons/balrog5-1.wav",
"ZB5/weapons/sfgun-1.wav",
"ZB5/weapons/dualkrisshero-1.wav"
}
new const models[][] =
{
"models/ZB5/Primary/v_crow5.mdl",	
"models/ZB5/Primary/v_cv47.mdl",
"models/ZB5/Primary/v_balrog5_new.mdl",	
"models/ZB5/Primary/v_sfgun.mdl",
"models/ZB5/Primary/v_dualkriss.mdl",
"models/ZB5/Primary/v_buffm4.mdl",
"models/ZB5/Primary/v_buffak.mdl"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud2.spr",	
"sprites/ZB5/HUD2/640hud32.spr",	
"sprites/ZB5/HUD2/640hud58.spr",	
"sprites/ZB5/HUD2/640hud127.spr",
"sprites/ZB5/HUD2/640hud132.spr",
"sprites/ZB5/HUD2/640hud142.spr",
"sprites/weapon_cv47_MSBG.txt",
"sprites/weapon_balrog5_MSBG.txt",
"sprites/weapon_sfgun_MSBG.txt",
"sprites/weapon_crow5_MSBG.txt",
"sprites/weapon_dualkriss_MSBG.txt",
"sprites/weapon_buffm4_MSBG.txt",
"sprites/weapon_buffak_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_cv47_MSBG",
"weapon_balrog5_MSBG",
"weapon_sfgun_MSBG",
"weapon_crow5_MSBG",
"weapon_dualkriss_MSBG",
"weapon_buffm4_MSBG",
"weapon_buffak_MSBG"
}
enum Weapons
{
INVALID = 0,	
BALROG5,	
CV47,
SFGUN,
KRISS,
CROW5,
M4BUFF,
AK47BUFF
}
enum Options
{
DUAL,
TMPCLIP,
Old
}

new Weapons:g_had[33], g_had2[33][Options], Float:TargetOrigin[3], ef_sprite[3], g_weapon[5]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]

public plugin_init() 
{
if(!zb5_weapons_primary())
return
	
Register_SafetyFunc()		
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")

RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_Item_AddToPlayer_Post", 1)
RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	

RegisterHam(Ham_Item_PostFrame, weapon_base, "Frame")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload_Post", 1);

RegisterHam(Ham_TakeDamage, "player", "fw_takedmg")
RegisterHam(Ham_TraceAttack, "worldspawn", "Forward_TraceAttack", 1)

register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")

g_weapon[2] = zb5_register_weapon("M4Buff", "\rDark Knight", WPN_RIFLES, LEVEL_M4BUFF, 1)
g_weapon[3] = zb5_register_weapon("AK47 Buff ", "\rPaladin", WPN_RIFLES, LEVEL_AK47BUFF, 1)
g_weapon[0] = zb5_register_weapon("Crow 5", "Dragon Eye", WPN_SUBS, LEVEL_CROW5, 0)
g_weapon[1] = zb5_register_weapon("Balrog V", "\rFlame", WPN_RIFLES, LEVEL_BALROG5, 0)
}

public plugin_precache()
{
PrecacheModel("sprites/ZB5/muzzleflash16.spr")
PrecacheModel("sprites/ZB5/muzzleflash21.spr")	
PrecacheModel("sprites/ZB5/muzzleflash41.spr")
PrecacheModel("sprites/ZB5/muzzleflash44.spr")
	
ef_sprite[0] = PrecacheModel("sprites/ZB5/balrog5stack.spr")	
ef_sprite[1] = PrecacheModel("sprites/ZB5/ef_buffak_hit.spr")
ef_sprite[2] = PrecacheModel("sprites/zbeam2.spr")

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
register_native("get_weapon_scope", "Get_Scope", 1)	
register_native("zb5_had_cv47", "Had_CV47", 1)
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}
public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0]) Get_Scope(id, 7)	
else if(wpnid == g_weapon[1]) Get_Scope(id, 2)
else if(wpnid == g_weapon[2]) Get_Scope(id, 5)
else if(wpnid == g_weapon[3]) Get_Scope(id, 6)
}
public Get_Scope(id, Weapon)
{
if(!zb5_weapons_primary())
return
	
drop_weapons(id, 1);
Reset_All(id)

fm_give_item(id, weapon_base)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) 
return

switch(Weapon)
{
case 1:
{
g_had[id] = CV47
cs_set_weapon_ammo(Ent, 60)	
SPR(id, "weapon_cv47_MSBG")	
}
case 2:
{
g_had[id] = BALROG5
cs_set_weapon_ammo(Ent, 40)	
SPR(id, "weapon_balrog5_MSBG")	
IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash21.spr", 0.07)
}
case 3:
{
g_had[id] = SFGUN
cs_set_weapon_ammo(Ent, 45)	
SPR(id, "weapon_sfgun_MSBG")	
IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash16.spr", 0.10)
}
case 4:
{
g_had[id] = KRISS
cs_set_weapon_ammo(Ent, 50)	
SPR(id, "weapon_dualkriss_MSBG")	
}
case 5:
{
g_had[id] = M4BUFF
cs_set_weapon_ammo(Ent, 50)	
SPR(id, "weapon_buffm4_MSBG")
IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash44.spr", 0.10)
}
case 6:
{
g_had[id] = AK47BUFF
cs_set_weapon_ammo(Ent, 50)	
SPR(id, "weapon_buffak_MSBG")
IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash41.spr", 0.10)
}
case 7:
{
g_had[id] = CROW5
cs_set_weapon_ammo(Ent, 40)	
SPR(id, "weapon_crow5_MSBG")
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

arrayset(_:g_had[id], false, sizeof(g_had[]));
}

public Had_CV47(id)return g_had[id] == CV47

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
case CV47:
{
SubModel = 4
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_cv47.mdl")
}
case BALROG5:
{
SubModel = 1
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_balrog5_new.mdl")
}
case SFGUN:
{
SubModel = 14
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_sfgun.mdl")
}
case M4BUFF:
{
SubModel = 24
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_buffm4.mdl")
}
case AK47BUFF:
{
SubModel = 8
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_buffak.mdl")
}
case CROW5:
{
SubModel = 6
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_crow5.mdl")
}
case KRISS:
{
SubModel = 16
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_dualkriss.mdl")
}
}

set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
public event_CurWeapon(id)
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

static ent; ent = fm_get_user_weapon_entity(id, CSW_BASE)

if(CSW_ID == CSW_BASE)
{
if(is_valid_ent(ent) && had != INVALID)
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

static Submodel, Sequence;

switch(had)
{
case CV47:
{
Submodel = 4;Sequence = 3	
}
case BALROG5:
{
Submodel = 1;Sequence = 0
}
case SFGUN:
{
Submodel = 14;Sequence = 12
}
case M4BUFF:
{
Submodel = 24;Sequence = 23
}
case AK47BUFF:
{
set_weapon_anim(id, 2)
Submodel = 8;Sequence = 7
}
case CROW5:
{
set_weapon_anim(id, 6)	
Submodel = 6;Sequence = 5
}
case KRISS:
{
set_weapon_anim(id, 6)
Submodel = 16;Sequence = 14
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

if(equal(model, "models/w_aug.mdl"))
{
static weapon; weapon = find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

static Weapons:had
had = g_had[iOwner] 

switch(had)
{
case CV47:
{
set_pev(weapon, pev_impulse, CV47)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 5 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case BALROG5:
{
set_pev(weapon, pev_impulse, BALROG5)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 4 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case SFGUN:
{
set_pev(weapon, pev_impulse, SFGUN)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 14 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case KRISS:
{
set_pev(weapon, pev_impulse, KRISS)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 30 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case M4BUFF:
{
set_pev(weapon, pev_impulse, M4BUFF)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 29 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case AK47BUFF:
{
set_pev(weapon, pev_impulse, AK47BUFF)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 28 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case CROW5:
{
set_pev(weapon, pev_impulse, CROW5)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 7 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}	
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
case CV47:
{
Reset_All(id)

g_had[id] = CV47
SPR(id, "weapon_cv47_MSBG")

set_pev(ent, pev_impulse, 0)
}
case BALROG5:
{
Reset_All(id)

g_had[id] = BALROG5
SPR(id, "weapon_balrog5_MSBG")

IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash21.spr", 0.07)
set_pev(ent, pev_impulse, 0)
}
case SFGUN:
{
Reset_All(id)

g_had[id] = SFGUN
SPR(id, "weapon_sfgun_MSBG")

IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash16.spr", 0.10)
set_pev(ent, pev_impulse, 0)
}
case KRISS:
{
Reset_All(id)

g_had[id] = KRISS
SPR(id, "weapon_dualkriss_MSBG")

set_pev(ent, pev_impulse, 0)
}
case M4BUFF:
{
Reset_All(id)

g_had[id] = M4BUFF
SPR(id, "weapon_buffm4_MSBG")

IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash44.spr", 0.10)
set_pev(ent, pev_impulse, 0)
}
case AK47BUFF:
{
Reset_All(id)

g_had[id] = AK47BUFF
SPR(id, "weapon_buffak_MSBG")

IG_Muzzleflash_Set(id, "sprites/ZB5/muzzleflash41.spr", 0.10)
set_pev(ent, pev_impulse, 0)
}
case CROW5:
{
Reset_All(id)

g_had[id] = CROW5
SPR(id, "weapon_crow5_MSBG")

set_pev(ent, pev_impulse, 0)
}
}

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
case CV47:Damage = float(get_damage_body(body, 1.5))
case SFGUN:Damage = float(get_damage_body(body, 0.8))
case KRISS:Damage = float(get_damage_body(body, 1.0))
case CROW5:Damage = float(get_damage_body(body, 1.1))
case BALROG5:
{		
Damage = 1.5
Jump = 50.0
Make_BalrogEffect(victim)
set_weapon_knockback(attacker, victim, Jump)	
}
case M4BUFF:
{
if(cs_get_user_zoom(attacker) == CS_SET_AUGSG552_ZOOM)
{
Damage = float(get_damage_body(body, 2.0))
Jump = 50.0

set_hudmessage(255, 0, 0, -1.0, 0.46, 0, 0.2, 0.2)
show_hudmessage(attacker, "\         /^n+^n/         \")
}
else
{
Damage = float(get_damage_body(body, 1.0))
Jump = 30.0
}
set_weapon_knockback(attacker, victim, Jump)
}
case AK47BUFF:
{
if(cs_get_user_zoom(attacker) != CS_SET_AUGSG552_ZOOM)		
Damage = float(get_damage_body(body, 1.0))
else 
{
Damage = float(get_damage_body(body, 1.5))
set_hudmessage(255, 0, 0, -1.0, 0.46, 0, 0.2, 0.2)
show_hudmessage(attacker, "\         /^n+^n/         \")
}
}
}

SetHamParamFloat(4, damage * Damage)
return HAM_HANDLED
}
public Buff_Effect(id)
{	
static Float:fStart[3], Float:originF[3], target, body

fm_get_aim_origin(id, originF)
get_user_aiming(id, target, body)

pev(id, pev_origin, fStart)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION) 
engfunc(EngFunc_WriteCoord, originF[0]) 
engfunc(EngFunc_WriteCoord, originF[1])
engfunc(EngFunc_WriteCoord, originF[2]+5.0)
write_short(ef_sprite[1]) 
write_byte(8)
write_byte(30)
write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NOPARTICLES|TE_EXPLFLAG_NODLIGHTS)
message_end()

static Float:origin[3]
pev(target, pev_origin, origin)
	
static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, 50.0)) != 0)
{
if(id == Victim)
continue;

if(!zp_core_is_zombie(Victim))
continue;

do_attack(id, Victim, 0, random_float(10.0, 50.0), 1)
set_weapon_kick(id, Victim, 2000.0)
}
}

public Forward_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
if(!is_player(iAttacker, 1))
return
if(get_player_weapon(iAttacker) != CSW_BASE || g_had[iAttacker] != M4BUFF)
return

static Float:flEnd[3], Float:WallVector[3]
get_tr2(ptr, TR_vecEndPos, flEnd)
get_tr2(ptr, TR_vecPlaneNormal, WallVector)

TargetOrigin = flEnd
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
case CV47:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);			
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/cv47-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_player_nextattack(id, 0.0650)
set_weapon_anim(id, random_num(3,4))
set_weapons_recoil(id, 1.0)
}
case BALROG5:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog5-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_player_nextattack(id, 0.11)	
set_weapons_recoil(id, 1.2)
set_weapon_anim(id, random_num(3,4))
IG_Muzzleflash_Activate(id)
}
case SFGUN:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/sfgun-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapon_anim(id, random_num(3,4))
set_weapons_recoil(id, 1.2)
IG_Muzzleflash_Activate(id)
}
case CROW5:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/crow5-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapon_anim(id, random_num(1,2))
set_weapons_recoil(id, 1.2)
}
case KRISS:
{	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dualkrisshero-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapons_recoil(id, 1.5)
Play_AttackAnimation(id, g_had2[id][DUAL]? 1:0)
set_weapon_anim(id, g_had2[id][DUAL]? random_num(1,2):random_num(3,4))
	
if(g_had2[id][DUAL]) 
zb5_make_shell(id, 3, 2.0, 17.0, -5.0, 30.0, -60.0, 3); // left side
else  zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3); // right side
g_had2[id][DUAL] = !g_had2[id][DUAL] ? 1 : 0
}
case M4BUFF:
{
zb5_make_shell(id, 3, -5.0, 15.0, 8.0, 10.0, 50.0, 3);			
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/m4a1buff-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(id, random_num(3,5))

if(cs_get_user_zoom(id) == CS_SET_AUGSG552_ZOOM)	
{
set_player_nextattack(id, 0.17)
Beam(id)
}
/*
switch(random_num(1,3))
{
case 1:Make_Sprite(id, ef_sprite[3], 1, 30, 40, 6, -16)
case 2:Make_Sprite(id, ef_sprite[4], 1, 30,  40, 6, -16)
case 3:Make_Sprite(id, ef_sprite[5], 1, 30,  40, 6, -16)
}*/
IG_Muzzleflash_Activate(id)
}
case AK47BUFF:
{		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/ak47buff-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapons_recoil(id, 0.9)
set_weapon_anim(id, random_num(3,5))
set_player_nextattack(id, 0.1)
/*switch(random_num(1,3))
{
case 1:Make_Sprite(id, ef_sprite[8], 1, 40, 40, 7, -15)
case 2:Make_Sprite(id, ef_sprite[9], 1, 40, 40, 7, -15)
case 3:Make_Sprite(id, ef_sprite[10], 1, 40, 40, 7, -15)
}
*/
if(cs_get_user_zoom(id) == CS_SET_AUGSG552_ZOOM)
{	
set_player_nextattack(id, 0.3)
Buff_Effect(id)
}
IG_Muzzleflash_Activate(id)
}
}
engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
return FMRES_SUPERCEDE
}
Beam(id)
{
static Float:StartOrigin[3]
get_position(id, 40.0, 6.0, -7.0, StartOrigin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMPOINTS)
engfunc(EngFunc_WriteCoord, StartOrigin[0])
engfunc(EngFunc_WriteCoord, StartOrigin[1])
engfunc(EngFunc_WriteCoord, StartOrigin[2])
engfunc(EngFunc_WriteCoord, TargetOrigin[0])
engfunc(EngFunc_WriteCoord, TargetOrigin[1])
engfunc(EngFunc_WriteCoord, TargetOrigin[2])
write_short(ef_sprite[2])
write_byte(0) // start frame
write_byte(0) // framerate
write_byte(2) // life
write_byte(8) // line width
write_byte(0) // amplitude
write_byte(200) // red
write_byte(200) // green
write_byte(200) // blue
write_byte(100) // brightness
write_byte(0) // speed
message_end()
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

if( fInReload && flNextAttack <= 0.0 )
{
static j,c
switch(had)
{
case CV47:c = 60
case BALROG5:c = 40
case SFGUN:c = 45
case KRISS:c = 50
case CROW5:c = 40
case M4BUFF:c = 50
case AK47BUFF:c = 50
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
case CV47:c = 60
case BALROG5:c = 40
case SFGUN:c = 45
case KRISS:c = 50
case CROW5:c = 40
case M4BUFF:c = 50
case AK47BUFF:c = 50
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

static anim, Float:time2
switch(had)
{
case KRISS:
{
anim = 5
time2 = 3.5
}
case CV47:
{
anim = 1
time2 = 3.0
}
case BALROG5:
{
anim = 1
time2 = 3.0
}
case SFGUN:
{
anim = 1
time2 = 3.0
}
case CROW5:
{
set_task(1.0, "Reload_Crow5", id)	
anim = 3
time2 = 2.3
}
case M4BUFF:
{
anim = 1	
time2 = 2.5
}
case AK47BUFF:
{
anim = 1	
time2 = 2.5
}	
}
set_pdata_int(weapon_entity, m_iClip, g_had2[id][TMPCLIP], WEAP_LINUX_XTRA_OFF)
set_pdata_float(weapon_entity, m_flTimeWeaponIdle, time2, WEAP_LINUX_XTRA_OFF)
set_pdata_float(id, m_flNextAttack, time2, PLAYER_LINUX_XTRA_OFF)
set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)
set_weapon_anim(id, anim)

return HAM_IGNORED;
}
public Reload_Crow5(id)
{
if(!is_player(id, 1))
return;

if(get_player_weapon(id) != CSW_BASE || g_had[id] != CROW5)
return;	

set_weapon_anim(id, 4)
}
public Make_BalrogEffect(id)
{
static Float:Origin[3], Float:Add_Point
pev(id, pev_origin, Origin)

if(!(pev(id, pev_flags) & FL_DUCKING))
Add_Point = 30.0
else
Add_Point = 19.0

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord,Origin[0])
engfunc(EngFunc_WriteCoord,Origin[1])
engfunc(EngFunc_WriteCoord,Origin[2] + Add_Point)
write_short(ef_sprite[0])
write_byte(6) // scale in 0.1's
write_byte(25) // framerate
write_byte(14)
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
write_byte(14)
write_byte(8)
write_byte(0)
message_end()
}
stock get_damage_body(body, Float:damage) 
{
switch(body) 
{
case HIT_HEAD: damage *= 2.0
case HIT_STOMACH: damage *= 1.9
case HIT_CHEST: damage *= 1.8
case HIT_LEFTARM: damage *= 1.75
case HIT_RIGHTARM: damage *= 1.75
case HIT_LEFTLEG: damage *= 1.25
case HIT_RIGHTLEG: damage *= 1.25
default: damage *= 1.0
}
return floatround(damage)
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

if(g_had[id] == CV47)
{
g_had[id] = INVALID
ham_strip_weapon(id, weapon_base)
}

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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
