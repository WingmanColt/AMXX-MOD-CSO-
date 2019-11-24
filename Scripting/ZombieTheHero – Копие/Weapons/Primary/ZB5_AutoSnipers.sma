#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define CSW_BASE CSW_SG550
#define weapon_base "weapon_sg550"

#define TASK_RELOAD 44344
#define TASK_RELOAD_DONE 44351
#define AT4CS_CLASSNAME "at4cs_fire"

#define WEAPON_ANIMEXT "at4"

enum Weapons
{
INVALID = 0,
MAGNUM,
Skull5,
AT4CS,
SL8EX,
AS50,
M95,
M24
}
enum _:Options
{
Float:LASTSHOT,
Float:LASTAIM,
TMPCLIP,
AIMING,
RELOAD,
Old
}

new const sound[][] =
{
"ZB5/weapons/as50-1.wav",
"ZB5/weapons/skull5-1.wav",
"ZB5/weapons/sl8ex-1.wav",
"ZB5/weapons/m24-1.wav",
"ZB5/weapons/m95-1.wav",
"ZB5/weapons/magnum-1.wav",
"ZB5/weapons/at4cs-1.wav"
}
new const models[][] =
{
"models/ZB5/Primary/v_skull5.mdl",
"models/ZB5/Primary/v_sl8ex.mdl",
"models/ZB5/Primary/v_as50.mdl",
"models/ZB5/Primary/v_m24.mdl",
"models/ZB5/Primary/v_m95.mdl",
"models/ZB5/Primary/v_magnum.mdl",
"models/ZB5/Primary/v_at4cs.mdl"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud53.spr",	
"sprites/ZB5/HUD2/640hud57.spr",	
"sprites/ZB5/HUD2/640hud59.spr",
"sprites/ZB5/HUD2/640hud78.spr",
"sprites/ZB5/HUD2/640hud122.spr",

"sprites/ZB5/HUD2/at4_scope.spr",
"sprites/ZB5/HUD2/sniper_scope-m24.spr",	
"sprites/ZB5/HUD2/sniper_scope-as50.spr",
"sprites/ZB5/HUD2/sniper_scope-skull5.spr",	
"sprites/ZB5/HUD2/sniper_scope-trg42.spr",
"sprites/ZB5/HUD2/scope_magnumbolt1.spr",	
"sprites/ZB5/HUD2/scope_magnumbolt2.spr",

"sprites/weapon_skull5_MSBG.txt",	
"sprites/weapon_as50_MSBG.txt",
"sprites/weapon_sl8ex_MSBG.txt",
"sprites/weapon_m24_MSBG.txt",
"sprites/weapon_m95_MSBG.txt",
"sprites/weapon_at4cs_MSBG.txt",
"sprites/weapon_magnum_MSBG_1.txt"
}
new const generic_spr[][] =
{
"weapon_skull5_MSBG",	
"weapon_as50_MSBG",
"weapon_sl8ex_MSBG",
"weapon_m24_MSBG",
"weapon_m95_MSBG",
"weapon_at4cs_MSBG",
"weapon_magnum_MSBG_1"
}

new Weapons:g_had[33], g_had2[33][Options]
new g_weapon[7], ef_sprite[4], g_maxplayers

new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]
public plugin_init()
{
if(!zb5_weapons_primary())
return

Register_SafetyFunc()
	
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")
register_think(AT4CS_CLASSNAME, "fw_AT4CS_Think")
register_touch(AT4CS_CLASSNAME, "*", "fw_AT4CS_Touch")

RegisterHam(Ham_TakeDamage, "player", "fw_takedmg")
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_item_addtoplayer", 1)
RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)

RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_WeaponIdle_Post", 1)
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload_Post", 1);
RegisterHam(Ham_Item_PostFrame, weapon_base, "Frame")
RegisterHam(Ham_Weapon_Reload, weapon_base, "Reload")

register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")

g_maxplayers = get_maxplayers()

