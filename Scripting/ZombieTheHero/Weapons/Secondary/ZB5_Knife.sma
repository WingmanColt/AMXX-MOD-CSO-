#include <amxmodx>
#include <ZombieMod5>


new const sound[][] =
{
"ZB5/weapons/mastercombat_draw.wav",
"ZB5/weapons/combat_hit.wav",
"ZB5/weapons/combat_slash.wav",
"ZB5/weapons/combat_stab.wav",

"ZB5/weapons/skullaxe_deploy1.wav",
"ZB5/weapons/skullaxe_slash.wav",
"ZB5/weapons/skullaxe_slash1.wav",
"ZB5/weapons/skullaxe_slash2.wav",
"ZB5/weapons/skullaxe_stab.wav",

"ZB5/weapons/strong_draw.wav",
"ZB5/weapons/strong_hit.wav",
"ZB5/weapons/strong_miss.wav",
"ZB5/weapons/strong_stab.wav",

"ZB5/weapons/warhammer_draw.wav",
"ZB5/weapons/warhammer_slash1.wav",
"ZB5/weapons/warhammer_stab.wav",

"ZB5/weapons/thanatos9_shoota1.wav",
"ZB5/weapons/thanatos9_shoota2.wav",
"ZB5/weapons/thanatos9_shootb_loop.wav",
"ZB5/weapons/thanatos9_shootb_end.wav",

"ZB5/weapons/crow9_draw.wav",
"ZB5/weapons/crow9_slasha_1.wav",
"ZB5/weapons/crow9_slasha_2.wav",
"ZB5/weapons/crow9_slashc_1.wav",
"ZB5/weapons/crow9_slashc_2.wav",
"ZB5/weapons/crow9_slashc_in.wav",

"ZB5/weapons/runeblade_draw.wav",
"ZB5/weapons/runeblade_hit1.wav",
"ZB5/weapons/runeblade_hit2.wav",
"ZB5/weapons/runeblade_slash1.wav",
"ZB5/weapons/runeblade_slash2.wav",
"ZB5/weapons/runeblade_finish1.wav",
"ZB5/weapons/runeblade_charge_idle1.wav",
"ZB5/weapons/runeblade_charge_start1.wav",
"ZB5/weapons/runeblade_v_charge_attack1.wav",

"ZB5/weapons/dragonsword_draw.wav",
"ZB5/weapons/dragonsword_hit1.wav",
"ZB5/weapons/dragonsword_hit2.wav",
"ZB5/weapons/dragonsword_idle.wav",
"ZB5/weapons/dragonsword_slash1.wav",
"ZB5/weapons/dragonsword_slash2.wav",
"ZB5/weapons/dragonsword_stab_hit.wav",
"ZB5/weapons/skullaxe_wall.wav",

"ZB5/weapons/crow9-exp.wav",
"ZB5/weapons/balrog9_slash1.wav",
"ZB5/weapons/balrog9_slash2.wav",
"ZB5/weapons/balrog9_hit1.wav",
"ZB5/weapons/balrog9_hit2.wav"
}
new const models[][] =
{
"models/ZB5/Knife/v_dragonsword2.mdl",
"models/ZB5/Knife/v_combat.mdl",
"models/ZB5/Knife/v_strong.mdl",
"models/ZB5/Knife/v_thanatos9.mdl",
"models/ZB5/Knife/v_skullaxe.mdl",
"models/ZB5/Knife/v_warhammer.mdl",
"models/ZB5/Knife/v_runeblade.mdl",
"models/ZB5/Knife/v_crow9.mdl",
"models/ZB5/Knife/p_runeblade.mdl",
"models/ZB5/Knife/p_crow9.mdl"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud21_2.spr",	
"sprites/ZB5/HUD2/640hud25.spr",	
"sprites/ZB5/HUD2/640hud39.spr",
"sprites/ZB5/HUD2/640hud54.spr",
"sprites/ZB5/HUD2/640hud74.spr",
"sprites/ZB5/HUD2/640hud75.spr",
"sprites/ZB5/HUD2/640hud79.spr",
"sprites/weapon_sword_MSBG.txt",
"sprites/weapon_combat_MSBG.txt",
"sprites/weapon_strong_MSBG.txt",
"sprites/weapon_skullaxe_MSBG.txt",
"sprites/weapon_warhammer_MSBG.txt",
"sprites/weapon_thanatos9_MSBG.txt",
"sprites/weapon_crow9_MSBG.txt",
"sprites/weapon_blade_MSBG.txt"
}
new const generic_spr[][] =
{
"weapon_sword_MSBG",
"weapon_combat_MSBG",
"weapon_strong_MSBG",
"weapon_skullaxe_MSBG",
"weapon_warhammer_MSBG",
"weapon_thanatos9_MSBG",
"weapon_crow9_MSBG",
"weapon_blade_MSBG"
}
#define WEAPON_ANIMEXT_DEFAULT "knife"
#define WEAPON_ANIMEXT_SKULL9 "skullaxe"
#define WEAPON_ANIMEXT_HAMMER "hammer"
#define WEAPON_ANIMEXT_DUAL "dualpistols"
#define WEAPON_ANIMEXT_KATANA "katana"

// CORE
#define TASK_SET_DAMAGE 1951

//THANATOS9
#define TASK_LOOP 1952
#define TASK_END 1953
#define TASK_END_2 1954

// RUNEBLADE
#define TASK_CHARGE_STARTING 1955
#define TASK_CHARGING 1956

enum
{
MODE_NORMAL = 1,
MODE_CHARGE
}

enum
{
ATTACK_SLASH1 = 1,
ATTACK_SLASH2,
ATTACK_SLASH3,
ATTACK_STAB
}
enum
{
MODE_SLASH = 1,
MODE_STAB,
MODE_LOOP
}
enum
{
HIT_NOTHING = 0,
HIT_ENEMY,
HIT_WALL
}

