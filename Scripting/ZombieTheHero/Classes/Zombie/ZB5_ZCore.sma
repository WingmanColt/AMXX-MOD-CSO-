#include <amxmodx>
#include <ZombieMod5>

#define FLAG_ADMIN ADMIN_CHAT
#define FLAG_VIP ADMIN_LEVEL_B

#define TASK_SKILL_DO 1152016
#define TASK_SKILL_DO2 1152017

new const ZombieSound[][] =
{
"ZB5/Zombie/zombi_attack_1.wav",
"ZB5/Zombie/zombi_attack_2.wav",

"ZB5/Zombie/zombi_swing_1.wav",
"ZB5/Zombie/zombi_swing_2.wav",

"ZB5/Zombie/zombi_wall_1.wav",
"ZB5/Zombie/zombi_wall_2.wav",

"ZB5/zombi_evolution_male.wav",
"ZB5/zombi_evolution_female.wav"
}

enum TOTAL_FORWARDS
{
FW_SELECT_ITEM = 0,
FW_SKILL_RESET,
FW_REMOVE,
FW_SKILL,
FW_EVO
}
enum _:Classes
{	
CLASS,	
ClassName
}
enum _:EVO
{
Float:Damage,			
Float:Gravity,	
Float:Speed,	
MaxHealth,
Health,	
Points,
Level
}
enum _:Skills
{
bool:HAD_SKILL,
		
SKILL1,
COUNTDOWN_TIME,
RESET_TIME,
bool:CAN_SKILL,
bool:DO_SKILL,

SKILL2,	
COUNTDOWN_TIME_2,
RESET_TIME_2,
bool:CAN_SKILL_2,
bool:DO_SKILL_2
}

static szName[32]

new Array:Class_Name, Array:Class_Desc, Array:Class_UnlockCost, 
Array:Class_Female, Array:Class_Knockback, Array:Class_Health, 
Array:Class_Skill_1, Array:Class_Skill_2

new g_ForwardResult, g_Forwards[TOTAL_FORWARDS]
new g_IsZombie, g_IsAlive, g_IsConnected, g_MaxPlayers

new g_had[33][Classes], g_had2[33][EVO], g_skill[33][Skills], g_check_skill[33], g_menu[33] = false
new g_wpn_i, g_class_primary[10], ef_blood[2], g_class_count, g_scaned, g_skill_hud, g_skill_hud2
public plugin_init() 
{
Register_SafetyFunc()	

set_msg_block(get_user_msgid( "ClCorpse" ), BLOCK_SET );  // REMOVE DEATH MODEL
	
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")		
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")

register_forward(FM_CmdStart, "fw_CmdStart")
register_forward(FM_EmitSound, "fw_EmitSound")
register_clcmd("lastinv", "cmd_inv")

g_Forwards[FW_EVO] = CreateMultiForward("zp_fw_zombie_evolution", ET_IGNORE, FP_CELL)	
g_Forwards[FW_SELECT_ITEM] = CreateMultiForward("zb5_zclass_selected_post", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_REMOVE] = CreateMultiForward("zb5_zclass_remove_post", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_SKILL] = CreateMultiForward("zb5_zombieskill", ET_IGNORE, FP_CELL, FP_CELL)
g_Forwards[FW_SKILL_RESET] = CreateMultiForward("zb5_zombieskill_reset", ET_IGNORE, FP_CELL, FP_CELL)

g_MaxPlayers = get_maxplayers()
g_skill_hud = zp_get_synchud_id(SYNCHUD_ZOMBIE_SKILL)
g_skill_hud2 = zp_get_synchud_id(SYNCHUD_HUMAN_QUESTS)
}
public plugin_natives()
{
register_native("zb5_zclass_menu", "do_open_menu_zclass", 1)
register_native("zb5_register_zclass", "native_register_zclass", 1)

register_native("zb5_remove_zclass", "RemoveAllClass", 1)
register_native("zb5_skill_zombie", "native_skill_zombie", 1)

register_native("zb5_get_zombie_info", "native_get_evo", 1)
register_native("zb5_set_zombie_info", "native_set_evo", 1)
}
public plugin_precache()
{	
Class_Name = ArrayCreate(64, 1)
Class_Desc = ArrayCreate(64, 1)
Class_UnlockCost = ArrayCreate(1, 1)
Class_Female = ArrayCreate(1, 1)
Class_Knockback = ArrayCreate(1, 1)
Class_Health = ArrayCreate(1, 1)
Class_Skill_1 = ArrayCreate(1, 1)
Class_Skill_2 = ArrayCreate(1, 1)

PrecacheModel("sprites/ZB5/zbs_zombiup.spr")	
ef_blood[0] = precache_model("sprites/blood.spr")
ef_blood[1] = precache_model("sprites/bloodspray.spr")

for(new i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	
}
public plugin_cfg()
{
if(!g_scaned)
{
g_scaned = 1

for(new i = 0; i < g_wpn_i; i++)
{
g_class_primary[g_class_count] = i
g_class_count++
}
log_amx("Zombie Class Count: %i", g_class_count)	
}	
}

public zp_fw_round_new()
{
for(new i = 0; i < g_MaxPlayers; i++)
{
if(!Get_BitVar(g_IsConnected, i))
continue

g_menu[i] = false		
}
}
public GiveZombie(id)
{
StripPlayerWeapons(id) 
		
if(g_had[id][CLASS])
{	
RemoveAllClass(id)
ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_had[id][ClassName])
}else zb5_get_regular(id)
if(zp_core_is_first_zombie(id))
native_force_evolved(id, ORIGIN)
else native_force_evolved(id, g_had2[id][Level])
}

