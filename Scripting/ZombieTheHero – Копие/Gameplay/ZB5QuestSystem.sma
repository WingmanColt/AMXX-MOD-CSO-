#include <amxmodx>
#include <fvault>
#include <ZombieMod5>

new const g_vault_name2[] = "ZB5QuestSystem_NICK";
static szName[32], szData[64]

#define MAX_HEADSHOT 5
#define MAX_MELEE 5
#define MAX_SUPPLYBOX 15
#define MAX_MORALE 5
#define MAX_INFECT 20
#define MAX_WIN 10
#define MAX_FRAG 200

enum _:Quests
{
MISSION_1,
MISSION_2,
MISSION_3,
MISSION_4,
MISSION_5,
MISSION_6,
MISSION_7
}
new g_had[33][Quests], g_reward[33][Quests], g_done[33][Quests], g_count[33], g_AliveHud

public plugin_init()
{	
g_AliveHud = zp_get_synchud_id(SYNCHUD_HUMAN_QUESTS)
}

public client_authorized(id)LoadData(id)

////////// HUD //////////
public RuningTime_Player(id)
{
if(!reg_is_user_logged(id))	
return;

if(is_user_alive(id) && !zp_core_is_zombie(id))	
HUD_ALIVE(id)
}

public HUD_ALIVE(id)
{	
static Temp_String[128]
formatex(Temp_String, sizeof(Temp_String), "^n.::You have %i rewards from mission to open, click M5 !::.", g_count[id])
		
set_hudmessage(0, 50, 150, 0.55, 0.968, 0, 2.0, 2.0)
ShowSyncHudMsg(id, g_AliveHud, Temp_String)
}

public Quests_Menu(id)  
{   
if(!is_user_connected(id))
return PLUGIN_HANDLED 
if(!reg_is_user_logged(id))
return PLUGIN_HANDLED 

static buffer[100]	
formatex(buffer, charsmax(buffer), "\rDaily Missions ^nCompleted: \y(%d / 7)", g_count[id])

static menu; menu = menu_create(buffer, "Quests_Menus")   

if(g_had[id][MISSION_1] < MAX_HEADSHOT)
formatex(buffer, charsmax(buffer), "Headshot Gladiator \d(\y%d\d/\r%d\d)", g_had[id][MISSION_1], MAX_HEADSHOT)
else
formatex(buffer, charsmax(buffer), "\dHeadshot Gladiator (\yDone !\d)")
menu_additem(menu, buffer, "1")	


if(g_had[id][MISSION_2] < MAX_MELEE)
formatex(buffer, charsmax(buffer), "Melee Expert \d(\y%d\d/\r%d\d)", g_had[id][MISSION_2], MAX_MELEE)
else
formatex(buffer, charsmax(buffer), "\dMelee Expert (\yDONE !\d)")
menu_additem(menu, buffer, "2")	


if(g_had[id][MISSION_3] < MAX_SUPPLYBOX)
formatex(buffer, charsmax(buffer), "Claim Supply Box \d(\y%d\d/\r%d\d)", g_had[id][MISSION_3], MAX_SUPPLYBOX)
else
formatex(buffer, charsmax(buffer), "\dClaim Supply Box (\yDONE !\d)")
menu_additem(menu, buffer, "3")	


if(g_had[id][MISSION_4] < MAX_MORALE)
formatex(buffer, charsmax(buffer), "Morale Boost Experience \d(\y%d\d/\r%d\d)", g_had[id][MISSION_4], MAX_MORALE)
else
formatex(buffer, charsmax(buffer), "\dMorale Boost Experience (\yDONE !\d)")
menu_additem(menu, buffer, "4")	


if(g_had[id][MISSION_5] < MAX_INFECT)
formatex(buffer, charsmax(buffer), "Virus Propagator \d(\y%d\d/\r%d\d)", g_had[id][MISSION_5], MAX_INFECT)
else
formatex(buffer, charsmax(buffer), "\dVirus Propagator (\yDONE !\d)")
menu_additem(menu, buffer, "5")	


if(g_had[id][MISSION_6] < MAX_WIN)
formatex(buffer, charsmax(buffer), "Glorious Winner \d(\y%d\d/\r%d\d)", g_had[id][MISSION_6], MAX_WIN)
else
formatex(buffer, charsmax(buffer), "\dGlorious Winner (\yDONE !\d)")
menu_additem(menu, buffer, "6")	

if(g_had[id][MISSION_7] < MAX_FRAG)
formatex(buffer, charsmax(buffer), "Master Killer \d(\y%d\d/\r%d\d)", g_had[id][MISSION_7], MAX_FRAG)
else
formatex(buffer, charsmax(buffer), "\dMaster Killer (\yDONE !\d)")
menu_additem(menu, buffer, "7")	


menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0)  
return PLUGIN_HANDLED   
} 
public Quests_Menus(id, menu, item)   
{   	
if(!is_user_connected(id))
return PLUGIN_HANDLED   

if (item == MENU_EXIT)   
{   	
menu_destroy(menu)   
return PLUGIN_HANDLED   
} 

new data[30], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback)   
new key = str_to_num(data)  

