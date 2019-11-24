#include <amxmodx>
#include <amxmisc>

#define OLD_CONNECTION_QUEUE 10
new g_Names[OLD_CONNECTION_QUEUE][32];
new g_SteamIDs[OLD_CONNECTION_QUEUE][32];
new g_IPs[OLD_CONNECTION_QUEUE][32];
new g_Access[OLD_CONNECTION_QUEUE];
new g_Tracker;
new g_Size;

stock InsertInfo(id)
{

if (g_Size > 0)
{
new ip[32]
new auth[32];

get_user_authid(id, auth, charsmax(auth));
get_user_ip(id, ip, charsmax(ip), 1/*no port*/);

new last = 0;

if (g_Size < sizeof(g_SteamIDs))
{
last = g_Size - 1;
}
else
{
last = g_Tracker - 1;

if (last < 0)
{
last = g_Size - 1;
}
}

if (equal(auth, g_SteamIDs[last]) &&
equal(ip, g_IPs[last])) // need to check ip too, or all the nosteams will while it doesn't work with their illegitimate server
{
get_user_name(id, g_Names[last], charsmax(g_Names[]));
g_Access[last] = get_user_flags(id);

return;
}
}

// Need to insert the entry

new target = 0;  // the slot to save the info at

// Queue is not yet full
if (g_Size < sizeof(g_SteamIDs))
{
target = g_Size;

++g_Size;

}
else
{
target = g_Tracker;

++g_Tracker;
// If we reached the end of the array, then move to the front
if (g_Tracker == sizeof(g_SteamIDs))
{
g_Tracker = 0;
}
}

get_user_authid(id, g_SteamIDs[target], charsmax(g_SteamIDs[]));
get_user_name(id, g_Names[target], charsmax(g_Names[]));
get_user_ip(id, g_IPs[target], charsmax(g_IPs[]), 1/*no port*/);

g_Access[target] = get_user_flags(id);

}
stock GetInfo(i, name[], namesize, auth[], authsize, ip[], ipsize, &access)
{
if (i >= g_Size)
{
abort(AMX_ERR_NATIVE, "GetInfo: Out of bounds (%d:%d)", i, g_Size);
}

new target = (g_Tracker + i) % sizeof(g_SteamIDs);

copy(name, namesize, g_Names[target]);
copy(auth, authsize, g_SteamIDs[target]);
copy(ip,   ipsize,   g_IPs[target]);
access = g_Access[target];

}
public client_disconnect(id)
{
if (!is_user_bot(id))
{
InsertInfo(id);
}
}

public plugin_init()
{
register_concmd("amx_kick", "cmdKick", ADMIN_KICK, "<name or #userid> [reason]")
register_concmd("amx_ban", "cmdBan", ADMIN_BAN, "<name or #userid> <minutes> [reason]")
register_concmd("amx_banip", "cmdBanIP", ADMIN_BAN, "<name or #userid> <minutes> [reason]")
register_concmd("amx_addban", "cmdAddBan", ADMIN_BAN, "<^"authid^" or ip> <minutes> [reason]")
register_concmd("amx_unban", "cmdUnban", ADMIN_BAN, "<^"authid^" or ip>")
register_concmd("amx_slay", "cmdSlay", ADMIN_SLAY, "<name or #userid>")
register_concmd("amx_map", "cmdMap", ADMIN_MAP, "<mapname>")
}
public cmdKick(id, level, cid)
{
if (!cmd_access(id, level, cid, 2))
return PLUGIN_HANDLED

new arg[32]
read_argv(1, arg, 31)
new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

if (!player)
return PLUGIN_HANDLED

new authid[32], authid2[32], name2[32], name[32], userid2, reason[32]

get_user_authid(id, authid, 31)
get_user_authid(player, authid2, 31)
get_user_name(player, name2, 31)
get_user_name(id, name, 31)
userid2 = get_user_userid(player)
read_argv(2, reason, 31)
remove_quotes(reason)

log_amx("Kick: ^"%s<%d><%s><>^" kick ^"%s<%d><%s><>^" (reason ^"%s^")", name, get_user_userid(id), authid, name2, userid2, authid2, reason)

show_activity_key("ADMIN_KICK_1", "ADMIN_KICK_2", name, name2);

if (is_user_bot(player))
server_cmd("kick #%d", userid2)
else
{
if (reason[0])
server_cmd("kick #%d ^"%s^"", userid2, reason)
else
server_cmd("kick #%d", userid2)
}

console_print(id, "[AMXX] Client ^"%s^" kicked", name2)

return PLUGIN_HANDLED
}