enum Weapons
{
INVALID = 0,	
SEAL,	
COMBAT,
STRONG,
SKULL9,
CROW9,
BLADE,
SWORD,
THANATOS9,
WARHAMMER
}
enum _:Options
{	
CHARGE_ATTACK,	
CHARGING,	
CHARGED,
ATTACK,
SLASH,
MODE,
Old
}

new Weapons:g_had[33], g_had2[33][Options], g_weapon[10], ef_sprite[5], m_iBlood[2]
new g_maxplayers, g_IsConnected, g_IsAlive, g_IsZombie, g_PlayerWeapon[33]

public plugin_init()
{
if(!zb5_weapons_secondary())
return;

Register_SafetyFunc()
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")
register_forward(FM_CmdStart, "fw_CmdStart")	

RegisterHam(Ham_Item_Deploy, "weapon_knife", "Deploy_Post", 1)
RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "fw_WeaponIdle_Post", 1)

g_maxplayers = get_maxplayers()

g_weapon[1] = zb5_register_weapon("Seal", "Melee", WPN_KNIVES, 0, 0)
g_weapon[2] = zb5_register_weapon("Master Combat", "Melee", WPN_KNIVES, LEVEL_COMBAT, 0)
g_weapon[3] = zb5_register_weapon("Nata Strong", "Knife", WPN_KNIVES, LEVEL_STRONG, 0)
g_weapon[4] = zb5_register_weapon("Skull9", "\rRex Research", WPN_KNIVES, LEVEL_SKULL9, 0)
g_weapon[5] = zb5_register_weapon("Dragon Sword", "\yGlaive", WPN_KNIVES, LEVEL_SWORD, 0)
g_weapon[6] = zb5_register_weapon("Thanatos9", "\rRex Research", WPN_KNIVES, LEVEL_THANATOS9, 0)
g_weapon[7] = zb5_register_weapon("WAR Hammer", "\rGladiator", WPN_KNIVES, LEVEL_WARHAMMER, 1)
g_weapon[8] = zb5_register_weapon("Crow9", "\rGladiator", WPN_KNIVES, LEVEL_CROW9, 1)
g_weapon[9] = zb5_register_weapon("Rune Blade", "\rGladiator", WPN_KNIVES, LEVEL_RUNEBLADE, 1)
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

ef_sprite[0] = PrecacheModel("sprites/ZB5/ef_buffak_hit.spr")
ef_sprite[1] = PrecacheModel("sprites/smokepuff.spr")	
ef_sprite[2] = PrecacheModel("sprites/ZB5/runeblade_ef.spr")
ef_sprite[3] = PrecacheModel("sprites/ZB5/runeblade_ef02.spr")
ef_sprite[4] = PrecacheModel("sprites/ZB5/ef_airexplosion.spr")

m_iBlood[0] = PrecacheModel("sprites/blood.spr")
m_iBlood[1] = PrecacheModel("sprites/bloodspray.spr")
}
public plugin_natives()
{
register_native("get_weapon_knife", "Get_Knives", 1)
}
public Hook_SPR(id)
{
engclient_cmd(id, "weapon_knife")
return;
}

public zb5_weapon_selected_post(id, wpnid)
{		
if(wpnid == g_weapon[1]) Get_Knives(id, 1)	
else if(wpnid == g_weapon[2]) Get_Knives(id, 2)
else if(wpnid == g_weapon[3]) Get_Knives(id, 3)
else if(wpnid == g_weapon[4]) Get_Knives(id, 4)
else if(wpnid == g_weapon[5]) Get_Knives(id, 5)
else if(wpnid == g_weapon[6]) Get_Knives(id, 6)
else if(wpnid == g_weapon[7]) Get_Knives(id, 7)
else if(wpnid == g_weapon[8]) Get_Knives(id, 8)
else if(wpnid == g_weapon[9]) Get_Knives(id, 9)
}
public Get_Knives(id, weapon)
{
if(!zb5_weapons_secondary())
return;

Reset_All(id, 1)

ham_strip_weapon(id, "weapon_knife")
fm_give_item(id, "weapon_knife")

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_KNIFE)
if(!is_valid_ent(Ent)) 
return

switch(weapon)
{
case 1:
{
g_had[id] = SEAL
SPR(id, "weapon_knife")	
}
case 2:
{
g_had[id] = COMBAT
SPR(id, "weapon_combat_MSBG")
}
case 3:
{
g_had[id] = STRONG
SPR(id, "weapon_strong_MSBG")
}
case 4:
{
g_had[id] = SKULL9
SPR(id, "weapon_skullaxe_MSBG")
}
case 5:
{
g_had[id] = SWORD
SPR(id, "weapon_sword_MSBG")
}
case 6:
{
g_had[id] = THANATOS9
g_had2[id][MODE] = MODE_SLASH

SPR(id, "weapon_thanatos9_MSBG")
}
case 7:
{
g_had[id] = WARHAMMER
SPR(id, "weapon_warhammer_MSBG")
}
case 8:
{
g_had[id] = CROW9
SPR(id, "weapon_crow9_MSBG")
}
case 9:
{
g_had[id] = BLADE
SPR(id, "weapon_blade_MSBG")
}
}
if(get_player_weapon(id) == CSW_KNIFE)
{
Draw_NewWeapon(id, CSW_KNIFE)	
Deploy_Post(Ent)
}
}
/*
public zp_fw_round_new()
{
for(new i = 0; i < g_maxplayers; i++)
{
if(!is_user_connected(i))
continue

Reset_All(i, 1)
}
}*/

