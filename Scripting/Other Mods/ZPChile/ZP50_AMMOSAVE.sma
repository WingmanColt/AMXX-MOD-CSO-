#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <fvault>
#include <zp50_core>

new const g_vault_ammo[] = "AmmoSystem";
new g_name[33][100]
public client_authorized(id)
{
if(!is_user_hltv(id) && !is_user_bot(id))
{
LoadDataAmmo(id)
}
}
public client_disconnect(id)
{
if(!is_user_hltv(id) && !is_user_bot(id))
{		
SaveDataAmmo(id)
}
}
LoadDataAmmo(id)
{	
new data1[30]; fvault_get_data(g_vault_ammo, g_name[id], data1, charsmax(data1))
new have = str_to_num(data1)
if(have > 0)
{
zp_ammopacks_set(id, have)
new string1[30]
formatex(string1, charsmax(string1), "0")
fvault_set_data(g_vault_ammo, g_name[id], string1)
}
}
SaveDataAmmo(id)
{	
new aps = zp_ammopacks_get(id)
if(aps == 0)
{
return PLUGIN_HANDLED;
}	
new aps_have[30]
fvault_get_data(g_vault_ammo, g_name[id], aps_have, 29)
new result = aps + str_to_num(aps_have)
new aps2[30]
formatex(aps2, charsmax(aps2), "%i", result)
fvault_set_data(g_vault_ammo, g_name[id], aps2)
return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
