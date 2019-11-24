#include <amxmodx>

public plugin_init() 
{
register_cvar("amx_rd_maxplayers","25")
register_cvar("amx_rd_server","79.124.58.57")
register_cvar("amx_rd_serverport","27034")
register_cvar("amx_rd_serverpw","")
}

public client_connect(id){
new rd_maxplayers = get_cvar_num("amx_rd_maxplayers")
new rd_serverport = get_cvar_num("amx_rd_serverport")
new rd_server[64], rd_serverpw[32]
get_cvar_string("amx_rd_server",rd_server,63)
get_cvar_string("amx_rd_serverpw",rd_serverpw,31)
if ( get_playersnum() >= rd_maxplayers) {
if ( !equal(rd_serverpw,"") )
client_cmd(id,"echo ^"[AMXX] Simple Redirection - Set Password to %s^";password %s",rd_serverpw,rd_serverpw)
client_cmd(id,"echo ^"[AMXX] Simple Redirection -  Redirecting to %s:%d^";connect %s:%d",rd_server,rd_serverport,rd_server,rd_serverport)
}
return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