Reset_All(id, All)
{
RemoveAllClass(id)				
arrayset(g_skill[id], false, sizeof(g_skill[]))

if(All)
{
ClearSyncHud(id, g_skill_hud)
ClearSyncHud(id, g_skill_hud2)
	
arrayset(g_had[id], false, sizeof(g_had[]))
arrayset(g_had2[id], false, sizeof(g_had2[]))
g_had2[id][Level] = NORMAL	
}
}

public RemoveAllClass(id)
{
for(new i = 0; i < g_wpn_i; i++)
ExecuteForward(g_Forwards[FW_REMOVE], g_ForwardResult, id, i)

ZombieSkillReset(id)	
}
public ZombieSkillReset(id)
{
remove_task(id+TASK_SKILL_DO)
remove_task(id+TASK_SKILL_DO2)
	
arrayset(g_skill[id], false, sizeof(g_skill[]))	
g_check_skill[id] = false		
}
public RuningTime_Player(id)
{				
if(!is_zombie(id, 1))
return
if(!reg_is_user_logged(id))
return
	
if(!g_check_skill[id])
{	
g_skill[id][SKILL1] = ArrayGetCell(Class_Skill_1, g_had[id][ClassName]);
g_skill[id][SKILL2] = ArrayGetCell(Class_Skill_2, g_had[id][ClassName]);

g_check_skill[id] = true	
}
else 
{
if(g_skill[id][SKILL1])
HUD_SKILL(id)
if(g_skill[id][SKILL2])
HUD_SKILL2(id)
}
}
public HUD_SKILL(id)
{	
if(g_skill[id][RESET_TIME] > 0) 
g_skill[id][RESET_TIME]--

if(g_skill[id][COUNTDOWN_TIME] > 0)
{ 
g_skill[id][COUNTDOWN_TIME]--

if(!g_skill[id][COUNTDOWN_TIME]) 
g_skill[id][CAN_SKILL] = true
}

static Temp_String[64]

if(g_skill[id][CAN_SKILL])	
formatex(Temp_String, sizeof(Temp_String), "^n[Press E] - Do Ability (Ready)")
else if(g_skill[id][DO_SKILL])		
formatex(Temp_String, sizeof(Temp_String), "^n[Press E] - Ability (Reset: %i)", g_skill[id][RESET_TIME])
else formatex(Temp_String, sizeof(Temp_String), "^n[Press E] - Ability (Countdown: %i)", g_skill[id][COUNTDOWN_TIME])

set_hudmessage(150, 150, 150, -1.0, 0.10, 0, 1.0, 1.0)
ShowSyncHudMsg(id, g_skill_hud, "%s", Temp_String)
}
public HUD_SKILL2(id)
{	
if(g_skill[id][RESET_TIME_2] > 0) 
g_skill[id][RESET_TIME_2]--

if(g_skill[id][COUNTDOWN_TIME_2] > 0)
{ 
g_skill[id][COUNTDOWN_TIME_2]--

if(!g_skill[id][COUNTDOWN_TIME_2]) 
g_skill[id][CAN_SKILL_2] = true
}

static Temp_String2[64]

if(g_skill[id][CAN_SKILL_2])	
formatex(Temp_String2, sizeof(Temp_String2), "^n^n[Press Q] - Do Ability 2 (Ready)")
else if(g_skill[id][DO_SKILL_2])		
formatex(Temp_String2, sizeof(Temp_String2), "^n^n[Press Q] - Ability 2 (Reset: %i)", g_skill[id][RESET_TIME_2])
else formatex(Temp_String2, sizeof(Temp_String2), "^n^n[Press Q] - Ability 2 (Countdown: %i)", g_skill[id][COUNTDOWN_TIME_2])


set_hudmessage(150, 150, 150, -1.0, 0.10, 0, 1.0, 1.0)
ShowSyncHudMsg(id, g_skill_hud2, "^n%s", Temp_String2)
}
// MENUS
public do_open_menu_zclass(id)
{
if(!is_zombie(id, 0))
return PLUGIN_HANDLED 		
if(!reg_is_user_logged(id))
return PLUGIN_HANDLED 	
static menu, MyLevel, Temp_String[128], Temp_String2[128], Temp_String3[10], Temp_String4[128]

MyLevel = zb5_get_user_level(id)
menu = menu_create("\rZombie: \yZ-Noid", "weapon_menu_zhandle")

g_menu[id] = true

for(new i = 0; i < g_wpn_i; i++)
{
if(MyLevel >= ArrayGetCell(Class_UnlockCost, i))
{					
ArrayGetString(Class_Name, i, Temp_String, sizeof(Temp_String))
ArrayGetString(Class_Desc, i, Temp_String4, sizeof(Temp_String4))
num_to_str(i, Temp_String3, sizeof(Temp_String3))
formatex(Temp_String2, sizeof(Temp_String2), "%s %s", Temp_String, Temp_String4)
menu_additem(menu, Temp_String2, Temp_String3)	
}
}

menu_setprop(menu,MPROP_PERPAGE, 0)   
menu_display(id, menu, 0)	
return PLUGIN_HANDLED
}

