#include <amxmodx> 
#include <amxmisc> 

#define FLAGADMINONE ADMIN_LEVEL_A
#define PREFIXADMINONE "Administrator"

#define FLAGHELP ADMIN_LEVEL_H
#define PREFIXHELP "Help Admin"

#define FLAGADMINSMS ADMIN_LEVEL_G
#define PREFIXADMINSMS "SMS Admin" 

#define FLAGVIPS ADMIN_LEVEL_B
#define PREFIXVIPS "V.I.P" 

#define FLAGAMMO ADMIN_LEVEL_C
#define PREFIXAMMO "AP Boosted" 

new SzMaxPlayers, SzSayText;
public plugin_init()
{
register_clcmd("say", "hook_say");
register_clcmd("say_team", "hook_say_team");
SzSayText = get_user_msgid ("SayText");
SzMaxPlayers = get_maxplayers();
register_message(SzSayText, "MsgDuplicate");
}

public MsgDuplicate(id){ return PLUGIN_HANDLED; }

public hook_say(id)
{
new SzMessages[192], SzName[32];
new SzAlive = is_user_alive(id);
new SzGetFlag = get_user_flags(id);

read_args(SzMessages, 191);
remove_quotes(SzMessages);
get_user_name(id, SzName, 31);

if(!is_valid_msg(SzMessages))
return PLUGIN_CONTINUE;

if(SzGetFlag & FLAGADMINONE)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXADMINONE, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXADMINONE, SzName, SzMessages));
else if(SzGetFlag & FLAGADMINSMS)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXADMINSMS, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXADMINSMS, SzName, SzMessages));
else if(SzGetFlag & FLAGVIPS)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXVIPS, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXVIPS, SzName, SzMessages));
else if(SzGetFlag & FLAGHELP)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXHELP, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXHELP, SzName, SzMessages));
else if(SzGetFlag & FLAGAMMO)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXAMMO, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXAMMO, SzName, SzMessages));
else if(!(SzGetFlag & FLAGADMINONE))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGADMINSMS))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGVIPS))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGHELP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGAMMO))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));

for(new i = 1; i <= SzMaxPlayers; i++)
{
if(!is_user_connected(i))
continue;

if(SzAlive && is_user_alive(i) || !SzAlive && !is_user_alive(i))
{
message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
write_byte(id);
write_string(SzMessages);
message_end();
}
}

return PLUGIN_CONTINUE;
}

public hook_say_team(id){
new SzMessages[192], SzName[32];
new SzAlive = is_user_alive(id);
new SzGetFlag = get_user_flags(id);
new SzGetTeam = get_user_team(id);

read_args(SzMessages, 191);
remove_quotes(SzMessages);
get_user_name(id, SzName, 31);

if(!is_valid_msg(SzMessages))
return PLUGIN_CONTINUE;

if(SzGetFlag & FLAGADMINONE)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXADMINONE, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXADMINONE, SzName, SzMessages));
else if(SzGetFlag & FLAGADMINSMS)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXADMINSMS, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXADMINSMS, SzName, SzMessages));
else if(SzGetFlag & FLAGVIPS)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXVIPS, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXVIPS, SzName, SzMessages));
else if(SzGetFlag & FLAGHELP)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXHELP, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXHELP, SzName, SzMessages));
else if(SzGetFlag & FLAGAMMO)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^4%s", PREFIXAMMO, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^4%s", PREFIXAMMO, SzName, SzMessages));
else if(!(SzGetFlag & FLAGADMINONE))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGADMINSMS))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGVIPS))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGHELP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAGAMMO))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));

for(new i = 1; i <= SzMaxPlayers; i++)
{
if(!is_user_connected(i))
continue;

if(get_user_team(i) != SzGetTeam)
continue;

if(SzAlive && is_user_alive(i) || !SzAlive && !is_user_alive(i))
{
message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
write_byte(id);
write_string(SzMessages);
message_end();
}
}

return PLUGIN_CONTINUE;
}


bool:is_valid_msg(const SzMessages[]){
if( SzMessages[0] == '@'
|| !strlen(SzMessages)){ return false; }
return true;
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