public Reset_All(id, all)
{	
/*remove_task(id+TASK_SET_DAMAGE)
remove_task(id+TASK_CHARGE_STARTING)
remove_task(id+TASK_CHARGING)		

remove_task(id+TASK_LOOP)
remove_task(id+TASK_END)
remove_task(id+TASK_END_2)
*/
if(all)
{
arrayset(_:g_had[id], false, sizeof(g_had[]))
//arrayset(_:g_had2[id], false, sizeof(g_had2[]))
}
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
case COMBAT:
{
SubModel = 25
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_combat.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case STRONG:
{
SubModel = 26
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_strong.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case SKULL9:
{
SubModel = 9
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_skullaxe.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case SWORD:
{
SubModel = 11
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_dragonsword2.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case THANATOS9:
{
SubModel = 12
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_thanatos9.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case WARHAMMER:
{
SubModel = 12
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_warhammer.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model2)
}
case BLADE:
{
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_runeblade.mdl")
set_pev(id, pev_weaponmodel2, "models/ZB5/Knife/p_runeblade.mdl")
}
case CROW9:
{
set_pev(id, pev_viewmodel2, "models/ZB5/Knife/v_crow9.mdl")
set_pev(id, pev_weaponmodel2, "models/ZB5/Knife/p_crow9.mdl")
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

if((CSWID == CSW_KNIFE && g_had2[id][Old] != CSW_KNIFE) && had != INVALID)
Draw_NewWeapon(id, CSWID)

else if((CSWID == CSW_KNIFE && g_had2[id][Old] == CSW_KNIFE) && had != INVALID) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_KNIFE)
if(!is_valid_ent(Ent))
{
g_had2[id][Old] = get_player_weapon(id)
return
}
} 

else if(CSWID != CSW_KNIFE && g_had2[id][Old] == CSW_KNIFE) 
Draw_NewWeapon(id, CSWID)

g_had2[id][Old] = get_player_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
static Weapons:had
had = g_had[id] 

static ent
ent = fm_get_user_weapon_entity(id, CSW_KNIFE)

if(CSW_ID == CSW_KNIFE)
{
if(is_valid_ent(ent) && had != INVALID)
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

static Submodel, Sequence;

switch(had)
{
case COMBAT:
{	
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_DEFAULT, -1 , 20)	
Submodel = 25;Sequence = 25
engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)	
}
case STRONG:
{	
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_DEFAULT, -1 , 20)	
Submodel = 26;Sequence = 26
engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)
}
case SKULL9:
{	
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_SKULL9, -1 , 20)	
Submodel = 9;Sequence = 8
engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)
}
case SWORD:
{
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_SKULL9, -1 , 20)	
Submodel = 11;Sequence = 10
engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)
}
case THANATOS9:
{
remove_task(id+TASK_LOOP)
remove_task(id+TASK_END)
remove_task(id+TASK_END_2)

set_weapon_anim(id, 0)	
g_had2[id][MODE] = MODE_SLASH

Submodel = 12;Sequence = 12
engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)
}
case WARHAMMER:
{	
set_weapon_anim(id, 3)
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_HAMMER, -1 , 20)			
Submodel = 13;Sequence = 13
engfunc(EngFunc_SetModel, ent, P_Model2)
set_pev(ent, pev_body, Submodel - 1)
set_pev(ent, pev_sequence, Sequence)
}
case BLADE:
{
set_weapon_anim(id, 2)	
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_KATANA, -1 , 20)	
engfunc(EngFunc_SetModel, ent, "models/ZB5/Knife/p_runeblade.mdl")
}
case CROW9:
{
set_weapon_anim(id, 3)	
set_pdata_string(id, 492 * 4, WEAPON_ANIMEXT_DUAL, -1 , 20)	
engfunc(EngFunc_SetModel, ent, "models/ZB5/Knife/p_crow9.mdl")
}
}


set_weapons_timeidle(id, CSW_KNIFE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)
}
} else {
if(is_valid_ent(ent)) 
set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 			
}
}
public fw_CmdStart(id, uc_handle, seed)
{
if(!Get_BitVar(g_IsConnected, id))
return 
if(!Get_BitVar(g_IsAlive, id))
return 
if(Get_BitVar(g_IsZombie, id))
return 

static ent; ent = fm_get_user_weapon_entity(id, get_user_weapon(id))
if(!is_valid_ent(ent))
return

if(get_player_weapon(id) != CSW_KNIFE)
return

if(get_pdata_float(id, 83, 5) > 0.0 || get_pdata_float(ent, 46, 4) > 0.0 || get_pdata_float(ent, 47, 4) > 0.0) 
return

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)

static Weapons:had 	
had  = g_had[id]	

switch(had)
{
case COMBAT:CMD_COMBAT(id, ent, uc_handle, CurButton)
case STRONG:CMD_STRONG(id, ent, uc_handle, CurButton)
case SWORD:CMD_SWORD(id, ent, uc_handle, CurButton)
case SKULL9:CMD_SKULL9(id, ent, uc_handle, CurButton)
case THANATOS9:CMD_THANATOS9(id, ent, uc_handle, CurButton)
case WARHAMMER:CMD_WARHAMMER(id, ent, uc_handle, CurButton)
case BLADE:CMD_BLADE(id, ent, uc_handle, CurButton)
case CROW9:CMD_CROW9(id, ent, uc_handle, CurButton)
}
}
public CMD_COMBAT(id, ent, uc_handle, CurButton)
{
if (CurButton & IN_ATTACK)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)
g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_DEFAULT)

set_pev(id, pev_framerate, 0.75)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)
set_weapon_anim(id, random_num(1,2))

set_task(0.20, "Do_Slashing", id+TASK_SET_DAMAGE)
}
if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)
g_had2[id][ATTACK] = ATTACK_STAB

create_fake_attack(id,  WEAPON_ANIMEXT_DEFAULT)
set_pev(id, pev_framerate, 1.0)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)
set_weapon_anim(id, 4)

remove_task(id+TASK_SET_DAMAGE)
set_task(0.3, "Do_StabNow", id+TASK_SET_DAMAGE)	
}
}
public CMD_STRONG(id, ent, uc_handle, CurButton)
{
if (CurButton & IN_ATTACK)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)
g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_DEFAULT)

