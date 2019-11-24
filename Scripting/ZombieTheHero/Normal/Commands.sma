#include <amxmodx>

public plugin_init()
{

register_cvar("amx_ex_interp", "1")
register_cvar("amx_rate", "1")
register_cvar("amx_cl_updaterate", "1")
register_cvar("amx_cl_cmdrate", "1")
register_cvar("amx_cl_cmdbackup", "1")
register_cvar("amx_mp_decals", "1")
register_cvar("amx_cl_rate", "1")
register_cvar("amx_fastsprites", "1")
register_cvar("amx_max_smokepuffs", "1")
register_cvar("amx_timeout", "1")
register_cvar("amx_dlmax", "1")
register_cvar("amx_allowdownload", "1")
register_cvar("amx_allowupload", "1")
register_cvar("amx_download_ingame", "1")
}

public client_PreThink(id)
{
new interp[32], rate[32], updaterate[32], cmdrate[32], cmdbackup[32]
new decals[32], cl_rate[32], fastsprites[32], smokepuffs[32], timeout[32]
new dlmax[32], allowdownload[32], allowupload[32], download[32]

get_user_info(id, "ex_interp", interp, 31)

if(get_cvar_num("amx_ex_interp"))
{
if(interp[id] != 0.01)
{
client_cmd(id, "ex_interp 0.01")
}
}

get_user_info(id, "rate", rate, 31)

if(get_cvar_num("amx_rate"))
{
if(rate[id] != 20000)
{
client_cmd(id, "rate 20000")
}
}

get_user_info(id, "cl_updaterate", updaterate, 31)

if(get_cvar_num("amx_cl_updaterate"))
{
if(updaterate[id] != 101)
{
client_cmd(id, "cl_updaterate 101")
}
}

get_user_info(id, "cl_cmdrate", cmdrate, 31)

if(get_cvar_num("amx_cl_cmdrate"))
{
if(cmdrate[id] != 101)
{
client_cmd(id, "cl_cmdrate 101")
}
}

get_user_info(id, "cl_cmdbackup", cmdbackup, 31)

if(get_cvar_num("amx_cl_cmdbackup"))
{
if(cmdbackup[id] != 2)
{
client_cmd(id, "cl_cmdbackup 2")
}
}

get_user_info(id, "mp_decals", decals, 31)

if(get_cvar_num("amx_mp_decals"))
{
if(decals[id] != 300)
{
client_cmd(id, "mp_decals 300")
}
}

get_user_info(id, "cl_rate", cl_rate, 31)

if(get_cvar_num("amx_cl_rate"))
{
if(cl_rate[id] != 20000)
{
client_cmd(id, "cl_rate 20000")
}
}

get_user_info(id, "fastsprites", fastsprites, 31)

if(get_cvar_num("amx_fastsprites"))
{
if(fastsprites[id] != 0)
{
client_cmd(id, "fastsprites 0")
}
}

get_user_info(id, "max_smokepuffs", smokepuffs, 31)

if(get_cvar_num("amx_max_smokepuffs"))
{
if(smokepuffs[id] != 120)
{
client_cmd(id, "max_smokepuffs 120")
}
}

get_user_info(id, "cl_timeout", timeout, 31)

if(get_cvar_num("amx_timeout"))
{
if(timeout[id] != 300)
{
client_cmd(id, "cl_timeout 300")
}
}

get_user_info(id, "cl_dlmax", dlmax , 31)

if(get_cvar_num("amx_dlmax"))
{
if(dlmax[id] != 128)
{
client_cmd(id, "cl_dlmax 128")
}
}    

get_user_info(id, "cl_allowdownload", allowdownload, 31)

if(get_cvar_num("amx_allowdownload"))
{
if(allowdownload[id] !=1 )
{
client_cmd(id, "cl_allowdownload 1")
}
}

get_user_info(id, "cl_allowupload", allowupload, 31)

if(get_cvar_num("amx_allowupload"))
{
if(allowupload[id] != 1)
{
client_cmd(id, "cl_allowupload 1")
}
}

get_user_info(id, "cl_download_ingame",download , 31)

if(get_cvar_num("amx_download_ingame"))
{
if(download[id] != 1)
{
client_cmd(id, "cl_download_ingame 1")
}
}
}  