#include <amxmodx>
#include <zp50_core>
#include <zp50_gamemodes>
#include <ZPC_Options>
#include <dhudmessage>


new const win_humans[][] = {"sound/ZPlague/Ends/win_humans001.mp3", "sound/ZPlague/Ends/win_humans02.mp3", "sound/ZPlague/Ends/win_humans003.mp3", "sound/ZPlague/Ends/win_humans004.mp3","sound/ZPlague/Ends/win_humans05.mp3","sound/ZPlague/Ends/win_humans07.mp3","sound/ZPlague/Ends/win_humans08.mp3","sound/ZPlague/Ends/win_humans11.mp3","sound/ZPlague/Ends/win_humans12.mp3","sound/ZPlague/Ends/win_humans13.mp3"}
new const win_zombies[][] = {"sound/ZPlague/Ends/win_zombies01.mp3"}

new g_ScoreHumans, g_ScoreZombies, g_GameModeBiohazardID
public plugin_init()
{
register_message(get_user_msgid("TextMsg"), "message_textmsg")
register_message(get_user_msgid("SendAudio"), "message_sendaudio")
}
public plugin_precache()
{
for(new i = 0; i < sizeof(win_humans); i++)
precache_generic(win_humans[i])
for(new i = 0; i < sizeof(win_zombies); i++)
precache_generic(win_zombies[i])
precache_sound("ZPlague/Ends/survivor_win2.wav")
precache_sound("ZPlague/Ends/zombie_win3.wav")
}
public plugin_cfg()
{
g_GameModeBiohazardID = zp_gamemodes_get_id("Biohazard Mode")
}
public zp_fw_gamemodes_end()
{
if (!zp_core_get_zombie_count())
{		
set_dhudmessage(0, random_num(50,150), random_num(50,150), -1.0, 0.17, 1, 1.0, 3.0, 1.0, 1.0)
show_dhudmessage(0, "|| ................................ ||^n Humans Win ! ^n|| ................................ ||")
if(zp_gamemodes_get_current() != g_GameModeBiohazardID)
{
PlaySoundToClients(win_humans[random_num(0, sizeof win_humans - 1)], 1)
}else{
PlaySoundToClients("ZPlague/Ends/survivor_win2.wav", 1)	
}
g_ScoreHumans++
}
else if (!zp_core_get_human_count())
{	
set_dhudmessage(random_num(50,150), random_num(50,150), 0, -1.0, 0.17, 1, 1.0, 3.0, 1.0, 1.0)
show_dhudmessage(0, "|| ................................ ||^n Zombies Win ! ^n|| ................................ ||")
if(zp_gamemodes_get_current() != g_GameModeBiohazardID)
{
PlaySoundToClients(win_zombies[random_num(0, sizeof win_zombies - 1)], 1)
}else{
PlaySoundToClients("ZPlague/Ends/zombie_win3.wav", 1)	
}
g_ScoreZombies++
}
else
{	
set_dhudmessage(0, random_num(50,150), random_num(50,150), -1.0, 0.17, 1, 1.0, 3.0, 1.0, 1.0)
show_dhudmessage(0, "|| ................................ ||^n Humans Win ! ^n|| ................................ ||")
PlaySoundToClients(win_humans[random_num(0, sizeof win_humans - 1)], 1)
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
PlaySoundToClients(const sound[], stop_sounds_first = 0)
{
if (stop_sounds_first)
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "stopsound; mp3 play ^"%s^"", sound)
else
client_cmd(0, "mp3 stop; stopsound; spk ^"%s^"", sound)
}
else
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(0, "mp3 play ^"%s^"", sound)
else
client_cmd(0, "spk ^"sound/%s^"", sound)
}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