g_weapon[0] = zb5_register_weapon("Remington", "\yM24", WPN_SNIPERS, LEVEL_M24, 0)
g_weapon[1] = zb5_register_weapon("H&K SL8", "\yExtreme", WPN_SNIPERS, LEVEL_SL8, 0)
g_weapon[2] = zb5_register_weapon("Skull5", "Behemoth Claw", WPN_SNIPERS, LEVEL_SKULL5, 0)
g_weapon[3] = zb5_register_weapon("AI AS50", "\yPower Sniper", WPN_SNIPERS, LEVEL_AS50, 0)
g_weapon[4] = zb5_register_weapon("M95", "\yBarrett", WPN_SNIPERS, LEVEL_M95, 0)
g_weapon[5] = zb5_register_weapon("AT4CS", "\rFire Power", WPN_DESTROYERS, LEVEL_AT4CS, 1)
g_weapon[6] = zb5_register_weapon("Magnum Bolt", "\w[\rNEW\w]", WPN_SNIPERS, LEVEL_MAGNUM, 1)
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

ef_sprite[0] = PrecacheModel("sprites/ZB5/zerogxplode-big1.spr")
ef_sprite[1] = PrecacheModel("sprites/laserbeam.spr")
ef_sprite[2] = PrecacheModel("sprites/smokepuff.spr")
ef_sprite[3] = PrecacheModel("sprites/ZB5/muzzleflash19.spr")
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}
public plugin_natives()
{
register_native("get_weapon_sniper", "Get_Sniper", 1)		
}
public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0]) Get_Sniper(id, 4)
else if(wpnid == g_weapon[1]) Get_Sniper(id, 3)
else if(wpnid == g_weapon[2]) Get_Sniper(id, 1)
else if(wpnid == g_weapon[3]) Get_Sniper(id, 2)
else if(wpnid == g_weapon[4]) Get_Sniper(id, 5)
else if(wpnid == g_weapon[5]) Get_Sniper(id, 6)
else if(wpnid == g_weapon[6]) Get_Sniper(id, 7)
}
public Get_Sniper(id, Weapon)
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
g_had[id] = Skull5
cs_set_weapon_ammo(Ent, 24)	
SPR(id, "weapon_skull5_MSBG")	
}
case 2:
{
g_had[id] = AS50
cs_set_weapon_ammo(Ent, 6)	
SPR(id, "weapon_as50_MSBG")	
}
case 3:
{
g_had[id] = SL8EX
cs_set_weapon_ammo(Ent, 25)	
SPR(id, "weapon_sl8ex_MSBG")
}
case 4:
{
g_had[id] = M24
cs_set_weapon_ammo(Ent, 10)	
SPR(id, "weapon_m24_MSBG")
}
case 5:
{
g_had[id] = M95
cs_set_weapon_ammo(Ent, 5)	
SPR(id, "weapon_m95_MSBG")
}
case 6:
{
g_had[id] = AT4CS
SPR(id, "weapon_at4cs_MSBG")
}
case 7:
{
g_had[id] = MAGNUM
SPR(id, "weapon_magnum_MSBG_1")
}
}
Draw_NewWeapon(id, CSW_BASE)
Deploy_Post(Ent)
zp_fw_restock_ammo(id)
}

public Reset_All(id)
{		
remove_task(id+TASK_RELOAD)
remove_task(id+TASK_RELOAD_DONE)

arrayset(_:g_had[id], false, sizeof(g_had[]));
arrayset(_:g_had2[id], false, sizeof(g_had2[]));

reset_weapons_recoil(id)
}

public zp_fw_restock_ammo(id)
{	
static Weapons:had
had = g_had[id] 

if(had == INVALID) 
return;

static Clip

switch(had)
{
case AS50:Clip = zb5_had_StrongLife(id)? 90: 60
case M95:Clip = zb5_had_StrongLife(id)? 60: 30
case M24:Clip = zb5_had_StrongLife(id)? 100: 70
case AT4CS:Clip = zb5_had_StrongLife(id)? 15: 10
case MAGNUM:Clip = zb5_had_StrongLife(id)? 25: 20
default:Clip = zb5_had_StrongLife(id)? 250: 200
}

cs_set_user_bpammo(id, CSW_BASE, Clip)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
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
case Skull5:
{
SubModel = 13
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_skull5.mdl")
}
case AS50:
{
SubModel = 11
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_as50.mdl")
}
case SL8EX:
{
SubModel = 23
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_sl8ex.mdl")
}
case M95:
{
SubModel = 33
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_m95.mdl")
}
case M24:
{
SubModel = 34
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_m24.mdl")
}
case MAGNUM:
{
SubModel = 33
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_magnum.mdl")
}
case AT4CS:
{
SubModel = 27
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_at4cs.mdl")
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT, -1 , 20)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
}
}
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
public event_CurWeapon(id)
{
if(!is_player(id, 1))
return

static Weapons:had
had = g_had[id] 

if((get_player_weapon(id) == CSW_BASE && g_had2[id][Old] != CSW_BASE) && had != INVALID)
{
Draw_NewWeapon(id, get_player_weapon(id))
}
else if((get_player_weapon(id) == CSW_BASE && g_had2[id][Old] == CSW_BASE) && had != INVALID) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent))
{
g_had2[id][Old] = get_player_weapon(id)
return
}
} 

