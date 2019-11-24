#include <amxmodx>
#include <amxmisc>
#include <fakemeta> 

#define charsof(%1) (sizeof(%1)-1)
new const g_iColors[][] = {  {0, 120, 180},  {200, 100, 0}, {200, 100, 0}, {200, 0, 0}, {200, 50, 100} }
new const Float:g_flCoords[][] = { {0.50, 0.40},{0.56, 0.44},{0.60, 0.50},{0.56, 0.56},{0.50, 0.60},{0.44, 0.56},{0.40, 0.50},{0.44, 0.44}}
new Array:g_Values, Array:g_Messages, g_iPlayerPos[33], g_iPlayerCol[33]
new g_MessagesNum, g_Current, g_HudSync, g_msgmode
public plugin_init()
{
register_event("Damage", "Event_Damage", "b", "2>0", "3=0")	
g_Messages=ArrayCreate(384);
g_Values=ArrayCreate(3);
g_HudSync = CreateHudSyncObj(1)
register_srvcmd("amx_imessage", "setMessage")
new lastinfo[8]
get_localinfo("lastinfomsg", lastinfo, 7)
g_Current = str_to_num(lastinfo)
set_localinfo("lastinfomsg", "")
}
public client_connect()g_msgmode = false
public client_disconnect()g_msgmode = false
public infoMessage()
{
if (g_Current >= g_MessagesNum)
g_Current = 0

// No messages, just get out of here
if (g_MessagesNum==0)
{
return;
}
new values[3];
new Message[384];
ArrayGetString(g_Messages, g_Current, Message, charsof(Message));
ArrayGetArray(g_Values, g_Current, values);
g_msgmode = true
ClearSyncHud(0, g_HudSync)
set_hudmessage(values[0], values[1], values[2], -1.0, 0.20, 0, 0.5, 3.0, 1.0, 2.0, -1);
ShowSyncHudMsg(0, g_HudSync, "%s", Message)
PlaySound(0, "ZPlague/tutor_msg.wav")
set_task(5.0, "close", 5521)
++g_Current;
new Float:freq_im = 60.0
if (freq_im > 0.0)
set_task(freq_im, "infoMessage", 12345);
}
public close()g_msgmode = false
public setMessage()
{
new Message[384];
remove_task(12345)
read_argv(1, Message, 380)
while (replace(Message, 380, "\n", "^n")) {}
new mycol[12]
new vals[3];
read_argv(2, mycol, 11)		// RRRGGGBBB
vals[2] = str_to_num(mycol[6])
mycol[6] = 0
vals[1] = str_to_num(mycol[3])
mycol[3] = 0
vals[0] = str_to_num(mycol[0])
g_MessagesNum++
new Float:freq_im = 60.0
ArrayPushString(g_Messages, Message);
ArrayPushArray(g_Values, vals);
if (freq_im > 0.0)
set_task(freq_im, "infoMessage", 12345)
return PLUGIN_HANDLED
}
public Event_Damage(iVictim)
{
if(read_data(4) || read_data(5) || read_data(6))
{
new id = get_user_attacker(iVictim)
if((1 <= id <= get_maxplayers()) && is_user_connected(id))
{
if(g_msgmode)
return	
new iPos = ++g_iPlayerPos[id]
if( iPos == sizeof(g_flCoords) )
{
iPos = g_iPlayerPos[id] = 0
}

new iCol = ++g_iPlayerCol[id]
if( iCol == sizeof(g_iColors) )
{
iCol = g_iPlayerCol[id] = 0
}
set_hudmessage(g_iColors[iCol][0], g_iColors[iCol][1], g_iColors[iCol][2], Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
ShowSyncHudMsg(id, g_HudSync,"%d", read_data(2));
new players[32], playerCnt, id_spectator
get_players(players, playerCnt, "bh")

for (new playerIdx = 0; playerIdx < playerCnt; ++playerIdx)
{
id_spectator = players[playerIdx];

if (pev(id_spectator, pev_iuser2) == id)
ShowSyncHudMsg(id_spectator, g_HudSync,"%d", read_data(2));			
}
}
}
}

public plugin_end()
{
new lastinfo[8]

num_to_str(g_Current, lastinfo, 7)
set_localinfo("lastinfomsg", lastinfo)
}
stock PlaySound(id, const sound[])
{
client_cmd(id, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