switch(key)   
{ 
case 1:   
{   
if(g_had[id][MISSION_1] < MAX_HEADSHOT)
{	
zp_colored_print(id, "^1You should kill %d zombies with ^3Headshot !", MAX_HEADSHOT)
zp_colored_print(id, "^3Reward: +5 XP")
}else{
g_done[id][MISSION_1] = true	

if(!g_reward[id][MISSION_1])
{	
zb5_set_user_exp(id, 5, 0)
g_reward[id][MISSION_1] = true	
}
}
return PLUGIN_HANDLED   
}  	
case 2:   
{   
if(g_had[id][MISSION_2] < MAX_MELEE)
{	
zp_colored_print(id, "^1You should kill %d zombies with ^3Melee !", MAX_MELEE)
zp_colored_print(id, "^3Reward: +10 XP")
}else{
if(!g_reward[id][MISSION_2])
{
zb5_set_user_exp(id, 10, 0)
g_reward[id][MISSION_2] = true
}
}
return PLUGIN_HANDLED   
}  
case 3:   
{  
if(g_had[id][MISSION_3] < MAX_SUPPLYBOX)
{	 
zp_colored_print(id, "^1You should to collect %d Supply Boxes !", MAX_SUPPLYBOX)
zp_colored_print(id, "^3Reward: +2 Code Box Decoders")
}else{
if(!g_reward[id][MISSION_3])	
{
zb5_give_cbox(id, 2)
g_reward[id][MISSION_3] = true	
}
}
return PLUGIN_HANDLED   
}  
case 4:   
{   
if(g_had[id][MISSION_4] < MAX_MORALE)
{	 	
zp_colored_print(id, "^1Reach %d times 200%% Morale Boost Experience !", MAX_MORALE)
zp_colored_print(id, "^3Reward: Skull Package Set")
}else{
if(!g_reward[id][MISSION_4])	
{
get_weapon_pistol(id, 7)	
get_weapon_rifle(id, 1)	
get_weapon_knife(id, 4)
get_weapon_grenade_he(id, 3)
g_reward[id][MISSION_4] = true	
}
}
return PLUGIN_HANDLED   
}  
case 5:   
{   
if(g_had[id][MISSION_5] < MAX_INFECT)
{	
zp_colored_print(id, "^1You should infect %d Humans to reach quest !", MAX_INFECT)
zp_colored_print(id, "^3Reward: Zombie Sheild")
}else{
if(!g_reward[id][MISSION_5])	
{
zb5_give_Sheild(id)
g_reward[id][MISSION_5] = true	
}
}
return PLUGIN_HANDLED   
} 
case 6:   
{   
if(g_had[id][MISSION_6] < MAX_WIN)
{		
zp_colored_print(id, "^1You should survive %d times as Human !", MAX_WIN)
zp_colored_print(id, "^3Reward: Damage Booster x3")
}else{
if(!g_reward[id][MISSION_6])	
{
zb5_give_DamageBooster(id)
g_reward[id][MISSION_6] = true	
}
}
return PLUGIN_HANDLED   
} 
case 7:   
{   
if(g_had[id][MISSION_7] < MAX_FRAG)
{	
zp_colored_print(id, "^1 Make %d Frags to get perfect Reward !", MAX_FRAG)
zp_colored_print(id, "^3Reward: Balrog Package Set; +20 EXP; 20 Code Decoders !!!")
}else{
if(!g_reward[id][MISSION_7])	
{
zb5_set_user_level(id, zb5_get_user_level(id) + 20)
get_weapon_pistol(id, 2)	
get_weapon_machine(id, 1)	
get_weapon_knife(id, 8)
get_weapon_grenade_he(id, 2)
get_weapon_grenade_flash(id, 1)
get_weapon_grenade_smoke(id, 3)	
zb5_give_cbox(id, 20)
g_reward[id][MISSION_7] = true	
}
}
return PLUGIN_HANDLED   
}			
}   
menu_destroy(menu)   
return PLUGIN_HANDLED   
} 


