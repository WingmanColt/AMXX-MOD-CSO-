#include <amxmodx>
#include <ZombieMod5>
#include <infinitygame>

#define FIRE_CLASSNAME "FLAME_BALROG11"
#define SCYTHE_CLASSNAME "scythe11"
#define TASK_CHANGE 23332

#define CSW_BASE CSW_XM1014
#define weapon_base "weapon_xm1014"
#define WEAPON_ANIMEXT "shotgun"

#define SCYTHE_CIRCLE "sprites/ZB5/circle.spr"
#define SCYTHE_DEATH "sprites/ZB5/thanatos11_fire.spr"

new const sound[][] =
{
"ZB5/weapons/qbarrel-1.wav",
"ZB5/weapons/dbarrel-1.wav",
"ZB5/weapons/gatling-1.wav",
"ZB5/weapons/m1887-1.wav",
"ZB5/weapons/uts15-1.wav",  
"ZB5/weapons/skull11-1.wav",  
"ZB5/weapons/balrog11-1.wav",
"ZB5/weapons/balrog11-2.wav",
"ZB5/weapons/balrog11_charge.wav",
"ZB5/weapons/thanatos11-1.wav",  
"ZB5/weapons/thanatos11_count.wav",  
"ZB5/weapons/thanatos11_shootb.wav",  
"ZB5/weapons/thanatos11_shootb_hit.wav"
}
new const models[][] =
{		
"models/ZB5/Primary/v_gatling.mdl",	
"models/ZB5/Primary/v_qbarrel.mdl",
"models/ZB5/Primary/v_dbarrel.mdl",
"models/ZB5/Primary/v_uts15.mdl",
"models/ZB5/Primary/v_skull11.mdl",
"models/ZB5/Primary/v_m1887.mdl",
"models/ZB5/Primary/v_thanatos11.mdl",
"models/ZB5/Primary/v_balrog11_new.mdl"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud2.spr",				
"sprites/ZB5/HUD2/640hud47.spr",
"sprites/ZB5/HUD2/640hud80.spr",
"sprites/ZB5/HUD2/640hud89.spr",		
"sprites/ZB5/HUD2/640hud121.spr",
"sprites/weapon_dbarrel_MSBG.txt",
"sprites/weapon_gatling_MSBG.txt",
"sprites/weapon_uts15_MSBG.txt",
"sprites/weapon_balrog11_MSBG.txt",
"sprites/weapon_skull11_MSBG.txt",
"sprites/weapon_m1887_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_dbarrel_MSBG",
"weapon_gatling_MSBG",
"weapon_uts15_MSBG",
"weapon_balrog11_MSBG",
"weapon_skull11_MSBG",
"weapon_m1887_MSBG"
}
enum Weapons
{
INVALID = 0,
THANATOS11,
BALROG11,
QBARREL,	
GATLING,
SKULL11,
UTS12,
M1887
}
enum _:Options
{
Old,	
AMMO,
MODE,
SHOTS,
TMPCLIP,
LAST_AMMO,
HOLD_ATTACK2,
Float:ATTACK1,
Float:ATTACK2
}
enum 
{	
MODE_A = 0,
MODE_B
}

new Weapons:g_had[33], g_special[33][Options], g_weapon[7], ef_sprite[3]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]
public plugin_init()
{
if(!zb5_weapons_primary())
return

Register_SafetyFunc()		
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")

register_think(FIRE_CLASSNAME, "fw_Think")
register_touch(FIRE_CLASSNAME, "*", "fw_Touch")

register_touch(SCYTHE_CLASSNAME, "*", "fw_Scythe_Touch")
register_think(SCYTHE_CLASSNAME, "fw_Scythe_Think")

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_item_addtoplayer", 1)
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_Weapon_WeaponIdle_Post", 1)	
RegisterHam(Ham_TakeDamage, "player", "fw_takedmg")

// reload 1
RegisterHam(Ham_Item_PostFrame, weapon_base, "fw_ItemPostFrame")
RegisterHam(Ham_Weapon_Reload, weapon_base, "fw_Reload")
RegisterHam(Ham_Weapon_Reload, weapon_base, "fw_Reload_Post", 1)

// reload 2
RegisterHam(Ham_Item_PostFrame, weapon_base, "Shotgun_PostFrame")
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "Shotgun_WeaponIdle")

register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
register_forward(FM_CmdStart, "fw_CmdStart")
register_forward(FM_SetModel, "fw_SetModel")	
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

PrecacheModel(SCYTHE_CIRCLE)

ef_sprite[0] = PrecacheModel("sprites/smokepuff.spr")	
ef_sprite[1] = PrecacheModel("sprites/laserbeam.spr")	
ef_sprite[2] = PrecacheModel(SCYTHE_DEATH)	

