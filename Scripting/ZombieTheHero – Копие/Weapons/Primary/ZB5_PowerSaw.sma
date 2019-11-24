#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define TASK_ATTACK 28070
#define TASK_ATTACK1 28071

#define PLAYER_ANIM_EXT_A "m249"
#define PLAYER_ANIM_EXT_B "knife"

#define SUBMODEL 21 - 1
#define SEQUENCE 20

#define CSW_BASE CSW_M249
#define weapon_base "weapon_m249"

new const Saw_Sounds[11][] =
{
"ZB5/weapons/chainsaw_attack1_end.wav",
"ZB5/weapons/chainsaw_attack1_loop.wav",
"ZB5/weapons/chainsaw_attack1_start.wav",
"ZB5/weapons/chainsaw_draw.wav",
"ZB5/weapons/chainsaw_hit1.wav",
"ZB5/weapons/chainsaw_hit2.wav",
"ZB5/weapons/chainsaw_hit3.wav",
"ZB5/weapons/chainsaw_hit4.wav",  
"ZB5/weapons/chainsaw_idle.wav",
"ZB5/weapons/chainsaw_slash1.wav",
"ZB5/weapons/chainsaw_slash2.wav"
}
new const sprites[][] =
{
"sprites/ZB5/HUD2/640hud21_2.spr",	
"sprites/ZB5/HUD2/640hud84_2.spr",	
"sprites/weapon_chainsaw_MSBG.txt"
}

enum
{
SAW_ATTACK_NOT = 0,
SAW_ATTACK_BEGIN,
SAW_ATTACK_LOOP,
SAW_ATTACK_END
}

enum Weapon
{
POWERSAW,
ATTACK,
STATE,
TYPE,
CLIP,
Old
}

new g_had[33][Weapon], g_weapon[2], g_PlayerWeapon[33]
new g_HamBot, g_IsConnected, g_IsAlive, g_IsZombie

public plugin_init() 
{	
if(!zb5_weapons_primary())
return
	
Register_SafetyFunc()	
register_event("CurWeapon", "event_CurWeapon", "be", "1=1")

RegisterHam(Ham_Item_Deploy, weapon_base, "Deploy_Post", 1)	
RegisterHam(Ham_Item_AddToPlayer, weapon_base, "fw_Item_AddToPlayer_Post", 1)
RegisterHam(Ham_Weapon_WeaponIdle, weapon_base, "fw_Weapon_WeaponIdle_Post", 1)

RegisterHam(Ham_Weapon_Reload, weapon_base, "fw_Weapon_Reload_Post", 1)
RegisterHam(Ham_Item_PostFrame, weapon_base, "fw_Item_PostFrame")	
RegisterHam(Ham_Weapon_Reload, weapon_base, "fw_Weapon_Reload")
	
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(Saw_Sounds); i++)
PrecacheSound(Saw_Sounds[i])
for(i = 0; i < sizeof(sprites); i++)
PrecacheGeneric(sprites[i])

PrecacheModel("models/ZB5/Primary/v_chainsaw_2.mdl")
register_clcmd("weapon_chainsaw_MSBG", "Hook_Weapon")

g_weapon[0] = zb5_register_weapon("Power Saw", "\rGrim Reaper", WPN_DESTROYERS, LEVEL_POWERSAW, 1)
g_weapon[1] = zb5_register_weapon("Plasma", "\yScientist Gun", WPN_DESTROYERS, LEVEL_PLASMA, 1)
}
public Hook_Weapon(id)engclient_cmd(id, weapon_base)
public plugin_natives()
{
register_native("get_weapon_chainsaw", "Get_PowerSaw", 1)
register_native("remove_weapon_chainsaw", "Reset_All", 1)
}


public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0]) Get_PowerSaw(id)
else if(wpnid == g_weapon[1]) get_weapon_subgun(id, 2)
}

public Get_PowerSaw(id)
{
if(!zb5_weapons_primary())
return
	
remove_all_machines(id, 1, 1)

Reset_All(id, 1)	
drop_weapons(id, 1)

g_had[id][POWERSAW] = true

fm_give_item(id, weapon_base)	
zp_fw_restock_ammo(id)
SPR(id)

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) 
return