else if(get_player_weapon(id) != CSW_BASE && g_had2[id][Old] == CSW_BASE) 
Draw_NewWeapon(id, get_player_weapon(id))

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
case Skull5:
{
Submodel = 13;Sequence = 11	
}
case AS50:
{
Submodel = 11;Sequence = 9
}
case SL8EX:
{
Submodel = 23;Sequence = 22
}
case M95:
{
Submodel = 33;Sequence = 31
}
case M24:
{
Submodel = 34;Sequence = 32
}
case MAGNUM:
{
set_weapon_anim(id, 2)	
Submodel = 33;Sequence = 31
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
}
case AT4CS:
{
Submodel = 27;Sequence = 16
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT, -1 , 20)
}
}

engfunc(EngFunc_SetModel, ent, P_Model)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)	
set_weapons_timeidle(id, CSW_BASE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)

g_had2[id][AIMING] = false
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

if(!equal(model, "models/w_sg550.mdl"))
return FMRES_IGNORED;

static weapon; weapon = find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

static Weapons:had
had = g_had[iOwner] 

switch(had)
{
case Skull5:
{	
set_pev(weapon, pev_impulse, Skull5)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 2 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case AS50:
{	
set_pev(weapon, pev_impulse, AS50)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 1 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case SL8EX:
{	
set_pev(weapon, pev_impulse, SL8EX)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 27 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case M24:
{	
set_pev(weapon, pev_impulse, M24)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 35 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case M95:
{	
set_pev(weapon, pev_impulse, M95)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 34 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case AT4CS:
{	
set_pev(weapon, pev_impulse, AT4CS)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(weapon, pev_iuser4, cs_get_user_bpammo(iOwner, CSW_BASE))
set_pev(entity, pev_body, 37 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case MAGNUM:
{	
set_pev(weapon, pev_impulse, MAGNUM)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(weapon, pev_iuser4, cs_get_user_bpammo(iOwner, CSW_BASE))
set_pev(entity, pev_body, 34 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
}
return FMRES_IGNORED;
}

public fw_item_addtoplayer(ent, id)
{
if(!is_valid_ent(ent))
return HAM_IGNORED
if(!is_player(id, 1))
return HAM_IGNORED

static impulse; impulse = pev(ent, pev_impulse)
switch(impulse)
{
case Skull5:
{
Reset_All(id)	

g_had[id] = Skull5
SPR(id, "weapon_skull5_MSBG")

set_pev(ent, pev_impulse, 0)	
return HAM_HANDLED
}
case AS50:
{
Reset_All(id)	

g_had[id] = AS50
SPR(id, "weapon_as50_MSBG")

set_pev(ent, pev_impulse, 0)
return HAM_HANDLED	
}
case SL8EX:
{
Reset_All(id)

g_had[id] = SL8EX
SPR(id, "weapon_sl8ex_MSBG")

set_pev(ent, pev_impulse, 0)	
return HAM_HANDLED
}
case M24:
{
Reset_All(id)	

g_had[id] = M24
SPR(id, "weapon_m24_MSBG")

set_pev(ent, pev_impulse, 0)	
return HAM_HANDLED
}
case M95:
{
Reset_All(id)	

g_had[id] = M95
SPR(id, "weapon_m95_MSBG")

set_pev(ent, pev_impulse, 0)	
return HAM_HANDLED
}
case AT4CS:
{
Reset_All(id)	

g_had[id] = AT4CS
cs_set_user_bpammo(id, CSW_BASE, pev(ent, pev_iuser4))
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

SPR(id, "weapon_at4cs_MSBG")
set_pev(ent, pev_impulse, 0)	
return HAM_HANDLED
}
case MAGNUM:
{
Reset_All(id)	

g_had[id] = MAGNUM
cs_set_user_bpammo(id, CSW_BASE, pev(ent, pev_iuser4))
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

SPR(id, "weapon_magnum_MSBG_1")
set_pev(ent, pev_impulse, 0)	
return HAM_HANDLED
}
}
return HAM_HANDLED
}

public fw_takedmg(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_player(attacker, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[attacker] 

if(get_player_weapon(attacker) != CSW_BASE || had == INVALID)	
return HAM_IGNORED;

if(had == AT4CS && had == MAGNUM) 	
return HAM_IGNORED;

if (damage_type & (1<<24))
return HAM_IGNORED;

static Float:Damage, Float:Jump , target, body
get_user_aiming(attacker, target, body)

switch(had)
{
case AS50:
{
Damage = float(get_damage_body(body, 2.0))	
Jump = 60.0
}
case M95:
{
Damage = float(get_damage_body(body, 3.0))	
Jump = 1000.0
}	
case M24:
{
Damage = float(get_damage_body(body, 1.3))	
Jump = 500.0
}
case Skull5:Damage = float(get_damage_body(body, 1.0))
case SL8EX:Damage = float(get_damage_body(body, 0.5))
}

set_weapon_kick(attacker, victim, Jump)
SetHamParamFloat(4, damage * Damage)
return HAM_HANDLED
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
case AS50:
{
zb5_make_shell(id, 3, 1.0, 17.0, -1.0, 30.0, -60.0, 3); // left side	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/as50-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_player_nextattack(id, 0.380)
set_weapons_recoil(id, 3.0)
set_weapon_anim(id, random_num(1,2))
}	
case Skull5:
{
zb5_make_shell(id, 3, 1.0, 17.0, -1.0, 30.0, -60.0, 3); // left side					
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skull5-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_weapons_recoil(id, 1.5)
set_player_nextattack(id, 0.2900)
set_weapon_anim(id, random_num(1,2))
}
case SL8EX:
{
zb5_make_shell(id, 3, 1.0, 17.0, -1.0, 30.0, -60.0, 3); // left side
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/sl8ex-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_weapons_recoil(id, 1.2)
set_player_nextattack(id, 0.09)
set_weapon_anim(id, random_num(1,2))
}
case M24:
{
zb5_make_shell(id, 3, 1.0, 17.0, -1.0, 30.0, -60.0, 3); // left side	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/m24-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_player_nextattack(id, 1.3)
set_weapons_recoil(id, 2.0)
set_weapon_anim(id, random_num(1,2))

g_had2[id][RELOAD] = true
cs_set_user_zoom(id, CS_RESET_ZOOM, 0)

remove_task(id+TASK_RELOAD_DONE)
set_task(1.3, "set_weapon_reload2", id+TASK_RELOAD_DONE)
}
case M95:
{
zb5_make_shell(id, 3, 1.0, 17.0, -1.0, 30.0, -60.0, 3); // left side	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/m95-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_player_nextattack(id, 1.9)
set_weapons_recoil(id, 3.0)

set_weapon_anim(id, random_num(1,2))
Make_PunchAngle(id, random_float(-6.0, -10.0), random_float(6.0, 7.0))

g_had2[id][RELOAD] = true
cs_set_user_zoom(id, CS_RESET_ZOOM, 1)

remove_task(id+TASK_RELOAD_DONE)
set_task(2.0, "set_weapon_reload2", id+TASK_RELOAD_DONE)
}
}
engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
return FMRES_HANDLED
}
public Frame(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

static Float:flNextAttack; flNextAttack = get_pdata_float(id, 83, 5)
static bpammo; bpammo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(ent, 51, 4)
static fInReload; fInReload  = get_pdata_int(ent, 54, 4)

if(fInReload && flNextAttack <= 0.0)
{
static c, temp1
switch(had)
{
case Skull5:c = 24
case AS50:c = 6
case SL8EX:c = 25
case M24:c = 10
case M95:c = 5
}	
temp1 = min(c - iClip, bpammo)
set_pdata_int(ent, 51, iClip + temp1, 4)
cs_set_user_bpammo(id, CSW_BASE, bpammo - temp1)		
set_pdata_int(ent, 54, 0, 4)
fInReload = 0
}		


return HAM_IGNORED	
}

public Reload(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

g_had2[id][TMPCLIP] = -1

static bpammo; bpammo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(ent, 51, 4)

if (bpammo <= 0)
return HAM_SUPERCEDE

static c
switch(had)
{
case Skull5:c = 24
case AS50:c = 6
case SL8EX:c = 25
case M24:c = 10
case M95:c = 5
}

if(iClip >= c)
return HAM_SUPERCEDE		

g_had2[id][TMPCLIP] = iClip

return HAM_IGNORED
}

public Reload_Post(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had == INVALID)	
return HAM_IGNORED

if (g_had2[id][TMPCLIP] == -1)
return HAM_IGNORED

static Float:time2
switch(had)
{
case Skull5:time2 = 2.2
case AS50:time2 = 3.2
case SL8EX:time2 = 3.3
case M95:
{
time2 = 4.0

remove_task(id+TASK_RELOAD_DONE)
set_task(time2, "set_weapon_reload2", id+TASK_RELOAD_DONE)
}
case M24:
{
time2 = 2.3

remove_task(id+TASK_RELOAD_DONE)
set_task(time2, "set_weapon_reload2", id+TASK_RELOAD_DONE)
}
}

set_pdata_int(ent, 51, g_had2[id][TMPCLIP], 4)
set_pdata_float(ent, 48, time2, 4)
set_pdata_float(id, 83, time2, 5)
set_pdata_int(ent, 54, 1, 4)

g_had2[id][RELOAD] = true
set_weapon_anim(id, 3)	

cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
//g_had2[id][AIMING] = false

return HAM_IGNORED
}

public fw_WeaponIdle_Post(Ent)
{
if(!is_valid_ent(Ent))
return HAM_IGNORED
	
static Id; Id = get_pdata_cbase(Ent, 41, 4)

if(!is_player(Id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[Id] 

if(get_player_weapon(Id) != CSW_BASE || had != MAGNUM)	
return HAM_IGNORED	

if(get_pdata_float(Ent, 48, 4) <= 0.1) 
{
set_weapon_anim(Id, 0)
set_pdata_float(Ent, 48, 20.0, 4)
}

return HAM_IGNORED	
}
public set_weapon_reload(id)
{
id -= TASK_RELOAD
if(!is_player(id, 1))
return;

static Weapons:had
had = g_had[id] 
if(get_player_weapon(id) != CSW_BASE || had != AT4CS)	
return 

g_had2[id][RELOAD] = true
set_weapon_anim(id, 3)

cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
g_had2[id][AIMING] = false
}

public set_weapon_reload2(id)
{
id -= TASK_RELOAD_DONE
if(!is_player(id, 1))
return;

static Weapons:had
had = g_had[id] 
if(get_player_weapon(id) != CSW_BASE || had != AT4CS && had != M95 && had != M24 && had != MAGNUM)	
return 

if(g_had2[id][AIMING])
cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 1)

g_had2[id][RELOAD] = false
}
//////////// AT4 CS ////////////
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had != AT4CS && had != MAGNUM)	
return FMRES_IGNORED

static Float:CurTime; CurTime = get_gametime()
static Body, Target
get_user_aiming(id, Target, Body, 99999999)

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)
if(CurButton & IN_ATTACK)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

if(cs_get_user_bpammo(id, CSW_BASE) <= 0)
{
return FMRES_HANDLED
}

switch(had)
{
case AT4CS:
{
if(get_gametime() - 4.5 > g_had2[id][LASTSHOT])
{
Set_1st_Attack(id)

cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
g_had2[id][AIMING] = false

UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
g_had2[id][LASTSHOT] = get_gametime()
}

}
case MAGNUM:
{
if(get_gametime() - 2.7 > g_had2[id][LASTSHOT])
{
Set_Magnum_Attack(id)
cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))
g_had2[id][LASTSHOT] = get_gametime()
}
}
}
}
if(CurButton & IN_ATTACK2 && (!g_had2[id][RELOAD]))
{
CurButton &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, CurButton)

if(CurTime - 0.5 > g_had2[id][LASTAIM])
{	
cs_set_user_zoom(id,!g_had2[id][AIMING] ? CS_SET_FIRST_ZOOM : CS_RESET_ZOOM, 1)
g_had2[id][AIMING] = (!g_had2[id][AIMING]? true : false)	
g_had2[id][LASTAIM] = CurTime
}
}

return FMRES_HANDLED
}

/// AT4CS ///
public Set_1st_Attack(id)
{
create_fake_attack(id, WEAPON_ANIMEXT)
Make_AT4CS(id)

set_weapon_anim(id, random_num(1,2))
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/at4cs-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	

cs_set_user_bpammo(id, CSW_BASE, cs_get_user_bpammo(id, CSW_BASE) - 1)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

set_player_nextattack(id, 4.5)
set_pdata_float(id, 83, 4.5, 5)	
Make_Sprite(id, ef_sprite[2], 9, 20, 30, 10,  -5)

if(cs_get_user_bpammo(id, CSW_BASE) >= 1)
{
set_task(1.0, "set_weapon_reload", id+TASK_RELOAD)
set_task(4.6, "set_weapon_reload2", id+TASK_RELOAD_DONE)
}else set_weapon_anim(id, 0)
}

public Make_AT4CS(id)
{
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent))
return;

