#include <amxmodx> 
#include <amxmisc> 
#include <ZombieMod5> 

#define FLAG_GENERAL ADMIN_LEVEL_A
#define PREFIX_GENERAL "General Admin"

#define FLAG_HELP ADMIN_LEVEL_H
#define PREFIX_HELP "Help Admin"

#define FLAG_LEADER ADMIN_LEVEL_D
#define PREFIX_LEADER "Leader Admin" 

#define FLAG_VIP ADMIN_LEVEL_B
#define PREFIX_VIP "V.I.P" 

#define FLAG_SUPPORT ADMIN_LEVEL_E
#define PREFIX_SUPPORT "Support" 

#define FLAG_JUNIOR ADMIN_LEVEL_C
#define PREFIX_JUNIOR "Junior Admin" 

#define FLAG_ADMIN ADMIN_CHAT
#define PREFIX_ADMIN "Admin" 

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

if(SzGetFlag & FLAG_GENERAL)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_GENERAL, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_GENERAL, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_HELP)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_HELP, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_HELP, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_LEADER)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_LEADER, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_LEADER, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_JUNIOR)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_JUNIOR, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_JUNIOR, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_SUPPORT)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_SUPPORT, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_SUPPORT, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_VIP)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_VIP, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_VIP, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_ADMIN)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_ADMIN, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_ADMIN, zb5_get_user_level(id), SzName, SzMessages));

else if(!(SzGetFlag & FLAG_GENERAL))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_HELP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD*  ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_LEADER))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_JUNIOR))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_SUPPORT))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD*  ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_VIP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_ADMIN))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));

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

if(SzGetFlag & FLAG_GENERAL)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_GENERAL, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_GENERAL, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_HELP)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_HELP, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_HELP, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_LEADER)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_LEADER, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_LEADER, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_JUNIOR)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_JUNIOR, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_JUNIOR, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_SUPPORT)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_SUPPORT, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_SUPPORT, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_VIP)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_VIP, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_VIP, zb5_get_user_level(id), SzName, SzMessages));
else if(SzGetFlag & FLAG_ADMIN)(SzAlive ? format(SzMessages, 191, "^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_ADMIN, zb5_get_user_level(id), SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s | LV: %i] ^3%s : ^4%s", PREFIX_ADMIN, zb5_get_user_level(id), SzName, SzMessages));

else if(!(SzGetFlag & FLAG_GENERAL))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_HELP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD*  ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_LEADER))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_JUNIOR))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_SUPPORT))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD*  ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_VIP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));
else if(!(SzGetFlag & FLAG_ADMIN))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1%s : ^1%s", SzName, SzMessages));

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
