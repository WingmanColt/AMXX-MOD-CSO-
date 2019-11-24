#include <amxmodx>
#include <ZombieMod5>

new const sound[][] = {"ZB5/win_human.wav","ZB5/win_zombie.wav"}
new g_ScoreHumans, g_ScoreZombies
public plugin_init()
{
register_event("TextMsg","event_restart_game","a", "2=#Game_Commencing")
register_event("TextMsg", "event_restart_game", "a", "2=#Game_will_restart_in")
register_message(get_user_msgid("TextMsg"), "message_textmsg")
register_message(get_user_msgid("SendAudio"), "message_sendaudio")
}
public plugin_precache()
{
for(new i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])	
}
public zp_fw_gamemodes_end()
{
if (!zp_core_get_players_count(1,1))
{	
client_print(0, print_center, "Humans Win!")
PlaySound(0, "ZB5/win_human.wav")

g_ScoreHumans++
}
else if (!zp_core_get_players_count(1,2))
{	
client_print(0, print_center, "Zombies Win!")
PlaySound(0, "ZB5/win_zombie.wav")

g_ScoreZombies++
}
else
{
client_print(0, print_center, "Humans Win!")
PlaySound(0, "ZB5/win_human.wav")

g_ScoreHumans++
}	

}

public event_restart_game() 
{
g_ScoreHumans = 0
g_ScoreZombies = 0
}
// Block some text messages
public message_textmsg()
{
static textmsg[22]
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
static audio[17]
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