g_weapon[0] = zb5_register_weapon("M1887", "Winchester", WPN_SHOTGUNS, 0, 0)
g_weapon[6] = zb5_register_weapon("Double", "Barrel", WPN_SHOTGUNS, 0, 0)
g_weapon[1] = zb5_register_weapon("UTS-15", "\yMaster Edition", WPN_SHOTGUNS, LEVEL_UTS15, 0)
g_weapon[2] = zb5_register_weapon("Gatling", "Volcano \r+2", WPN_SHOTGUNS, LEVEL_GATLING, 0)
g_weapon[3] = zb5_register_weapon("Skull 11", "\rAnti-Zombie", WPN_SHOTGUNS, LEVEL_SKULL11, 0)
g_weapon[4] = zb5_register_weapon("Kel-Tec", "\rThanatos 11", WPN_SHOTGUNS, LEVEL_KSG, 1)
g_weapon[5] = zb5_register_weapon("Balrog XI", "\rFlame Shooter", WPN_SHOTGUNS, LEVEL_BALROG11, 1)
}
public plugin_natives()
{
register_native("get_weapon_shotgun", "Get_Shotgun", 1)
}
public Hook_SPR(id)
{
engclient_cmd(id, weapon_base)
return;
}
public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0]) Get_Shotgun(id, 6)
else if(wpnid == g_weapon[1]) Get_Shotgun(id, 1)
else if(wpnid == g_weapon[2]) Get_Shotgun(id, 2)
else if(wpnid == g_weapon[3]) Get_Shotgun(id, 7)
else if(wpnid == g_weapon[4]) Get_Shotgun(id, 3)
else if(wpnid == g_weapon[5]) Get_Shotgun(id, 4)
else if(wpnid == g_weapon[6]) Get_Shotgun(id, 5)
}
public Get_Shotgun(id, Weapon)
{
if(!zb5_weapons_primary())
return

drop_weapons(id, 1)
Reset_All(id)
fm_give_item(id, weapon_base)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) 
return

switch(Weapon)
{
case 1:
{
g_had[id] = UTS12	
cs_set_weapon_ammo(Ent, 20)	
SPR(id, "weapon_uts15_MSBG")
}
case 2:
{
g_had[id] = GATLING	
cs_set_weapon_ammo(Ent, 40)
SPR(id, "weapon_gatling_MSBG")
}
case 3:
{
g_had[id] = THANATOS11	
cs_set_weapon_ammo(Ent, 15)
SPR(id, "weapon_thanatos11_MSBG")
}	
case 4:
{
g_had[id] = BALROG11	
cs_set_weapon_ammo(Ent, 7)
SPR(id, "weapon_balrog11_MSBG")
IG_Muzzleflash_Set(id, "sprites/ZB5/muz_sfmg.spr", 0.20)
}
case 5:
{
g_had[id] = QBARREL	
cs_set_weapon_ammo(Ent, zp_core_is_hero(id) ? 4 : 2)
SPR(id, "weapon_dbarrel_MSBG")
}
case 6:
{
g_had[id] = M1887	
cs_set_weapon_ammo(Ent, 8)
SPR(id, "weapon_m1887_MSBG")
}
case 7:
{
g_had[id] = SKULL11	
cs_set_weapon_ammo(Ent, 28)
SPR(id, "weapon_skull11_MSBG")
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

static Clip
switch(zb5_had_StrongLife(id))
{
case 0: Clip = 90	
case 1: Clip = 130	
}

cs_set_user_bpammo(id, CSW_BASE, Clip)
}
public Reset_All(id)
{
update_specialammo(id, g_special[id][AMMO], 0)	

arrayset(_:g_had[id], false, sizeof(g_had[]));
arrayset(_:g_special[id], false, sizeof(g_special[]));	
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
case UTS12:
{
SubModel = 9
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_uts15.mdl")
}
case GATLING:
{
SubModel = 17
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_gatling.mdl")
}
case THANATOS11:
{
SubModel = 32
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_thanatos11.mdl")
}
case BALROG11:
{
SubModel = 2
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_balrog11_new.mdl")
}
case QBARREL:
{
SubModel = 18
set_pev(id, pev_viewmodel2, zp_core_is_hero(id) ? "models/ZB5/Primary/v_qbarrel.mdl" : "models/ZB5/Primary/v_dbarrel.mdl")
}
case M1887:
{
SubModel = 30
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_m1887.mdl")
}
case SKULL11:
{
SubModel = 19
set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_skull11.mdl")
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

if((CSWID == CSW_BASE && g_special[id][Old] != CSW_BASE) && had != INVALID)
Draw_NewWeapon(id, CSWID)

else if((CSWID == CSW_BASE && g_special[id][Old] == CSW_BASE) && had != INVALID) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent))
{
g_special[id][Old] = get_player_weapon(id)
return
}

static ammo; ammo = read_data(3) 

if (g_special[id][LAST_AMMO] > ammo) 
{ 
static vec1[3], vec2[3] 
get_user_origin(id,vec1,1) 
get_user_origin(id,vec2,3) 

message_begin(MSG_PAS, SVC_TEMPENTITY,vec1 ) 
write_byte( 6 ) 
write_coord(vec1[0]) 
write_coord(vec1[1]) 
write_coord(vec1[2]) 
write_coord(vec2[0]) 
write_coord(vec2[1]) 
write_coord(vec2[2]) 
message_end() 
} 

g_special[id][LAST_AMMO] = ammo 
} 

else if(CSWID != CSW_BASE && g_special[id][Old] == CSW_BASE) 
Draw_NewWeapon(id, CSWID)

g_special[id][Old] = get_player_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
if(!is_player(id, 1))
return	
static Weapons:had
had = g_had[id] 

