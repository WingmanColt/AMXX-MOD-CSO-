#include <amxmodx>
#include <hlsdk_const>
#include <zp50_gamemodes>
new g_MsgDeathMsg,g_MsgScoreAttrib,g_shake
public plugin_init()
{
g_MsgDeathMsg = get_user_msgid("DeathMsg")
g_MsgScoreAttrib = get_user_msgid("ScoreAttrib")
g_shake = get_user_msgid("ScreenShake")
}
public zp_fw_core_infect_post(id, attacker)
{	
if (!is_user_connected(attacker))
return
if (attacker != id)
{
new attacker_name[32], victim_name[32]
get_user_name(attacker, attacker_name, charsmax(attacker_name))
get_user_name(id, victim_name, charsmax(victim_name))
SendDeathMsg(attacker, id)
FixDeadAttrib(id)
}
new origin[3]
get_user_origin(id, origin)
message_begin(MSG_ONE_UNRELIABLE, g_shake, _, id)
write_short((2<<12)*4)           
write_short((2<<12)*10) 
write_short((2<<12)*10) 
message_end()	
}
SendDeathMsg(attacker, victim)
{
message_begin(MSG_BROADCAST, g_MsgDeathMsg)
write_byte(attacker) // killer
write_byte(victim) // victim
write_byte(1) // headshot flag
write_string("infection") // killer's weapon
message_end()
}
FixDeadAttrib(id)
{
message_begin(MSG_BROADCAST, g_MsgScoreAttrib)
write_byte(id) // id
write_byte(0) // attrib
message_end()
}
stock SendCenterText(id, const message[])
{
if(!is_user_connected(id)) return	
client_print(id, print_center, message)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
