#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fvault>
#include <ZombieMod5>
#include <infinitygame>

#define NICK
#define TASK_FADE 110
#define TASK_REMOVE_FADE 111

enum _:Item
{
LV,
EXP,
RANK,
Float:DAMAGE		
}
new const gNameRanks[][] = 
{ 
"UnRanked",	
"Silver I",	
"Silver II",		
"Silver III",		
"Silver Elite",		
"Gold Nova I",		
"Gold Nova II",		
"Gold Nova Master",		
"Sergeant First Class (1st tier)",		
"Sergeant First Class (2nd tier)",		
"Sergeant First Class (Final tier)",		
"Master Guardian (1st tier)",		
"Master Guardian (2nd tier)",		
"Master Guardian (Final tier)",	
"Sergeant Major (1st tier)",		
"Sergeant Major (2nd tier)",		
"Sergeant Major (3rd tier)",		
"Sergeant Major (Final tier)",	
"Legendary Eagle",		
"Legendary Eagle Master",		
"Second Lieutenant (1st tier)",		
"Second Lieutenant (2nd tier)",		
"Second Lieutenant (Final tier)",	
"First Lieutenant (1st tier)",		
"First Lieutenant (2nd tier)",		
"First Lieutenant (3rd tier)",		
"First Lieutenant (4th tier)",		
"First Lieutenant (Final tier)",		
"Captain (1st tier)",		
"Captain (2nd tier)",		
"Captain (3rd tier)",		
"Captain (4th tier)",		
"Captain (Final tier)",		
"Major (1st tier)",		
"Major (2nd tier)",		
"Major (3rd tier)",	
"Major (4th tier)",		
"Major (Final tier)",		
"Lieutenant Colonel (1st tier)",	
"Lieutenant Colonel (2nd tier)",		
"Lieutenant Colonel (3rd tier)",		
"Lieutenant Colonel (4th tier)",		
"Lieutenant Colonel (Final tier)",		
"Colonel (1st tier)",		
"Colonel (2nd tier)",		
"Colonel (3rd tier)",		
"Colonel (4th tier)",	
"Colonel (Final tier)",		
"Commodore (1st tier)",	
"Commodore (2nd tier)",		
"Commodore (3rd tier)",		
"Commodore (Final tier)",		
"Supreme Master First Class",		
"Global Elite",
"Global Elite (1st tier)",	
"Global Elite (2nd tier)",		
"Global Elite (3rd tier)",		
"Gladiator (1st tier)",
"Gladiator (2nd tier)",		
"Gladiator (3rd tier)",		
"Gladiator  (4th tier)",
"DESTROYER (Final tier)"
} 
new const gWeapons[][] = 
{ 
"Nothing",	
"SF SMG Tempset (Sub Gun)",	
"Master Combat (Knife)",		
"SF Blaster (Sub Gun)",		
"SAF (Human Class)",		
"Remington M24 (Sniper)",		
"Dual Kriss (Sub Gun)",		
"Double Infinity (Pistol)",		
"SAT (Human Class)",		
"Strong (Knife)",		
"K1ases (Sub Gun)",		
"Rheinmetall MG3 (Machine)",		
"H&K SL8 (AutoSniper)",	
"Balrog-1 (Pistol)",	
"Gatling Volcano (Shot Gun)",		
"Double Skull4 (Assault Rifle)",	
"CROW-5 (Assault Rifle)",			
"Sapientia (Pistol)",
"Gerrard (Human Class)",		
"SKULL9 AXE (Knife)",		
"SKULL-8 (Machine)",	
"Janus5 (Assault Rifle)",	
"Thanatos 3 (Sub Gun)",		
"UTS15 (Shot Gun)",		
"Thanatos 1 (Pistol)",	
"Balrog7 (Machine)",	
"DragonSword (Knife)",	
"SKULL5 (AutoSniper)",			
"Balrog5 (Assault Rifle)",		
"SKULL-11 (Shot Gun)",	//30
"Skull 2 (Pistol)",		
"Crow7 (Machine)",	
"Thanatos 5 (Assault Rifle)",	
"Thanatos 9 (Knife)",		
"Jennifer (Human Class)",		
"AS50 (AutoSniper)",		
"Janus1 (Pistol)",		
"Thanatos 11 (Shot Gun)",		
"M4 Buff (Assault Rifle)",		
"AK47 Buff (Assault Rifle)",	
"Plasma Gun (Beast WPN)",	
"May China (Human Class)",			
"Power ChainSaw (Beast WPN)",	
"Thanatos 7 (Machine)",	
"M95 Barret (Sniper)",	
"Vulcanus-1 (Pistol)",		
"Dragon Cannon (Beast WPN)",	
"Crimson (Pistol)",		
"WarHammer (Knife)",	
"Walter (Human Class)",	
"Janus 7 (Machine)",		
"AT4CS Bazooka (Beast WPN)",			
"Magnum (Sniper)",		
"Balrog 11 (Shot Gun)",	
"M134 (Machine)",	
"Crow9 (Knife)",		
"Hunter (Human Class)",			
"RuneBlade (Knife)",	
"Jim (Human Class)",	
"Petrol Boomer (Beast WPN)",	
"Blood Dripper (Beast WPN)", // 61
"Full SET" // 61
} 
new const g_vault_name2[] = "ZB5LevelSystem_NICK";