if(CSW_ID == CSW_BASE)
{
static ent
ent = fm_get_user_weapon_entity(id, CSW_BASE)

if(is_valid_ent(ent) && had != INVALID)
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

static Submodel, Sequence;

switch(had)
{
case UTS12:
{
Submodel = 9;Sequence = 8	
}
case GATLING:
{
set_weapon_anim(id, 4)	
Submodel = 17;Sequence = 18
}
case THANATOS11:
{
g_special[id][MODE] = MODE_A	
set_weapon_anim(id, 14)	
update_specialammo(id, g_special[id][AMMO], g_special[id][AMMO] > 0 ? 1 : 0)		
Submodel = 32;Sequence = 30
}
case BALROG11:
{
update_specialammo(id, g_special[id][AMMO], g_special[id][AMMO] > 0 ? 1 : 0)	
Submodel = 2;Sequence = 1
}
case QBARREL:
{
set_weapon_anim(id, 4)
Submodel = 18;Sequence = 15
}
case M1887:
{
Submodel = 30;Sequence = 28
}
case SKULL11:
{
set_weapon_anim(id, 4)		
Submodel = 19;Sequence = 11
}
}

engfunc(EngFunc_SetModel, ent, P_Model)		
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)	

set_weapons_timeidle(id, CSW_BASE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)
}
} else {
static ent; ent = fm_get_user_weapon_entity(id, CSW_BASE)

if(is_valid_ent(ent)) 
set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 	

update_specialammo(id, g_special[id][AMMO], 0)		
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

if(!equal(model, "models/w_xm1014.mdl"))
return FMRES_IGNORED;

static weapon; weapon = find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

static Weapons:had
had = g_had[iOwner] 

switch(had)
{
case QBARREL:
{	
set_pev(weapon, pev_impulse, QBARREL)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 25 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case GATLING:
{	
set_pev(weapon, pev_impulse, GATLING)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 25 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case UTS12:
{	
set_pev(weapon, pev_impulse, UTS12)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 8 - 1)
Reset_All(iOwner)	
return FMRES_SUPERCEDE
}
case THANATOS11:
{	
set_pev(weapon, pev_impulse, THANATOS11)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(weapon, pev_iuser4, g_special[iOwner][AMMO])
set_pev(entity, pev_body, 32 - 1)
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case BALROG11:
{	
set_pev(weapon, pev_impulse, BALROG11)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 10 - 1)
set_pev(weapon, pev_iuser4, g_special[iOwner][AMMO])
Reset_All(iOwner)
return FMRES_SUPERCEDE
}
case M1887:
{	
set_pev(weapon, pev_impulse, M1887)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 36 - 1)
Reset_All(iOwner)	
return FMRES_SUPERCEDE
}
case SKULL11:
{	
set_pev(weapon, pev_impulse, SKULL11)	
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 39 - 1)
Reset_All(iOwner)	
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
case QBARREL:
{	
g_had[id] = QBARREL
SPR(id, "weapon_dbarrel_MSBG")
set_pev(ent, pev_impulse, 0)
}
case GATLING:
{	
g_had[id] = GATLING	
SPR(id, "weapon_gatling_MSBG")
set_pev(ent, pev_impulse, 0)
}
case THANATOS11:
{	
g_had[id] = THANATOS11
g_special[id][AMMO] = pev(ent, pev_iuser4)

SPR(id, "weapon_thanatos11_MSBG")
set_pev(ent, pev_impulse, 0)
}
case UTS12:
{	
g_had[id] = UTS12	
SPR(id, "weapon_uts15_MSBG")
set_pev(ent, pev_impulse, 0)
}
case BALROG11:
{
g_had[id] = BALROG11
g_special[id][AMMO] = pev(ent, pev_iuser4)

SPR(id, "weapon_balrog11_MSBG")
IG_Muzzleflash_Set(id, "sprites/ZB5/muz_sfmg.spr", 0.20)

set_pev(ent, pev_impulse, 0)
}
case M1887:
{
g_had[id] = M1887
SPR(id, "weapon_m1887_MSBG")
set_pev(ent, pev_impulse, 0)
}
case SKULL11:
{
g_had[id] = SKULL11
SPR(id, "weapon_skull11_MSBG")
set_pev(ent, pev_impulse, 0)
}
}

}

public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return FMRES_IGNORED

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had == INVALID)	
return FMRES_IGNORED

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)	
static Float:CurTime; CurTime = get_gametime()

static ent; ent = find_ent_by_owner(-1, weapon_base, id)

if(!is_valid_ent(ent))
return FMRES_IGNORED

if(get_pdata_float(id, 83, 5) > 0.0) 
return FMRES_IGNORED

switch(had)
{
case QBARREL:SHOOT_QBARREL(id, uc_handle, CurButton, Float:CurTime, ent)
case THANATOS11:SHOOT_THANATOS11(id, uc_handle, CurButton, Float:CurTime, ent)
case BALROG11:SHOOT_BALROG11(id, uc_handle, CurButton, Float:CurTime, ent)
}
return FMRES_HANDLED
}

