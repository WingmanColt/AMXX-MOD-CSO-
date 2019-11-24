#include <amxmodx> 
#include <amxmisc>
#include <cstrike>
#include <ZombieMod5>

#define TASK_MSG 61

enum _:CvarBits (<<=1) 
{
BLOCK_RADIO = 1,
BLOCK_MSG
};

new g_pCvar, g_started, g_MaxPlayers
public plugin_init()  
{ 	
register_event("Damage", "damage_msg", "b", "2!0", "3=0", "4!0")
register_event("StatusValue", "showStatus", "be", "1=2", "2!0")

register_message( get_user_msgid( "TextMsg" ),   "MessageTextMsg" )
register_message( get_user_msgid( "SendAudio" ), "MessageSendAudio" )
register_forward(FM_GetGameDescription, "fw_GetGameDesc")

register_clcmd("say /admin", "ShowAdmin")
register_clcmd("say admin", "ShowAdmin")
register_clcmd("say vip", "ShowVip")
register_clcmd("say /vip", "ShowVip")

g_pCvar = register_cvar( "sv_fith_block", "3" );
g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
//register_native("zb5_set_user_unstuck", "Unstuck", 1)	
}

public fw_GetGameDesc()
{
forward_return(FMV_STRING, "NEW ( 2017 )")
return FMRES_SUPERCEDE
}
public client_putinserver(id)
{		
remove_task(id+TASK_MSG)
set_task(60.0, "MSG", id+TASK_MSG, _, _, "b")
client_cmd(id, "bind INS exit;bind DEL exit;bind F12 exit") 
}
public client_connect(id) 
{
if(!is_user_bot(id) && !is_user_hltv(id)) 
{
static name[64]	
get_user_name(id, name, 100)
zp_colored_print(0, "^1%s Connected", name)
}
return PLUGIN_CONTINUE
}

public client_disconnected(id) 
{
remove_task(id+TASK_MSG)
	
if(!is_user_bot(id) && !is_user_hltv(id))
{
static name[64]		
get_user_name(id, name, 100)
zp_colored_print(0, "^1%s Disconnected", name)
}
return PLUGIN_CONTINUE
}

public zp_fw_game_start()
{
g_started = true

for(new i = 1; i < g_MaxPlayers; i++)
{
if(!is_user_alive(i))
continue;

if (!is_player_stuck2(i))
continue;

user_silentkill(i)
}	
}
stock is_player_stuck2(id)
{
static Float:originF[3]
pev(id, pev_origin, originF)

engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)

if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
return true;

return false;
}
public zp_fw_game_end()g_started = false
public MSG(id)
{
id -= TASK_MSG	

switch(random_num(1, 14))
{
case 1:zp_colored_print(id, "^4[INFO] ^1Click button ^4[M4] ^1to open Code Decoder menu.") 	
case 2:zp_colored_print(id, "^4[INFO] ^3Owner Skype: ^4support.cso2") 	
case 3:zp_colored_print(id, "^4[INFO] ^1Useful commands: ^3/vip, /admin, /register") 		
case 4:zp_colored_print(id, "^4[SOCIAL] ^1Like us on facebook. ^3Link: ^4www.fb.com/CSZB5") 
case 5:zp_colored_print(id, "^4[HappyHour] ^3^4 7pm - 9pm ^3chasa vecher dvoino poveche EXP !!!") 
case 6:zp_colored_print(id, "^4[HappyHour] ^3At^4 7 - 9 pm ^3multiple x2 EXP!!!") 
case 7:zp_colored_print(id, "^4[HappyHour] ^3Ot^4 8 - 10 ^3chasa sutrin dvoino poveche EXP !!!") 
case 8:zp_colored_print(id, "^4[HappyHour] ^3At^4 8 - 10 am ^3multiple x2 EXP!!!")
case 9:zp_colored_print(id, "^4[ACCESS] ^3If you want FREE V.I.P || Skype: ^4support.cso2")  
case 10:zp_colored_print(id, "^4[SOCIAL] ^1Like us on facebook. Link: www.fb.com/cmsbgeu") 
case 11:zp_colored_print(id, "^4[WEB] ^3Visit our webpage: ^4www.CMS-BG.eu") 
case 12:zp_colored_print(id, "^4[WEB] ^3Visit our webpage: ^4www.CMS-BG.eu")
case 13:zp_colored_print(id, "^4[WEB] ^3Visit our webpage: ^4www.CMS-BG.eu") 
case 14:zp_colored_print(id, "^4[ACCESS] ^3If you want to Buy ADMIN || Skype: ^4support.cso2")  
}

}
public damage_msg(vIndex)
{ 
static id, damage	
id = get_user_attacker(vIndex)
damage = read_data(2)

if(!is_user_connected(id))
return;

client_print(id, print_center, "%i", damage)   
}
public showStatus(id)
{	
if(!g_started)
return;	

if(!is_user_connected(id))
return;

static name[32], i
i = read_data(2);
get_user_name(i, name, 31);

if (!zp_core_is_zombie(id))
{
if (is_user_connected(i) && !zp_core_is_zombie(i))
client_print(id, print_center, "%s - Health: %d - Armor: %d - Money: %d$ - Level: %d", name, get_user_health(i), get_user_armor(i), cs_get_user_money(i), zb5_get_user_level(i));
}else{
if (is_user_connected(i) && zp_core_is_zombie(i))
client_print(id, print_center, "%s - Health: %d - Armor: %d - Evolution Level: %d", name, get_user_health(i), get_user_armor(i), zb5_get_zombie_info(i, EVO_LV));		
}
}
public ShowAdmin(id)show_motd(id,"addons/amxmodx/configs/motds/admin.txt")
public ShowVip(id)show_motd(id,"addons/amxmodx/configs/motds/vip.txt")
public MessageTextMsg( )
return ( get_msg_args( ) == 5 && IsBlocked( BLOCK_MSG ) ) ? GetReturnValue( 5, "#Fire_in_the_hole" ) : PLUGIN_CONTINUE;

public MessageSendAudio( )
return IsBlocked( BLOCK_RADIO ) ? GetReturnValue( 2, "%!MRAD_FIREINHOLE" ) : PLUGIN_CONTINUE;

GetReturnValue( const iParam, const szString[ ] ) {
new szTemp[ 18 ];
get_msg_arg_string( iParam, szTemp, 17 );

return ( equal( szTemp, szString ) ) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

bool:IsBlocked( const iType )
return bool:( get_pcvar_num( g_pCvar ) & iType );
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