public cmdUnban(id, level, cid)
{
if (!cmd_access(id, level, cid, 2))
return PLUGIN_HANDLED

new arg[32], authid[32], name[32]

read_argv(1, arg, 31)

if (contain(arg, ".") != -1)
{
server_cmd("removeip ^"%s^";writeip", arg)
console_print(id, "[ZB5] IP removed", arg)
} else {
server_cmd("removeid %s;writeid", arg)
console_print(id, "[ZB5] AuthID removed !", arg)
}

get_user_name(id, name, 31)

show_activity_key("ADMIN_UNBAN_1", "ADMIN_UNBAN_2", name, arg);

get_user_authid(id, authid, 31)
log_amx("Cmd: ^"%s<%d><%s><>^" unban ^"%s^"", name, get_user_userid(id), authid, arg)

return PLUGIN_HANDLED
}

public cmdAddBan(id, level, cid)
{
if (!cmd_access(id, level, cid, 3, true)) // check for ADMIN_BAN access
{
if (get_user_flags(id) & level) // Getting here means they didn't input enough args
{
return PLUGIN_HANDLED;
}
if (!cmd_access(id, ADMIN_RCON, cid, 3)) // If somehow they have ADMIN_RCON without ADMIN_BAN, continue
{
return PLUGIN_HANDLED;
}
}

new arg[32], authid[32], name[32], minutes[32], reason[32]

read_argv(1, arg, 31)
read_argv(2, minutes, 31)
read_argv(3, reason, 31)


if (!(get_user_flags(id) & ADMIN_RCON))
{
new bool:isip = false;
// Limited access to this command
if (equali(arg, "STEAM_ID_PENDING") ||
equali(arg, "STEAM_ID_LAN") ||
equali(arg, "HLTV") ||
equali(arg, "4294967295") ||
equali(arg, "VALVE_ID_LAN") ||
equali(arg, "VALVE_ID_PENDING"))
{
// Hopefully we never get here, so ML shouldn't be needed
console_print(id, "Cannot ban %s", arg);
return PLUGIN_HANDLED;
}

if (contain(arg, ".") != -1)
{
isip = true;
}

// Scan the disconnection queue
if (isip)
{
new IP[32];
new Name[32];
new dummy[1];
new Access;
for (new i = 0; i < g_Size; i++)
{
GetInfo(i, Name, charsmax(Name), dummy, 0, IP, charsmax(IP), Access);

if (equal(IP, arg))
{
if (Access & ADMIN_IMMUNITY)
{
console_print(id, "[ZB5] %s : Client %s has immunity", IP, id, Name);

return PLUGIN_HANDLED;
}
}
}
}
else
{
new Auth[32];
new Name[32];
new dummy[1];
new Access;
for (new i = 0; i < g_Size; i++)
{
GetInfo(i, Name, charsmax(Name), Auth, charsmax(Auth), dummy, 0, Access);

if (equal(Auth, arg))
{
if (Access & ADMIN_IMMUNITY)
{
console_print(id, "[ZB5] %s : Client %s has immunity", Auth, id, Name);

return PLUGIN_HANDLED;
}
}
}
}

}

// User has access to ban their target
if (contain(arg, ".") != -1)
{
server_cmd("addip ^"%s^" ^"%s^";wait;writeip", minutes, arg)
console_print(id, "[ZB5] Ip ^"%s^" added to ban list", arg)
} else {
server_cmd("banid %s %s;wait;writeid", minutes, arg)
console_print(id, "[ZB5] Authid ^"%s^" added to ban list", arg)
}

get_user_name(id, name, 31)

show_activity_key("ADMIN_ADDBAN_1", "ADMIN_ADDBAN_2", name, arg);

get_user_authid(id, authid, 31)
log_amx("Cmd: ^"%s<%d><%s><>^" ban ^"%s^" (minutes ^"%s^") (reason ^"%s^")", name, get_user_userid(id), authid, arg, minutes, reason)

return PLUGIN_HANDLED
}

