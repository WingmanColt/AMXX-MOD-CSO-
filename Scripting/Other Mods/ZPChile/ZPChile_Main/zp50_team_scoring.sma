#include <amxmodx>
#include <zp50_core>
#include <zp50_gamemodes>
#include <ZPC_Options>
new g_ScoreHumans, g_ScoreZombies
public plugin_init()
{
register_message(get_user_msgid("TextMsg"), "message_textmsg")
register_message(get_user_msgid("SendAudio"), "message_sendaudio")
}
public zp_fw_gamemodes_end()
{
if (!zp_core_get_zombie_count())
{
client_print(0, print_center, "Humans Win!")
PlaySound("ZPChile\win_humans.wav")
g_ScoreHumans++
}
else if (!zp_core_get_human_count())
{
client_print(0, print_center, "Zombies Win!")
PlaySound("ZPChile\win_zombies.wav")
g_ScoreZombies++
}
else
{
client_print(0, print_center, "Humans Win!")
PlaySound("ZPChile\win_humans.wav")
g_ScoreHumans++
}	
}
// Block some text messages
public message_textmsg()
{
new textmsg[22]
get_msg_arg_string(2, textmsg, charsmax(textmsg))

// Game restarting/game commencing, reset scores
if (equal(textmsg, "#Game_will_restart_in") || equal(textmsg, "#Game_Commencing"))
{
g_ScoreHumans = 0
g_ScoreZombies = 0
}
// Block round end related messages
else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
new audio[17]
get_msg_arg_string(2, audio, charsmax(audio))

if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
new team[2]
get_msg_arg_string(1, team, charsmax(team))

switch (team[0])
{
// CT
case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_ScoreHumans)
// Terrorist
case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_ScoreZombies)
}
}
stock PlaySound(const sound[])
{
client_cmd(0, "spk ^"sound/%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