set_pev(id, pev_framerate, 1.2)
set_weapons_timeidle(id, CSW_KNIFE, 1.2)
set_player_nextattack(id, 1.2)
set_weapon_anim(id, random_num(1,2))

set_task(0.20, "Do_Slashing", id+TASK_SET_DAMAGE)
}
if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)
g_had2[id][ATTACK] = ATTACK_STAB

create_fake_attack(id,  WEAPON_ANIMEXT_DEFAULT)

set_pev(id, pev_framerate, 2.0)
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, 4)

remove_task(id+TASK_SET_DAMAGE)
set_task(0.3, "Do_StabNow", id+TASK_SET_DAMAGE)	
}
}
public CMD_SKULL9(id, ent, uc_handle, CurButton)
{
if (CurButton & IN_ATTACK)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)
g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_SKULL9)

set_pev(id, pev_framerate, 2.0)
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, 4)

set_task(0.600, "Do_Slashing", id+TASK_SET_DAMAGE)
}
if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)
g_had2[id][ATTACK] = ATTACK_STAB

create_fake_attack(id,  WEAPON_ANIMEXT_SKULL9)

set_pev(id, pev_framerate, 1.5)
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, 2)

remove_task(id+TASK_SET_DAMAGE)
set_task(1.25, "Do_StabNow", id+TASK_SET_DAMAGE)	
}
}

public CMD_THANATOS9(id, ent, uc_handle, CurButton)
{
if (CurButton & IN_ATTACK)
{	
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)

if(g_had2[id][MODE] == MODE_SLASH)
{
switch(random_num(1,2))
{	
case 1:
{
g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_SKULL9)

set_pev(id, pev_framerate, 2.5)
set_weapons_timeidle(id, CSW_KNIFE, 2.5)
set_player_nextattack(id, 2.5)

set_weapon_anim(id, 7)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos9_shoota1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)		

set_task(0.9, "Do_Slashing", id+TASK_SET_DAMAGE)
}
case 2:
{
g_had2[id][ATTACK] = ATTACK_SLASH2

create_fake_attack(id,  WEAPON_ANIMEXT_SKULL9)
set_pev(id, pev_framerate, 2.5)
set_weapons_timeidle(id, CSW_KNIFE, 2.5)
set_player_nextattack(id, 2.5)

set_weapon_anim(id, 8)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos9_shoota2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)		

set_task(1.0, "Do_Slashing", id+TASK_SET_DAMAGE)
}
}
}
else if(g_had2[id][MODE] == MODE_STAB)
{
set_pev(id, pev_framerate, 0.8)	
set_weapons_timeidle(id, CSW_KNIFE, 0.8 + 0.1)
set_player_nextattack(id, 0.8 + 0.1)

set_weapon_anim(id, 2)	
Make_Sprite(id, ef_sprite[1], 9, 20, 35, 8, -15)

if(task_exists(id+TASK_LOOP))remove_task(id+TASK_LOOP)
set_task(0.8, "THANATOS9_LOOP", id+TASK_LOOP)

if(task_exists(id+TASK_END))remove_task(id+TASK_END)
set_task(5.0, "THANATOS9_END", id+TASK_END)
}
}
if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)

if(g_had2[id][MODE] != MODE_STAB)
{
g_had2[id][MODE] = MODE_STAB
set_pev(id, pev_framerate, 5.0)
set_weapons_timeidle(id, CSW_KNIFE, 5.0)
set_player_nextattack(id, 5.0)

set_weapon_anim(id, 9)
Make_Sprite(id, ef_sprite[1], 9, 20, 35, 8, -15)
}
else
{
g_had2[id][MODE] = MODE_SLASH
set_pev(id, pev_framerate, 3.0)
set_weapons_timeidle(id, CSW_KNIFE, 3.0)
set_player_nextattack(id, 3.0)

set_weapon_anim(id, 10)	
Make_Sprite(id, ef_sprite[1], 9, 50, 35, 8, -15)
}
}
}
public THANATOS9_LOOP(id)
{
id -= TASK_LOOP

static ent; ent = fm_get_user_weapon_entity(id, CSW_KNIFE)
if(!is_valid_ent(ent)) 
return;

if(zp_core_is_zombie(id) || !is_player(id, 1) || get_player_weapon(id) != CSW_KNIFE || g_had[id] != THANATOS9)
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos9_shootb_end.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	
remove_task(id+TASK_LOOP)
remove_task(id+TASK_END)
return		
}

g_had2[id][MODE] = MODE_LOOP

set_pev(id, pev_framerate, 0.2)
set_weapons_timeidle(id, CSW_KNIFE, 0.2)
set_player_nextattack(id, 0.2)
set_weapon_anim(id, 1)
Make_Sprite(id, ef_sprite[1], 7, 80, 35, 8, -15)

CDamage(id, 100.0, 300.0)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos9_shootb_loop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	

if(task_exists(id+TASK_LOOP))remove_task(id+TASK_LOOP)
set_task(0.2, "THANATOS9_LOOP", id+TASK_LOOP)
}
public THANATOS9_END(id)
{
id -= TASK_END

if(!is_player(id, 1))
return

if(get_player_weapon(id) != CSW_KNIFE || g_had[id] != THANATOS9)
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos9_shootb_end.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	
remove_task(id+TASK_LOOP)
remove_task(id+TASK_END)
return		
}

g_had2[id][MODE] = MODE_SLASH
remove_task(id+TASK_LOOP)

set_pev(id, pev_framerate, 2.0)
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)

set_weapon_anim(id, 3)
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos9_shootb_end.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
Make_Sprite(id, ef_sprite[1], 9, 20, 35, 8, -15)

set_task(1.0, "THANATOS9_CHANGE", id+TASK_END_2)
}
public THANATOS9_CHANGE(id)
{
id -= TASK_END_2

if(!is_player(id, 1))
return 

if(get_player_weapon(id) != CSW_KNIFE || g_had[id] != THANATOS9)
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/thanatos9_shootb_end.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	
remove_task(id+TASK_END)
remove_task(id+TASK_END_2)
return		
}