public cmdBan(id, level, cid)
{
if (!cmd_access(id, level, cid, 3))
return PLUGIN_HANDLED

new target[32], minutes[8], reason[64]

read_argv(1, target, 31)
read_argv(2, minutes, 7)
read_argv(3, reason, 63)

new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF)

if (!player)
return PLUGIN_HANDLED

new authid[32], name2[32], authid2[32], name[32]
new userid2 = get_user_userid(player)

get_user_authid(player, authid2, 31)
get_user_authid(id, authid, 31)
get_user_name(player, name2, 31)
get_user_name(id, name, 31)

log_amx("Ban: ^"%s<%d><%s><>^" ban and kick ^"%s<%d><%s><>^" (minutes ^"%s^") (reason ^"%s^")", name, get_user_userid(id), authid, name2, userid2, authid2, minutes, reason)

new temp[64], banned[16], nNum = str_to_num(minutes)
if (nNum)
format(temp, 63, "for %s minutes", player, minutes)
else
format(temp, 63, "permanent", player)

format(banned, 15, "banned", player)

if (reason[0])
server_cmd("kick #%d ^"%s (%s %s)^";wait;banid %s %s;wait;writeid", userid2, reason, banned, temp, minutes, authid2)
else
server_cmd("kick #%d ^"%s %s^";wait;banid %s %s;wait;writeid", userid2, banned, temp, minutes, authid2)


// Display the message to all clients

new msg[256];
new len;
new maxpl = get_maxplayers();
for (new i = 1; i <= maxpl; i++)
{
if (is_user_connected(i) && !is_user_bot(i))
{
len = formatex(msg, charsmax(msg), "ban", i);
len += formatex(msg[len], charsmax(msg) - len, " %s ", name2);
if (nNum)
{
len += formatex(msg[len], charsmax(msg) - len, "minutes", i, minutes);
}
else
{
len += formatex(msg[len], charsmax(msg) - len, "permanent", i);
}
if (strlen(reason) > 0)
{
formatex(msg[len], charsmax(msg) - len, " (Reason: %s)", i, reason);
}
show_activity_id(i, id, name, msg);
}
}

console_print(id, "[ZB5] Client Banned %s", name2)

return PLUGIN_HANDLED
}

public cmdBanIP(id, level, cid)
{
if (!cmd_access(id, level, cid, 3))
return PLUGIN_HANDLED

new target[32], minutes[8], reason[64]

read_argv(1, target, 31)
read_argv(2, minutes, 7)
read_argv(3, reason, 63)

new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF)

if (!player)
{
// why is this here?
// no idea
// player = cmd_target(id, target, 9);
return PLUGIN_HANDLED
}

new authid[32], name2[32], authid2[32], name[32]
new userid2 = get_user_userid(player)

get_user_authid(player, authid2, 31)
get_user_authid(id, authid, 31)
get_user_name(player, name2, 31)
get_user_name(id, name, 31)

log_amx("Ban: ^"%s<%d><%s><>^" ban and kick ^"%s<%d><%s><>^" (minutes ^"%s^") (reason ^"%s^")", name, get_user_userid(id), authid, name2, userid2, authid2, minutes, reason)

new temp[64], banned[16], nNum = str_to_num(minutes)
if (nNum)
format(temp, 63, "for %s minutes", player, minutes)
else
format(temp, 63, "permanent", player)
format(banned, 15, "banned", player)

new address[32]
get_user_ip(player, address, 31, 1)

