#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <unixtime>
#include <WPMGPrintChatColor>

#pragma semicolon 1

#define ADMIN_CMD_BAN_ACCESS     ADMIN_KICK
#define ADMIN_CMD_UNBAN_ACCESS   ADMIN_BAN

enum _:ChatBanData
{
cb_ip[32],
cb_name[32],
cb_banexpire,
cb_reason[128],
cb_admin_name[64]
};

enum _:eSettings
{
UCHAT_CHAT_PREF[32],
UCHAT_USER_HUD_MESSAGE_WHEN_UNBAN,
UCHAT_MAX_BAN_TIME,
UCHATBAN_BLOCK_SPEAK,
UCHATBAN_BAN_TIMES,
UCHATBAN_HUD_RED_COLOR,
UCHATBAN_HUD_GREEN_COLOR,
UCHATBAN_HUD_BLUE_COLOR,
Float:UCHATBAN_HUD_X_POS,
Float:UCHATBAN_HUD_Y_POS,
UCHATBAN_EFFECTS,
Float:UCHATBAN_FFXTIME
};

new const g_szClassName[] = "CronBansCheck";

new g_iBanTimesCount, g_iMaxPlayers, g_iMsgHud, g_iChatBanTime, g_iThinker;
new g_szCachedUserName[32], g_szCachedUserIp[32],g_szFileName[128];

new g_pSettings[eSettings];

new Array:g_aBanTimes;
new Trie:g_tChatBanData;

public plugin_init()
{
register_concmd("amx_chatban","cmdChatBan",ADMIN_CMD_BAN_ACCESS,"<nick> <time> [reason]");
register_concmd("amx_unbanchat","cmdUnbanChat",ADMIN_CMD_UNBAN_ACCESS, "<nick>");
register_concmd("amx_chatbanmenu","cmdChatBanMenu",ADMIN_CMD_BAN_ACCESS," - open menu to chatban player/s");
register_concmd("amx_chatbanreason","cmdChatBanReason",ADMIN_CMD_BAN_ACCESS);

register_clcmd("say","HookSay");
register_clcmd("say_team","HookSay");

get_datadir(g_szFileName, sizeof(g_szFileName) - 1);
add(g_szFileName, sizeof(g_szFileName) - 1, "/UChatBan/UChatBan.txt");

g_iMaxPlayers = get_maxplayers();
g_iMsgHud = CreateHudSyncObj();
g_aBanTimes = ArrayCreate(64,1);
g_tChatBanData = TrieCreate();

LoadConfig();
LoadBans();

register_forward(FM_Voice_SetClientListening, "FwdSetVoice");

g_iThinker = create_entity( "info_target" );

if(is_valid_ent(g_iThinker)) {

entity_set_string( g_iThinker, EV_SZ_classname, g_szClassName );
entity_set_float( g_iThinker, EV_FL_nextthink, get_gametime( ) + 0.01 );

register_think( g_szClassName, "FwdThinker" );
}
}

public HookSay(id)
{
new szUsrIp[32], szData[ChatBanData];
new iMonth, iDay, iYear, iHour, iMinute, iSecond;

get_user_ip(id,szUsrIp,charsmax(szUsrIp),1);

if(TrieKeyExists(g_tChatBanData,szUsrIp))
{
TrieGetArray(g_tChatBanData,szUsrIp,szData,charsmax(szData));

UnixToTime(szData[cb_banexpire],iYear,iMonth,iDay,iHour,iMinute,iSecond, UT_TIMEZONE_EET);

PrintChatColor(id, PRINT_COLOR_GREY, "!g[!t%s!g] !yYou are chat !gBANNED!y! !tExpired on: !g%02d/%02d/%02d - %02d:%02d:%02d!y Reason: !g%s",g_pSettings[UCHAT_CHAT_PREF],iDay, iMonth, iYear, iHour, iMinute , iSecond,szData[cb_reason]);
return PLUGIN_HANDLED;
}

return PLUGIN_CONTINUE;

}

public plugin_end()
{
ArrayDestroy(g_aBanTimes);
TrieDestroy(g_tChatBanData);
}

