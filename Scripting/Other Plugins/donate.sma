#include <amxmodx>
#include <cstrike>

new players_menu, players[32], num
new saytext
public plugin_init()
{    
saytext = get_user_msgid("SayText")	
register_clcmd("donate", "transfer_menu")  
register_clcmd("transfer", "transfer_money") 
}
public transfer_menu(id)
{   
if(!is_user_connected(id))
return PLUGIN_HANDLED    
	
get_players(players, num, "h")       
if (num <= 1)  
{              
return PLUGIN_HANDLED    
}   

new tempname[32], info[10]  

players_menu = menu_create("Money Donate Menu", "players_menu_handler")  

for(new i = 0; i < num; i++) 
{       
if(players[i] == id)           
continue  

get_user_name(players[i], tempname, 31)       
num_to_str(players[i], info, 9)       
menu_additem(players_menu, tempname, info, 0)    
}       
menu_setprop(players_menu, MPROP_EXIT, MEXIT_ALL)  

menu_display(id, players_menu, 0)   
return PLUGIN_CONTINUE
}

public players_menu_handler(id, players_menu, item)
{ 
if(item == MENU_EXIT)   
{       
menu_destroy(players_menu)       
return PLUGIN_HANDLED   

}    
new data[6], accessmenu, iName[64], callback  
menu_item_getinfo(players_menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback) 
new player = str_to_num(data)  
client_cmd(id, "messagemode ^"transfer %i^"", player)  
return PLUGIN_CONTINUE
}

public transfer_money(id)
{    
if(!is_user_connected(id))
return 1;	

new param[6]    
read_argv(2, param, charsmax(param))

for (new x; x < strlen(param); x++)    
{       
if(!isdigit(param[x]))       
{            
return 0        
}    
}    
if(is_user_connected(id))
{
new amount = str_to_num(param)   
new money = cs_get_user_money(id) 

if (money < amount)    
{                     
return 0    
} 

read_argv(1, param, charsmax(param))   
new player = str_to_num(param) 
new names[2][32]        
get_user_name(id, names[0], 31)    
get_user_name(player, names[1], 31)        
colorchat(0, "^4[ZB5] ^3%s donate %i$ for %s!", names[0], amount, names[1]);  
cs_set_user_money(id, money - amount)    
cs_set_user_money(player,  cs_get_user_money(player) + amount)    
}

return 0
}
stock colorchat(const id, const input[], any:...) 
{ 
new count = 1, players[32]; 
static msg[191]; 
vformat(msg, 190, input, 3); 
replace_all(msg, 190, "!g", "^4"); // Green Color 
replace_all(msg, 190, "!y", "^1"); // Default Color (?©°  ??«??©) 
replace_all(msg, 190, "!t", "^3"); // Team Color 
if (id) players[0] = id; else get_players(players, count, "ch"); 
{ 
for (new i = 0; i < count; i++) 
{ 	
if (is_user_connected(players[i])) 
{ 
message_begin(MSG_ONE_UNRELIABLE, saytext, _, players[i]); 
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