public SHOOT_QBARREL(id, uc_handle, CurButton, Float:CurTime, ent)
{	
if(!zp_core_is_hero(id))
return;

if(cs_get_weapon_ammo(ent) <= 0 || get_pdata_int(ent, 54, 4))
return

if(CurButton & IN_ATTACK2 && !(pev(id, pev_oldbuttons) & IN_ATTACK))
{
CurButton &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, CurButton)

static ammo, i 
ammo = cs_get_weapon_ammo(ent)

if(ammo <= 0)
return;	

if(CurTime - 3.7 > g_special[id][ATTACK2])
{	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/qbarrel-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
set_weapon_anim(id, random_num(1, 2))
set_weapons_recoil(id, 1.0)

for(i = 0; i < ammo; i++)
ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)

g_special[id][ATTACK2] = CurTime		
}
}
}
public SHOOT_BALROG11(id, uc_handle, CurButton, Float:CurTime, ent)
{		
if(CurButton & IN_ATTACK2 && !(pev(id, pev_oldbuttons) & IN_ATTACK))
{
CurButton &= ~IN_ATTACK2
set_uc(uc_handle, UC_Buttons, CurButton)	

if(CurTime - 0.45 > g_special[id][ATTACK2])
{
if(g_special[id][AMMO] <= 0)
return	

update_specialammo(id, g_special[id][AMMO], 0)
g_special[id][AMMO]--
update_specialammo(id, g_special[id][AMMO], g_special[id][AMMO] > 0 ? 1 : 0)

Create_FireSystem(id, 1)
set_weapon_anim(id, 2)

emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog11-2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
g_special[id][ATTACK2] = CurTime		
}
}
}
public Config_Balrog11(id)
{
g_special[id][SHOTS]++

if(g_special[id][SHOTS] >= 6)
{
if(g_special[id][AMMO] < 7)
{
update_specialammo(id, g_special[id][AMMO], 0)
g_special[id][AMMO]++
update_specialammo(id, g_special[id][AMMO], 1)

g_special[id][SHOTS] = 0
Make_Sprite(id, ef_sprite[0], 9, 20, 35, 8, -15)			
emit_sound(id, CHAN_ITEM, "ZB5/weapons/balrog11_charge.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}
}	
}

/// THANATOS 11 ///
public SHOOT_THANATOS11(id, uc_handle, CurButton, Float:CurTime, ent)
{	
if(get_gametime() - 10.0 > g_special[id][ATTACK1])
{
if(g_special[id][AMMO] < 3)
{
update_specialammo(id, g_special[id][AMMO], 0)
g_special[id][AMMO]++

if(g_special[id][AMMO] == 1 && g_special[id][MODE] == MODE_B) 
set_weapon_anim(id, 15)

emit_sound(id, CHAN_ITEM,"ZB5/weapons/thanatos11_count.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
update_specialammo(id, g_special[id][AMMO], 1)
}

g_special[id][ATTACK1] = get_gametime()
}

if(get_player_weapon(id) != CSW_BASE)
return

if(CurButton & IN_RELOAD)
{
if(get_pdata_float(id, 83, 5) > 0.0)
return 

if(g_special[id][MODE] == MODE_B)
{
CurButton &= ~IN_RELOAD
set_uc(uc_handle, UC_Buttons, CurButton)
}
}

if(CurButton & IN_ATTACK)
{
if(get_pdata_float(id, 83, 5) > 0.0)
return 

if(g_special[id][MODE] == MODE_B)
{
CurButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, CurButton)

Shoot_Scythe(id)
}
}

if(CurButton & IN_ATTACK2)
{
if(get_pdata_float(id, 83, 5) > 0.0)
return 

switch(g_special[id][MODE])
{
case MODE_A:
{
if(g_special[id][AMMO] > 0) set_weapon_anim(id, 10)
else set_weapon_anim(id, 11)

set_pdata_float(id, 83, 2.5, 5)

remove_task(id+TASK_CHANGE)
set_task(2.35, "Complete_Reload", id+TASK_CHANGE)
}
case MODE_B:
{
if(g_special[id][AMMO] > 0) set_weapon_anim(id, 12)
else set_weapon_anim(id, 13)

set_pdata_float(id, 83, 2.5, 5)

remove_task(id+TASK_CHANGE)
set_task(2.35, "Complete_Reload", id+TASK_CHANGE)
}
}
}
}
public Complete_Reload(id)
{
id -= TASK_CHANGE

if(!is_player(id, 1))
return

static Weapons:had
had = g_had[id] 

if(get_player_weapon(id) != CSW_BASE || had != THANATOS11)	
return

g_special[id][MODE] = (g_special[id][MODE]? MODE_A : MODE_B)	
}
public Shoot_Scythe(id)
{
if(g_special[id][AMMO] <= 0)
return

create_fake_attack(id, WEAPON_ANIMEXT)
update_specialammo(id, g_special[id][AMMO], 0)
g_special[id][AMMO]--
update_specialammo(id, g_special[id][AMMO], 1)

set_weapon_anim(id, 9)
emit_sound(id, CHAN_ITEM,"ZB5/weapons/thanatos11_shootb.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_pdata_float(id, 83, 1.0, 5)
Make_PunchAngle(id, 3.0, 0.0)

// Scythe
Create_Scythe(id)
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

static Float:Damage, target, body
get_user_aiming(attacker, target, body)

switch(had)
{
case BALROG11:Damage = float(get_damage_body(body, 1.0))
case GATLING:Damage = float(get_damage_body(body, random_float(1.0, 1.3)))
case UTS12:Damage = float(get_damage_body(body, 1.1))	
case THANATOS11:Damage = float(get_damage_body(body, 1.2))	
case SKULL11:Damage = float(get_damage_body(body, random_float(1.0, 1.4)))
case M1887:
{
Damage = float(get_damage_body(body, random_float(1.0, 2.0)))
set_weapon_knockback(attacker, victim, 100.0)
}
case QBARREL:
{
if(zp_core_is_hero(attacker))	
Damage = float(get_damage_body(body, random_float(4.0, 5.0)))
else 
Damage = float(get_damage_body(body, random_float(1.0, 3.0)))
set_weapon_kick(attacker, victim, zp_core_is_hero(attacker) ? 5000.0 : 2000.0)	
}
}

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
case QBARREL:
{	
emit_sound(id, CHAN_WEAPON, zp_core_is_hero(id) ? "ZB5/weapons/qbarrel-1.wav" : "ZB5/weapons/dbarrel-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_weapons_recoil(id, 1.0)	
set_weapon_anim(id, random_num(1,2))
}
case GATLING:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/gatling-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Sprite(id, ef_sprite[0], 9, 20, 35, 8, -15)

set_player_nextattack(id, 0.250)
set_weapon_anim(id, random_num(1,2))
}
case SKULL11:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skull11-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Sprite(id, ef_sprite[0], 9, 20, 35, 8, -15)

set_player_nextattack(id, 0.350)
set_weapon_anim(id, random_num(1,2))
}
case UTS12:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/uts15-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Sprite(id, ef_sprite[0], 9, 20, 35, 8, -15)

set_weapon_anim(id, random_num(1,2))
set_player_nextattack(id, 0.450)
}
case M1887:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/m1887-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Sprite(id, ef_sprite[0], 9, 20, 35, 8, -15)

set_weapon_anim(id, random_num(1,2))
set_player_nextattack(id, 0.650)
}
case BALROG11:
{	
IG_Muzzleflash_Activate(id);		
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog11-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	
zb5_make_shell(id, 4, -5.0, 15.0, 0.0, -10.0, -70.0, 3);

set_weapon_anim(id, 1)
Config_Balrog11(id)	
}
case THANATOS11:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos11-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Sprite(id, ef_sprite[0], 9, 20, 35, 8, -15)

set_player_nextattack(id, 0.7)
set_weapon_anim(id, 7)		
}
}
return FMRES_HANDLED
}
// BALROG XI
public Create_FireSystem(id, OffSet)
{
const MAX_FIRE = 10
static Float:StartOrigin[3], Float:TargetOrigin[MAX_FIRE][3], Float:Speed[MAX_FIRE], Float:RTime[MAX_FIRE], i

// -- Left
get_position(id, 100.0, 2.0, 2.0, TargetOrigin[0]); Speed[0] = 700.0; RTime[0] = 0.8
get_position(id, 100.0,	6.0, 2.0, TargetOrigin[1]); Speed[1] = 700.0; RTime[1] = 0.8
get_position(id, 100.0, 8.0, 3.0, TargetOrigin[2]); Speed[2] = 700.0; RTime[2] = 0.8
get_position(id, 100.0, 10.0, 3.0, TargetOrigin[3]); Speed[3] = 700.0; RTime[3] = 0.8

// -- Center
get_position(id, 100.0, 12.0, 0.0, TargetOrigin[4]); Speed[4] = 900.0; RTime[4] = 0.01 
get_position(id, 100.0, -12.0, 0.0, TargetOrigin[5]); Speed[5] = 900.0; RTime[5] = 0.01

// -- Right
get_position(id, 100.0, -2.0 , 2.0, TargetOrigin[6]); Speed[6] = 700.0; RTime[6] = 0.8
get_position(id, 100.0, -6.0, 2.0, TargetOrigin[7]); Speed[7] = 700.0; RTime[7] = 0.8
get_position(id, 100.0,	-8.0, 3.0, TargetOrigin[8]); Speed[8] = 700.0; RTime[8] = 0.8
get_position(id, 100.0,	-10.0, 3.0, TargetOrigin[9]); Speed[9] = 700.0; RTime[9] = 0.8


for(i = 0; i < MAX_FIRE; i++)
{
// Get Start
get_position(id, random_float(20.0, 60.0), 0.0, -5.0, StartOrigin)
Create_Fire(id, StartOrigin, TargetOrigin[i], Speed[i], RTime[i], OffSet)
}
}
public Create_Fire(id, Float:Origin[3], Float:TargetOrigin[3], Float:Speed, Float:RTime, Offset)
{
static Ent; Ent = create_entity("info_target")
if(!is_valid_ent(Ent))
return;

static Float:Velocity[3]

// Set info for ent
entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(Ent, EV_INT_solid, SOLID_TRIGGER)

entity_set_int(Ent, EV_INT_rendermode, kRenderTransAdd)
entity_set_float(Ent, EV_FL_renderamt, 80.0)
entity_set_float(Ent, EV_FL_scale, 0.50)

entity_set_float(Ent, EV_FL_fuser1, get_gametime() + RTime) 
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.05) 

