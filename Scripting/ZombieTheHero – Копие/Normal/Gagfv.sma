#include <amxmodx> 
#include <amxmisc> 
#include <engine> 
#include <unixtime> 
#include <fvault> 

#pragma semicolon 0 

new MsgHudSync, SayText, iTime; 
new iCacheUserName[34], bool:iUserGaGed[33]; 
new iCacheAdmName[34], iCacheUserIp[18]; 
new iMaxGagTime, iFlagGagTime; 

new const g_vault_name[] = "GagSystem";
public plugin_init() 
{ 
iMaxGagTime = register_cvar("amx_maxgag_time", "20"); 
iFlagGagTime = register_cvar("amx_maxgag_flag", "d"); 

register_concmd("amx_gag", "cmdGag", ADMIN_RESERVATION, "<name> <time> [reason]"); 
register_concmd("amx_ungag", "cmdUnGag", ADMIN_RESERVATION, "<ip>"); 
register_concmd("amx_gagmenu", "cmdGagMenu", ADMIN_RESERVATION); 
register_concmd("amx_gagreason", "cmdGagReason", ADMIN_RESERVATION); 
register_concmd("amx_gag_clean", "cmdCleanTable", ADMIN_RCON); 

register_concmd("say", "cmdSayChat", -1); 
register_concmd("say_team", "cmdSayChat", -1); 

MsgHudSync   = CreateHudSyncObj(); 
SayText    = get_user_msgid("SayText"); 
} 

public cmdGag(id, level, cid) 
{ 
if(!cmd_access(id, level, cid, 3)) 
{ 
return PLUGIN_HANDLED; 
} 

new iArg[32], iTime[5], iReason[129]; 
read_argv(1, iArg, sizeof iArg - 1); 
read_argv(2, iTime, sizeof iTime - 1); 
read_argv(3, iReason, sizeof iReason - 1); 

new AdminName[33];  
get_user_name(id, AdminName, sizeof AdminName - 1); 

new iPlayer = cmd_target(id, iArg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF); 
new iGetTime = str_to_num(iTime); 

new PlayerIp[18]; 
get_user_ip(iPlayer, PlayerIp, sizeof PlayerIp - 1, 1); 

if(!iPlayer) 
{ 
client_print(id, print_console, "Cannot find player %s", iArg); 
} else { 
new iGetCvar[16]; 
get_pcvar_string(iFlagGagTime, iGetCvar, sizeof iGetCvar - 1); 
if(iGetTime > get_pcvar_num(iMaxGagTime)) 
{ 
if(!(get_user_flags(id) & read_flags(iGetCvar))) 
{ 
client_print(id, print_console, "You have no right to gag more than %d minutes", get_pcvar_num(iMaxGagTime)); 
return PLUGIN_HANDLED; 
} 
} 
GagPlayer(id, iArg, PlayerIp, iGetTime, iReason, AdminName); 
} 

return PLUGIN_HANDLED; 
} 

public cmdUnGag(id, level, cid) 
{ 
if(!cmd_access(id, level, cid, 1)) 
{ 
return PLUGIN_HANDLED; 
} 

new PlayerIp[33]; 
read_argv(1, PlayerIp, sizeof PlayerIp - 1); 
UnGagPlayer(id, PlayerIp); 

return PLUGIN_HANDLED; 
} 

public cmdCleanTable(id, level, cid) 
{ 
if(!cmd_access(id, level, cid, 1)) 
{ 
return PLUGIN_HANDLED; 
} 

TruncateTableMenu(id); 
return PLUGIN_HANDLED; 
} 

public TruncateTableMenu(id) 
{ 
new iMenu = menu_create("\wAre you sure you want to empty database?", "TruncateTableMenuFunc"); 
menu_additem(iMenu, "\rYes", "1", 0); 
menu_additem(iMenu, "\rNo", "2", 0); 
menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL); 
menu_display(id, iMenu, 0); 
} 

public TruncateTableMenuFunc(id, iMenu, Item) 
{ 
if(Item == MENU_EXIT) 
{ 
menu_destroy(iMenu); 
return PLUGIN_HANDLED; 
} 

new iData[6], iName[64]; 
new access, callback; 

menu_item_getinfo(iMenu, Item, access, iData, charsmax(iData), iName, sizeof iName - 1, callback); 

new iKey = str_to_num(iData); 

switch(iKey) 
{ 
case 1: 
{ 
if(fvault_prune(g_vault_name, 0, time()) ) { 
Gaged(id, "^4The table was cleared ^3successfully^1!"); 
} 
else { 
Gaged(id, "^4There was a problem, the table is not cleared^4!"); 
} 

} 
case 2: 
{ 
return PLUGIN_CONTINUE; 
} 
} 

menu_destroy(iMenu); 
return PLUGIN_HANDLED; 
} 

