#include <amxmodx>
#include <fakemeta>
#include <hlsdk_const>
#include <zp50_gamemodes>

new const infect[][] = {"ZPlague/Infect/zombie_infect1.wav","ZPlague/Infect/zombie_infect2.wav","ZPlague/Infect/zombie_infect3.wav","ZPlague/Infect/zombie_infect4.wav"}
new const infect2[][] = {"ZPlague/Infect/zombie_infect5.wav","ZPlague/Infect/zombie_infect6.wav","ZPlague/Infect/zombie_infect7.wav"}

new g_MsgDeathMsg,g_MsgScoreAttrib,g_shake, g_smoke, g_GameModeBiohazardID
public plugin_init()
{
g_MsgDeathMsg = get_user_msgid("DeathMsg")
g_MsgScoreAttrib = get_user_msgid("ScoreAttrib")
g_shake = get_user_msgid("ScreenShake")
}
public plugin_precache()
{
g_smoke = engfunc(EngFunc_PrecacheModel, "sprites/ZPlague/infect_smoke.spr")	
}
public plugin_cfg()
{
g_GameModeBiohazardID = zp_gamemodes_get_id("Biohazard Mode")
}
public zp_fw_core_infect_post(id, attacker)
{	
if (!is_user_connected(attacker))
return
if(zp_gamemodes_get_current() != g_GameModeBiohazardID)
{
PlaySound(id, infect[random_num(0, sizeof infect - 1)])	
}else{
PlaySound(0, infect2[random_num(0, sizeof infect2 - 1)])	
}
if (attacker == id)
{
}
else
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
Smoke(id)
}
public Smoke(id)
{
static Float:originF[3]
pev(id, pev_origin, originF)
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
write_byte( TE_FIREFIELD);
engfunc(EngFunc_WriteCoord, originF[0]+15.0);
engfunc(EngFunc_WriteCoord, originF[1]);
engfunc(EngFunc_WriteCoord, originF[2]);
write_short(2);
write_short(g_smoke);
write_byte(5);
write_byte(TEFIRE_FLAG_ALPHA|TEFIRE_FLAG_SOMEFLOAT|TEFIRE_FLAG_LOOP);
write_byte(1);
message_end();	
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
stock PlaySound(id, const sound[])
{
emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