entity_set_string(Ent, EV_SZ_classname, FIRE_CLASSNAME)
entity_set_model(Ent, "sprites/ZB5/fire.spr")

entity_set_vector(Ent,EV_VEC_mins, Float:{-1.0, -1.0, -1.0})
entity_set_vector(Ent,EV_VEC_maxs, Float:{1.0, 1.0, 1.0})

entity_set_origin(Ent, Origin)

entity_set_int(Ent, EV_INT_iuser1, id)	
entity_set_int(Ent, EV_INT_iuser4, Offset)

get_speed_vector(Origin, TargetOrigin, Speed, Velocity)
entity_set_vector(Ent, EV_VEC_velocity, Velocity) 
}
public fw_Think(ent)
{
if(!is_valid_ent(ent)) 
return

static Float:fFrame; fFrame = entity_get_float(ent, EV_FL_frame) 

fFrame += 1.5
fFrame = floatmin(21.0, fFrame)

entity_set_float(ent, EV_FL_frame, fFrame) 
entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.05) 

// time remove
static Float:fTimeRemove; fTimeRemove = entity_get_float(ent,EV_FL_fuser1)
static Float:Amount; Amount = entity_get_float(ent,EV_FL_renderamt)

if(get_gametime() >= fTimeRemove) 
{
Amount -= 10.0
entity_set_float(ent,EV_FL_renderamt, Amount)

if(Amount <= 15.0) 
remove_entity(ent)
}
}
public fw_Touch(ent, id)
{
if(!is_valid_ent(ent))
return

static Classname[32]
pev(id, pev_classname, Classname, sizeof(Classname))

if(equal(Classname, FIRE_CLASSNAME)) 
return

entity_set_int(ent,EV_INT_movetype, MOVETYPE_NONE)
entity_set_int(ent,EV_INT_solid, SOLID_NOT)

static Attacker; Attacker = entity_get_int(ent,EV_INT_iuser1)

if(is_player(Attacker, 1))
{
if(Get_BitVar(g_IsZombie, id))
{
set_weapon_kick(Attacker, id, 500.0)
zb5_make_burn(id, Attacker, 6.0, 0.3, "sprites/ZB5/flame_burn01.spr")
}
do_attack(Attacker, id, 0, random_float(40.0, 70.0), 0)
}

remove_entity(ent)
}	
//// SCYTHE BLADE SYSTEM ////
public Create_Scythe(id)
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
entity_set_string(iEnt, EV_SZ_classname, SCYTHE_CLASSNAME)