public cmdSayChat(id) 
{ 
new iGetUserIp[18]; 
get_user_ip(id, iGetUserIp, sizeof iGetUserIp - 1, 1); 
CheckGagedPlayer(id, iGetUserIp); 

if(iUserGaGed[id]) 
{ 
return PLUGIN_HANDLED; 
} 

return PLUGIN_CONTINUE; 
} 

public client_PreThink(id) 
{ 
if(is_user_connected(id)) 
{ 
if(iUserGaGed[id]) 
{ 
set_speak(id, SPEAK_MUTED); 
} else { 
set_speak(id, SPEAK_NORMAL); 
} 
} 
} 

public client_connect(id) 
{ 
iUserGaGed[id] = false; 
} 

public client_disconnected(id) 
{ 
iUserGaGed[id] = false; 
} 

public cmdGagMenu(id, level, cid) 
{ 
if(!cmd_access(id, level, cid, 1)) 
return PLUGIN_HANDLED; 

new iMenu = menu_create("\rGag Menu:", "cmdGagMenuFunc"); 
new iPlayers[32], iNum, iTarget; 
new UserName[34], szTempID[10]; 
get_players(iPlayers, iNum); 
for(new i; i < iNum; i++) 
{ 
iTarget = iPlayers[i]; 
get_user_name(iTarget, UserName, sizeof UserName - 1); 
num_to_str(iTarget, szTempID, charsmax(szTempID)); 
menu_additem(iMenu, UserName, szTempID, _, menu_makecallback("GagMenuPlayers")); 
} 

menu_display(id, iMenu, 0); 
return PLUGIN_HANDLED; 
} 

public GagMenuPlayers(iClient, iMenu, Item) 
{ 
new iAccess, Info[3], iCallback; 
menu_item_getinfo(iMenu, Item, iAccess, Info, sizeof Info - 1, _, _, iCallback); 

new iGetID = str_to_num(Info); 

if(access(iGetID, ADMIN_IMMUNITY)) 
{ 
return ITEM_DISABLED; 
}  

if(iUserGaGed[iGetID]) 
{ 
return ITEM_DISABLED; 
} 

return ITEM_ENABLED; 
} 

public cmdGagMenuFunc(id, iMenu, Item) 
{ 
if(Item == MENU_EXIT) 
{ 
menu_destroy(iMenu); 
return PLUGIN_HANDLED; 
} 

new iData[6], iName[64]; 
new access, callback; 
menu_item_getinfo(iMenu, Item, access, iData, charsmax(iData), iName, charsmax(iName), callback); 

new iTarget = str_to_num(iData); 
get_user_name(iTarget, iCacheUserName, sizeof iCacheUserName - 1); 
get_user_name(id, iCacheAdmName, sizeof iCacheAdmName - 1); 
get_user_ip(iTarget, iCacheUserIp, sizeof iCacheUserIp - 1, 1); 
cmdGagMenuTime(id); 
menu_destroy(iMenu); 
return PLUGIN_HANDLED; 
} 

public cmdGagMenuTime(id) 
{ 
new iMenu = menu_create("\wSelect minutes?", "cmdGagMenuTimeFunc"); 
menu_additem(iMenu, "\y1 minute", "1"); 
menu_additem(iMenu, "\y5 minutes", "5"); 
menu_additem(iMenu, "\y10 minutes", "10"); 
menu_additem(iMenu, "\y15 minutes", "15"); 
menu_additem(iMenu, "\y20 minutes", "20"); 
menu_additem(iMenu, "\rPERMANENT", "99999999"); 
menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL); 
menu_display(id, iMenu, 0); 
} 

public cmdGagMenuTimeFunc(id, iMenu, Item) 
{ 
if(Item == MENU_EXIT) 
{ 
menu_destroy(iMenu); 
return PLUGIN_HANDLED; 
} 
new iData[6]; 
new access, callback; 
menu_item_getinfo(iMenu, Item, access, iData, sizeof iData - 1, _, _, callback); 
iTime = str_to_num(iData); 
client_cmd(id, "messagemode amx_gagreason"); 
menu_destroy(iMenu); 
return PLUGIN_HANDLED; 
} 