set_pev(id, pev_framerate, 3.0)
set_weapons_timeidle(id, CSW_KNIFE, 3.0)
set_player_nextattack(id, 3.0)

Make_Sprite(id, ef_sprite[1], 9, 30, 35, 8, -15)
set_weapon_anim(id, 10)
}
public CMD_WARHAMMER(id, ent, uc_handle, CurButton)
{
if (CurButton & IN_ATTACK)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)
g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_HAMMER)
Make_PunchAngle(id, random_float(-1.0, -2.0), random_float(0.5, 1.5))
set_weapon_anim(id, 2)

set_pev(id, pev_framerate, 1.0)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

set_task(0.2, "Do_Slashing", id+TASK_SET_DAMAGE)
}
if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)
g_had2[id][ATTACK] = ATTACK_STAB

create_fake_attack(id,  WEAPON_ANIMEXT_HAMMER)
set_pev(id, pev_framerate, 2.0)
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, 4)

remove_task(id+TASK_SET_DAMAGE)
set_task(0.750, "Do_StabNow", id+TASK_SET_DAMAGE)	
}
}
public CMD_SWORD(id, ent, uc_handle, CurButton)
{
if (CurButton & IN_ATTACK)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)
if(!g_had2[id][SLASH])
{
g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_SKULL9)
set_pev(id, pev_framerate, 1.0)
set_weapons_timeidle(id, CSW_KNIFE, 1.1)
set_player_nextattack(id, 1.1)
set_weapon_anim(id, 1)

set_task(0.7, "Do_Slashing", id+TASK_SET_DAMAGE)
}
else
{
g_had2[id][ATTACK] = ATTACK_SLASH2

create_fake_attack(id,  WEAPON_ANIMEXT_SKULL9)
set_pev(id, pev_framerate, 1.0)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)
set_weapon_anim(id, 2)

set_task(0.3, "Do_Slashing", id+TASK_SET_DAMAGE)
}
g_had2[id][SLASH] = !g_had2[id][SLASH]
}
if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)
g_had2[id][ATTACK] = ATTACK_STAB

create_fake_attack(id,  WEAPON_ANIMEXT_SKULL9)
set_pev(id, pev_framerate, 1.0)
set_weapons_timeidle(id, CSW_KNIFE, 1.5)
set_player_nextattack(id, 1.5)
set_weapon_anim(id, 4)

remove_task(id+TASK_SET_DAMAGE)
set_task(0.657, "Do_StabNow", id+TASK_SET_DAMAGE)	
}
}


public CMD_CROW9(id, ent, uc_handle, CurButton)
{
static  OldButton
OldButton = (pev(id, pev_oldbuttons) & IN_ATTACK2)

if(get_pdata_float(ent, 46, 4) > 0.0 || get_pdata_float(ent, 47, 4) > 0.0) 
return

if (CurButton & IN_ATTACK)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)

if(!g_had2[id][SLASH])
{
g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_DUAL)
set_pev(id, pev_framerate, 0.5)
set_weapons_timeidle(id, CSW_KNIFE, 0.5)
set_player_nextattack(id, 0.5)
set_weapon_anim(id, 1)

set_task(0.2, "Do_Slashing", id+TASK_SET_DAMAGE)
}
else
{
g_had2[id][ATTACK] = ATTACK_SLASH2

create_fake_attack(id,  WEAPON_ANIMEXT_DUAL)
set_pev(id, pev_framerate, 0.5)
set_weapons_timeidle(id, CSW_KNIFE, 0.5)
set_player_nextattack(id, 0.5)
set_weapon_anim(id, 2)

set_task(0.3, "Do_Slashing", id+TASK_SET_DAMAGE)
}
g_had2[id][SLASH] = !g_had2[id][SLASH]

} else {

///// ATTACK2
if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)

if(OldButton) // Holding This Button
{
if(g_had2[id][CHARGING] == 2)
{
if(g_had2[id][CHARGED])
{
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

if(pev(id, pev_weaponanim) != 4)
set_weapon_anim(id, 4)
} else {
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

if(pev(id, pev_weaponanim) != 6)
set_weapon_anim(id, 6)
}
}
}

if(get_pdata_float(ent, 46, 4) > 0.0 || get_pdata_float(ent, 47, 4) > 0.0) 
return

remove_task(id+TASK_CHARGE_STARTING)
remove_task(id+TASK_CHARGING)	

g_had2[id][ATTACK] = ATTACK_STAB
g_had2[id][CHARGING] = 1
g_had2[id][CHARGE_ATTACK] = 1
g_had2[id][CHARGED] = 0

set_weapons_timeidle(id, CSW_KNIFE, 0.75 + 0.25)
set_player_nextattack(id, 0.75 + 0.25)

set_task(0.50, "Do_HoldCharge", id+TASK_CHARGE_STARTING)
set_task(0.9, "Do_SetCharge", id+TASK_CHARGING)

}else{

if(g_had2[id][CHARGING] == 2)
{	
if(g_had2[id][CHARGE_ATTACK])
{
create_fake_attack(id,  WEAPON_ANIMEXT_DUAL)
set_weapons_timeidle(id, CSW_KNIFE, 0.5)
set_player_nextattack(id, 0.5)

g_had2[id][CHARGE_ATTACK] = 0
g_had2[id][CHARGED] = 0
g_had2[id][CHARGING] = 0

remove_task(id+TASK_CHARGE_STARTING)
remove_task(id+TASK_CHARGING)

set_weapon_anim(id, 5)
Make_PunchAngle(id, random_float(-1.0, -2.0), random_float(0.5, 1.5))
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/crow9_slashc_1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

set_task(0.3, "Effect_ChargedAttack2", id)
}
}
}
}
}
//// RUNEBLADE ///
public CMD_BLADE(id, ent, uc_handle, CurButton)
{
static  OldButton
OldButton = (pev(id, pev_oldbuttons) & IN_ATTACK2)

if(get_pdata_float(ent, 46, 4) > 0.0 || get_pdata_float(ent, 47, 4) > 0.0) 
return

if (CurButton & IN_ATTACK)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)