entity_set_model(iEnt, "models/ZB5/Items/ZB5_Items_NEW.mdl")
entity_set_int(iEnt,EV_INT_body, 8 - 1)

set_pev(iEnt, pev_mins, Float:{-6.0, -6.0, -6.0})
set_pev(iEnt, pev_maxs, Float:{6.0, 6.0, 6.0})

entity_set_origin(iEnt, Origin)
entity_set_vector(iEnt, EV_VEC_angles, Angles)
entity_set_float(iEnt, EV_FL_gravity, 0.01)

entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER)

entity_set_edict(iEnt, EV_ENT_owner, id);
entity_set_float(iEnt, EV_FL_fuser1, get_gametime() + 10.0)

get_speed_vector(Origin, TargetOrigin, 1600.0, Velocity)
entity_set_vector(iEnt, EV_VEC_velocity, Velocity) 
entity_set_float(iEnt, EV_FL_nextthink, halflife_time() + 0.1) 

// Animation
entity_set_float(iEnt, EV_FL_animtime, get_gametime())
entity_set_float(iEnt, EV_FL_framerate, 2.0)
entity_set_int(iEnt, EV_INT_sequence, 6)

// Make a Beam
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW)
write_short(iEnt)
write_short(ef_sprite[1])
write_byte(10)
write_byte(3)
write_byte(0)
write_byte(85)
write_byte(255)
write_byte(255)
message_end()
}

public fw_Scythe_Touch(Ent, id)
{
if(!pev_valid(Ent))
return

if(is_user_alive(id))
{
static Owner; Owner = pev(Ent, pev_owner)
if(!is_user_connected(Owner) || (get_user_team(id) == pev(Ent, pev_iuser1)))
return

ThanatosBladeSystem(id, Owner)

set_pev(Ent, pev_movetype, MOVETYPE_NONE)
set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})

set_pev(Ent, pev_flags, FL_KILLME)
set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
} else {
set_pev(Ent, pev_movetype, MOVETYPE_NONE)
set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})

set_pev(Ent, pev_flags, FL_KILLME)
set_pev(Ent, pev_nextthink, get_gametime() + 0.1)

return
}
}
public ThanatosBladeSystem(id, attacker)
{
if(!is_valid_ent(id))	
return

if(Get_BitVar(g_IsZombie, id))	
zb5_AddTofull_Icon(id, 250.0, 0.7, 3.0, SCYTHE_CIRCLE, 10)

emit_sound(id, CHAN_ITEM, "ZB5/weapons/thanatos11_shootb_hit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

static ArraySuck[2]
ArraySuck[0] = id
ArraySuck[1] = attacker

set_task(3.0, "Explosion", id+2122, ArraySuck, 2)
}

public Explosion(ArraySuck[], taskid)
{
static id, attacker;
id = ArraySuck[0]
attacker  = ArraySuck[1]

if(!is_valid_ent(id))
return

static Float:Origin[3]; 
entity_get_vector(id, EV_VEC_origin, Origin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2]+ 40.0)
write_short(ef_sprite[2])
write_byte(10)
write_byte(15)
write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS)  
message_end()

emit_sound(id, CHAN_VOICE, "ZB5/weapons/thanatos11_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

if(is_player(attacker, 0))
{
static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, Origin, 150.0)) != 0)
{
if(attacker == Victim)
continue;

do_attack(attacker, Victim, 0, random_float(300.0, 600.0), 1)
}
}
}

public fw_Scythe_Think(Ent)
{
if(!is_valid_ent(Ent))
return

static Float:Time; Time = entity_get_float(Ent,EV_FL_fuser1)

if(Time <= get_gametime())
{
entity_set_int(Ent, EV_INT_flags, FL_KILLME)
entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.1) 
return
}

entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 0.1) 
}