Deploy_Post(Ent)
Draw_NewWeapon(id, CSW_BASE)
}
public Reset_All(id, full)
{
remove_task(id+TASK_ATTACK)
		
g_had[id][TYPE] = false
g_had[id][STATE] = false

if(full)	
g_had[id][POWERSAW] = false
}
public zp_fw_restock_ammo(id)
{	
if (!g_had[id][POWERSAW]) 
return;

cs_set_user_bpammo(id, CSW_BASE, zb5_had_StrongLife(id) ? 250 : 200)

if(get_user_weapon(id) == CSW_BASE)
update_ammo_hud(id, 100, 200)
}
public Deploy_Post(Ent)
{
if(!is_valid_ent(Ent))
return

static id; id = get_pdata_cbase(Ent, 41, 4)
if(!is_player(id, 1))
return

if(!g_had[id][POWERSAW])
return

static SubModel; SubModel = 21

set_pev(id, pev_viewmodel2, "models/ZB5/Primary/v_chainsaw_2.mdl")
set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : P_Model)
}
public event_CurWeapon(id)
{
if(!is_player(id, 1))
return

static CSWID; CSWID = get_player_weapon(id)
static SubModel; SubModel = SUBMODEL

if((CSWID == CSW_BASE && g_had[id][Old] != CSW_BASE) && g_had[id][POWERSAW])
{
if(SubModel != -1) 
Draw_NewWeapon(id, CSWID)
} 

else if((CSWID == CSW_BASE && g_had[id][Old] == CSW_BASE) && g_had[id][POWERSAW]) 
{
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent))
{
g_had[id][Old] = get_player_weapon(id)
return
}
} 

else if(CSWID != CSW_BASE && g_had[id][Old] == CSW_BASE) 
{
if(SubModel != -1)
Draw_NewWeapon(id, CSWID)
}

g_had[id][Old] = get_player_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
if(!is_player(id, 1))
return
	
static ent
ent = fm_get_user_weapon_entity(id, CSW_BASE)
	
if(CSW_ID == CSW_BASE)
{
if(is_valid_ent(ent) && g_had[id][POWERSAW])
{
set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 

set_pdata_string(id, (492) * 4, PLAYER_ANIM_EXT_A, -1 , 20)
engfunc(EngFunc_SetModel, ent, P_Model)	
set_pev(ent, pev_body, SUBMODEL)
set_pev(ent, pev_sequence, SEQUENCE)	

set_weapons_timeidle(id, CSW_BASE, 1.0 + 0.5)
set_player_nextattack(id, 1.0)
set_weapon_anim(id, 1)

g_had[id][TYPE] = 1
g_had[id][STATE] = SAW_ATTACK_NOT
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

if(!equal(model, "models/w_m249.mdl"))
return FMRES_IGNORED;

static weapon; weapon = fm_find_ent_by_owner(-1, weapon_base, entity)

if(!is_valid_ent(weapon))
return FMRES_IGNORED;

if(g_had[iOwner][POWERSAW])
{
set_pev(weapon, pev_impulse, 08162019)
engfunc(EngFunc_SetModel, entity, W_Model)
set_pev(entity, pev_body, 24 - 1)
Reset_All(iOwner, 1)
return FMRES_SUPERCEDE
}


return FMRES_IGNORED;
}
public fw_Item_AddToPlayer_Post(ent, id)
{
if(!is_valid_ent(ent))
return 

if(pev(ent, pev_impulse) == 08162019)
{
remove_all_machines(id, 1, 1)

Reset_All(id, 1)
g_had[id][POWERSAW] = true

SPR(id)
set_pev(ent, pev_impulse, 0)
}	
		
}

public fw_CmdStart(id, uc_handle, seed)
{
if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || !g_had[id][POWERSAW])	
return

static NewButton; NewButton = get_uc(uc_handle, UC_Buttons)
static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)

if(!pev_valid(Ent))
return

if(NewButton & IN_ATTACK2)
{
if(g_had[id][STATE] == SAW_ATTACK_LOOP)
{
set_weapons_timeidle(id, CSW_BASE, 0.0)
set_player_nextattack(id, 0.0)

remove_task(id+TASK_ATTACK)
g_had[id][STATE] = SAW_ATTACK_NOT
}

if(get_pdata_float(id, 83, 5) > 0.0 || get_pdata_float(Ent, 46, 4) > 0.0 || get_pdata_float(Ent, 47, 4) > 0.0) 
return

create_fake_attack(id, PLAYER_ANIM_EXT_B)
Make_PunchAngle(id, 0.0, random_float(-2.0, 2.0))

set_weapons_timeidle(id, CSW_BASE, 1.0 - 0.5)
set_player_nextattack(id, 1.0)

static TargetSlash, StartSlash
if(cs_get_weapon_ammo(Ent) > 0) { StartSlash = 7; TargetSlash = 8; }
else { StartSlash = 9; TargetSlash = 10; } 

if(g_had[id][TYPE]) set_weapon_anim(id, StartSlash)
else set_weapon_anim(id, TargetSlash)

set_pdata_string(id, (492) * 4, PLAYER_ANIM_EXT_B, -1 , 20)
set_task(0.1, "PowerSaw_Do_Damage", id)

g_had[id][TYPE] = !g_had[id][TYPE]
}	

if(NewButton & IN_ATTACK)
{
NewButton &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, NewButton)