if (reason[0])
server_cmd("kick #%d ^"%s (%s %s)^";wait;addip ^"%s^" ^"%s^";wait;writeip", userid2, reason, banned, temp, minutes, address)
else
server_cmd("kick #%d ^"%s %s^";wait;addip ^"%s^" ^"%s^";wait;writeip", userid2, banned, temp, minutes, address)

// Display the message to all clients

new msg[256];
new len;
new maxpl = get_maxplayers();
for (new i = 1; i <= maxpl; i++)
{
if (is_user_connected(i) && !is_user_bot(i))
{
len = formatex(msg, charsmax(msg), "ban", i);
len += formatex(msg[len], charsmax(msg) - len, " %s ", name2);
if (nNum)
{
formatex(msg[len], charsmax(msg) - len, "for %s minutes", i, minutes);
}
else
{
formatex(msg[len], charsmax(msg) - len, "permanent", i);
}
if (strlen(reason) > 0)
{
formatex(msg[len], charsmax(msg) - len, " (Reason: %s)", i, reason);
}
show_activity_id(i, id, name, msg);
}
}

console_print(id, "[AMXX] Client banned %s", id, name2)

return PLUGIN_HANDLED
}

public cmdSlay(id, level, cid)
{
if (!cmd_access(id, level, cid, 2))
return PLUGIN_HANDLED

new arg[32]

read_argv(1, arg, 31)

new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE)

if (!player)
return PLUGIN_HANDLED

user_kill(player)

new authid[32], name2[32], authid2[32], name[32]

get_user_authid(id, authid, 31)
get_user_name(id, name, 31)
get_user_authid(player, authid2, 31)
get_user_name(player, name2, 31)

log_amx("Cmd: ^"%s<%d><%s><>^" slay ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2)

show_activity_key("ADMIN_SLAY_1", "ADMIN_SLAY_2", name, name2);

console_print(id, "[ZB5] %L", id, "CLIENT_SLAYED", name2)

return PLUGIN_HANDLED
}

public cmdSlap(id, level, cid)
{
if (!cmd_access(id, level, cid, 2))
return PLUGIN_HANDLED

new arg[32]

read_argv(1, arg, 31)
new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE)

if (!player)
return PLUGIN_HANDLED

new spower[32], authid[32], name2[32], authid2[32], name[32]

read_argv(2, spower, 31)

new damage = str_to_num(spower)

user_slap(player, damage)

get_user_authid(id, authid, 31)
get_user_name(id, name, 31)
get_user_authid(player, authid2, 31)
get_user_name(player, name2, 31)

log_amx("Cmd: ^"%s<%d><%s><>^" slap with %d damage ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, damage, name2, get_user_userid(player), authid2)

show_activity_key("ADMIN_SLAP_1", "ADMIN_SLAP_2", name, name2, damage);

console_print(id, "[ZB5] %s slapped with %s dmg", id, name2, damage)

return PLUGIN_HANDLED
}

public chMap(map[])
{
server_cmd("changelevel %s", map)
}

public cmdMap(id, level, cid)
{
if (!cmd_access(id, level, cid, 2))
return PLUGIN_HANDLED

new arg[32]
new arglen = read_argv(1, arg, 31)

if (!is_map_valid(arg))
{
console_print(id, "[ZB5] Not Found", id)
return PLUGIN_HANDLED
}

new authid[32], name[32]

get_user_authid(id, authid, 31)
get_user_name(id, name, 31)

show_activity_key("ADMIN_MAP_1", "ADMIN_MAP_2", name, arg);

log_amx("Cmd: ^"%s<%d><%s><>^" changelevel ^"%s^"", name, get_user_userid(id), authid, arg)

new _modName[10]
get_modname(_modName, 9)

if (!equal(_modName, "zp"))
{
message_begin(MSG_ALL, SVC_INTERMISSION)
message_end()
}

set_task(2.0, "chMap", 0, arg, arglen + 1)

return PLUGIN_HANDLED
}

stock bool:onlyRcon(const name[])
{
new ptr=get_cvar_pointer(name);
if (ptr && get_pcvar_flags(ptr) & FCVAR_PROTECTED)
{
return true;
}
return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