public fw_Weapon_WeaponIdle_Post(iEnt)
{
if(!is_valid_ent(iEnt))
return 

static id; id = get_pdata_cbase(iEnt, 41, 4)

if(!is_player(id, 1))
return 

static Weapons:had 	
had  = g_had[id]	

if(had != THANATOS11)
return 

static SpecialReload; SpecialReload = get_pdata_int(iEnt, 55, 4)
if(!SpecialReload && get_pdata_float(iEnt, 48, 4) <= 0.25)
{
switch(g_special[id][MODE])
{
case MODE_A: set_weapon_anim(id, 0)
case MODE_B: 
{
if(g_special[id][AMMO] > 0) set_weapon_anim(id, 1)
else set_weapon_anim(id, 6)
}
}

set_pdata_float(iEnt, 48, 20.0, 4)
}	
}
// RELOAD
public fw_ItemPostFrame(weapon_entity) 
{
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had != QBARREL && had != GATLING  && had != SKULL11)	
return HAM_IGNORED

static c, j
switch(had)
{
case GATLING:c = 40
case SKULL11:c = 28
case QBARREL:
{
if(pev(id, pev_weaponanim) == 3)
set_weapon_anim(id, 7)	
c = zp_core_is_hero(id) ? 4 : 2
}
}

static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)
static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)
static fInReload; fInReload  = get_pdata_int(weapon_entity, 54, 4)

if( fInReload && flNextAttack <= 0.0 )
{	
j = min(c - iClip, iBpAmmo)

set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
cs_set_user_bpammo(id, CSW_BASE, iBpAmmo-j)

set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
fInReload = 0
}
return HAM_IGNORED
}
public fw_Reload(weapon_entity) 
{
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had != QBARREL && had != GATLING  && had != SKULL11)	
return HAM_IGNORED

g_special[id][TMPCLIP] = -1

static iBpAmmo; iBpAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(weapon_entity, 51, 4)

if (iBpAmmo <= 0)
return HAM_SUPERCEDE

static c
switch(had)
{
case GATLING:c = 40
case QBARREL:c = zp_core_is_hero(id) ? 4 : 2
case SKULL11:c = 28
}

if (iClip >= c)
return HAM_SUPERCEDE

g_special[id][TMPCLIP] = iClip

return HAM_IGNORED
}
public fw_Reload_Post(weapon_entity) 
{
if(!is_valid_ent(weapon_entity))
return HAM_IGNORED;

static id; id = pev(weapon_entity, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had
had = g_had[id] 

if(had != QBARREL && had != GATLING && had != SKULL11)	
return HAM_IGNORED

if (g_special[id][TMPCLIP] == -1)
return HAM_IGNORED

static Float:time2
switch(had)
{
case GATLING:
{
time2 = 4.7
set_weapon_anim(id, 3)
}
case QBARREL:
{
time2 = zp_core_is_hero(id) ? 2.8 : 1.7
set_weapon_anim(id, 3)
}
case SKULL11:
{
time2 = 4.4
set_weapon_anim(id, 3)
}
}	
set_pdata_int(weapon_entity, m_iClip, g_special[id][TMPCLIP], WEAP_LINUX_XTRA_OFF)
set_pdata_float(weapon_entity, m_flTimeWeaponIdle, time2, WEAP_LINUX_XTRA_OFF)
set_pdata_float(id, m_flNextAttack, time2, PLAYER_LINUX_XTRA_OFF)
set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)

return HAM_IGNORED
}


stock const g_iDftMaxClip[CSW_P90+1] = {-1,  13, -1, 10,  1,  7,    1, 30, 30,  1,  30, 20, 25, 30, 35, 25,   12, 20, 10, 30, 100, 8 , 30, 30, 20,  2,    7, 30, 30, -1,  50}
public Shotgun_WeaponIdle(iEnt)
{
if(pev_valid(iEnt) != 2)
return 
static id; id = get_pdata_cbase(iEnt, 41, 4)
if(!is_player(id, 1))
return 

static Weapons:had
had = g_had[id] 

if(had == QBARREL || had == SKULL11 || had == GATLING)	
return

if(had != UTS12 && had != THANATOS11 && had != BALROG11 && had != M1887 && g_special[id][MODE] == MODE_B)	
return

static iId ; iId = get_pdata_int(iEnt, 43, 4)
static iMaxClip;
switch(had)
{
case UTS12:iMaxClip = 20
case THANATOS11:iMaxClip = 15
case BALROG11:iMaxClip = 7
case M1887:iMaxClip = 8
}

static iClip ; iClip = get_pdata_int(iEnt, m_iClip, 4)
static fInSpecialReload ; fInSpecialReload = get_pdata_int(iEnt, 55, 4)

if( !iClip && !fInSpecialReload )
{
return
}

if( fInSpecialReload )
{
static id ; id = get_pdata_cbase(iEnt, 41, 4)
static iBpAmmo ; iBpAmmo = get_pdata_int(id, 381, 5)
static iDftMaxClip ; iDftMaxClip = g_iDftMaxClip[iId]

if( iClip < iMaxClip && iClip == iDftMaxClip && iBpAmmo )
{
Shotgun_Reload(iEnt, iId, iMaxClip, iClip, iBpAmmo, id)
return
}
else if( iClip == iMaxClip && iClip != iDftMaxClip )
{
// after reload
set_weapon_anim(id, 4)
set_pdata_int(iEnt, 55, 0, 4)
//set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5, 4)
}
}
return
}