static Float:Velocity[3], Float:Origin[3], Float:Angles[3]
get_position(id, 50.0, 10.0, 0.0, Origin)
entity_get_vector(id, EV_VEC_angles, Angles)

entity_set_string(Ent,EV_SZ_classname, AT4CS_CLASSNAME)
entity_set_model(Ent, "models/ZB5/Items/ZB5_Items_NEW.mdl")

entity_set_int(Ent,EV_INT_body, 8 -1)
entity_set_int(Ent,EV_INT_sequence, 6)

entity_set_edict(Ent, EV_ENT_owner, id);
entity_set_int(Ent,EV_INT_iuser4, 0)

entity_set_int(Ent,EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(Ent,EV_INT_solid, SOLID_BBOX)
entity_set_int(Ent,EV_INT_effects,  EF_LIGHT)

entity_set_vector(Ent,EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(Ent,EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, Angles)

VelocityByAim(id, 1400, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.05) 

Make_PunchAngle(id, 20.0, 0.0)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(Ent) // entity
write_short(ef_sprite[1]) // sprite
write_byte(50)  // life
write_byte(15)  // width
write_byte(100) // r
write_byte(100)  // g
write_byte(100)  // b
write_byte(100) // brightness
message_end()	
}
public fw_AT4CS_Think(ent)
{
if(!is_valid_ent(ent))
return

static Attacker; Attacker = entity_get_edict(ent, EV_ENT_owner)

static Float:Origin[3]
entity_get_vector(ent, EV_VEC_origin, Origin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_SPRITE)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[2]) 
write_byte(3) 
write_byte(230)
message_end()

if(g_had2[Attacker][AIMING])
{
if(entity_get_int(ent,EV_INT_iuser4) == 0)
{
static Victim
Victim = FindClosesEnemy(ent)

if(Get_BitVar(g_IsZombie, Victim))
entity_set_int(ent,EV_INT_iuser4, Victim)
 else {
static Victim
Victim = entity_get_int(ent, EV_INT_iuser4)

if(zp_core_is_zombie(Victim))
{
static Float:VicOrigin[3]
pev(Victim, pev_origin, VicOrigin)

turn_to_target(ent, Origin, Victim, VicOrigin)
hook_ent(ent, Victim, 500.0)
} else {
entity_set_int(ent,EV_INT_iuser4, 0)
}
}
}
}
entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.05) 
}
public fw_AT4CS_Touch(Ent, id)
{
if(!is_valid_ent(Ent))
return

static Float:Origin[3]
entity_get_vector(Ent, EV_VEC_origin, Origin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 10.0)
write_short(ef_sprite[0])
write_byte(80)
write_byte(15)
write_byte(0)
message_end()	

Check_AttackDamge(Ent, Origin)
remove_entity(Ent)
}
public Check_AttackDamge(Ent, Float:Origin[3])
{
if(!is_valid_ent(Ent))
return

static Attacker; Attacker = entity_get_edict(Ent, EV_ENT_owner)
if(!is_player(Attacker, 0))
return;

static Float:Origin[3]
pev(Ent, pev_origin, Origin)

static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, Origin, 200.0)) != 0)
{
if(Attacker == Victim)
continue;

if(!zbs_is_scenario() && Get_BitVar(g_IsZombie, Victim))
do_attack(Attacker, Victim, 0, random_float(500.0, 1000.0), 1)
else 
do_attack(Attacker, Victim, 0, random_float(500.0, 1000.0), 1)
}
}