public weapon_menu_zhandle(id, menu, item)
{
if(!is_zombie(id, 0))
return PLUGIN_HANDLED 	
if(!reg_is_user_logged(id))
return PLUGIN_HANDLED 			
new data[6], access, callback
menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)

static wpn_id;
wpn_id = str_to_num(data)

RemoveAllClass(id)
g_had[id][CLASS] = true
g_had[id][ClassName] = wpn_id
g_menu[id] = true

ExecuteForward(g_Forwards[FW_SELECT_ITEM], g_ForwardResult, id, g_had[id][ClassName])
return PLUGIN_HANDLED   
}

//// EVOLUTION ///
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (!is_zombie(attacker, 1))
return HAM_IGNORED;

SetHamParamFloat(4, damage * 3.0)
return HAM_IGNORED;
}

public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{	
if(!is_zombie(victim, 1))
return HAM_IGNORED

if(g_had2[victim][Level] == ORIGIN)
return HAM_IGNORED

g_had2[victim][Damage] += damage;

if(g_had2[victim][Damage] >= 2700.0)
{
g_had2[victim][Damage] -= 2700.0;
g_had2[victim][Points] += 1	
UpdateLevelZombie(victim)
}


return HAM_HANDLED
}
public UpdateLevelZombie(id)
{
switch(g_had2[id][Points])
{
case 5:	
{	
g_had2[id][Level] = HOST
evolution_start(id)

set_hudmessage(200, 145, 0, 0.02, 0.40, 0, 7.0, 7.0)
ShowSyncHudMsg(id, zp_get_synchud_id(SYNCHUD_NOTICE), "Evolution Up to Level: 1 (Host Zombie)")
}
case 10:	
{
g_had2[id][Level] = ORIGIN
evolution_start(id)

set_hudmessage(200, 145, 0, 0.02, 0.40, 0, 7.0, 7.0)
ShowSyncHudMsg(id, zp_get_synchud_id(SYNCHUD_NOTICE), "Evolution Up to Level: 2 (Origin Zombie)")
}
}
}
public evolution_start(id)
{	
g_had2[id][Damage] = 0.0;
	
zb5_AddTofull_Icon(id, 220.0, 0.5, 3.0, "sprites/ZB5/zbs_zombiup.spr", 11)
native_force_evolved(id, g_had2[id][Level])

if(ArrayGetCell(Class_Female, g_had[id][ClassName]) != 1)
emit_sound(id, CHAN_VOICE, native_get_evo(id, FEMALE) != 1 ? "ZB5/zombi_evolution_male.wav" : "ZB5/zombi_evolution_female.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_pev(id, pev_weaponanim, 3)
message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
write_byte(3)
write_byte(0)
message_end()

ExecuteForward(g_Forwards[FW_EVO], g_ForwardResult, id)	
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
return FMRES_SUPERCEDE;

if(!is_zombie(id, 1))
return FMRES_IGNORED

// Zombie attacks with knife
if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
{
if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
{
emit_sound(id, channel, ZombieSound[random_num(2, 3)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}

if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
{
if (sample[17] == 'w') // wall
{
emit_sound(id, channel, ZombieSound[random_num(4, 5)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
} else {
emit_sound(id, channel, ZombieSound[random_num(0, 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
}

if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
{
emit_sound(id, channel, ZombieSound[random_num(0, 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
}

return FMRES_IGNORED;
}

public fw_CmdStart(id, uc_handle, seed)
{
if(!is_zombie(id, 1))
return

if(!g_skill[id][SKILL1])
return	

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)	

if((CurButton & IN_USE) && g_skill[id][CAN_SKILL] && !g_skill[id][DO_SKILL])
{
CurButton &= ~IN_USE
set_uc(uc_handle, UC_Buttons, CurButton)

switch(zb5_get_zombie_info(id, EVO_LV))
{
case ORIGIN:g_skill[id][RESET_TIME] = 10
case HOST:g_skill[id][RESET_TIME] = 8
case NORMAL:g_skill[id][RESET_TIME] = 4
}
	
g_skill[id][DO_SKILL] = true
g_skill[id][CAN_SKILL] = false

ExecuteForward(g_Forwards[FW_SKILL], g_ForwardResult, id, SKILL_E)

remove_task(id+TASK_SKILL_DO)
set_task(float(g_skill[id][RESET_TIME]), "Reset_Skill", id+TASK_SKILL_DO)	
}	
}

public cmd_inv(id)
{
if(!is_zombie(id, 1))
return
if(!g_skill[id][SKILL2])
return	

if(g_skill[id][CAN_SKILL_2] && !g_skill[id][DO_SKILL_2])
{
switch(zb5_get_zombie_info(id, EVO_LV))
{
case ORIGIN:g_skill[id][RESET_TIME_2] = 6
case HOST:g_skill[id][RESET_TIME_2] = 4
case NORMAL:g_skill[id][RESET_TIME_2] = 2
}
	
g_skill[id][DO_SKILL_2] = true
g_skill[id][CAN_SKILL_2] = false

ExecuteForward(g_Forwards[FW_SKILL], g_ForwardResult, id, SKILL_Q)

remove_task(id+TASK_SKILL_DO2)
set_task(float(g_skill[id][RESET_TIME_2]), "Reset_Skill2", id+TASK_SKILL_DO2)	
}	
}

public Reset_Skill(id)
{
id -= TASK_SKILL_DO

if(!is_zombie(id, 1))
{
remove_task(id+TASK_SKILL_DO)	
return
}

switch(zb5_get_zombie_info(id, EVO_LV))
{
case ORIGIN:g_skill[id][COUNTDOWN_TIME] = 15
case HOST: g_skill[id][COUNTDOWN_TIME] = 20
case NORMAL:g_skill[id][COUNTDOWN_TIME] = 25
}

g_skill[id][DO_SKILL] = false	
ExecuteForward(g_Forwards[FW_SKILL_RESET], g_ForwardResult, id, SKILL_E)
}
public Reset_Skill2(id)
{
id -= TASK_SKILL_DO2

if(!is_zombie(id, 1))
{
remove_task(id+TASK_SKILL_DO2)	
return
}

switch(zb5_get_zombie_info(id, EVO_LV))
{
case ORIGIN:g_skill[id][COUNTDOWN_TIME_2] = 25
case HOST:g_skill[id][COUNTDOWN_TIME_2] = 30
case NORMAL:g_skill[id][COUNTDOWN_TIME_2] = 35
}

g_skill[id][DO_SKILL_2] = false	
ExecuteForward(g_Forwards[FW_SKILL_RESET], g_ForwardResult, id, SKILL_Q)
}	
StripPlayerWeapons(id) 
{ 
fm_strip_user_weapons(id) 
fm_give_item(id, "weapon_knife")
}

public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], trace, damage_type)
{
if(!is_zombie(victim, 1))
return HAM_IGNORED

//Retrieve the end of the trace
static Float: end[3]
get_tr2(trace, TR_vecEndPos, end);

//This message will draw blood sprites at the end of the trace
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, end[0])
engfunc(EngFunc_WriteCoord, end[1])
engfunc(EngFunc_WriteCoord, end[2]+5.0)
write_short(ef_blood[1])
write_short(ef_blood[0])
write_byte(59) // color index
write_byte(random_num(5, 10)) // size
message_end()

return HAM_IGNORED;
}
// NATIVES
public native_skill_zombie(id, INFO2)
{
switch(INFO2)
{
case SKILL_CAN: 
{
g_skill[id][CAN_SKILL] = true	
g_skill[id][DO_SKILL] = false

g_skill[id][COUNTDOWN_TIME] = 0	
g_skill[id][RESET_TIME] = 0	
}
case SKILL_CAN_2: 
{
g_skill[id][CAN_SKILL_2] = true	
g_skill[id][DO_SKILL_2] = false

g_skill[id][COUNTDOWN_TIME_2] = 0	
g_skill[id][RESET_TIME_2] = 0
}
case SKILL_DO_2: return g_skill[id][DO_SKILL_2];		
case SKILL_CTIME_2:return g_skill[id][COUNTDOWN_TIME_2]
case SKILL_RTIME_2:return g_skill[id][RESET_TIME_2];
}
return 0;
}
public native_get_evo(id, INFO)
{
switch(INFO)
{
case FEMALE: return ArrayGetCell(Class_Female, g_had[id][ClassName]);		
case HEALTH: return g_had2[id][Health];	
case MAXHEALTH: return g_had2[id][MaxHealth];	
case SPEED: return g_had2[id][Speed];
case GRAVITY: return g_had2[id][Gravity];
case EVO_LV: return g_had2[id][Level];
case EVO_POINTS: return g_had2[id][Points];
case ZCLASS: return g_had[id][CLASS];
case KNOCKBACK: return ArrayGetCell(Class_Knockback, g_had[id][ClassName]);
}
return 0;
}
public native_set_evo(id, INFO, amount, Float:amount2)
{
switch(INFO)
{
case HEALTH:
{
static health; health = get_user_health(id)

g_had2[id][Health] = clamp(health + amount, 0, amount+1)
fm_set_user_health(id, g_had2[id][Health])
g_had2[id][MaxHealth] = g_had2[id][Health]
}
case SPEED:
{
cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, amount2)
}
case GRAVITY:
{
fm_set_user_gravity(id, amount2)
}
case RESET_SPEED:
{
cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, g_had2[id][Speed])
}
case RESET_GRAVITY:fm_set_user_gravity(id, g_had2[id][Gravity])
case EVO_LV:g_had2[id][Level] = amount
case EVO_POINTS:g_had2[id][Points] += amount
}
}

public native_force_evolved(id, mode)
{
if (!is_zombie(id, 1))
return;

static health
health = get_user_health(id)

switch(mode) 
{	
case HOST:
{
g_had2[id][Gravity] = 0.7
g_had2[id][Speed] = 320.0

g_had2[id][Points] = 5
g_had2[id][Level] = HOST

g_had2[id][MaxHealth] = 12000
g_had2[id][Health] = clamp(health + 12000, 0, 12001)
fm_set_user_health(id, g_had2[id][Health])

fm_set_user_armor(id, 600)
fm_set_user_gravity(id, g_had2[id][Gravity])

cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, g_had2[id][Speed])
}
case ORIGIN:
{	
g_had2[id][Gravity] = 0.650
g_had2[id][Speed] = 330.0

g_had2[id][Points] = 10
g_had2[id][Level] = ORIGIN

g_had2[id][MaxHealth] = 14000
g_had2[id][Health] = clamp(health + 14000, 0, 14001)
fm_set_user_health(id, g_had2[id][Health])

fm_set_user_armor(id, 900)
fm_set_user_gravity(id, g_had2[id][Gravity])

cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, g_had2[id][Speed])
}
case NORMAL:
{
g_had2[id][Gravity]  = 0.750
g_had2[id][Speed] = 310.0

g_had2[id][Points] = 0
g_had2[id][Level] = 0

g_had2[id][Health] = clamp(health + ArrayGetCell(Class_Health, g_had[id][ClassName]), 0, ArrayGetCell(Class_Health, g_had[id][ClassName])+1)
fm_set_user_health(id, g_had2[id][Health])
g_had2[id][MaxHealth] = g_had2[id][Health]

fm_set_user_armor(id, 200)
fm_set_user_gravity(id, g_had2[id][Gravity])

cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, g_had2[id][Speed])
}
}
}

public native_register_zclass(const Name[], const Desc[], unlock_cost, female, Knockback, Health2, SSkill_1, SSkill_2)
{
param_convert(1)
param_convert(2)

ArrayPushString(Class_Name, Name)
ArrayPushString(Class_Desc, Desc)

ArrayPushCell(Class_UnlockCost, unlock_cost)
ArrayPushCell(Class_Female, female)

ArrayPushCell(Class_Knockback, Knockback)
ArrayPushCell(Class_Health, Health2)

ArrayPushCell(Class_Skill_1, SSkill_1)
ArrayPushCell(Class_Skill_2, SSkill_2)

g_wpn_i++
return (g_wpn_i - 1)
}

/* ===============================
------------- SAFETY -------------
=================================*/

public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)

Reset_All(id, 1)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)

Reset_All(id, 1)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
{	
Set_BitVar(g_IsZombie, id)
GiveZombie(id)

if(!g_menu[id])
do_open_menu_zclass(id)

}else Reset_All(id, 0)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)	
UnSet_BitVar(g_IsZombie, id)
Reset_All(id, 0)

cs_reset_player_view_model(id, CSW_KNIFE)
cs_reset_player_weap_model(id, CSW_KNIFE)
cs_set_player_weap_restrict(id, false)
}

public fw_Safety_Killed_Post(id)
{
if(!is_zombie(id, 0))
return

menu_cancel(id)

UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)	

Reset_All(id, 0)	
}
public zp_fw_core_infect_post(id, attacker)
{
if(zp_core_is_zombie(id))
{
Set_BitVar(g_IsZombie, id)	
GiveZombie(id)
}
if (Get_BitVar(g_IsZombie, attacker) && g_had2[attacker][Points] < 11)
{
g_had2[attacker][Points] += 1
UpdateLevelZombie(attacker)
}
}

is_zombie(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsZombie, id))
return 0
if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}
return 1
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/

