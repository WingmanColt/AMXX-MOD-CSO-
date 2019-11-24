#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#include <cstrike>

#define FLAG_LOAD ADMIN_CFG
#define MAX_PREFIXES 33

new g_listen, g_listen_flag, g_custom, g_custom_flag, g_say_characters, g_prefix_characters;
new pre_ips_count = 0, pre_names_count = 0, pre_steamids_count, pre_flags_count = 0, i, temp_cvar[2];
new configs_dir[64], file_prefixes[128], text[128], prefix[32], type[2], key[32], length, line = 0, error[256];
new g_saytxt, g_maxplayers, CsTeams:g_team;
new g_typed[192], g_message[192], g_name[32];
new Trie:pre_ips_collect, Trie:pre_names_collect, Trie:pre_steamids_collect, Trie:pre_flags_collect, Trie:client_prefix;
new str_id[16], temp_key[35], temp_prefix[32]
new bool:g_toggle[33];

new const say_team_info[2][CsTeams][] =
{
{"*SPEC* ", "*DEAD* ", "*DEAD* ", "*SPEC* "},
{"", "", "", ""}
}

new const sayteam_team_info[2][CsTeams][] =
{
{"(Spectator) ", "*DEAD*(Terrorist) ", "*DEAD*(Counter-Terrorist) ", "(Spectator) "},
{"(Spectator) ", "(Terrorist) ", "(Counter-Terrorist) ", "(Spectator) "}
}

new const forbidden_say_symbols[] = {
"/",
"!",
"%",
"$"
}

new const forbidden_prefixes_symbols[] = {
"/",
"\",
"%",
"$",
".",
":",
"?",
"!",
"@",
"#",
"%"
}

new const in_prefix[] = "[ZB5]"

public plugin_init()
{
g_listen = register_cvar("ap_listen", "0")
g_listen_flag = register_cvar("ap_listen_flag", "a")
g_custom = register_cvar("ap_custom_current", "0")
g_custom_flag = register_cvar("ap_custom_current_flag", "b")
g_say_characters = register_cvar("ap_say_characters", "1")
g_prefix_characters = register_cvar("ap_prefix_characters", "1")

g_saytxt = get_user_msgid ("SayText")
g_maxplayers = get_maxplayers()

register_concmd("ap_reload_prefixes", "LoadPrefixes")
register_concmd("ap_put", "SetPlayerPrefix")
register_clcmd("say", "HookSay")
register_clcmd("say_team", "HookSayTeam")

pre_ips_collect = TrieCreate()
pre_names_collect = TrieCreate()
pre_steamids_collect = TrieCreate()
pre_flags_collect = TrieCreate()
client_prefix = TrieCreate()

register_dictionary("admin_prefixes.txt")

get_configsdir(configs_dir, charsmax(configs_dir))
formatex(file_prefixes, charsmax(file_prefixes), "%s/ap_prefixes.ini", configs_dir)

LoadPrefixes(0)
}

public LoadPrefixes(id)
{
TrieClear(pre_ips_collect)
TrieClear(pre_names_collect)
TrieClear(pre_steamids_collect)
TrieClear(pre_flags_collect)

line = 0, length = 0, pre_flags_count = 0, pre_ips_count = 0, pre_names_count = 0;

if(!file_exists(file_prefixes)) 
{
formatex(error, charsmax(error), "%L", LANG_SERVER, "PREFIX_NOT_FOUND", in_prefix, file_prefixes)
set_fail_state(error)
}

while(read_file(file_prefixes, line++ , text, charsmax(text), length) && (pre_ips_count + pre_names_count + pre_steamids_count + pre_flags_count) <= MAX_PREFIXES)
{
if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
continue

parse(text, type, charsmax(type), key, charsmax(key), prefix, charsmax(prefix))
trim(prefix)

if(!type[0] || !prefix[0] || !key[0])
continue

replace_all(prefix, charsmax(prefix), "!g", "^x04")
replace_all(prefix, charsmax(prefix), "!t", "^x03")
replace_all(prefix, charsmax(prefix), "!n", "^x01")

switch(type[0])
{
case 'f':
{
pre_flags_count++
TrieSetString(pre_flags_collect, key, prefix)
}
case 'i':
{
pre_ips_count++
TrieSetString(pre_ips_collect, key, prefix)
}
case 's':
{
pre_steamids_count++
TrieSetString(pre_steamids_collect, key, prefix)
}
case 'n':
{
pre_names_count++
TrieSetString(pre_names_collect, key, prefix)
}
default:
{
continue
}
}
}
for(new i = 1; i <= g_maxplayers; i++)
{
num_to_str(i, str_id, charsmax(str_id))
TrieDeleteKey(client_prefix, str_id)
PutPrefix(i)
}

return PLUGIN_HANDLED
}
public client_putinserver(id)
{
g_toggle[id] = true
num_to_str(id, str_id, charsmax(str_id))
TrieSetString(client_prefix, str_id, "")
PutPrefix(id)
}