/// MAGNUM SNIPER ///
public Check_Damage(id)
{
static Float:StartOrigin[3], Float:EndOrigin[3], Float:EndOrigin2[3]

get_position(id, 40.0, 7.5, -5.0, StartOrigin)
get_position(id, 4096.0, 0.0, 0.0, EndOrigin)

static TrResult; TrResult = create_tr2()
engfunc(EngFunc_TraceLine, StartOrigin, EndOrigin, IGNORE_MONSTERS, id, TrResult) 
get_tr2(TrResult, TR_vecEndPos, EndOrigin2)
free_tr2(TrResult)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMPOINTS)
engfunc(EngFunc_WriteCoord, StartOrigin[0])
engfunc(EngFunc_WriteCoord, StartOrigin[1])
engfunc(EngFunc_WriteCoord, StartOrigin[2])
engfunc(EngFunc_WriteCoord, EndOrigin2[0])
engfunc(EngFunc_WriteCoord, EndOrigin2[1])
engfunc(EngFunc_WriteCoord, EndOrigin2[2])
write_short(ef_sprite[1])
write_byte(0)
write_byte(0)
write_byte(10)
write_byte(25)
write_byte(0)
write_byte(0)
write_byte(0)
write_byte(200)
write_byte(200)
write_byte(0)
message_end()	

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_SPARKS) //TE_SPARKS
engfunc(EngFunc_WriteCoord, EndOrigin2[0])
engfunc(EngFunc_WriteCoord, EndOrigin2[1])
engfunc(EngFunc_WriteCoord, EndOrigin2[2])
message_end()	