// NATIVES
public plugin_natives() 
{
register_native("zb5_menu_quest", "Quests_Menu", 1)	
//register_native("zb5_get_user_quest", "native_get_user_quest", 1)
register_native("zb5_set_user_quest", "native_set_user_quest", 1)		
}
/*public native_get_user_quest(id, mission)
{
switch(mission)
{
case QUEST_HEADSHOT: return g_had[id][MISSION_1]
case QUEST_MELEE: return g_had[id][MISSION_2]
case QUEST_SUPPLYBOX: return g_had[id][MISSION_3]
case QUEST_MORALE: return g_had[id][MISSION_4]
case QUEST_INFECT: return g_had[id][MISSION_5]
case QUEST_SURVIVE: return g_had[id][MISSION_6]
case QUEST_MASTER: return g_had[id][MISSION_7]	
}

return 0;
}*/
public native_set_user_quest(id, mission, amount)
{
switch(mission)
{
case QUEST_HEADSHOT: 
{
if(g_had[id][MISSION_1] < MAX_HEADSHOT)	
g_had[id][MISSION_1] += amount
else {
g_count[id]++
g_done[id][MISSION_1] = true
}
}
case QUEST_MELEE: 
{
if(g_had[id][MISSION_2] < MAX_MELEE)	
g_had[id][MISSION_2] += amount
else g_count[id]++
}
case QUEST_SUPPLYBOX: 
{
if(g_had[id][MISSION_3] < MAX_SUPPLYBOX)	
g_had[id][MISSION_3] += amount
else g_count[id]++
}
case QUEST_MORALE: 
{
if(g_had[id][MISSION_4] < MAX_MORALE)	
g_had[id][MISSION_4] += amount
else g_count[id]++
}
case QUEST_INFECT: 
{
if(g_had[id][MISSION_5] < MAX_INFECT)	
g_had[id][MISSION_5] += amount
else g_count[id]++
}
case QUEST_SURVIVE: 
{
if(g_had[id][MISSION_6] < MAX_WIN)	
g_had[id][MISSION_6] += amount
else g_count[id]++
}
case QUEST_MASTER: 
{
if(g_had[id][MISSION_7] < MAX_FRAG)	
g_had[id][MISSION_7] += amount
else g_count[id]++
}	
}

SaveData(id)

}
public client_disconnected(id)Safety_Disconnected(id)

Safety_Disconnected(id)
{
SaveData(id)
arrayset(_:g_had[id], false, sizeof(g_had[]));	
}
public reg_user_logged(id)
{
if(!reg_is_user_logged(id))
return

LoadData(id)
}

// FVAULT 
public SaveData(id)
{
if(is_user_bot(id))
return;

get_user_name(id, szName, charsmax(szName))

format(szData, charsmax(szData), "%d %d %d %d %d %d %d", g_had[id][MISSION_1], g_had[id][MISSION_2], g_had[id][MISSION_3], g_had[id][MISSION_4], g_had[id][MISSION_5], g_had[id][MISSION_6], g_had[id][MISSION_7]);
fvault_set_data(g_vault_name2, szName, szData);
}


public LoadData(id)
{
get_user_name(id, szName, charsmax(szName))
format(szData, charsmax(szData), "%d %d %d %d %d %d %d", g_had[id][MISSION_1], g_had[id][MISSION_2], g_had[id][MISSION_3], g_had[id][MISSION_4], g_had[id][MISSION_5], g_had[id][MISSION_6], g_had[id][MISSION_7]);

if(fvault_get_data(g_vault_name2, szName, szData, charsmax(szData)))		
{
static MISSION1[2], MISSION2[2], MISSION3[2], MISSION4[2], MISSION5[2], MISSION6[2], MISSION7[2]			
parse(szData, MISSION1, charsmax(MISSION1), MISSION2, charsmax(MISSION2), MISSION3, charsmax(MISSION3), MISSION4, charsmax(MISSION4), MISSION5, charsmax(MISSION5), MISSION6, charsmax(MISSION6), MISSION7, charsmax(MISSION7));	

g_had[id][MISSION_1] = str_to_num(MISSION1);
g_had[id][MISSION_2] = str_to_num(MISSION2);
g_had[id][MISSION_3] = str_to_num(MISSION3);
g_had[id][MISSION_4] = str_to_num(MISSION4);
g_had[id][MISSION_5] = str_to_num(MISSION5);
g_had[id][MISSION_6] = str_to_num(MISSION6);
g_had[id][MISSION_7] = str_to_num(MISSION7);
}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
