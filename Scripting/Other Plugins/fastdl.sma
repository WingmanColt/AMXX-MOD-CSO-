#include <amxmodx>

new ip[32], g_time, g_setinfo
public plugin_init()
{
register_cvar("fixfastdl_ip","127.0.0.1:27019")
}

public plugin_cfg()
{
g_time=get_cvar_num("3.0")
g_setinfo=get_cvar_num("1")
if(!g_time)
g_time=3
get_cvar_string("3.0",ip,31)
}

public client_connect(id)
{
if(!is_user_hltv(id) && !is_user_bot(id))
{
static last_time[33]
static userip[33]
static userinfo[2]
get_user_ip(id,userip,32)
get_user_info(id,"rd",userinfo,1)
if((get_systime()-last_time[id])>g_time && (!userinfo[1] || !g_setinfo))
{
if(g_setinfo) client_cmd(id,"setinfo rd 1") 
set_task(0.1,"cl_reconnect",id)
}
else
{
if(g_setinfo) client_cmd(id,"setinfo rd ^"^"") 
}
last_time[id]=get_systime()
}
}

public cl_reconnect(id)
client_cmd(id,"Connect %s %d", ip,random_num(1,9999))
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