DealDamage(id, StartOrigin, EndOrigin2)	
}
public Set_Magnum_Attack(id)
{
g_had2[id][RELOAD] = true
set_weapon_anim(id, 1)

//Make_PunchAngle(id, -20.0, 0.0)
set_player_nextattack(id, 2.7)
set_pdata_float(id, 83, 2.7, 5)	

Make_Sprite(id, ef_sprite[3], 1, 20, 30, 5,  -11)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/magnum-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

cs_set_user_bpammo(id, CSW_BASE, cs_get_user_bpammo(id, CSW_BASE) - 1)
UpdateAmmo(id, -1, cs_get_user_bpammo(id, CSW_BASE))

if(cs_get_user_bpammo(id, CSW_BASE) >= 1)
set_task(2.7, "set_weapon_reload2", id+TASK_RELOAD_DONE)
else set_weapon_anim(id, 0)

static weapon_ent
weapon_ent = find_ent_by_owner(-1, weapon_base, id)

if(!is_valid_ent(weapon_ent))
return

ExecuteHamB(Ham_Weapon_PrimaryAttack, weapon_ent)
Check_Damage(id)
}
public DealDamage(id, Float:Start[3], Float:End[3])
{
static TrResult; TrResult = create_tr2()

// Trace First Time
engfunc(EngFunc_TraceLine, Start, End, DONT_IGNORE_MONSTERS, id, TrResult) 
static pHit1; pHit1 = get_tr2(TrResult, TR_pHit)
static Float:End1[3]; get_tr2(TrResult, TR_vecEndPos, End1)

if(is_valid_ent(pHit1)) 
{
do_attack(id, pHit1, 0, float(300), 1)
engfunc(EngFunc_TraceLine, End1, End, DONT_IGNORE_MONSTERS, pHit1, TrResult) 
} else engfunc(EngFunc_TraceLine, End1, End, DONT_IGNORE_MONSTERS, -1, TrResult) 

// Trace Second Time
static pHit2; pHit2 = get_tr2(TrResult, TR_pHit)
static Float:End2[3]; get_tr2(TrResult, TR_vecEndPos, End2)

if(is_valid_ent(pHit2)) 
{
do_attack(id, pHit2, 0, float(200), 1)
engfunc(EngFunc_TraceLine, End2, End, DONT_IGNORE_MONSTERS, pHit2, TrResult) 
} else engfunc(EngFunc_TraceLine, End2, End, DONT_IGNORE_MONSTERS, -1, TrResult) 

// Trace Third Time
static pHit3; pHit3 = get_tr2(TrResult, TR_pHit)
static Float:End3[3]; get_tr2(TrResult, TR_vecEndPos, End3)

if(is_valid_ent(pHit3)) 
{
do_attack(id, pHit3, 0, float(100), 1)
engfunc(EngFunc_TraceLine, End3, End, DONT_IGNORE_MONSTERS, pHit3, TrResult) 
} else engfunc(EngFunc_TraceLine, End3, End, DONT_IGNORE_MONSTERS, -1, TrResult) 

// Trace Fourth Time
static pHit4; pHit4 = get_tr2(TrResult, TR_pHit)
if(is_valid_ent(pHit4)) do_attack(id, pHit4, 0, float(300), 1)

free_tr2(TrResult)
}

