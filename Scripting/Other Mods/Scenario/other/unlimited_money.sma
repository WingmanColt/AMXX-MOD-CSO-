#include <amxmodx>
#include <amxmisc>
#include <cstrike>

#define MONEY_TIER 32000 // DON'T MESS WITH, Money total at which the plugin switches over keeping track of money
new money_total[33] // Keep track of peeps money if above MONEY_TIER
new gmsg_Money

new amx_maxmoney
new amx_startmoney

public client_connect(id)
{
set_cvar_float("mp_startmoney", 801.0) // So you can track when to change to amx_startmoney ammount, I know.. a crude method
money_total[id] = 0
}


public read_gmsg_Money(id) {
if(!is_user_connected(id)) return PLUGIN_HANDLED

new current_total = read_data(1)

if(current_total == 801){         // If CS is spawning you with mp_startmoney default
current_total = get_pcvar_num(amx_startmoney)      // current total is actually amx_startmoney
cs_set_user_money(id, current_total,0)         // so set user money to amx_startmoney
money_total[id] = 0 // reset
}
if(current_total >= MONEY_TIER && !money_total[id]) // If first time above MONEY_TIER
{
money_total[id] = current_total // Keep track of current total

send_moneymsg(id,current_total-MONEY_TIER,read_data(2)) // send money msg of current total

return PLUGIN_CONTINUE
}
if(money_total[id]) // If was over tier on last money message
{
money_total[id] += current_total - MONEY_TIER  // figure the term of current total - tier

if(money_total[id] < MONEY_TIER){  // If less then tier set user money to money_total[id] and stop keeping track
cs_set_user_money(id,money_total[id],1)
money_total[id] = 0
}
else{
send_moneymsg(id,current_total-MONEY_TIER,read_data(2)) // else send money message
}

return PLUGIN_CONTINUE
}

return PLUGIN_CONTINUE
}

//change flash to ammount
public send_moneymsg(id,ammount,flash)
{
cs_set_user_money(id,MONEY_TIER,0) //Set user money to tier ammount so easy to track add and subtract terms

new maxamount = get_pcvar_num(amx_maxmoney)

if(money_total[id] >  maxamount)
money_total[id] =  maxamount

//send old money
message_begin( MSG_ONE , gmsg_Money , {0,0,0}, id )
write_long(money_total[id]-ammount)
write_byte(0)
message_end()

//send current money
message_begin( MSG_ONE , gmsg_Money , {0,0,0}, id ) //Send money message with ammount stored in money_total[id]
write_long(money_total[id])
write_byte(flash)
message_end()
}


public find_money_target(id, level, cid)
{
if(!cmd_access(id, level, cid, 3))
return PLUGIN_HANDLED

new target[16], ammount[8], players[32]
new num

read_argv(1,target,15)
read_argv(2,ammount,7)

if(target[0] == '@'){    //If trying to give a team money
if(target[1] == 'C' || target[1] == 'c'){
get_players(players, num ,"e", "CT")
}
else if(target[1] == 'T' || target[1] == 't'){
get_players(players, num ,"e", "TERRORIST")
}
else{
console_print(id, "*** No known team by that name. ***")
return PLUGIN_HANDLED
}
}
else if(target[0] == '#'){  //If trying to give a player(userid) money
new userid = str_to_num(target[1])
players[0] = find_player("k", userid)
}
else{  // else search for matching name to try and give money
players[0] = find_player("bl", target)
}

if(players[0] == 0){  //If no target(s) could be found
console_print(id, "*** No target(s) could be found. ***")
return PLUGIN_HANDLED
}
else 
give_money(players, str_to_num(ammount))

return PLUGIN_HANDLED
}


public give_money(players[], ammount)
{
new i
while(players[i]){
if(money_total[players[i]]){
money_total[players[i]] += ammount // Keep track of current total
send_moneymsg(players[i],ammount,1) // send money msg of current total
}
else if( (cs_get_user_money(players[i]) + ammount) >= MONEY_TIER){
money_total[players[i]] = cs_get_user_money(players[i]) + ammount // Keep track of current total
send_moneymsg(players[i],ammount,1) // send money msg of current total
}
else{
ammount += cs_get_user_money(players[i])
cs_set_user_money(players[i],ammount,1)
money_total[players[i]] = 0
}

++i
}
}

public restartround() 
{ 
for (new i=1; i<33; i++)
money_total[i] = 0
} 

public _cs_get_user_money_ul(plug,param) {
if(param != 1)
return PLUGIN_HANDLED

new id = get_param(1)


if (id < 1 || id > get_maxplayers()) {
log_error(AMX_ERR_NATIVE, "Player out of range (%d)", id)
return PLUGIN_HANDLED
} else {
if (!is_user_connected(id)) {
log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
return PLUGIN_HANDLED
}
}

if(money_total[id] < MONEY_TIER) {
return cs_get_user_money(id)
}
else {
return money_total[id]
}

return PLUGIN_HANDLED

}

public _cs_set_user_money_ul(plug,param) {
if(param != 2 && param != 3 )
return PLUGIN_HANDLED

new id = get_param(1)

if (id < 1 || id > get_maxplayers()) {
log_error(AMX_ERR_NATIVE, "Player out of range (%d)", id)
return PLUGIN_HANDLED
} else {
if (!is_user_connected(id)) {
log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
return PLUGIN_HANDLED
}
}

new ammount = get_param(2)

if(ammount >= MONEY_TIER){
new change = ammount - money_total[id]
money_total[id] = ammount
send_moneymsg(id,change,get_param(3))
}
else{
if (ammount < 0) ammount = 0
cs_set_user_money(id,ammount,get_param(3))
money_total[id] = 0
}
return PLUGIN_HANDLED	
}

public plugin_natives() {
register_library("money_ul")
register_native("cs_get_user_money_ul","_cs_get_user_money_ul")
register_native("cs_set_user_money_ul","_cs_set_user_money_ul")
}

public plugin_init()
{
register_plugin("Unlimited Money","2.0","NL)Ramon(NL")

register_event("Money","read_gmsg_Money","b")
register_event("TextMsg", "restartround", "a", "2&#Game_C","2&#Game_w") 

amx_startmoney = register_cvar("amx_startmoney", "8000")
amx_maxmoney = register_cvar("amx_maxmoney", "32000")

register_concmd("amx_setmoney", "find_money_target",ADMIN_LEVEL_A, "{@team, #userid, or name(can be partial)} <ammount>")

gmsg_Money = get_user_msgid("Money")

return PLUGIN_CONTINUE
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
