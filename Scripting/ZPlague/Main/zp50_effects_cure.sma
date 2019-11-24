#include <amxmodx>
#include <zp50_core>

new g_HudSync
public plugin_init()
{	
g_HudSync = CreateHudSyncObj()
}
public zp_fw_core_cure_post(id, attacker)
{	
if (is_user_connected(attacker))
{
emit_sound(id, CHAN_ITEM, "ZPlague/Antidote.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
if (attacker == id)
{		
new victim_name[32]
get_user_name(id, victim_name, charsmax(victim_name))
set_hudmessage(3, random_num(50,150), random_num(50,150), 0.05, 0.40, 0, 0.0, 5.0, 1.0, 1.0, -1)
ShowSyncHudMsg(0, g_HudSync, "%s Picked Antidote !", victim_name)
}
}
}