stock SPR(id, const weapon[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
write_string(weapon)
write_byte(4)
write_byte(90)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(16)
write_byte(13)
write_byte(CSW_BASE)
message_end()
}

stock create_beampoints(Float:StartPosition[3], Float:TargetPosition[3], SpritesID, StartFrame, Framerate, Life, LineWidth, Amplitude, Red, Green, Blue, Brightness, Speed)
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMPOINTS)
engfunc(EngFunc_WriteCoord, StartPosition[0])
engfunc(EngFunc_WriteCoord, StartPosition[1])
engfunc(EngFunc_WriteCoord, StartPosition[2])
engfunc(EngFunc_WriteCoord, TargetPosition[0])
engfunc(EngFunc_WriteCoord, TargetPosition[1])
engfunc(EngFunc_WriteCoord, TargetPosition[2])
write_short(SpritesID)
write_byte(StartFrame)
write_byte(Framerate)
write_byte(Life)
write_byte(LineWidth)
write_byte(Amplitude)
write_byte(Red)
write_byte(Green)
write_byte(Blue)
write_byte(Brightness)
write_byte(Speed)
message_end()
}
stock get_damage_body(body, Float:damage) 
{
switch(body) 
{
case HIT_HEAD: damage *= 2.5
case HIT_STOMACH: damage *= 2.0
case HIT_CHEST: damage *= 1.9
case HIT_LEFTARM: damage *= 1.75
case HIT_RIGHTARM: damage *= 1.75
case HIT_LEFTLEG: damage *= 1.25
case HIT_RIGHTLEG: damage *= 1.25
default: damage *= 1.0
}
return floatround(damage)
}
public UpdateAmmo(Id, Ammo, BpAmmo)
{
static weapon_ent; weapon_ent = fm_get_user_weapon_entity(Id, CSW_BASE)
if(is_valid_ent(weapon_ent))
{
if(BpAmmo > 0) cs_set_weapon_ammo(weapon_ent, 1)
else cs_set_weapon_ammo(weapon_ent, 0)
}

engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0, 0, 0}, Id)
write_byte(1)
write_byte(CSW_BASE)
write_byte(-1)
message_end()

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, Id)
write_byte(1)
write_byte(BpAmmo)
message_end()