public FwdThinker(iEntity) {

new szName[32],szIp[32],szData[ChatBanData];

for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
{
if(!is_user_connected(iPlayer) || is_user_bot(iPlayer) || is_user_hltv(iPlayer))
continue;

get_user_name(iPlayer,szName,charsmax(szName));
get_user_ip(iPlayer,szIp,charsmax(szIp),1);

if(TrieKeyExists(g_tChatBanData,szIp))
{
TrieGetArray(g_tChatBanData, szIp,szData,charsmax(szData));

if(szData[cb_banexpire] < time())
{
TrieDeleteKey(g_tChatBanData,szIp);
DeleteLineFromFile(szIp);

PrintChatColor(0, PRINT_COLOR_GREY, "!g[!t%s!g] !t%s !ychat ban expired! [Reason: !g%s!y]",g_pSettings[UCHAT_CHAT_PREF], szName,szData[cb_reason]);
}
}
}

entity_set_float(iEntity, EV_FL_nextthink, get_gametime() + 0.01);

}

public FwdSetVoice(receiver, sender, listen)
{	

if(!(1 <= receiver <= g_iMaxPlayers) || !is_user_connected(receiver) || !(1 <= sender <= g_iMaxPlayers) || !is_user_connected(sender))
return FMRES_IGNORED;

new szUserIp[32];

get_user_ip(sender,szUserIp,charsmax(szUserIp),1);

if(g_pSettings[UCHATBAN_BLOCK_SPEAK] && TrieKeyExists(g_tChatBanData,szUserIp))
{
engfunc(EngFunc_SetClientListening, receiver, sender, 0);
return FMRES_SUPERCEDE;
}

return FMRES_IGNORED;
}

public cmdChatBan(id,iLevel,iCid)
{
if(!cmd_access(id,iLevel,iCid,4))
return PLUGIN_HANDLED;

new szTargetName[32], szTargetBanTime[32],szTargetReason[128], szAdminName[32], szTargetIp[32];
new iTempBanTime,iTarget;

read_argv(1,szTargetName,charsmax(szTargetName));
read_argv(2,szTargetBanTime,charsmax(szTargetBanTime));
read_argv(3,szTargetReason,charsmax(szTargetReason));

if(equali(szTargetName,"") || equali(szTargetBanTime,""))
{
console_print(id,"[%s] Usage: amx_chatban <nick> <time> <reason>",g_pSettings[UCHAT_CHAT_PREF]);
return PLUGIN_HANDLED;
}

if(equali(szTargetReason,""))
copy(szTargetReason,charsmax(szTargetReason),"Undefined");

iTempBanTime = str_to_num(szTargetBanTime);

if(g_pSettings[UCHAT_MAX_BAN_TIME] && (!iTempBanTime || iTempBanTime > g_pSettings[UCHAT_MAX_BAN_TIME]))
{
console_print(id,"[%s] ChatBan Time can't be more than %i minutes! :(",g_pSettings[UCHAT_CHAT_PREF], g_pSettings[UCHAT_MAX_BAN_TIME]);
return PLUGIN_HANDLED;
}

iTarget = cmd_target(id,szTargetName,0);

if(!iTarget)
return PLUGIN_HANDLED;

if(get_user_flags(iTarget) & ADMIN_IMMUNITY)
{
console_print(id,"[%s] Player %s has immunity from chatban! :(",g_pSettings[UCHAT_CHAT_PREF], szTargetName);
return PLUGIN_HANDLED;
}

get_user_ip(iTarget,szTargetIp,charsmax(szTargetIp),1);

if(TrieKeyExists(g_tChatBanData,szTargetIp))
{
console_print(id,"[%s] Player %s is already banned from chat! :(",g_pSettings[UCHAT_CHAT_PREF], szTargetName);
return PLUGIN_HANDLED;
}

get_user_name(id,szAdminName,charsmax(szAdminName));

ChatBanPlayer(szTargetIp,szTargetName,iTempBanTime,szTargetReason,szAdminName);

console_print(id,"[%s] Player %s was successfull banned from chat! :)",g_pSettings[UCHAT_CHAT_PREF],szTargetName);

log_amx("[%s] ADMIN %s chat banned %s for %i minutes. Reason: %s",g_pSettings[UCHAT_CHAT_PREF],szAdminName, szTargetName, iTempBanTime,szTargetReason);

return PLUGIN_HANDLED;

}