static szName[32], szData[64]
new g_IsAlive, g_IsZombie, g_IsConnected
new g_had[33][Item], g_Forward, g_ForwardResult, g_AliveHud 

public plugin_init()
{	
Register_SafetyFunc()	
	
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
register_clcmd ("ggg", "CmdGiveAP", ADMIN_RCON, "- zp_giveap <name> <amount> : Give Ammo Packs" );	

g_AliveHud = zp_get_synchud_id(SYNCHUD_HUMAN_HUD)
g_Forward = CreateMultiForward("zp_fw_level_post", ET_IGNORE, FP_CELL)

//new end_prune_time = get_systime() - (15 * 24 * 60 * 60);
//fvault_prune(g_vault_name2, _, end_prune_time);
}
public plugin_precache()
{
PrecacheSound("ZB5/systemlvup.wav")	
}

public reg_user_logged(id)
{
if(!reg_is_user_logged(id))
return

LoadData(id)
 
if(!zp_core_is_zombie(id))
zb5_weapons_menu(id)
}
public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_player(attacker, 1) || is_user_bot(attacker))
return HAM_IGNORED

if(!reg_is_user_logged(attacker))
return HAM_IGNORED

if(!Get_BitVar(g_IsZombie, victim))
return HAM_IGNORED

if(get_user_weapon(attacker) == CSW_KNIFE)
return HAM_IGNORED

if(g_had[attacker][LV] >= MAX_LEVEL)
return HAM_IGNORED

g_had[attacker][DAMAGE] += damage;

static Damage
Damage = zb5_item_exp(attacker) ? (300 * (g_had[attacker][LV] +1)) / 2  : (700 * (g_had[attacker][LV] +1)) / 2  

if(g_had[attacker][DAMAGE] >= Damage)
{	
g_had[attacker][DAMAGE] -= Damage;
native_set_exp(attacker, 1, 0)
}

return HAM_HANDLED
}
public LevelUP(id)
{	
if(g_had[id][LV] >= MAX_LEVEL)
return 

while(g_had[id][EXP] >= MAX_EXP) 
{
g_had[id][LV] += 1
g_had[id][EXP] = 0
SaveData(id)

set_task(0.1, "Fading", id+TASK_FADE, _, _, "b")
set_task(4.0, "Remove_Fading", id+TASK_REMOVE_FADE)

PlaySound(id, "ZB5/systemlvup.wav")

get_user_name(id, szName, 31)
zp_colored_print(0, "^1 ***** Congratulations. ^4( %s )^1 promoted to ^3%d LV ^1. *****", szName, g_had[id][LV]);
zp_colored_print(id, "^3|Rank| ^4Rank: ^3%s^4.", gNameRanks[g_had[id][LV]]);	
zp_colored_print(id, "^4|Promotion| ^3Unlocked: ^4%s^3.", gWeapons[g_had[id][LV]]);	
		
set_dhudmessage(200, 145, 0, -1.0, 0.145, 0, 4.0, 1.0, 0.7)
show_dhudmessage(id, "^n^nGame Level: [ %i ]", g_had[id][LV])
ExecuteForward(g_Forward, g_ForwardResult, id)
}
}

// EFFECTS 
public Fading(id)
{
id -= TASK_FADE

if(!is_player(id, 1))
{
remove_task(id+TASK_FADE)	
remove_task(id+TASK_REMOVE_FADE)
return;
}

Make_ScreenFade(id, 0.1, random_num(100,250), random_num(100,250), 0, 80, FADE_STAYOUT)	
}

public Remove_Fading(id)
{
id -= TASK_REMOVE_FADE

if(!is_player(id, 1))
{
remove_task(id+TASK_FADE)	
remove_task(id+TASK_REMOVE_FADE)
return;
}

remove_task(id+TASK_FADE)
Make_ScreenFade(id, 1.0, 0, 0, 0, 200, FADE_OUT)
}

////////// HUD //////////
public HUD_ALIVE(id)
{	
static Temp_String_CAN[350]
formatex(Temp_String_CAN, sizeof(Temp_String_CAN), "Website: www.CMS-BG.eu^nRank: %s ^nDecoders: %i - Open Time: %i's ^nLevel: %i - Exprience: %i / 100^nUnlocked: %s", gNameRanks[g_had[id][LV]], zb5_cbox(id), zb5_cbox_time(id), g_had[id][LV], g_had[id][EXP], gWeapons[g_had[id][LV]])

set_hudmessage(50, 150, 0, 0.02, 0.15, 0, 1.0, 1.0)		
ShowSyncHudMsg(id, g_AliveHud, "%s", Temp_String_CAN)
}
public HUD_ALIVE2(id)
{	
static Temp_String_CAN[128]
formatex(Temp_String_CAN, sizeof(Temp_String_CAN), "Zombie Evolution: %i%%^nLevel: %i - Exprience: %i / 100", (zb5_get_zombie_info(id, EVO_POINTS) * 10), g_had[id][LV], g_had[id][EXP])
	
set_hudmessage(200, 10, 0, 0.6, 0.95, 0, 1.0, 1.0)
ShowSyncHudMsg(id, g_AliveHud, "%s", Temp_String_CAN)
}

