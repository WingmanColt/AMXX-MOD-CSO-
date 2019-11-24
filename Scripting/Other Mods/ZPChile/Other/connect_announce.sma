#include <amxmodx>

public client_authorized(id)
{
if(!is_user_bot(id)) return PLUGIN_CONTINUE;
new iPlayers[32], iNum, i;
get_players(iPlayers, iNum);
for(i = 0; i <= iNum; i++)
{
new x = iPlayers[i];

if(!is_user_connected(x) || !is_user_bot(x)) continue;
new const sound[2][] = { "ZPChile/Connect_sound.mp3", "ZPChile/Connect_sound2.mp3" }
PlaySound(id, sound[random_num(0, sizeof sound - 1)])	
}
return PLUGIN_CONTINUE;
}
stock PlaySound(id, const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(id, "mp3 play ^"sound/%s^"", sound)
else
client_cmd(id, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