if(get_pdata_float(id, 83, 5) > 0.0 || get_pdata_float(Ent, 46, 4) > 0.0 || get_pdata_float(Ent, 47, 4) > 0.0) 
return

if(g_had[id][STATE] == SAW_ATTACK_NOT)
{
g_had[id][STATE] = SAW_ATTACK_BEGIN
} 
else if(g_had[id][STATE] == SAW_ATTACK_BEGIN) 
{
set_weapon_anim(id, 3)

set_weapons_timeidle(id, CSW_BASE, 0.5)
set_player_nextattack(id, 0.5)

if(!task_exists(id+TASK_ATTACK)) set_task(0.40, "Task_ChangeState_Loop", id+TASK_ATTACK)
} 
else if(g_had[id][STATE] == SAW_ATTACK_LOOP) 
{
if(cs_get_weapon_ammo(Ent) > 0)
{
set_weapon_anim(id, 4)

set_weapons_timeidle(id, CSW_BASE, 0.5)
set_player_nextattack(id, 0.5)
} 
else 
{
g_had[id][STATE] = SAW_ATTACK_END
set_weapon_anim(id, 5)

set_weapons_timeidle(id, CSW_BASE, 0.5)
set_player_nextattack(id, 1.5)

remove_task(id+TASK_ATTACK)
g_had[id][STATE] = SAW_ATTACK_NOT	
}
}
if(!task_exists(id+TASK_ATTACK1))
set_task(0.01, "Attack1", id+TASK_ATTACK1, _,_, "b")
} 
else 
{
if(!task_exists(id+TASK_ATTACK1))	
remove_task(id+TASK_ATTACK1)	

if(g_had[id][STATE] == SAW_ATTACK_LOOP) 
{
g_had[id][STATE] = SAW_ATTACK_END
set_weapon_anim(id, 5)

//set_weapons_timeidle(id, CSW_BASE, 0.1)
//set_player_nextattack(id, 0.1)
remove_task(id+TASK_ATTACK)
g_had[id][STATE] = SAW_ATTACK_NOT
}
if(pev(id, pev_oldbuttons) & IN_ATTACK)
{
if((cs_get_weapon_ammo(Ent) <= 0) && get_pdata_int(Ent, 54, 4) != 1)
{
set_pdata_int(Ent, 54, 1, 4)
ExecuteHamB(Ham_Weapon_Reload, Ent)
}
}
}
}
public Attack1(id)
{
id -= TASK_ATTACK1
	
if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || !g_had[id][POWERSAW])
return
if(g_had[id][STATE] != SAW_ATTACK_LOOP)
return	

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

if(cs_get_weapon_ammo(Ent) > 0)
{
cs_set_weapon_ammo(Ent, cs_get_weapon_ammo(Ent) - 1)
Make_PunchAngle(id, random_float(-1.75, 1.75), random_float(-1.75, 1.75))

static Body, Target
get_user_aiming(id, Target, Body, floatround(120.0))

static Float:Origin[3]
pev(Target, pev_origin, Origin)

if(Get_BitVar(g_IsAlive, Target)) 
{
if(Get_BitVar(g_IsZombie, Target)) 
do_attack(id, Target, 0, float(30), 1)

emit_sound(id, CHAN_WEAPON, Saw_Sounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
} 
else 
{
Check_AttackDamge(id, 40.0)	
static Float:StartOrigin[3], Float:EndOrigin[3]

pev(id, pev_origin, StartOrigin)
get_weapon_attachment(id, EndOrigin, 120.0 + 2.5)

if(is_wall_between_points(StartOrigin, EndOrigin, id))
{
emit_sound(id, CHAN_WEAPON, Saw_Sounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)

}
}
} 
else 
{
g_had[id][STATE] = SAW_ATTACK_END
set_weapon_anim(id, 5)

set_weapons_timeidle(id, CSW_BASE, 0.5)
set_player_nextattack(id, 1.5)

remove_task(id+TASK_ATTACK)
g_had[id][STATE] = SAW_ATTACK_NOT
}

}

public Task_ChangeState_Loop(id)
{
id -= TASK_ATTACK

if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || !g_had[id][POWERSAW])
return
if(g_had[id][STATE] != SAW_ATTACK_BEGIN)
return

g_had[id][STATE] = SAW_ATTACK_LOOP
}