public CmdGiveAP(id, level, cid)
{
if (!cmd_access(id, level, cid, 3))
{
return PLUGIN_HANDLED;
}        

static s_Name[ 32 ], s_Amount[ 4 ]; 
read_argv ( 1, s_Name, charsmax ( s_Name ) );
read_argv ( 2, s_Amount, charsmax ( s_Amount ) );       
new i_Target = cmd_target ( id, s_Name, 2 );        
if (!i_Target)
{
client_print ( id, print_console, "(!) Player not found" );
return PLUGIN_HANDLED;
}  

if(str_to_num ( s_Amount ) <= 61)
{
g_had[i_Target][LV] = max ( 1, str_to_num ( s_Amount ) ) 
}
return PLUGIN_HANDLED;
}
// NATIVES
public plugin_natives()
{
register_native("zb5_get_user_level", "native_get_level", 1)
register_native("zb5_get_user_exp", "native_get_exp", 1)

register_native("zb5_set_user_level", "native_set_level", 1)
register_native("zb5_set_user_exp", "native_set_exp", 1)
}
public native_get_level(id)return g_had[id][LV];
public native_get_exp(id)return g_had[id][EXP];
public native_set_level(id, levels)
{
if(g_had[id][LV] >= MAX_LEVEL)
return;

g_had[id][LV] += levels
LevelUP(id)

get_user_name(id, szName, 31)
zp_colored_print(0, "^3 ***** Congratulations. [%s] promoted to %d level. *****", szName, g_had[id][LV]);
zp_colored_print(id, "^3 ***** Your rank is now %s. *****", gNameRanks[g_had[id][LV]]);		
}
public native_set_exp(id, amount, mode)
{	
if(!reg_is_user_logged(id))
return;
	
if(g_had[id][LV] >= MAX_LEVEL)
return 

switch(mode)
{
case 0:	
{
if(g_had[id][EXP] >= MAX_EXP)
return;

g_had[id][EXP] += amount
LevelUP(id)
SaveData(id)
}
case 1:	
{
if(g_had[id][EXP] > 0)	
{
g_had[id][EXP] -= amount
LevelUP(id)
SaveData(id)
}
}
}
}
// FVAULT 
public RuningTime_Player(id)
{
if(!reg_is_user_logged(id))
return;


if(!Get_BitVar(g_IsAlive, id))
return

if(!Get_BitVar(g_IsZombie, id))	
HUD_ALIVE(id)
else HUD_ALIVE2(id)	
}
public SaveVault(id)
{	
if(g_had[id][EXP] > 0)SaveData(id) 
else if(g_had[id][LV] > 0)SaveData(id)	
}

public SaveData(id)
{
if(is_user_bot(id))
return;
	
if(!reg_is_user_logged(id))
return
			
get_user_name(id, szName, charsmax(szName))

format(szData, charsmax(szData), "%d %d", g_had[id][LV], g_had[id][EXP]);
fvault_set_data(g_vault_name2, szName, szData);
}

public LoadData(id)
{	
get_user_name(id, szName, charsmax(szName))
format(szData, charsmax(szData), "%d %d", g_had[id][LV], g_had[id][EXP]);

if(fvault_get_data(g_vault_name2, szName, szData, charsmax(szData)))		
{
static LVV[3], EXX[4]			
parse(szData, LVV, charsmax(LVV), EXX, charsmax(EXX));	

g_had[id][LV] = str_to_num(LVV);
g_had[id][EXP] = str_to_num(EXX);	
}
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
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

arrayset(_:g_had[id], false, sizeof(g_had[]));	
}

Safety_Disconnected(id)
{
SaveVault(id)	

if(task_exists(id+TASK_FADE))	
remove_task(id+TASK_FADE)
	
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

arrayset(_:g_had[id], false, sizeof(g_had[]));	
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

SaveVault(id)	

if(task_exists(id+TASK_FADE))	
remove_task(id+TASK_FADE)

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)
}
public zp_fw_core_cure_post(id)
{	
SaveVault(id)	

if(task_exists(id+TASK_FADE))	
remove_task(id+TASK_FADE)
		
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
SaveVault(id)	

if(task_exists(id+TASK_FADE))	
remove_task(id+TASK_FADE)
	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id, attacker)
{
if(zp_core_is_zombie(id))
{		
SaveVault(id)	

if(task_exists(id+TASK_FADE))	
remove_task(id+TASK_FADE)
	
Set_BitVar(g_IsAlive, id)	
Set_BitVar(g_IsZombie, id)
}

if(zp_core_is_zombie(attacker))
native_set_exp(id, 1, 0)
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
/* ===============================
--------- END OF SAFETY  ---------
=================================*/

