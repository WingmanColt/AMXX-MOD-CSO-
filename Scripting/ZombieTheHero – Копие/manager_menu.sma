#include <amxmodx>
#include <amxmisc>
#include <fvault>
#include <ZombieMod5>

enum _:PlayerData
{
g_szName[32],
g_szSteamID[32],
g_iOption,
g_iPlayer,
g_iChoosen
}


// DATA CENTER

#define MAXDATA 64
new const g_vault_name[] = "RegisterSystem";
static szData[MAXDATA], szName[32]
// END 

new g_PlayerInfo[33][PlayerData]
#define MANAGER_FLAG ADMIN_IMMUNITY

enum
{
DIR_USERS,
DIR_VIPS,
DIR_PREFIX
}

new const g_szDataDir[][] =
{
"addons/amxmodx/configs/users.ini",
"addons/amxmodx/configs/vips.ini",
"addons/amxmodx/configs/ap_prefixes.ini"
}

enum RELOAD_TYPE
{
RLD_ADMINS,
RLD_VIPS
}

new const g_szReloadCmds[RELOAD_TYPE][] =
{
"amx_reloadadmins",
"amx_reloadvips"
}

new const g_szZPMenuItems[][] =
{
"\wPlayer \rMenu",
"\wLevel \rMenu",	
"\wRank \rMenu",
"\wVIP \rMenu"
}
new const g_szZPPlayerMenuItems[][] =
{
"\yMake Human/Zombie",
"\yMake Hero/Heroine",
"\yRespawn player"
}
new const g_szZPLevelMenuItems[][] =
{
"\yGive Level",
"\yGive Exp",
"\rRemove from Fvault System"
}

new const g_szZPRankMenuItems[][] =
{
"\yGive Rank",
"\yRemove Rank",
"\yReload Ranks"
}

new const g_szVipMenuItems[][] =
{
"\yGive VIP",
"\yRemove VIP",
"\yReload VIP"
}

//*/**/**/*/*/*/*/*/*/ Change or Add The Ranks Names and Flags Here (Respectively) //*/*/*/*/*/*/*/*//
//Note Last line should not have a comma ',' but other should have one ',' as you can notice
new const g_szRanks[][] =
{
"| Owner |",
"| Help Admin |",
"(ADMIN + VIP)",
"(ADMIN)",
"|V.I.P|"
}

new const g_szFlags[][] =
{
"abcdefghijklmnopqrstuv",
"bcdefjkluimntp",
"bcefjuoi",
"ceit",
"bcefjuoi"
}

//***********************************************************************************************************************************//

public plugin_init()
{
register_concmd("managermenu", "CheckAccess")

register_concmd("GIVE_LEVEL_AMOUNT", "LVEntred")
register_concmd("GIVE_EXP_AMOUNT", "LVEntred2")
}

public client_authorized(id)
{
get_user_name(id, g_PlayerInfo[id][g_szName], charsmax(g_PlayerInfo[][g_szName]))
get_user_authid(id, g_PlayerInfo[id][g_szSteamID], charsmax(g_PlayerInfo[][g_szSteamID]))
}

public CheckAccess(id)
{
if(get_user_flags(id) & MANAGER_FLAG)
ZpRankMenu(id)
else
zino_colored_print(id, "!g[ACCESS]!y Only The server Manager can access this menu")
}



public ZpRankMenu(id)
{
zino_colored_print(id, "!g[ACCESS]!y Welcome to the Manager Menu!t %s", g_PlayerInfo[id][g_szName])

new iMenuID = menu_create("\r.::[\rManager \d: \yMenu\r]::.", "ZPMenuHandle")
for(new i=0; i<sizeof(g_szZPMenuItems); i++) menu_additem(iMenuID, g_szZPMenuItems[i])
menu_display(id, iMenuID)

}

public ZPMenuHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID)
return;
}
switch(iItem)
{
case 0: PlayerMenu(id)
case 1: LevelMenu(id)
case 2: RankMenu(id)
case 3: VipMenu(id)
}

g_PlayerInfo[id][g_iOption] = iItem+1

}



/////// PLAYER MENU //////
public PlayerMenu(id)
{	
new iMenuID = menu_create("\yPlayer Menu\w:", "PlayerMenuHandle")
for(new i=0; i<sizeof(g_szZPPlayerMenuItems); i++) menu_additem(iMenuID, g_szZPPlayerMenuItems[i])
menu_display(id, iMenuID)
}

public PlayerMenuHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID);
return;
}

switch(iItem)
{
case 0: ChooseClassPlayer(id)
case 1: ChooseHeroPlayer(id)
case 2: RespawnPlayer(id)
}
}


public ChooseClassPlayer(id)
{
new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "ChooseClassPlayerHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue

g_PlayerInfo[n++][g_iPlayer] = i

get_user_name(i, szItem, charsmax(szItem))
menu_additem(iMenuID, szItem, "0", 0)
}

menu_display(id, iMenuID)
}

public ChooseClassPlayerHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID)
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer]
if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.")
ChooseClassPlayer(id)
return;
}

if(zp_core_is_zombie(g_PlayerInfo[id][g_iChoosen]))
{
zp_core_respawn_as_zombie(g_PlayerInfo[id][g_iChoosen], false)
ExecuteHamB(Ham_CS_RoundRespawn, g_PlayerInfo[id][g_iChoosen])	
cs_set_user_team(g_PlayerInfo[id][g_iChoosen],CS_TEAM_CT)	

} else {

zp_core_respawn_as_zombie(g_PlayerInfo[id][g_iChoosen], true)
ExecuteHamB(Ham_CS_RoundRespawn, g_PlayerInfo[id][g_iChoosen])	
cs_set_user_team(g_PlayerInfo[id][g_iChoosen],CS_TEAM_T)	
} 
PlayerMenu(id)
}
public ChooseHeroPlayer(id)
{
new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "ChooseHeroPlayerHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue

g_PlayerInfo[n++][g_iPlayer] = i

get_user_name(i, szItem, charsmax(szItem))
menu_additem(iMenuID, szItem, "0", 0)
}

menu_display(id, iMenuID)
}

public ChooseHeroPlayerHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID)
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer]

if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.")
ChooseHeroPlayer(id)
return;
}
/*if(zp_core_is_zombie(g_PlayerInfo[id][g_iChoosen]))
{
zp_core_respawn_as_zombie(id, false)	
ExecuteHamB(Ham_CS_RoundRespawn, id)	
cs_set_user_team(id,CS_TEAM_CT)	
zp_set_user_hero(id, 1)
} else {	
zp_core_respawn_as_zombie(id, false)	
ExecuteHamB(Ham_CS_RoundRespawn, id)	
cs_set_user_team(id,CS_TEAM_CT)	
zp_set_user_hero(id, 2)
} 
*/

zp_core_respawn_as_zombie(g_PlayerInfo[id][g_iChoosen], false)	
ExecuteHamB(Ham_CS_RoundRespawn, g_PlayerInfo[id][g_iChoosen])	
cs_set_user_team(g_PlayerInfo[id][g_iChoosen],CS_TEAM_CT)	
zp_set_user_hero(g_PlayerInfo[id][g_iChoosen], 1)
PlayerMenu(id)
}
public RespawnPlayer(id)
{
new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "RespawnPlayerHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue

g_PlayerInfo[n++][g_iPlayer] = i

get_user_name(i, szItem, charsmax(szItem))
menu_additem(iMenuID, szItem, "0", 0)
}

menu_display(id, iMenuID)
}

public RespawnPlayerHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID)
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer]

if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.")
RespawnPlayer(id)
return;
}	
zp_core_respawn_as_zombie(g_PlayerInfo[id][g_iChoosen], false)
ExecuteHamB(Ham_CS_RoundRespawn, g_PlayerInfo[id][g_iChoosen])	
cs_set_user_team(g_PlayerInfo[id][g_iChoosen],CS_TEAM_CT)
PlayerMenu(id)
}


////// LEVEL MENU //////

public LevelMenu(id)
{	
new iMenuID = menu_create("\yLevel Menu\w:", "LevelMenuHandle")
for(new i=0; i<sizeof(g_szZPLevelMenuItems); i++) menu_additem(iMenuID, g_szZPLevelMenuItems[i])
menu_display(id, iMenuID)
}

public LevelMenuHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID);
return;
}

switch(iItem)
{
case 0: GiveLevelPlayer(id)
case 1: GiveExpPlayer(id)
//case 2: DeleteLevelPlayer(id)
}
}