cs_set_user_bpammo(Id, CSW_BASE, BpAmmo)
}

stock FindClosesEnemy(entid)
{
static Float:Dist
static Float:maxdistance; maxdistance = 400.0
static indexid; indexid = 0
	
for(new i=1; i <= g_maxplayers; i++)
{
if(is_user_alive(i) && is_valid_ent(i) && can_see_fm(entid, i) && pev(entid, pev_owner) != i && cs_get_user_team(pev(entid, pev_owner)) != cs_get_user_team(i))
{
Dist = entity_range(entid, i)
if(Dist <= maxdistance)
{
maxdistance=Dist
indexid=i

return indexid
}
}	
}	
return 0
}

stock bool:can_see_fm(entindex1, entindex2)
{
if (!entindex1 || !entindex2)
return false

if (is_valid_ent(entindex1) && is_valid_ent(entindex1))
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

stock turn_to_target(ent, Float:Ent_Origin[3], target, Float:Vic_Origin[3]) 
{
if(target) 
{
new Float:newAngle[3]
entity_get_vector(ent, EV_VEC_angles, newAngle)
new Float:x = Vic_Origin[0] - Ent_Origin[0]
new Float:z = Vic_Origin[1] - Ent_Origin[1]

new Float:radians = floatatan(z/x, radian)
newAngle[1] = radians * (180 / 3.14)
if (Vic_Origin[0] < Ent_Origin[0])
newAngle[1] -= 180.0

entity_set_vector(ent, EV_VEC_angles, newAngle)
}
}
stock hook_ent(ent, victim, Float:speed)
{
static Float:fl_Velocity[3]
static Float:VicOrigin[3], Float:EntOrigin[3]

pev(ent, pev_origin, EntOrigin)
pev(victim, pev_origin, VicOrigin)

static Float:distance_f
distance_f = get_distance_f(EntOrigin, VicOrigin)

if (distance_f > 10.0)
{
new Float:fl_Time = distance_f / speed

fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
} else
{
fl_Velocity[0] = 0.0
fl_Velocity[1] = 0.0
fl_Velocity[2] = 0.0
}

entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
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
