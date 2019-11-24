#include <amxmodx> 
#include <amxmisc>
#include <fakemeta> 
#include <hamsandwich>
#include <fun> 
#include <zp50_core> 

#define VIP ADMIN_LEVEL_B
#define ADMIN ADMIN_IMMUNITY
#define OFFSET_MONEY 115
#define OFFSET_LINUX 5

public plugin_init()  
{ 
RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1)			
register_concmd("ammo", "cmdGiveMoney",ADMIN_RESERVATION,"<target> <ammo>");
register_clcmd("cl_setautobuy","block")
register_clcmd("cl_autobuy","block")
register_clcmd("cl_setrebuy","block")
register_clcmd("cl_rebuy","block")
}
public client_connect(id) 
{
if(!is_user_bot(id) && !is_user_hltv(id)) 
{
new name[100]	
get_user_name(id, name, 100)
client_print(0, print_chat, "%s Connected", name)
}
return PLUGIN_CONTINUE
}

public client_disconnect(id) 
{
if(!is_user_bot(id) && !is_user_hltv(id))
{
new name[100]		
get_user_name(id, name, 100)
client_print(0, print_chat, "%s Disconnected", name)
}
return PLUGIN_CONTINUE
}
public client_putinserver(id)
{
if(!is_user_connected(id))
return;	
client_cmd(id, "rate 25000;cl_updaterate 101;cl_cmdrate 101;fps_max 101;fps_modem 0")
}
public fw_Spawn_Post(id)
{
if(!is_user_alive(id))
return	
set_task(3.5, "set_bind_button", id)
}
public set_bind_button(id)
{
if(!is_user_connected(id))
return	
client_cmd(id, "bind INS exit")
client_cmd(id, "bind DEL exit")
client_cmd(id, "bind F12 exit")
client_cmd(id, "sv_skycolor_r 0")
client_cmd(id, "sv_skycolor_g 0")
client_cmd(id, "sv_skycolor_b 0")
client_cmd(id, "violence_hblood 1")
client_cmd(id, "violence_ablood 1")
client_cmd(id, "hideradar")
client_cmd(id, "mp_decals 0")
client_cmd(id, "r_decals 0")
client_cmd(id, "mp_decals 0")
}  
public cmdGiveMoney(id,level,cid)
{
if(!cmd_access(id,level,cid,2)) 
return PLUGIN_HANDLED;
new arg[32],argm[8]
read_argv(1, arg, 31);
read_argv(2, argm, 7);
new money = str_to_num(argm)

new target = cmd_target(id,arg,0)
if (!target) return PLUGIN_HANDLED

new current = zp_ammopacks_get(target)

zp_ammopacks_set(target,(money+current))

return PLUGIN_HANDLED;
}

stock fm_set_user_money(index, money, flash=1)
{
set_pdata_int(index, OFFSET_MONEY, money, OFFSET_LINUX);

message_begin(MSG_ONE,get_user_msgid("Money"), {0,0,0}, index)
write_long(money);
write_byte(flash);
message_end();
}  

stock fm_get_user_money(index)
{
return get_pdata_int(index, OFFSET_MONEY, OFFSET_LINUX);
} 
public block(id)
{
return PLUGIN_HANDLED
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