public cmdUnbanChat(id,iLevel,iCid)
{
if(!cmd_access(id,iLevel,iCid,2))
return PLUGIN_HANDLED;

new szTargetName[32],szTargetIp[32], szAdminName[32], iTarget;

read_argv(1,szTargetName,charsmax(szTargetName));

if(equali(szTargetName,""))
{
console_print(id,"[%s] Usage: amx_unbanchat <nick>",g_pSettings[UCHAT_CHAT_PREF]);
return PLUGIN_HANDLED;
}

iTarget = cmd_target(id,szTargetName,0);

if(!iTarget)
return PLUGIN_HANDLED;

get_user_ip(iTarget,szTargetIp,charsmax(szTargetIp),1);
get_user_name(id,szAdminName,charsmax(szAdminName));

if(TrieKeyExists(g_tChatBanData,szTargetIp))
{
UnbanChatPlayer(szTargetIp, szTargetName,szAdminName);

console_print(id,"[%s] Player ^"%s^" has been successful unbanned! :)",g_pSettings[UCHAT_CHAT_PREF], szTargetName);

log_amx("ADMIN %s unbanned from chat %s!", szAdminName, szTargetName);

}
else
{
console_print(id,"[%s] Player ^"%s^" was not found in database! :(",g_pSettings[UCHAT_CHAT_PREF],szTargetName);
}

return PLUGIN_HANDLED;

}

public cmdChatBanMenu(id,iLevel,iCid)
{
if(!cmd_access(id,iLevel, iCid,1))
return PLUGIN_HANDLED;

new szMenuTitle[200], szItem[64],szName[32], szUserIp[32], szTempID[32], iMenu;
new bool:isAdmin;
new bool:isChatBanned;

formatex(szMenuTitle, sizeof szMenuTitle -1,"\r[UChatBan] \yChoose player to change \rChatBan status\y:");
iMenu = menu_create(szMenuTitle,"handlerChatBanMenu");

for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
{
if(!is_user_connected(iPlayer) || is_user_bot(iPlayer) || is_user_hltv(iPlayer))
continue;

if(get_user_flags(iPlayer) & ADMIN_IMMUNITY)
isAdmin = true;
else
isAdmin = false;

get_user_ip(iPlayer,szUserIp,charsmax(szUserIp),1);

if(TrieKeyExists(g_tChatBanData,szUserIp))
isChatBanned = true;
else 
isChatBanned = false;

get_user_name(iPlayer,szName,charsmax(szName));
num_to_str(iPlayer,szTempID, charsmax(szTempID));

formatex(szItem, sizeof szItem -1,"%s%s %s",(isAdmin ? "\d": "\y"), szName,(isChatBanned ? "\r[Chat BANNED]" : ""));
menu_additem(iMenu,szItem,szTempID,0);
}

menu_setprop(iMenu, MPROP_BACKNAME, "\yBack");
menu_setprop(iMenu, MPROP_NEXTNAME, "\yNext");
menu_setprop(iMenu, MPROP_EXITNAME, "\yClose \rChatBan Menu");

menu_display(id,iMenu,0);

return PLUGIN_HANDLED;
}

public handlerChatBanMenu(id,iMenu, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenu);
return PLUGIN_HANDLED;
}

static data[6], name[64];
static item_access, item_callback;
static iUserID;

menu_item_getinfo(iMenu, iItem, item_access, data, sizeof data -1, name, sizeof name -1, item_callback);
iUserID = str_to_num(data);

new szName[32],szIp[32],szAdminName[32];

get_user_ip(iUserID,szIp,charsmax(szIp),1);
get_user_name(iUserID,szName,charsmax(szName));

if(get_user_flags(iUserID) & ADMIN_IMMUNITY)
{
PrintChatColor(0, PRINT_COLOR_GREY, "!g[!t%s!g] !t%s !y can't chat banned due immunity!",g_pSettings[UCHAT_CHAT_PREF], szName);
return PLUGIN_HANDLED;
}

if(TrieKeyExists(g_tChatBanData,szIp))
{
get_user_name(id,szAdminName,charsmax(szAdminName));

UnbanChatPlayer(szIp,szName,szAdminName);
}
else 
{
copy(g_szCachedUserIp,charsmax(g_szCachedUserIp),szIp);
copy(g_szCachedUserName,charsmax(g_szCachedUserName),szName);
menuBanTimes(id);
}

menu_destroy(iMenu);
return PLUGIN_HANDLED;
}

public menuBanTimes(id)
{		
new iMenu, iBanTimes, szItem[64],szBanTime[32];
iMenu = menu_create("\r[UChatBan] \yChoose BAN time:","handlerBanTimes");

for(new i=0; i < g_iBanTimesCount; i++)
{
iBanTimes = ArrayGetCell(g_aBanTimes,i);

formatex(szItem,charsmax(szItem),"%i minutes",iBanTimes);
num_to_str(iBanTimes,szBanTime,charsmax(szBanTime));

menu_additem(iMenu,szItem,szBanTime);
}

menu_setprop(iMenu, MPROP_BACKNAME, "\yNext");
menu_setprop(iMenu, MPROP_NEXTNAME, "\yPrevious");
menu_setprop(iMenu, MPROP_EXITNAME, "\rClose");

menu_display(id,iMenu,0);

}

