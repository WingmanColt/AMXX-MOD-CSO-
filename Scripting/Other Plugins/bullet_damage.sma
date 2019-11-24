#include <amxmodx>
new g_iMaxPlayers
public plugin_init() 
{  
register_event("Damage", "Event_Damage", "b", "2>0", "3=0")
g_iMaxPlayers = get_maxplayers()	
} 
public Event_Damage( iVictim )
{
new id = get_user_attacker(iVictim)
if((1 <= id <= g_iMaxPlayers) && is_user_connected(id))
{
client_print(id, print_center, "%d", read_data(2))
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