public HookSay(id)
{
read_args(g_typed, charsmax(g_typed))
remove_quotes(g_typed)

trim(g_typed)

if(equal(g_typed, "") || !is_user_connected(id))
return PLUGIN_HANDLED_MAIN

if(equal(g_typed, "/prefix"))
{
if(g_toggle[id])
{
g_toggle[id] = false
client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_OFF", in_prefix)
}
else
{
g_toggle[id] = true
client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_ON", in_prefix)
}

return PLUGIN_HANDLED_MAIN
}

if(!g_toggle[id])
return PLUGIN_CONTINUE

num_to_str(id, str_id, charsmax(str_id))

if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 2) || get_pcvar_num(g_say_characters) == 3)
{
if(check_say_characters(g_typed))
return PLUGIN_HANDLED_MAIN
}

get_user_name(id, g_name, charsmax(g_name))

g_team = cs_get_user_team(id)

if(temp_prefix[0])
{
formatex(g_message, charsmax(g_message), "^1%s^4%s^3 %s :^4 %s", say_team_info[is_user_alive(id)][g_team], temp_prefix, g_name, g_typed)
}
else
{
formatex(g_message, charsmax(g_message), "^1%s^3%s :^1 %s", say_team_info[is_user_alive(id)][g_team], g_name, g_typed)
}

get_pcvar_string(g_listen_flag, temp_cvar, charsmax(temp_cvar))

for(new i = 1; i <= g_maxplayers; i++)
{
if(!is_user_connected(i))
continue

if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(g_listen) && get_user_flags(i) & read_flags(temp_cvar))
{
send_message(g_message, id, i)
}
}

return PLUGIN_HANDLED_MAIN
}

public HookSayTeam(id)
{
read_args(g_typed, charsmax(g_typed))
remove_quotes(g_typed)

trim(g_typed)

if(equal(g_typed, "") || !is_user_connected(id))
return PLUGIN_HANDLED_MAIN

if(equal(g_typed, "/prefix"))
{
if(g_toggle[id])
{
g_toggle[id] = false
client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_OFF", in_prefix)
}
else
{
g_toggle[id] = true
client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_ON", in_prefix)
}

return PLUGIN_HANDLED_MAIN
}

if(!g_toggle[id])
return PLUGIN_CONTINUE

num_to_str(id, str_id, charsmax(str_id))

if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 2) || get_pcvar_num(g_say_characters) == 3)
{
if(check_say_characters(g_typed))
return PLUGIN_HANDLED_MAIN
}

get_user_name(id, g_name, charsmax(g_name))

g_team = cs_get_user_team(id)

if(temp_prefix[0])
{
formatex(g_message, charsmax(g_message), "^1%s^4%s^3 %s :^4 %s", sayteam_team_info[is_user_alive(id)][g_team], temp_prefix, g_name, g_typed)
}
else
{
formatex(g_message, charsmax(g_message), "^1%s^3%s :^1 %s", sayteam_team_info[is_user_alive(id)][g_team], g_name, g_typed)
}

get_pcvar_string(g_listen_flag, temp_cvar, charsmax(temp_cvar))

for(new i = 1; i <= g_maxplayers; i++)
{
if(!is_user_connected(i))
continue

if(get_user_team(id) == get_user_team(i) || get_pcvar_num(g_listen) && get_user_flags(i) & read_flags(temp_cvar))
{
if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(g_listen) && get_user_flags(i) & read_flags(temp_cvar))
{
send_message(g_message, id, i)
}
}
}

return PLUGIN_HANDLED_MAIN
}