public handlerBanTimes(id,iMenu, iItem)
{
if(iItem == MENU_EXIT)
{
menu_destroy(iMenu);
return PLUGIN_HANDLED;
}

new data[6], name[64];
new item_access, item_callback;

menu_item_getinfo(iMenu, iItem, item_access, data, sizeof data -1, name, sizeof name -1, item_callback);
g_iChatBanTime = str_to_num(data);

client_cmd(id, "messagemode amx_chatbanreason");
menu_destroy(iMenu);
return PLUGIN_HANDLED;
}

public cmdChatBanReason(id,iLevel,iCid)
{
if(!cmd_access(id,iLevel,iCid,1))
return PLUGIN_HANDLED;

new szReason[128], szAdminName[64];

get_user_name(id,szAdminName, sizeof szAdminName -1);

read_argv(1,szReason, sizeof szReason -1);

ChatBanPlayer(g_szCachedUserIp,g_szCachedUserName,g_iChatBanTime,szReason,szAdminName);

return PLUGIN_HANDLED;
}

ChatBanPlayer(const szIp[], const szName[], const iBanTime,const szReason[],const szAdminName[])
{
new iTempTime, szFileData[512], szData[ChatBanData];

iTempTime = time()+(iBanTime *60);

formatex(szFileData, sizeof szFileData -1,"^"%s^" ^"%s^" ^"%i^" ^"%s^" ^"%s^"",szIp,szName, iTempTime, szReason, szAdminName);
write_file(g_szFileName,szFileData, -1);

copy(szData[cb_ip],charsmax(szData[cb_ip]), szIp);
copy(szData[cb_name], charsmax(szData[cb_name]), szName);
szData[cb_banexpire] = iTempTime;
copy(szData[cb_reason],charsmax(szData[cb_reason]), szReason);
copy(szData[cb_admin_name],charsmax(szData[cb_admin_name]), szAdminName);

TrieSetArray(g_tChatBanData, szIp, szData, sizeof (szData));

set_hudmessage(g_pSettings[UCHATBAN_HUD_RED_COLOR],g_pSettings[UCHATBAN_HUD_GREEN_COLOR],g_pSettings[UCHATBAN_HUD_BLUE_COLOR],g_pSettings[UCHATBAN_HUD_X_POS],g_pSettings[UCHATBAN_HUD_Y_POS],g_pSettings[UCHATBAN_EFFECTS],g_pSettings[UCHATBAN_FFXTIME],6.0);
ShowSyncHudMsg(0,g_iMsgHud,"[%s] ^n%s has been banned from chat for %i minutes!^nReason: %s ^nBy Admin: %s",g_pSettings[UCHAT_CHAT_PREF],szName,iBanTime,szReason,szAdminName);

}

UnbanChatPlayer(const szIp[], const szPlayerName[], const szAdminNick[])
{
TrieDeleteKey(g_tChatBanData,szIp);
DeleteLineFromFile(szIp);

if(g_pSettings[UCHAT_USER_HUD_MESSAGE_WHEN_UNBAN])
{
set_hudmessage(g_pSettings[UCHATBAN_HUD_RED_COLOR],g_pSettings[UCHATBAN_HUD_GREEN_COLOR],g_pSettings[UCHATBAN_HUD_BLUE_COLOR],g_pSettings[UCHATBAN_HUD_X_POS],g_pSettings[UCHATBAN_HUD_Y_POS],g_pSettings[UCHATBAN_EFFECTS],g_pSettings[UCHATBAN_FFXTIME],6.0);
ShowSyncHudMsg(0,g_iMsgHud,"[%s] ^n%s has been unbanned from chat!^nBy Admin: %s",g_pSettings[UCHAT_CHAT_PREF],szPlayerName,szAdminNick);
}
}

