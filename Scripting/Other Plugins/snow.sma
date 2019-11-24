#include <amxmodx> 
#include <engine> 

public plugin_init() 
{ 
    register_plugin("Snow", "1.0", "rumqna.bs") 
}  

public client_connect(id) 
{ 
    client_cmd(id, "cl_weather 1") 
}  

public plugin_precache() 
{ 
    create_entity("env_snow") 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