g_had2[id][ATTACK] = ATTACK_SLASH1

create_fake_attack(id,  WEAPON_ANIMEXT_KATANA)
set_weapon_anim(id, 1)

set_pev(id, pev_framerate, 1.0)
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

Make_PunchAngle(id, random_float(-1.0, -2.0), 0.0)
set_task(0.20, "Do_Slashing", id+TASK_SET_DAMAGE)

set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)

} else {

if (CurButton & IN_ATTACK2)
{
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK2)
set_uc(uc_handle, UC_Buttons, CurButton & ~IN_ATTACK)

if(OldButton) // Holding This Button
{
if(g_had2[id][CHARGING] == 2)
{
if(g_had2[id][CHARGED])
{
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

if(pev(id, pev_weaponanim) != 6)
set_weapon_anim(id, 6)
} else {
set_weapons_timeidle(id, CSW_KNIFE, 1.0)
set_player_nextattack(id, 1.0)

if(pev(id, pev_weaponanim) != 5)
set_weapon_anim(id, 5)
}
}
}

if(get_pdata_float(ent, 46, 4) > 0.0 || get_pdata_float(ent, 47, 4) > 0.0) 
return

remove_task(id+TASK_CHARGE_STARTING)
remove_task(id+TASK_CHARGING)	

g_had2[id][ATTACK] = ATTACK_STAB
g_had2[id][CHARGING] = 1
g_had2[id][CHARGE_ATTACK] = 1
g_had2[id][CHARGED] = 0

set_weapons_timeidle(id, CSW_KNIFE, 0.75 + 0.25)
set_player_nextattack(id, 0.75 + 0.25)

if(pev(id, pev_weaponanim) != 9)
set_weapon_anim(id, 9)

set_task(0.30,"set_weapon_an",id)

set_task(0.50, "Do_HoldCharge", id+TASK_CHARGE_STARTING)
set_task(1.40, "Do_SetCharge", id+TASK_CHARGING)

}else{

if(g_had2[id][CHARGING] == 2)
{	
if(g_had2[id][CHARGE_ATTACK])
{
create_fake_attack(id,  WEAPON_ANIMEXT_KATANA)

set_weapons_timeidle(id, CSW_KNIFE, 0.5)
set_player_nextattack(id, 0.5)

g_had2[id][CHARGE_ATTACK] = 0
g_had2[id][CHARGED] = 0
g_had2[id][CHARGING] = 0

remove_task(id+TASK_CHARGE_STARTING)
remove_task(id+TASK_CHARGING)

Make_PunchAngle(id, random_float(-1.0, -2.0), random_float(0.5, 1.5))
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/runeblade_v_charge_attack1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

set_weapon_anim(id, random_num(7, 8))
set_task(0.3, "Effect_ChargedAttack", id)
}
}
}
}
}
public set_weapon_an(id)set_weapon_anim(id, 3)

public Do_SetCharge(id)
{
id -= TASK_CHARGING

static Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_KNIFE || had != BLADE && had != CROW9)
return

g_had2[id][CHARGED] = 1
g_had2[id][CHARGING] = 2
g_had2[id][CHARGE_ATTACK] = 2

switch(had)
{
case CROW9:
{
set_weapons_timeidle(id, CSW_KNIFE, 0.7)
set_player_nextattack(id, 0.7)
set_weapon_anim(id, 4)	
}
case BLADE:
{
set_weapons_timeidle(id, CSW_KNIFE, 0.7)
set_player_nextattack(id, 0.7)
set_weapon_anim(id, 4)	
}
}
}

public Do_HoldCharge(id)
{
id -= TASK_CHARGE_STARTING

static Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_KNIFE || had != BLADE && had != CROW9)
return

if(!(pev(id, pev_button) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2))
{
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)

g_had2[id][CHARGE_ATTACK] = 0
g_had2[id][CHARGED] = 0
g_had2[id][CHARGING] = 0

remove_task(id+TASK_CHARGE_STARTING)
remove_task(id+TASK_CHARGING)

return
}

g_had2[id][CHARGE_ATTACK] = 1
g_had2[id][CHARGED] = 0
g_had2[id][CHARGING] = 2

switch(had)
{
case CROW9:
{
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)
}
case BLADE:
{
set_weapons_timeidle(id, CSW_KNIFE, 2.0)
set_player_nextattack(id, 2.0)
set_weapon_anim(id, 5)	
}
}

}
public Effect_ChargedAttack(id)
{	
new Float:VicOrigin[3]
fm_get_aim_origin2(id, VicOrigin)

static TE_FLAG

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND
TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, VicOrigin[0])
engfunc(EngFunc_WriteCoord, VicOrigin[1])
engfunc(EngFunc_WriteCoord, VicOrigin[2])
write_short(ef_sprite[2])
write_byte(10)
write_byte(30)
write_byte(TE_FLAG)
message_end()

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, VicOrigin[0])
engfunc(EngFunc_WriteCoord, VicOrigin[1])
engfunc(EngFunc_WriteCoord, VicOrigin[2])
write_short(ef_sprite[3])
write_byte(10)
write_byte(30)
write_byte(TE_FLAG)
message_end()

// DLight
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(27)
engfunc(EngFunc_WriteCoord, VicOrigin[0])
engfunc(EngFunc_WriteCoord, VicOrigin[1])
engfunc(EngFunc_WriteCoord, VicOrigin[2])
write_byte(20)
write_byte(20)
write_byte(50)
write_byte(220)
write_byte(10)
write_byte(60)
message_end()

emit_sound(id, CHAN_VOICE, "ZB5/weapons/runeblade_finish1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 200.0, random_float(400.0, 700.0))
}

