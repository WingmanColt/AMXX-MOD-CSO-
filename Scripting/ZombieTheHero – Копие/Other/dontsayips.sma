#include <amxmodx>
#include <regex>

#define PATTERN				"(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" // \b
#define REASON				"IP advertising"
#define CVAR_BANMINUTES		"ip_banminutes"
#define CVAR_BANVIOLATORS	"ip_banviolators"

// Globals below
new Regex:g_result
new g_returnvalue
new g_error[64]
new g_allArgs[1024]

public hook_say(id, level, cid) {
read_args(g_allArgs, 1023)
g_result = regex_match(g_allArgs, PATTERN, g_returnvalue, g_error, 63)
switch (g_result) {
case REGEX_MATCH_FAIL: {
log_amx("REGEX_MATCH_FAIL! %s", g_error)
return PLUGIN_CONTINUE
}
case REGEX_PATTERN_FAIL: {
log_amx("REGEX_PATTERN_FAIL! %s", g_error)
return PLUGIN_CONTINUE
}
case REGEX_NO_MATCH: {
return PLUGIN_CONTINUE
}
default: {
if (get_cvar_num(CVAR_BANVIOLATORS)) {
new userid = get_user_userid(id)
new minutesString[10]
get_cvar_string(CVAR_BANMINUTES, minutesString, 9)
new temp[64], banned[16], minutes = get_cvar_num(CVAR_BANMINUTES)

if (minutes)
format(temp, 63, "%L", id, "FOR_MIN", minutesString)
else
format(temp, 63, "%L", id, "PERM")

format(banned, 15, "%L", id, "BANNED")

new authid[32]
get_user_authid(id, authid, 31)

new name[32]
get_user_name(id, name, 31)
log_amx("%s (%s), %s %s because of advertising an IP address. This was written: ^"%s^"", name, authid, banned, temp, g_allArgs)

server_cmd("kick #%d ^"%s (%s %s)^";wait;banid ^"%d^" ^"%s^";wait;writeid", userid, REASON, banned, temp, minutes, authid)				
}
else {
client_cmd(id, "say ^"I must say.... This server ROCKS!^"")
}
regex_free(g_result)
return PLUGIN_HANDLED // block msg
}
}

return PLUGIN_CONTINUE
}



public plugin_init() 
{
register_clcmd("say", "hook_say")
register_cvar(CVAR_BANVIOLATORS, "0")
register_cvar(CVAR_BANMINUTES, "30")

register_dictionary("admincmd.txt")
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
