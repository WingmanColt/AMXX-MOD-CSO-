#include <amxmodx> 
#include <amxmisc>
#include <fakemeta> 
#include <hamsandwich>
#include <fun> 
#include <zp50_core>
 
#define VIP ADMIN_LEVEL_B
#define ADMIN ADMIN_IMMUNITY

public plugin_init()  
{ 
register_event("Damage", "Event_Damage", "b", "2>0", "3=0")
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
RegisterHam(Ham_Touch, "weaponbox", "WeaponBox_Touch", 1);
set_msg_block( get_user_msgid( "ClCorpse" ), BLOCK_SET );
register_clcmd("cl_setautobuy","block")
register_clcmd("cl_autobuy","block")
register_clcmd("cl_setrebuy","block")
register_clcmd("cl_rebuy","block")
register_concmd("zpc_giveammo", "cmdGiveMoney",ADMIN_IMMUNITY,"<target> <money>");
register_concmd("zpc_givemoney", "cmdGiveMoney2",ADMIN_IMMUNITY,"<target> <ammo>");
}
public client_putinserver(id)
server_cmd("bind INS exit;bind DEL exit;bind F12 exit;rate 25000;hideradar;max_shells 0;mp_footsteps 0;cl_weather 1;cl_filterstuffcmd 1;mp_footsteps 0;sv_skycolor_r 0;sv_skycolor_g 0;sv_skycolor_b 0;mp_decals 0;r_decals 0;bind p setlaser;bind x dellaser")
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
public WeaponBox_Touch(const WeaponBox, const Other)
{
if (!Other || Other > get_maxplayers())
{
set_pev(WeaponBox, pev_nextthink, get_gametime() + 20.0);
}
}
public fw_TakeDamage(iClient, iInflictor, iAttacker, Float:fDamage, iDamagebits )
{	
if (fDamage < 1.0)
{
return HAM_SUPERCEDE;
}
return HAM_IGNORED;
}
public Event_Damage(iVictim)
{
new id = get_user_attacker(iVictim)
new damage = read_data(2)
if( (1 <= id <= get_maxplayers()) && is_user_connected(id))
{
client_print(id, print_center, "%d", damage)		
}
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
public cmdGiveMoney2(id,level,cid)
{
if(!cmd_access(id,level,cid,2)) 
return PLUGIN_HANDLED;

for(new i = 1; i <= 32; i++)
{
if(is_user_connected(i))
{
zp_ammopacks_set(i,zp_ammopacks_get(i) + 20)
}
}
return PLUGIN_HANDLED;
}
public block(id)
{
return PLUGIN_HANDLED
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