public Effect_ChargedAttack2(id)
{	
new Float:VicOrigin[3]
fm_get_aim_origin2(id, VicOrigin)

static TE_FLAG

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND
TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, VicOrigin[0])
engfunc(EngFunc_WriteCoord, VicOrigin[1])
engfunc(EngFunc_WriteCoord, VicOrigin[2])
write_short(ef_sprite[4])
write_byte(10)
write_byte(30)
write_byte(TE_FLAG)
message_end()

emit_sound(id, CHAN_VOICE, "ZB5/weapons/crow9-exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 250.0, random_float(400.0, 500.0))
}

public Buff_Effect(id, scale)
{		
static  Float:Origin[3]
pev(id, pev_origin, Origin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION) 
engfunc(EngFunc_WriteCoord, Origin[0]) 
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(ef_sprite[0]) 
write_byte(scale)
write_byte(30)
write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS|TE_EXPLFLAG_NOPARTICLES)
message_end()
}
public fw_WeaponIdle_Post(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED	

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

static Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_KNIFE || had == INVALID)
return HAM_IGNORED

if(get_pdata_float(ent, 48, 4) > 0.1) 
return HAM_IGNORED

switch(had)
{
case THANATOS9:
{
if(g_had2[id][MODE] == MODE_SLASH)
set_weapon_anim(id, 5)
if(g_had2[id][MODE] == MODE_STAB)
set_weapon_anim(id, 4)
}
}
set_pdata_float(ent, 48, 20.0, 4)
return HAM_IGNORED	
}

public Do_Slashing(id)
{
id -= TASK_SET_DAMAGE

if(!is_player(id, 1))
return

static Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_KNIFE && had == INVALID)
{
remove_task(id+TASK_SET_DAMAGE)	
return	
}

static Ent; Ent = fm_get_user_weapon_entity(id, get_player_weapon(id))
if(!is_valid_ent(Ent)) Ent = 0

static Body, Target
get_user_aiming(id, Target, Body, 100)

switch(had)
{
case COMBAT:
{
if(is_valid_ent(Target)) 
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/combat_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, "ZB5/weapons/combat_slash.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	

CDamage(id, 60.0, random_float(50.0, 150.0))
g_had2[id][ATTACK] = 0
}
case STRONG:
{
if(is_valid_ent(Target)) 
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/strong_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, "ZB5/weapons/strong_miss.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	

CDamage(id, 80.0, random_float(150.0, 250.0))
g_had2[id][ATTACK] = 0
}
case SKULL9:
{	
if(is_valid_ent(Target)) 	
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skullaxe_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, sound[random_num(5, 7)], 1.0, ATTN_NORM, 0, PITCH_NORM)

set_weapon_anim(id, 1)	
CDamage(id, 90.0, random_float(200.0, 400.0))

g_had2[id][ATTACK] = 0
}
case SWORD:
{
if(is_valid_ent(Target)) 
{
switch(g_had2[id][ATTACK])
{
case ATTACK_SLASH1:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dragonsword_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 100.0, random_float(250.0, 350.0))
}
case ATTACK_SLASH2:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dragonsword_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 70.0, random_float(200.0, 250.0))
}
}
} 
else 
{
switch(g_had2[id][ATTACK])
{
case ATTACK_SLASH1:emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dragonsword_slash1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
case ATTACK_SLASH2:emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dragonsword_slash2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}		
}

g_had2[id][ATTACK] = 0
}
case WARHAMMER:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/warhammer_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 90.0, random_float(300.0, 350.0))

g_had2[id][ATTACK] = 0
}
case BLADE:
{
if(is_valid_ent(Target)) 
{
switch(g_had2[id][ATTACK])
{
case ATTACK_SLASH1:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/runeblade_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 100.0, random_float(250.0, 350.0))
}
case ATTACK_SLASH2:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/runeblade_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 70.0, random_float(200.0, 250.0))
}
}
} 
else 
{
switch(g_had2[id][ATTACK])
{
case ATTACK_SLASH1:emit_sound(id, CHAN_WEAPON, "ZB5/weapons/runeblade_slash1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
case ATTACK_SLASH2:emit_sound(id, CHAN_WEAPON, "ZB5/weapons/runeblade_slash2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}		
}

g_had2[id][ATTACK] = 0
}
case THANATOS9:
{
CDamage(id, 110.0, random_float(300.0, 350.0))	
g_had2[id][ATTACK] = 0
}
case CROW9:
{
if(is_valid_ent(Target)) 
{
switch(g_had2[id][ATTACK])
{
case ATTACK_SLASH1:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog9_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 100.0, random_float(250.0, 350.0))
}
case ATTACK_SLASH2:
{
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog9_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
CDamage(id, 70.0, random_float(200.0, 250.0))
}
}
} 
else 
{
switch(g_had2[id][ATTACK])
{
case ATTACK_SLASH1:emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog9_slash1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
case ATTACK_SLASH2:emit_sound(id, CHAN_WEAPON, "ZB5/weapons/balrog9_slash2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}		
}

g_had2[id][ATTACK] = 0
}
}
}

public Do_StabNow(id)
{
id -= TASK_SET_DAMAGE

if(!is_player(id, 1))
return

static Weapons:had 	
had  = g_had[id]	

if(get_player_weapon(id) != CSW_KNIFE || had == INVALID)
{
remove_task(id+TASK_SET_DAMAGE)	
return	
}

static Body, Target
get_user_aiming(id, Target, Body, 100)

switch(had)
{
case COMBAT:
{
if(is_valid_ent(Target)) 
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/combat_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, "ZB5/weapons/combat_slash.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

CDamage(id, 70.0, random_float(150.0, 250.0))
g_had2[id][ATTACK] = 0
}
case STRONG:
{
if(is_valid_ent(Target)) 
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/strong_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, "ZB5/weapons/strong_miss.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

CDamage(id, 80.0, random_float(400.0, 600.0))
g_had2[id][ATTACK] = 0
}	
case SKULL9:
{
if(is_valid_ent(Target)) 
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/skullaxe_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, sound[random_num(5, 7)], 1.0, ATTN_NORM, 0, PITCH_NORM)	

CDamage(id, 120.0, random_float(400.0, 650.0))
g_had2[id][ATTACK] = 0
}
case SWORD:
{
if(is_valid_ent(Target)) 
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dragonsword_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, "ZB5/weapons/dragonsword_stab_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

CDamage(id, 110.0, random_float(450.0, 700.0))
set_weapon_anim(id, 5)

g_had2[id][ATTACK] = 0
}
case WARHAMMER:
{
if(is_valid_ent(Target)) 
emit_sound(id, CHAN_WEAPON, "ZB5/weapons/warhammer_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	

CDamage(id, 100.0, random_float(500.0, 700.0))
g_had2[id][ATTACK] = 0
}
}
}