public cmdGagReason(id, level, cid) 
{ 
if(!cmd_access(id, level, cid, 1)) 
return PLUGIN_HANDLED; 

new iReason[64]; 
read_argv(1, iReason, sizeof iReason - 1); 
GagPlayer(id, iCacheUserName, iCacheUserIp, iTime, iReason, iCacheAdmName); 
return PLUGIN_HANDLED; 
} 

stock GagPlayer(id, const iPlayer[], const PlayerIp[], iTime, const iReason[], const iAdminName[]) 
{ 
new ExpireData = time() + (iTime * 60); 
new vaultkey[40], vaultdata[512]; 
formatex(vaultkey, sizeof vaultkey-1, "[user]%s", PlayerIp); 
new szIp[32]; 
if(!fvault_get_data(g_vault_name, vaultkey, szIp, sizeof szIp-1))  { 
formatex(vaultdata, sizeof vaultdata-1, "^"%s^"#^"%s^"#%i#^"%s^"", iPlayer, iReason, ExpireData, iAdminName); 
fvault_set_data(g_vault_name, vaultkey, vaultdata)

client_print(id, print_console, "Player is gaged successfully!"); 
switch(get_cvar_num("amx_show_activity")) { 
case 1: 
{ 
set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 12.0, 0.1, 0.2, 12); 
ShowSyncHudMsg(0, MsgHudSync, "%s has been gaged. ^nReason: %s", iPlayer, iReason); 
} 
case 2: 
{ 
set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 12.0, 0.1, 0.2, 12); 
ShowSyncHudMsg(0, MsgHudSync, "%s has been gaged. ^nReason: %s ^nBy admin %s", iPlayer, iReason, iAdminName); 
} 
} 
} 
else { 
client_print(id, print_console, "User ^"%s^" is already gaged", iPlayer); 
} 
} 

stock UnGagPlayer(id, const PlayerIp[]) 
{ 
new vaultkey[40] 
formatex(vaultkey, sizeof vaultkey-1, "[user]%s", PlayerIp); 
new szIp[32]; 
if(!fvault_get_data(g_vault_name, vaultkey, szIp, sizeof szIp-1)) 
{ 
client_print(id, print_console, "No user with that ipaddres in the database!"); 
} 
else { 
fvault_remove_key(g_vault_name, vaultkey)
client_print(id, print_console, "Gag has been removed successfully!"); 
} 
} 

stock CheckGagedPlayer(id, const iPlayerIP[]) 
{ 
new vaultkey[40], vaultdata[512]; 
formatex(vaultkey, sizeof vaultkey-1, "[user]%s", iPlayerIP); 

if(!fvault_get_data(g_vault_name, vaultkey, vaultdata, sizeof vaultdata-1)) { 
iUserGaGed[id] = false; 
} 
else { 
new szPlayerName[32], szReason[64], szExpireDate[32], szAdminName[32]; 
replace_all(vaultdata, sizeof vaultdata-1, "#", " ") 
parse(vaultdata, szPlayerName, sizeof szPlayerName-1, szReason, sizeof szReason-1, szExpireDate, sizeof szExpireDate-1, szAdminName, sizeof szAdminName-1) 
if(time() < str_to_num(szExpireDate) || str_to_num(szExpireDate) == 0) { 
new iGagChat[512], iMonth, iDay, iYear, iHour, iMinute, iSecond; 
new iUnixTime = str_to_num(szExpireDate); 
UnixToTime(iUnixTime , iYear , iMonth , iDay , iHour , iMinute , iSecond, UT_TIMEZONE_EET); 
formatex(iGagChat, sizeof iGagChat - 1, "^4You are gaged^1! Your gag will expire on: ^3%02d/%02d/%02d - %02d:%02d:%02d ^1: Reason: ^4%s", iDay, iMonth, iYear, iHour, iMinute , iSecond, szReason); 
Gaged(id, "%s", iGagChat); 
iUserGaGed[id] = true; 
} 
else { 
fvault_remove_key(g_vault_name, vaultkey)
iUserGaGed[id] = false; 
} 
} 
} 

stock Gaged(const id, const input[], any:...) 
{ 
new count = 1, players[32]; 
static msg[191]; 
vformat(msg, 190, input, 3); 
if (id) players[0] = id; else get_players(players, count, "ch"); 
{ 
for (new i = 0; i < count; i++) 
{ 
if (is_user_connected(players[i])) 
{ 
message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i]) ;  
write_byte(players[i]); 
write_string(msg); 
message_end(); 
} 
} 
} 
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