LoadConfig()
{
new szConfigsName[256], szFilename[256],iFilePointer;

get_configsdir(szConfigsName, charsmax(szConfigsName));
formatex(szFilename, charsmax(szFilename), "%s/UChatBan.ini", szConfigsName);

iFilePointer = fopen(szFilename,"rt");

if(!iFilePointer)
return;

new szData[192], szValue[160], szKey[32];

while(!feof(iFilePointer))
{
fgets(iFilePointer, szData,charsmax(szData));		
trim(szData);

if(szData[0] == EOS || szData[0] == ';' || szData[0] == '/' && szData[1] == '/')
continue;

strtok2(szData,szKey,charsmax(szKey),szValue, charsmax(szValue),'=',TRIM_FULL);

if(equal(szKey,"CHAT_PREFIX"))
copy(g_pSettings[UCHAT_CHAT_PREF], charsmax(g_pSettings[UCHAT_CHAT_PREF]),szValue);

else if(equal(szKey,"USER_HUD_MESSAGE_WHEN_UNBAN"))
g_pSettings[UCHAT_USER_HUD_MESSAGE_WHEN_UNBAN] = str_to_num(szValue);

else if(equal(szKey,"MAX_BAN_TIME"))
g_pSettings[UCHAT_MAX_BAN_TIME] = str_to_num(szValue);

else if(equal(szKey,"BLOCK_SPEAK"))
g_pSettings[UCHATBAN_BLOCK_SPEAK] = str_to_num(szValue);

else if(equal(szKey,"BAN_TIMES"))
{
while(strlen(szValue) != 0)
{
new szValue1[32];
strtok2(szValue, szValue1, charsmax(szValue1), szValue, charsmax(szValue), ',', TRIM_FULL);

ArrayPushCell(g_aBanTimes,str_to_num(szValue1));

g_iBanTimesCount++;
}
}

else if(equal(szKey,"HUD_RED_COLOR"))
g_pSettings[UCHATBAN_HUD_RED_COLOR] = str_to_num(szValue);

else if(equal(szKey,"HUD_GREEN_COLOR"))
g_pSettings[UCHATBAN_HUD_GREEN_COLOR] = str_to_num(szValue);

else if(equal(szKey,"HUD_BLUE_COLOR"))
g_pSettings[UCHATBAN_HUD_BLUE_COLOR] = str_to_num(szValue);

else if(equal(szKey,"HUD_X_POS"))
g_pSettings[UCHATBAN_HUD_X_POS] = str_to_float(szValue);

else if(equal(szKey,"HUD_Y_POS"))
g_pSettings[UCHATBAN_HUD_Y_POS] = str_to_float(szValue);

else if(equal(szKey,"HUD_EFFECTS"))
g_pSettings[UCHATBAN_EFFECTS] = str_to_num(szValue);

else if(equal(szKey,"HUD_FFXTIME"))
g_pSettings[UCHATBAN_FFXTIME] = str_to_float(szValue);


}

fclose(iFilePointer);
}

LoadBans()
{
new iFilePointer,szLineData[512], szIp[32],szName[32],szExpire[32],szReason[128],szAdminName[32], szData[ChatBanData];

iFilePointer = fopen(g_szFileName,"rt+");

if(!iFilePointer)
return;

while(!feof(iFilePointer))
{
fgets(iFilePointer,szLineData,charsmax(szLineData));

trim(szLineData);

if(szLineData[0] == EOS || szLineData[0] == ';')
continue;

parse(szLineData, szIp,charsmax(szIp),szName,charsmax(szName),szExpire,charsmax(szExpire), szReason, charsmax(szReason),szAdminName,charsmax(szAdminName));

copy(szData[cb_ip],charsmax(szData[cb_ip]), szIp);
copy(szData[cb_name], charsmax(szData[cb_name]), szName);
szData[cb_banexpire] = str_to_num(szExpire);
copy(szData[cb_reason],charsmax(szData[cb_reason]), szReason);
copy(szData[cb_admin_name],charsmax(szData[cb_admin_name]), szAdminName);

TrieSetArray(g_tChatBanData,szIp,szData,sizeof szData);
}

fclose(iFilePointer);
}

DeleteLineFromFile(const szPlayerIp[])
{
static iFilePointer, szLineItem[512], iLine;

iFilePointer = fopen(g_szFileName,"rt");

if(!iFilePointer)
return;

while(!feof(iFilePointer))
{
fgets(iFilePointer, szLineItem, sizeof szLineItem -1);

if(szLineItem[0] == EOS || szLineItem[0] == ';')
continue;

if(containi(szLineItem, szPlayerIp) != -1)
{
write_file(g_szFileName,"",iLine);
break;
}

iLine++;
}

fclose(iFilePointer);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