public CDamage(id, Float:Max_Distance, Float:ZDMG)
{
#define MAX_POINT 5	
static ent; ent = fm_get_user_weapon_entity(id, get_player_weapon(id))

if(!is_valid_ent(ent))
return 0

static Have_Victim; Have_Victim = 0	

switch(zbs_is_scenario()) 	
{
case 0:	
{
static Float:Point[MAX_POINT][3], Float:TB_Distance	
TB_Distance = Max_Distance / float(MAX_POINT)

static Float:VicOrigin[3], Float:MyOrigin[3]
pev(id, pev_origin, MyOrigin)

for(new i = 0; i < MAX_POINT; i++)
get_position(id, TB_Distance * (i + 1), 0.0, 0.0, Point[i])

for(new i = 0; i < g_maxplayers; i++)
{
if(!is_user_alive(i))
continue
if(id == i)
continue
if(!zp_core_is_zombie(i))
continue
if(!can_see_fm(id, i))
continue
if(entity_range(id, i) > Max_Distance)
continue

pev(i, pev_origin, VicOrigin)
if(is_wall_between_points(MyOrigin, VicOrigin, id))
continue

if(get_distance_f(VicOrigin, Point[0]) <= Max_Distance
|| get_distance_f(VicOrigin, Point[1]) <= Max_Distance
|| get_distance_f(VicOrigin, Point[2]) <= Max_Distance
|| get_distance_f(VicOrigin, Point[3]) <= Max_Distance)
{
if(!Have_Victim) Have_Victim = 1
do_attack2(id, i, ent, ZDMG, 0)
}
}	

}

case 1:	
{
static Float:origin[3], Float:Origin[3]
pev(ent, pev_origin, origin)

static i; i = -1
while ((i = engfunc(EngFunc_FindEntityInSphere, i, origin, Max_Distance)) != 0)
{
if(!is_valid_ent(i))
continue;

if(id == i)
continue;

pev(i, pev_origin, Origin)

if(!is_in_viewcone(id, Origin, 1))
continue

if(!Have_Victim) Have_Victim = 1
do_attack2(id, i, ent, ZDMG, 1)
}
}

}

if(Have_Victim)
return 1
else
return 0
}	

stock SPR(id, const name[])
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
write_string(name)
write_byte(-1)
write_byte(-1)
write_byte(-1)
write_byte(-1)
write_byte(2)
write_byte(1)
write_byte(29)
write_byte(CSW_KNIFE)
message_end()	
}
public do_attack2(attacker, victim, Inflictor, Float:fDamage, fake)
{
if(attacker == victim)
return 

fake_player_trace_attack(attacker, victim, fDamage, fake)
fake_take_damage(attacker, victim, fDamage, Inflictor)

static Float:origin[3]
pev(victim, pev_origin, origin)

create_blood(origin)

static Weapons:had 	
had  = g_had[attacker]	

if(get_player_weapon(attacker) != CSW_KNIFE || had == INVALID)
return 

switch(had)
{
case WARHAMMER:
{
if(g_had2[attacker][ATTACK] == ATTACK_STAB)
{
set_weapon_kick(attacker, victim, 5000.0)
Make_ScreenShake(victim, 4, 4, 4)

Make_Dlight(victim, 10, 0, 50, 200, 4, 4)
Buff_Effect(victim, 4)
}
else if(g_had2[attacker][ATTACK] == ATTACK_SLASH1)
{
set_weapon_kick(attacker, victim, 2000.0)
Buff_Effect(victim, 10)	
}
}
case CROW9:
{
if(g_had2[attacker][ATTACK] == ATTACK_STAB)
{
set_weapon_kick(attacker, victim, 5000.0)
Make_ScreenShake(victim, 4, 4, 4)
}
}
}
}
stock create_blood(const Float:origin[3])
{
// Show some blood :)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, origin[0])
engfunc(EngFunc_WriteCoord, origin[1])
engfunc(EngFunc_WriteCoord, origin[2]+20.0)
write_short(m_iBlood[1])
write_short(m_iBlood[0])
write_byte(59) // color index
write_byte(random_num(10, 13)) // size
message_end()
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
stock fm_get_aim_origin2(index, Float:origin[3]) 
{
new Float:start[3], Float:view_ofs[3];
pev(index, pev_origin, start);
pev(index, pev_view_ofs, view_ofs);
xs_vec_add(start, view_ofs, start);

new Float:dest[3];
pev(index, pev_v_angle, dest);
engfunc(EngFunc_MakeVectors, dest);
global_get(glb_v_forward, dest);
xs_vec_mul_scalar(dest, 150.0, dest);
xs_vec_add(start, dest, dest);

engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
get_tr2(0, TR_vecEndPos, origin);

return 1;
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_putinserver(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public zb5_weapon_remove_post(id)Reset_All(id, 1)

Register_SafetyFunc()
{
register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")

RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
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
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

Get_Knives(id, 1)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Get_Knives(id, 1)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id, 1)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsAlive, id)
Set_BitVar(g_IsZombie, id)

Get_Knives(id, 1)
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

