#include <amxmodx>

new const symbols[] = {"#", "%", "`"}

public plugin_init()
{
register_clcmd("say","handle_say")
register_clcmd("say_team","handle_say")
}

public handle_say(id)
{
static arg[256]
read_args(arg, charsmax(arg))
remove_quotes(arg)
trim(arg)

for(new i = 0; i < charsmax(symbols); i++)
{
if(containi(arg, symbols[i]) != -1)
{
ColorMessage(id, "^x04[BlackChipher]^x01 Your message can't contain ^x04# ^x01or ^x04%")
return PLUGIN_HANDLED
}
}
return PLUGIN_CONTINUE
}

stock ColorMessage(const id, const input[], any:...)
{
new count = 1, players[32];
static msg[191];
vformat(msg, 190, input, 3);
if (id) players[0] = id; else get_players(players , count , "ch");
{
for (new i = 0; i < count; i++)
{
if (is_user_connected(players[i]))
{
message_begin(MSG_ONE_UNRELIABLE , get_user_msgid("SayText"), _, players[i]);
write_byte(players[i]);
write_string(msg);
message_end();
}
}
}
}
