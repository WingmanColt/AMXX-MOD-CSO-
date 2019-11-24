#include <amxmodx>
#include <amxmisc>

new choises[6]
new Float:g_timelimit

public plugin_init() 
{
set_task(100.0, "start_vote");	
}
public start_vote(id)
{
new menu = menu_create("\rChoose timelimit for this map?", "menu_handler")
menu_additem(menu, "\w10 minutes", "1", 0)
menu_additem(menu, "\y20 minutes", "2", 0)
menu_additem(menu, "\r30 minutes", "3", 0)
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 

set_task(15.0, "finish_vote")

choises[1] = choises[2] = choises[3] = choises[4] = choises[5] = 0

return 1
}

public menu_handler(id, menu, item)
{
if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   

new data[6], name[32]
new access, callback

menu_item_getinfo(menu, item, access, data, 5, _, _, callback)

new key = str_to_num(data)
get_user_name(id, name, 31)

switch (key) 
{
case 1: 
{
client_printcolor(id, "^4[MegaStrike-BG]^3 %s voted for 10 minutes", name);
}
case 2:
{
client_printcolor(id, "^4[MegaStrike-BG]^3 %s voted for 20 minutes", name);
}
case 3:
{
client_printcolor(id, "^4[MegaStrike-BG]^3 %s voted for 30 minutes", name);
}
}

++choises[key]
menu_destroy(menu)   
return PLUGIN_HANDLED
}

public finish_vote()
{
g_timelimit = get_cvar_float("mp_timelimit")
if(choises[1] > choises[2] && choises[1] > choises[3] && choises[1] > choises[4] && choises[1] > choises[5])
{
client_printcolor(0, "^4[MegaStrike-BG]^3 Option ^"10 minutes^" won with %d votes", choises[1])
server_cmd("mp_timelimit 20");
}

else if(choises[2] > choises[1] && choises[2] > choises[3] && choises[2] > choises[4] && choises[2] > choises[5])
{
client_printcolor(0, "^4[MegaStrike-BG]^3 Option ^"20 minutes^" won with %d votes", choises[2])
server_cmd("mp_timelimit 30");
}
else if(choises[3] > choises[1] && choises[3] > choises[2] && choises[3] > choises[4] && choises[3] > choises[5])
{
client_printcolor(0, "^4[MegaStrike-BG]^3 Option ^"30 minutes^" won with %d votes", choises[3])
server_cmd("mp_timelimit 40");
}
}  

public plugin_end() 
{
set_cvar_float("mp_timelimit", g_timelimit)
}
stock client_printcolor(const id, const input[], any:...)
{
new iCount = 1, iPlayers[32]
static szMsg[191]

vformat(szMsg, charsmax(szMsg), input, 3)
replace_all(szMsg, 190, "/g", "^4")
replace_all(szMsg, 190, "/y", "^1")
replace_all(szMsg, 190, "/t", "^3")
replace_all(szMsg, 190, "/w", "^0")

if(id) iPlayers[0] = id
else get_players(iPlayers, iCount, "ch")

for(new i = 0; i < iCount; i++)
{
if (is_user_connected(iPlayers[i]))
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, iPlayers[i])
write_byte(iPlayers[i])
write_string(szMsg)
message_end()
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
