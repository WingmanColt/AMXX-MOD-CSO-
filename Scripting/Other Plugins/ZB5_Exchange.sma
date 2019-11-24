#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <zp50_colorchat>
#include <ZombieMod5>

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
if (equal(arg1,"/money", 5))
CmdMoney(id, arg2)
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
zp_colored_print(id, " ^x03You can not give money to yourself.")
return
}

new ammo_sender = cs_get_user_money(id)
new ammo = str_to_num(count)

if (ammo <= 0)
{
zp_colored_print(id, " ^x03You can give only positive money.")
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
zp_colored_print(id," ^x03You give %i money for %s", ammo, g_name)
zp_colored_print(reciever," ^x03You recieved %i money from %s", ammo, g_name2)
cs_set_user_money(reciever, cs_get_user_money(reciever) + ammo)
cs_set_user_money(id, ammo_sender)
}
public CmdMoney(id, arg[])
{
new to[32], count[10]
strbreak(arg, to, charsmax(to), count, charsmax(count))

new reciever = cmd_target(id, to, 0)

if (!reciever)
{
zp_colored_print(id, " ^x03Player not found.!")
return
}


static g_name[64]
get_user_name(reciever, g_name, charsmax(g_name))
zp_colored_print(id," ^x03%s have %i money.", g_name, cs_get_user_money(reciever))
}
