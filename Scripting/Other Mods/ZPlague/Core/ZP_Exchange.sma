#include <amxmodx>
#include <amxmisc>
#include <zp50_colorchat>
#include <zp50_core>

public plugin_init()
{
register_clcmd("say", "handleSay")
register_clcmd("say_team", "handleSay")
}

public handleSay(id)
{
new args[64]

read_args(args, charsmax(args))
remove_quotes(args)

new arg1[16], arg2[32]

strbreak(args, arg1, charsmax(arg1), arg2, charsmax(arg2))

if (equal(arg1,"/give", 5))
CmdGiveAP(id, arg2)
}

public CmdGiveAP(id, arg[])
{
new to[32], count[10]
strbreak(arg, to, charsmax(to), count, charsmax(count))

if (!to[0] || !count[0])
{
zp_colored_print(id, " ^x03Type: ^x04/give ^x03<target> <amount>")
return
}

new reciever = cmd_target(id, to, 0)

if (!reciever)
{
zp_colored_print(id, " ^x03Player not found.!")
return
}

if (reciever == id)
{
zp_colored_print(id, " ^x03You can not give ammo packs to yourself.")
return
}

new ammo_sender = zp_ammopacks_get(id)
new ammo = str_to_num(count)

if (ammo <= 0)
{
zp_colored_print(id, " ^x03You can give only positive ammo packs.")
return
}

ammo_sender -= ammo

if (ammo_sender < 0)
{
ammo += ammo_sender
ammo_sender = 0	
}
static g_name[64], g_name2[64]
get_user_name(reciever, g_name, charsmax(g_name))
get_user_name(id, g_name2, charsmax(g_name2))
zp_colored_print(id," ^x03You give %i ammo packs for %s", ammo, g_name)
zp_colored_print(reciever," ^x03You recieved %i ammo packs from %s", ammo, g_name2)
zp_ammopacks_set(reciever, zp_ammopacks_get(reciever) + ammo)
zp_ammopacks_set(id, ammo_sender)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