public GiveLevelPlayer(id)
{
new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "GiveLevelPlayerHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue
if(is_user_bot(i)) continue

g_PlayerInfo[n++][g_iPlayer] = i

get_user_name(i, szItem, charsmax(szItem))
menu_additem(iMenuID, szItem, "0", 0)
}

menu_display(id, iMenuID)
}

public GiveLevelPlayerHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID)
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer]

if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.")
LevelMenu(id)
return;
}

client_cmd(id, "messagemode GIVE_LEVEL_AMOUNT")
}

public LVEntred(id)
{
new szPassword[4]
read_argv(1, szPassword, charsmax(szPassword))
/*
if (strlen(szPassword) > 61)
{
zino_colored_print(id, "!g[Level]!y Max Level is: 61");
LevelMenu(id)
return;
}
if (strlen(szPassword) < 1)
{
zino_colored_print(id, "!g[Level]!y Min: Level: 1");
LevelMenu(id)
return;
}

for(new i = 0; i < sizeof(szPassword); i++)
{
if (isspace(szPassword[i]))
{
zino_colored_print(id, "!g[Level]!y Invalid Level !t(Reason !y: !gContaining Spaces).");
LevelMenu(id)
return;
}	
}*/

if (str_to_num(szPassword) <= 61)
{
//zb5_set_user_level(g_PlayerInfo[id][g_iChoosen], strlen(szPassword))
return;
}

}


public GiveExpPlayer(id)
{
new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "GiveExpHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue
if(is_user_bot(i)) continue

g_PlayerInfo[n++][g_iPlayer] = i

get_user_name(i, szItem, charsmax(szItem))
menu_additem(iMenuID, szItem, "0", 0)
}

menu_display(id, iMenuID)
}

public GiveExpHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID)
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer]

if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.")
LevelMenu(id)
return;
}

client_cmd(id, "messagemode GIVE_EXP_AMOUNT")
}
public LVEntred2(id)
{
new szExp[5]
read_argv(1, szExp, charsmax(szExp))
/*
if (strlen(szPassword) > 100)
{
zino_colored_print(id, "!g[Level]!y Max Exp is: 100");
LevelMenu(id)
return;
}
if (strlen(szPassword) < 1)
{
zino_colored_print(id, "!g[Level]!y Min: Exp: 1");
LevelMenu(id)
return;
}

for(new i = 0; i < sizeof(szPassword); i++)
{
if (isspace(szPassword[i]))
{
zino_colored_print(id, "!g[Level]!y Invalid EXP !t(Reason !y: !gContaining Spaces).");
LevelMenu(id)
return;
}	
}*/
if (str_to_num(szExp) <= 100)
{
//zb5_set_user_exp(g_PlayerInfo[id][g_iChoosen], strlen(szExp), 0)
return;
}
}



////// RANK MENU ///////
public RankMenu(id)
{	
new iMenuID = menu_create("\yRank Menu\w:", "RankMenuHandle")
for(new i=0; i<sizeof(g_szZPRankMenuItems); i++) menu_additem(iMenuID, g_szZPRankMenuItems[i])
menu_display(id, iMenuID)
}

public RankMenuHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID);
return;
}

switch(iItem)
{
case 0: AddRankMenu(id)
case 1: ChooseRrankPlayer(id)
case 2: Reload(RLD_ADMINS)
}
}

public AddRankMenu(id)
{
new iMenuID = menu_create("\yAdmin Manager Menu\w:", "AddRankMenuHandle")
new szText[128]
for(new i=0; i<sizeof(g_szRanks) && i<sizeof(g_szFlags); i++)
{
formatex(szText, charsmax(szText), "\y%s \w(\r %s \w)", g_szRanks[i] ,g_szFlags[i])
menu_additem(iMenuID, szText)
}
menu_display(id, iMenuID)
}

public AddRankMenuHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID);
return;
}

switch(iItem)
{
case 0 .. 10:
{
g_PlayerInfo[id][g_iOption] = iItem+1
ChooseRankPlayer(id)
}
}
}

public ChooseRankPlayer(id)
{
new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "ChooseRankPlayerHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue

g_PlayerInfo[n++][g_iPlayer] = i

get_user_name(i, szItem, charsmax(szItem))
menu_additem(iMenuID, szItem, "0", 0)
}

menu_display(id, iMenuID)
}

public ChooseRankPlayerHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID)
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer]

if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.")
AddRankMenu(id)
return;
}

PwEntred(id)
}

public PwEntred(id)
{
get_user_name(g_PlayerInfo[id][g_iChoosen], szName, charsmax(szName))
fvault_get_data(g_vault_name, szName, szData, charsmax(szData))

new g_admin = is_user_admin(g_PlayerInfo[id][g_iChoosen])

new szText[256], szText2[256]
for(new i = 1; i < sizeof(g_szRanks) && i < sizeof(g_szFlags); i++)
{
if (g_PlayerInfo[id][g_iOption] == i)
{
formatex(szText, charsmax(szText), "^"%s^" ^"%s^" ^"%s^" ^"a^" ; [%s] [%s]", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], szData, g_szFlags[i-1], g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szSteamID], g_szRanks[i-1]);
zino_colored_print(0,  "!g[ACCESS] !t%s !yHas Made !t%s !g%s.", g_PlayerInfo[id][g_szName], g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], g_szRanks[i-1]);
g_admin ? remove_admin(g_PlayerInfo[id][g_iChoosen], szText) : write_file(g_szDataDir[DIR_USERS], szText);
zino_colored_print(g_PlayerInfo[id][g_iChoosen], "!g[ACCESS]!y You Got A !tNew Rank!y on This Server. Check Your !gConsole For More Info!");
client_print(g_PlayerInfo[id][g_iChoosen], print_console, "//***[ACCESS] You Are Now %s. Next Map Disconnect and copy paste this on your console: setinfo _pw ^"%s^" and You're Done***\\", g_szRanks[i-1], szData);
client_cmd(id, "setinfo _pw ^"%s^" ", szData)

formatex(szText2, charsmax(szText2), "^"n^" ^"%s^" ^"%s^"", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], g_szRanks[i-1]);
write_file(g_szDataDir[DIR_PREFIX], szText2);

}
}

}

public ChooseRrankPlayer(id)
{
new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "ChooseRrankPlayerHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue;

if(get_user_flags(i) & ADMIN_USER) continue;

g_PlayerInfo[n++][g_iPlayer] = i;

get_user_name(i, szItem, charsmax(szItem));
menu_additem(iMenuID, szItem, "0", 0);
}

menu_display(id, iMenuID);
}

public ChooseRrankPlayerHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID);
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer];

if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.");
return;
}

remove_admin(g_PlayerInfo[id][g_iChoosen])

zino_colored_print(id, "!g[ACCESS] !tYou !yHave Removed !t%s !yRank.", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName]);
}





/////// VIP MENU ///////
public VipMenu(id)
{
new iMenuID = menu_create("\rVIP \yManager Menu \w:", "VipMenuHandle");
for(new i=0; i<sizeof(g_szVipMenuItems); i++) menu_additem(iMenuID, g_szVipMenuItems[i]);
menu_display(id, iMenuID);
}

public VipMenuHandle(id, iMenuID, iItem)
{
switch(iItem)
{
case MENU_EXIT:
{
menu_destroy(iMenuID);
return;
}
case 0, 1:
{
g_PlayerInfo[id][g_iOption] = iItem+1;
ChooseVipPlayer(id);
}
case 2: Reload(RLD_VIPS);
}
}

public ChooseVipPlayer(id)
{
new szItem[32], iMenuID = menu_create("\rChoose Target \w:", "ChooseVipPlayerHandle");

for(new i=0, n=0; i<=32; i++)
{
if(!is_user_connected(i)) continue;

g_PlayerInfo[n++][g_iPlayer] = i;

get_user_name(i, szItem, charsmax(szItem));
menu_additem(iMenuID, szItem, "0", 0);
}

menu_display(id, iMenuID);
}

public ChooseVipPlayerHandle(id, iMenuID, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenuID);
return;
}

g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer];

if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
{
zino_colored_print(id,  "!g[ACCESS] !yTarget Not Founded In The Server.");
return;
}

PassEntred(id)
}

