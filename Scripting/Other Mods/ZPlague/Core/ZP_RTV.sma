#include <amxmodx>
#include <zp50_colorchat>

new g_voted[33], g_voting = 0;
public plugin_init() 
{
register_clcmd("say rtv", "rockthevote");
}
public rockthevote(id)
{
if(g_voted[id])
{
zp_colored_print(id, " ^x03You already voted  for rock the map %i/10 player ramaning!", g_voting)	
}else{
g_voting++
zp_colored_print(id, " ^x03You voted for rock the map %i/10 player ramaning!", g_voting)
zp_colored_print(0, " ^x03One more voted, %i/20 player ramaning!", g_voting)		
		
g_voted[id] = true
}
if(g_voting == 10)
{
zp_colored_print(id, " ^x03The map will be changed round end!", g_voting)			
set_task(1.0,"change_level",id, _, _,"b")
}
}	
public change_level(id)
{
switch(random_num(1, 26))
{
case 1:server_cmd("changelevel zm_battle_ground2")
case 2:server_cmd("changelevel zm_evil-ice_attack2")
case 3:server_cmd("changelevel zm_zombattack_new")
case 4:server_cmd("changelevel zm_brambor")
case 5:server_cmd("changelevel zm_sewers")
case 6:server_cmd("changelevel zm_forested")
case 7:server_cmd("changelevel zm_gbox6")
case 8:server_cmd("changelevel zm_toxic_house_final")
case 9:server_cmd("changelevel zm_toxichouse_new")
case 10:server_cmd("changelevel zm_ice_attack3")
case 11:server_cmd("changelevel zm_dex")
case 12:server_cmd("changelevel zm_laf")
case 13:server_cmd("changelevel zm_snowbase4_zp")
case 14:server_cmd("changelevel zm_snowhouse")
case 15:server_cmd("changelevel zm_dust_jasionka")
case 16:server_cmd("changelevel zm_dd_v1")
case 17:server_cmd("changelevel zm_cpl_mill_kamp")
case 18:server_cmd("changelevel zm_dust_winter")
case 19:server_cmd("changelevel zm_nightcamp")
case 20:server_cmd("changelevel zm_klimax_v2")
case 21:server_cmd("changelevel zm_ice_attack")
case 22:server_cmd("changelevel zm_ice_attack2")
case 23:server_cmd("changelevel zm_AandD_extended")
case 24:server_cmd("changelevel zm_heal_dust2")
case 25:server_cmd("changelevel zm_firezone")
case 26:server_cmd("changelevel zm_decline2k")
}
}	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