public SetPlayerPrefix(id)
{
if(!get_pcvar_num(g_custom) || !get_pcvar_string(g_custom_flag, temp_cvar, charsmax(temp_cvar)))
{
console_print(id, "%L", LANG_SERVER, "CUSTOM_OFF", in_prefix)
return PLUGIN_HANDLED
}

if(!(get_user_flags(id) & read_flags(temp_cvar)))
{
console_print(id, "%L", LANG_SERVER, "CUSTOM_PERMISSION", in_prefix)
return PLUGIN_HANDLED
}

new input[128], target;
new arg_type[2], arg_prefix[32], arg_key[35];
new temp_str[16];

read_args(input, charsmax(input))
remove_quotes(input)
parse(input, arg_type, charsmax(arg_type), arg_key, charsmax(arg_key), arg_prefix, charsmax(arg_prefix))
trim(arg_prefix)

if(get_pcvar_num(g_prefix_characters) && check_prefix_characters(arg_prefix))
{
console_print(id, "%L", LANG_SERVER, "CUSTOM_SYMBOL", in_prefix, arg_prefix, forbidden_prefixes_symbols[i])
return PLUGIN_HANDLED
}

switch(arg_type[0])
{
case 'f':
{
target = 0
temp_str = "Flag"
}
case 'i':
{
target = find_player("d", arg_key)
temp_str = "IP"
}
case 's':
{
target = find_player("c", arg_key)
temp_str = "SteamID"
}
case 'n':
{
target = find_player("a", arg_key)
temp_str = "Name"
}
default:
{
console_print(id, "%L", LANG_SERVER, "CUSTOM_INVALID", in_prefix, arg_type)
return PLUGIN_HANDLED
}
}

get_user_name(id, g_name, charsmax(g_name))

if(equali(arg_prefix, ""))
{
find_and_delete(arg_type, arg_key)

if(target)
{
PutPrefix(target)
}

console_print(id, "%L", LANG_SERVER, "CUSTOM_REMOVE", in_prefix, temp_str, arg_key)
server_print("%L", LANG_SERVER, "CUSTOM_REMOVE_INFO", in_prefix, g_name, temp_str, arg_key)
return PLUGIN_HANDLED
}

find_and_delete(arg_type, arg_key)

formatex(text, charsmax(text), "^"%s^" ^"%s^" ^"%s^"", arg_type, arg_key, arg_prefix)
write_file(file_prefixes, text, -1)

switch(arg_type[0])
{
case 'f':
{
TrieSetString(pre_flags_collect, arg_key, arg_prefix)
}
case 'i':
{
TrieSetString(pre_ips_collect, arg_key, arg_prefix)
}
case 's':
{
TrieSetString(pre_steamids_collect, arg_key, arg_prefix)
}
case 'n':
{
TrieSetString(pre_names_collect, arg_key, arg_prefix)
}
}

if(target)
{
num_to_str(target, str_id, charsmax(str_id))
TrieSetString(client_prefix, str_id, arg_prefix)
}

console_print(id, "%L", LANG_SERVER, "CUSTOM_CHANGE", in_prefix, temp_str, arg_key, arg_prefix)
server_print("%L", LANG_SERVER, "CUSTOM_CHANGE_INFO", in_prefix, g_name, temp_str, arg_key, arg_prefix) 

return PLUGIN_HANDLED
}

public client_infochanged(id)
{
if(!is_user_connected(id))
return PLUGIN_CONTINUE

new g_old_name[32];

get_user_info(id, "name", g_name, charsmax(g_name))
get_user_name(id, g_old_name, charsmax(g_old_name))

if(!equal(g_name, g_old_name))
{
num_to_str(id, str_id, charsmax(str_id))
TrieSetString(client_prefix, str_id, "")
set_task(0.5, "PutPrefix", id)
return PLUGIN_HANDLED
}

return PLUGIN_CONTINUE
}

public PutPrefix(id)
{
num_to_str(id, str_id, charsmax(str_id))
TrieSetString(client_prefix, str_id, "")

new sflags[32], temp_flag[2];
get_flags(get_user_flags(id), sflags, charsmax(sflags))

for(new i = 0; i <= charsmax(sflags); i++)
{
formatex(temp_flag, charsmax(temp_flag), "%c", sflags[i])

if(TrieGetString(pre_flags_collect, temp_flag, temp_prefix, charsmax(temp_prefix)))
{
TrieSetString(client_prefix, str_id, temp_prefix)
}
}

get_user_ip(id, temp_key, charsmax(temp_key), 1)

if(TrieGetString(pre_ips_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
{
TrieSetString(client_prefix, str_id, temp_prefix)
}

get_user_authid(id, temp_key, charsmax(temp_key))

if(TrieGetString(pre_steamids_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
{
TrieSetString(client_prefix, str_id, temp_prefix)
}

get_user_name(id, temp_key, charsmax(temp_key))

if(TrieGetString(pre_names_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
{
TrieSetString(client_prefix, str_id, temp_prefix)
}

return PLUGIN_HANDLED
}

send_message(const message[], const id, const i)
{
message_begin(MSG_ONE, g_saytxt, {0, 0, 0}, i)
write_byte(id)
write_string(message)
message_end()
}

bool:check_say_characters(const check_message[])
{
for(new i = 0; i < charsmax(forbidden_say_symbols); i++)
{
if(check_message[0] == forbidden_say_symbols[i])
{
return true
}
}
return false
}

bool:check_prefix_characters(const check_prefix[])
{
for(i = 0; i < charsmax(forbidden_prefixes_symbols); i++)
{
if(containi(check_prefix, forbidden_prefixes_symbols[i]) != -1)
{
return true
}
}
return false
}

find_and_delete(const arg_type[], const arg_key[])
{
line = 0, length = 0;

while(read_file(file_prefixes, line++ , text, charsmax(text), length))
{
if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
continue

parse(text, type, charsmax(type), key, charsmax(key), prefix, charsmax(prefix))
trim(prefix)

if(!type[0] || !prefix[0] || !key[0])
continue

if(!equal(arg_type, type) || !equal(arg_key, key))
continue

write_file(file_prefixes, "", line - 1)
}

switch(arg_type[0])
{
case 'f':
{
TrieDeleteKey(pre_flags_collect, arg_key)
}
case 'i':
{
TrieDeleteKey(pre_ips_collect, arg_key)
}
case 's':
{
TrieDeleteKey(pre_steamids_collect, arg_key)
}
case 'n':
{
TrieDeleteKey(pre_names_collect, arg_key)
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
