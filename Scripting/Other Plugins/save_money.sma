#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>
#include <zp50_core>

#define MAX_SAVE 100000
new g_save, g_money[33], g_money_can_save[33]
public plugin_init()
{
register_event("DeathMsg","event_deathmsg","a")
register_logevent("logevent_round_end", 2, "1=Round_End")
RegisterHam(Ham_Spawn, "player", "fw_spawn_post", 1)	
register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
g_save = nvault_open("g_money")
}
public client_putinserver(id)
{
if(!is_user_bot(id))	
set_task(2.0, "now_can_save", id)
}
public now_can_save(id)
{
Load_Ammo_date(id)
set_task(0.5, "can_save_true", id)
}
public can_save_true(id)g_money_can_save[id] = true
public client_connect(id)
{
Load_Ammo_date(id)	
set_money(id)
}
public fw_spawn_post(id)
{
Load_Ammo_date(id)	
set_money(id)	
}
public zp_fw_core_infect_post(id, infector)
{
if (g_money_can_save[infector])
Save_Ammo_date(infector)
if (g_money_can_save[id])
Save_Ammo_date(id)
}
public logevent_round_end(id)
{
if (g_money_can_save[id])
Save_Ammo_date(id)
}
public client_disconnect(id)Save_Ammo_date(id)
public event_deathmsg()
{
new killer = read_data(1)
new victim = read_data(2)

if (!killer && !victim)
return PLUGIN_CONTINUE;

if (g_money_can_save[killer])
Save_Ammo_date(killer)

if (g_money_can_save[victim])
Save_Ammo_date(victim)

return PLUGIN_CONTINUE;
}

public fw_PlayerPreThink(id)
{
if (g_money_can_save[id])
{
new money = cs_get_user_money(id)
g_money[id] = money
}
return FMRES_IGNORED;
}
public Save_Ammo_date(id)
{
new vaultkey[64], vaultdata[256]

new name[33];
get_user_name(id,name,32)

format(vaultkey, 63, "%s-/", name)
format(vaultdata, 255, "%i#", g_money[id])

nvault_set(g_save, vaultkey, vaultdata)
return PLUGIN_CONTINUE;
}

public Load_Ammo_date(id)
{
if(!is_user_connected(id))
return		
new vaultkey[64], vaultdata[256]
new name[33];
get_user_name(id,name,32)

format(vaultkey, 63, "%s-/", name)

format(vaultdata, 255, "%i#", g_money[id])

nvault_get(g_save, vaultkey, vaultdata, 255)
replace_all(vaultdata, 255, "#", " ")

new playmoney[32]
parse(vaultdata, playmoney, 31)
g_money[id] = str_to_num(playmoney)
set_money(id)
}
public set_money(id)
{
if(!is_user_connected(id))
return	
if (g_money[id] > MAX_SAVE)
{
cs_set_user_money(id, MAX_SAVE)
g_money[id] = MAX_SAVE
}
else
cs_set_user_money(id, g_money[id])
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