public PowerSaw_Do_Damage(id)
{
if(!is_player(id, 1))
return
if(get_player_weapon(id) != CSW_BASE || !g_had[id][POWERSAW])
return
if(!Check_SlashAttack(id))
return

static Ent; Ent = fm_get_user_weapon_entity(id, CSW_BASE)
if(!is_valid_ent(Ent)) return

if(cs_get_weapon_ammo(Ent) > 0) 
emit_sound(id, CHAN_WEAPON, Saw_Sounds[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
else emit_sound(id, CHAN_WEAPON, Saw_Sounds[random_num(6, 7)], 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public fw_Item_PostFrame(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

if(!g_had[id][POWERSAW])
return HAM_IGNORED	

static Float:flNextAttack; flNextAttack = get_pdata_float(id, 83, 5)
static bpammo; bpammo = cs_get_user_bpammo(id, CSW_BASE)

static iClip; iClip = get_pdata_int(ent, 51, 4)
static fInReload; fInReload = get_pdata_int(ent, 54, 4)

if(fInReload && flNextAttack <= 0.0)
{
static temp1
temp1 = min(100 - iClip, bpammo)

set_pdata_int(ent, 51, iClip + temp1, 4)
cs_set_user_bpammo(id, CSW_BASE, bpammo - temp1)		

set_pdata_int(ent, 54, 0, 4)

fInReload = 0
}		

return HAM_IGNORED
}

public fw_Weapon_Reload(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

if(!g_had[id][POWERSAW])
return HAM_IGNORED	

g_had[id][CLIP] = -1

static BPAmmo; BPAmmo = cs_get_user_bpammo(id, CSW_BASE)
static iClip; iClip = get_pdata_int(ent, 51, 4)

if(BPAmmo <= 0)
return HAM_SUPERCEDE

if(iClip >= 100)
return HAM_SUPERCEDE		

g_had[id][CLIP] = iClip	

return HAM_HANDLED
}

public fw_Weapon_Reload_Post(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

if(!g_had[id][POWERSAW])
return HAM_IGNORED

if((get_pdata_int(ent, 54, 4) == 1))
{ 
if (g_had[id][CLIP] == -1)
return HAM_IGNORED

set_pdata_int(ent, 51, g_had[id][CLIP], 4)
set_weapon_anim(id, 6)
set_weapons_timeidle(id, CSW_BASE, 3.0 - 1.0)
set_player_nextattack(id, 3.0)
}

return HAM_HANDLED
}

public fw_Weapon_WeaponIdle_Post(ent)
{
if(!is_valid_ent(ent))
return HAM_IGNORED

static id; id = pev(ent, pev_owner)
if(!is_player(id, 1))
return HAM_IGNORED

if(!g_had[id][POWERSAW])
return HAM_IGNORED

if(get_pdata_float(ent, 48, 4) <= 0.1) 
{
set_weapon_anim(id, cs_get_weapon_ammo(ent) > 0 ? 0 : 11)
set_pdata_float(ent, 48, 20.0, 4)
set_pdata_string(id, (492) * 4, PLAYER_ANIM_EXT_A, -1 , 20)
}

return HAM_IGNORED	
}
public Check_SlashAttack(id)
{
#define MAX_POINT 4	
static Float:Max_Distance, Float:Point[4][3], Float:TB_Distance

Max_Distance = float(300)	
TB_Distance = Max_Distance / MAX_POINT

for(new i = 0; i < 4; i++)
get_position(id, TB_Distance * (i + 1), 0.0, 0.0, Point[i])

static ent; ent = fm_get_user_weapon_entity(id, get_player_weapon(id))

if(!is_valid_ent(ent))
return;

static Float:origin[3], Float:Origin[3]
pev(ent, pev_origin, origin)

static i; i = -1
while ((i = engfunc(EngFunc_FindEntityInSphere, i, origin, TB_Distance)) != 0)
{
if(id == i)
continue;

pev(i, pev_origin, Origin)

if(!is_in_viewcone(id, Origin, 1))
continue

if(Get_BitVar(g_IsZombie, i))
set_weapon_kick(id, i, 7000.0)

do_attack(id, i, 0, random_float(800.0, 1200.0), 1)
}	

}	

public Check_AttackDamge(Attacker, Float:Ratio)
{	
if(!is_player(Attacker, 0))
return
	
static Float:origin[3]
pev(Attacker, pev_origin, origin)
	
static Victim; Victim = -1
while ((Victim = engfunc(EngFunc_FindEntityInSphere, Victim, origin, Ratio)) != 0)
{
if(Attacker == Victim)
continue;

do_attack(Attacker, Victim, 0, random_float(100.0, 200.0), 1)
}
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

public update_ammo_hud(id, ammo, bpammo)
{
engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0, 0, 0}, id)
write_byte(1)
write_byte(CSW_BASE)
write_byte(ammo)
message_end()

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, id)
write_byte(1)
write_byte(bpammo)
message_end()
}

stock SPR(id)
{
message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
write_string("weapon_chainsaw_MSBG")
write_byte(3)
write_byte(200)
write_byte(-1)
write_byte(-1)
write_byte(0)
write_byte(4)
write_byte(20)
write_byte(CSW_BASE)
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

Reset_All(id, 0)

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)
}
public zp_fw_core_cure_post(id)
{
Reset_All(id, 0)
	
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
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

Reset_All(id, 1)

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
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
