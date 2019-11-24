#include <amxmodx> 
#include <amxmisc>

// PCvars
new hpk_ping, hpk_check, hpk_tests, hpk_delay

new g_Ping[33]
new g_Samples[33]

public plugin_init() 
{
hpk_ping = register_cvar("amx_hpk_ping","255")
hpk_check = register_cvar("amx_hpk_check","12")
hpk_tests = register_cvar("amx_hpk_tests","7")
hpk_delay = register_cvar("amx_hpk_delay","80")

if (get_pcvar_num(hpk_check) < 5) set_pcvar_num(hpk_check,5)
if (get_pcvar_num(hpk_tests) < 3) set_pcvar_num(hpk_tests,3)
}

public client_disconnected(id) 
remove_task(id)

public client_putinserver(id) {    
g_Ping[id] = 0 
g_Samples[id] = 0

if ( !is_user_bot(id) ) 
{
new param[1]
param[0] = id 

if (get_pcvar_num(hpk_delay) != 0) {
set_task( float(get_pcvar_num(hpk_delay)), "taskSetting", id, param , 1)
}
else {	    
set_task( float(get_pcvar_num(hpk_check)) , "checkPing" , id , param , 1 , "b" )
}
}
}


public taskSetting(param[]) {
new name[32]
get_user_name(param[0],name,31)
set_task( float(get_pcvar_num(hpk_check)) , "checkPing" , param[0] , param , 1 , "b" )
}

kickPlayer(id) { 
new name[32],authid[36]
get_user_name(id,name,31)
get_user_authid(id,authid,35)
client_print(0,print_chat,"[CSO] Player %s disconnected due to high ping",name)
server_cmd("kick #%d ^"Sorry but your ping is too high, try again later...^"",get_user_userid(id))
log_amx("HPK: ^"%s<%d><%s>^" was kicked due high ping (Average Ping ^"%d^")", name,get_user_userid(id),authid,(g_Ping[id] / g_Samples[id]))
}

public checkPing(param[]) 
{ 

if (get_pcvar_num(hpk_tests) < 3)
set_pcvar_num(hpk_tests,3)

new id = param[ 0 ] 

new ping, loss

get_user_ping(id,ping,loss) 

g_Ping[ id ] += ping
++g_Samples[ id ]

if ( (g_Samples[ id ] > get_pcvar_num(hpk_tests)) && (g_Ping[id] / g_Samples[id] > get_pcvar_num(hpk_ping))  )    
kickPlayer(id)

return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
