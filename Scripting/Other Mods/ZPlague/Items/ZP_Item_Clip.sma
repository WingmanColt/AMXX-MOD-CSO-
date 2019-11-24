#include <amxmodx>
#include <fakemeta>
#include <zp50_colorchat>
#include <zp50_core>

#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
const OFFSET_LINUX_WEAPONS = 4
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }
new g_has_unlimited_clip[33]
public plugin_init()
{
register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
}
public plugin_natives()
{
register_native("give_item_clip", "BuyClip", 1)
}
public BuyClip(id)
{
if(!is_user_alive(id))
return;

if(!g_has_unlimited_clip[id])
{	
new money = zp_ammopacks_get(id) 		
if (money >= 20)
{		
zp_ammopacks_set(id, money - 20)	
g_has_unlimited_clip[id] = true
}else{
zp_colored_print(id, " ^x01Not enough AmmoPacks!")
}
}
}
public event_round_start()
{
for (new id; id <= 32; id++) g_has_unlimited_clip[id] = false;
}
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
if (!g_has_unlimited_clip[msg_entity])
return;

if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
return;

static weapon, clip
weapon = get_msg_arg_int(2) // get weapon ID
clip = get_msg_arg_int(3) // get weapon clip

if (MAXCLIP[weapon] > 2) // skip grenades
{
set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]) // HUD should show full clip all the time

if (clip < 2) // refill when clip is nearly empty
{
static wname[32], weapon_ent
get_weaponname(weapon, wname, sizeof wname - 1)
weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)

fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
}
}
}

stock fm_find_ent_by_owner(entity, const classname[], owner)
{
while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}

return entity;
}

stock fm_set_weapon_ammo(entity, amount)
{
set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
