#include <amxmodx>
#include <zp50_core>

new const g_SprFireNade[] = "dmg_heat" // Fire Nade Sprite
new const g_SprFrostNade[] = "dmg_cold" // Frost Nade Sprite
new const g_SprFlareNade[] = "dmg_shock" // Flare Nade Sprite
new g_iMsgStatusIcon, g_aGrenadeIcon[33][32]
public plugin_init()
{
register_event("CurWeapon", "ev_CurWeapon", "be", "1=1")
register_event("DeathMsg", "ev_DeathMsg", "a")
g_iMsgStatusIcon = get_user_msgid("StatusIcon")
}
public ev_CurWeapon(id)
{
fn_RemoveGrenadeIcon(id)	
if(is_user_alive(id) && !zp_core_is_zombie(id))
{
static Color[3]
switch(get_user_weapon(id))
{
case CSW_HEGRENADE:
{
g_aGrenadeIcon[id] = g_SprFireNade
Color[0] = 150; Color[1] = 70; Color[2] = 0
}
case CSW_FLASHBANG:
{
g_aGrenadeIcon[id] = g_SprFrostNade
Color[0] = 0; Color[1] = 90; Color[2] = 150
}
case CSW_SMOKEGRENADE:
{
g_aGrenadeIcon[id] = g_SprFlareNade
Color[0] = random_num(50, 200); Color[1] = random_num(50, 200); Color[2] = random_num(50, 200)
}
default: 
return
}
// Show Grenade Icon
message_begin(MSG_ONE, g_iMsgStatusIcon, {0,0,0}, id)
write_byte(1) // Status [0=Hide, 1=Show, 2=Flash]
write_string(g_aGrenadeIcon[id]) // Sprite Name
write_byte(Color[0]) // Red
write_byte(Color[1]) // Green
write_byte(Color[2]) // Blue
message_end()
return
}
}
public ev_DeathMsg()
{
new id = read_data(2)
if(!is_user_alive(id))
return;	
fn_RemoveGrenadeIcon(id)
}
public fn_RemoveGrenadeIcon(id)
{
if(!is_user_alive(id))
return;	
message_begin(MSG_ONE, g_iMsgStatusIcon, {0,0,0}, id)
write_byte(0) // Status [0=Hide, 1=Show, 2=Flash]
write_string(g_aGrenadeIcon[id]) // Sprite Name
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
