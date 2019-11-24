#include <amxmodx>

new g_TimeSet[32][2]
new g_LastTime
new g_CountDown
new g_Switch

public plugin_init()
{
register_cvar("amx_timeleft", "00:00", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)	
register_srvcmd("amx_time_display", "setDisplaying")
register_clcmd("say timeleft", "sayTimeLeft", 0, "- displays timeleft")
register_clcmd("say thetime", "sayTheTime", 0, "- displays current time")
set_task(0.8, "timeRemain", 8648458, "", 0, "b")
}

public sayTheTime(id)
{
new ctime[64]
get_time("%m/%d/%Y - %H:%M:%S", ctime, 63)
client_print(0, print_chat, "The time:   %s", ctime)
return PLUGIN_CONTINUE
}

public sayTimeLeft(id)
{
if (get_cvar_float("mp_timelimit"))
{
new a = get_timeleft()
client_print(0, print_chat, "Time Left:  %d:%02d", (a / 60), (a % 60))
}
else
client_print(0, print_chat, "No Time Limit")

return PLUGIN_CONTINUE
}

setTimeText(text[], len, tmlf, id)
{
new secs = tmlf % 60
new mins = tmlf / 60

if (secs == 0)
format(text, len, "%d минутес", mins, id)
else if (mins == 0)
format(text, len, "%d seconds", secs, id)
else
format(text, len, "%d minutes %d seconds", mins, secs, id)
}

findDispFormat(time)
{
for (new i = 0; g_TimeSet[i][0]; ++i)
{
if (g_TimeSet[i][1] & 16)
{
if (g_TimeSet[i][0] > time)
{
if (!g_Switch)
{
g_CountDown = g_Switch = time
remove_task(8648458)
set_task(1.0, "timeRemain", 34543, "", 0, "b")
}

return i
}
}
else if (g_TimeSet[i][0] == time)
{
return i
}
}

return -1
}

public setDisplaying()
{
new arg[32], flags[32], num[32]
new argc = read_argc() - 1
new i = 0

while (i < argc && i < 32)
{
read_argv(i + 1, arg, 31)
parse(arg, flags, 31, num, 31)

g_TimeSet[i][0] = str_to_num(num)
g_TimeSet[i][1] = read_flags(flags)

i++
}
g_TimeSet[i][0] = 0

return PLUGIN_HANDLED
}

public timeRemain(param[])
{
new gmtm = get_timeleft()
new tmlf = g_Switch ? --g_CountDown : gmtm
new stimel[12]

format(stimel, 11, "%02d:%02d", gmtm / 60, gmtm % 60)
set_cvar_string("amx_timeleft", stimel)

if (g_Switch && gmtm > g_Switch)
{
remove_task(34543)
g_Switch = 0
set_task(0.8, "timeRemain", 8648458, "", 0, "b")

return
}

if (tmlf > 0 && g_LastTime != tmlf)
{
g_LastTime = tmlf
new tm_set = findDispFormat(tmlf)

if (tm_set != -1)
{
new flags = g_TimeSet[tm_set][1]
new arg[128]

if (flags & 1)
{
new players[32], pnum

get_players(players, pnum, "c")

for (new i = 0; i < pnum; i++)
{
setTimeText(arg, 127, tmlf, players[i])

if (flags & 16)
set_hudmessage(100, 100, 100, -1.0, 0.85, 0, 0.0, 1.1, 0.1, 0.5, -1)
else
set_hudmessage(100, 100, 100, -1.0, 0.85, 0, 0.0, 3.0, 0.0, 0.5, -1)

show_hudmessage(players[i], "%s", arg)
}
}
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