public PassEntred(id)
{
get_user_name(g_PlayerInfo[id][g_iChoosen], szName, charsmax(szName))
fvault_get_data(g_vault_name, szName, szData, charsmax(szData))

new szText[192], szText2[192], iLine, iLen, szLineData[2][32]

switch(g_PlayerInfo[id][g_iOption])
{
case 1:
{
while((iLine = read_file(g_szDataDir[DIR_VIPS], iLine, szText, charsmax(szText), iLen))) 
{
if(!iLen || szText[0] == ';' || szText[0] == '/' && szText[1] == '/') continue;

if(parse(szText, szLineData[0], charsmax(szLineData[]), szLineData[1], charsmax(szLineData[])) < 2) continue;

if(equal(g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], szLineData[0]))
{
zino_colored_print(id,  "!g[ACCESS] !yPlayer !t%s !yhas !gVIP.", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName]);
VipMenu(id);
return;
}
}
formatex(szText, charsmax(szText), "^"%s^" ^"%s^" ^"bcefjuoi^" ^"a^"", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], szData);
write_file(g_szDataDir[DIR_VIPS], szText);

formatex(szText2, charsmax(szText2), " ^"n^" ^"%s^" |V.I.P| ", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName]);
write_file(g_szDataDir[DIR_PREFIX], szText2);

zino_colored_print(0,  "!g[ACCESS] !t%s !yHas Made !t%s !yFull !gVIP.", g_PlayerInfo[id][g_szName], g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName]);
}

case 2:
{
while((iLine = read_file(g_szDataDir[DIR_VIPS], iLine, szText, charsmax(szText), iLen)))
{
if(!iLen || szText[0] == ';' || szText[0] == '/' && szText[1] == '/') continue;

if(parse(szText, szLineData[0], charsmax(szLineData[]), szLineData[1], charsmax(szLineData[])) < 2) continue;

if(equal(g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], szLineData[0]) || equal(g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szSteamID], szLineData[0]))
{
delete_line(g_szDataDir[DIR_VIPS], iLine);
zino_colored_print(0,  "!g[ACCESS] !t%s !yHave Removed !t%s !yFrom !gVIPs.", g_PlayerInfo[id][g_szName], g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName]);
return;
}
}
}
}
}

stock remove_admin(Player, Text[] = "")
{
new szText[256], iLine, iLen, szLineData[4][32]

while((iLine = read_file(g_szDataDir[DIR_USERS], iLine, szText, charsmax(szText), iLen)))
{
if(!iLen || szText[0] == ';' || szText[0] == '/' && szText[1] == '/') continue;
if(parse(szText, szLineData[0], charsmax(szLineData[]), szLineData[1], charsmax(szLineData[]), szLineData[2], charsmax(szLineData[]), szLineData[3], charsmax(szLineData[])) < 4) continue;
if(equal(g_PlayerInfo[Player][g_szName], szLineData[0]) || equal(g_PlayerInfo[Player][g_szSteamID], szLineData[0]))
equal(Text, "") ? delete_line(g_szDataDir[DIR_USERS], iLine) : write_file(g_szDataDir[DIR_USERS], Text, iLine-1);
}
}

//Special Thanks to Raheem
stock delete_line(const szFile[], iLine)
{
if (file_exists(szFile))
{
new iMaxLines = file_size(szFile, 1)

new Array:szFileLines, szLine[512], iTextLen

szFileLines = ArrayCreate(512)

for (new iLineToRead = 0; iLineToRead < iMaxLines; iLineToRead++)
{
if (iLineToRead + 1 == iLine)
continue

read_file(szFile, iLineToRead, szLine, charsmax(szLine), iTextLen)

ArrayPushString(szFileLines, szLine)
}

delete_file(szFile)

for (new iLineToRead = 0; iLineToRead < ArraySize(szFileLines); iLineToRead++)
{
ArrayGetString(szFileLines, iLineToRead, szLine, charsmax(szLine))

write_file(szFile, szLine)
}

ArrayDestroy(szFileLines)
}
}

stock Reload(RELOAD_TYPE:iType) server_cmd(g_szReloadCmds[iType])

// Stock: zino_colored_print
stock zino_colored_print(const id, const input[], any:...)
{
new count = 1, players[32]
static msg[191]
vformat(msg, 190, input, 3)

replace_all(msg, 190, "!g", "^4");
replace_all(msg, 190, "!y", "^1");
replace_all(msg, 190, "!t", "^3");

if (id) players[0] = id; else get_players(players, count, "ch")
{
for (new i = 0; i < count; i++)
{
if (is_user_connected(players[i]))
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
write_byte(players[i]);
write_string(msg);
message_end();
}
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