public Shotgun_PostFrame(iEnt)
{
if(pev_valid(iEnt) != 2)
return 

static id; id = get_pdata_cbase(iEnt, 41, 4)
if(!is_player(id, 1))
return 

static Weapons:had
had = g_had[id] 

if(had == QBARREL || had == SKULL11 || had == GATLING)	
return

if(had != UTS12 && had != THANATOS11 && had != BALROG11 && had != M1887 && g_special[id][MODE] == MODE_B)	
return

static iBpAmmo ; iBpAmmo = get_pdata_int(id, 381, 5)
static iClip ; iClip = get_pdata_int(iEnt, m_iClip, 4)
static iId ; iId = get_pdata_int(iEnt, 43, 4)
static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)
static iMaxClip, j

switch(had)
{
case UTS12:iMaxClip = 20
case THANATOS11:iMaxClip = 15
case BALROG11:iMaxClip = 7
case M1887:iMaxClip = 8
}


// Support for instant reload (used for example in my plugin "Reloaded Weapons On New Round")
// It's possible in default cs
if( get_pdata_int(iEnt, m_fInReload, 4) && flNextAttack <= 0.0 )
{
j = min(iMaxClip - iClip, iBpAmmo)
set_pdata_int(iEnt, m_iClip, iClip + j, 4)
set_pdata_int(id, 381, iBpAmmo-j, 5)

set_pdata_int(iEnt, m_fInReload, 0, 4)
return
}

static iButton ; iButton = pev(id, pev_button)
if( iButton & IN_ATTACK && get_pdata_float(iEnt, m_flNextPrimaryAttack, 5) <= 0.0) // 4
{
return
}

if(iButton & IN_RELOAD )
{
if( iClip >= iMaxClip )
{
set_pev(id, pev_button, iButton & ~IN_RELOAD) // still this fucking animation
set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5, 5)  // Tip ? // 4
}

else if( iClip == g_iDftMaxClip[iId] )
{
if( iBpAmmo )
{
Shotgun_Reload(iEnt, iId, iMaxClip, iClip, iBpAmmo, id)
}
}
}

if(get_pdata_int(iEnt, 55, 4) == 1) set_weapon_anim(id, 3)
}

Shotgun_Reload(iEnt, iId, iMaxClip, iClip, iBpAmmo, id)
{
if(!is_valid_ent(iEnt))
return;

if(iBpAmmo <= 0 || iClip == iMaxClip)
return

static Weapons:had
had = g_had[id] 

if(had == QBARREL || had == SKULL11 || had == GATLING)	
return

if(had != UTS12 && had != THANATOS11 && had != BALROG11 && had != M1887 && g_special[id][MODE] == MODE_B)	
return

if(get_pdata_int(iEnt, m_flNextPrimaryAttack, 5) > 0.0) // 4
return

switch( get_pdata_int(iEnt, 55, 4))
{
case 0:
{
// start reload
set_weapon_anim(id, 5)
set_pdata_int(iEnt, 55, 1, 4)
set_pdata_float(id, m_flNextAttack, 0.1) 
set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.1, 4)
set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.1, 4)
set_pdata_float(iEnt, 75, 0.1, 4)
return
}
case 1:
{
if( get_pdata_float(iEnt, m_flTimeWeaponIdle, 5) > 0.0) // 4
{
return
}
// insert
set_weapon_anim(id, 3)
set_pdata_int(iEnt, 55, 2, 4) 
emit_sound(id, CHAN_ITEM, random_num(0,1) ? "weapons/reload1.wav" : "weapons/reload3.wav", 1.0, ATTN_NORM, 0, 85 + random_num(0,0x1f))
set_pdata_float(iEnt, 75, 0.1, 4)
set_pdata_float(iEnt, m_flTimeWeaponIdle, iId == CSW_BASE ? 0.05 : 0.05, 4) // 4
}
default:
{
set_pdata_int(iEnt, m_iClip, iClip + 1, 4) 
set_pdata_int(id, 381, iBpAmmo-1, 5)
set_pdata_int(iEnt, 55, 1, 4)
set_pdata_float(iEnt, 75, 0.1, 4)
set_pdata_float(id, m_flNextAttack, 0.1) 
}
}
}
// STOCKS 
stock SPR(id, const weapon[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
write_string(weapon)
write_byte(5)                  
write_byte(32)                  
write_byte(-1)                   
write_byte(-1)                   
write_byte(0)                    
write_byte(12)
write_byte(5)                      
write_byte(0)              
message_end()
}
stock fm_set_weapon_ammo(entity, amount)
{
set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}
stock is_wall_between_points(Float:start[3], Float:end[3], ignore_ent)
{
static ptr
ptr = create_tr2()

engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, ignore_ent, ptr)

static Float:EndPos[3]
get_tr2(ptr, TR_vecEndPos, EndPos)

free_tr2(ptr)
return floatround(get_distance_f(end, EndPos))
} 
stock get_damage_body(body, Float:damage) 
{
switch(body) 
{
case HIT_HEAD: damage *= 2.5
case HIT_STOMACH: damage *= 2.0
case HIT_CHEST: damage *= 2.0
case HIT_LEFTARM: damage *= 1.77
case HIT_RIGHTARM: damage *= 1.77
case HIT_LEFTLEG: damage *= 1.50
case HIT_RIGHTLEG: damage *= 1.50
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

if(g_had[id] == QBARREL)	
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
