#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>

const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373
new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE,
CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4 }
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }
#define REFILL_WEAPONID args[0]
new g_MsgAmmoPickup
public plugin_init()
{
register_event("AmmoX", "event_ammo_x", "be")
g_MsgAmmoPickup = get_user_msgid("AmmoPickup")
}

// BP Ammo update
public event_ammo_x(id)
{
// Not alive or not human
if (!is_user_alive(id) || zp_core_is_zombie(id))
return;

// Get ammo type
new type = read_data(1)

// Unknown ammo type
if (type >= sizeof AMMOWEAPON)
return;

// Get weapon's id
new weapon = AMMOWEAPON[type]

// Primary and secondary only
if (MAXBPAMMO[weapon] <= 2)
return;

// Get ammo amount
new amount = read_data(2)

// Unlimited BP Ammo
if (amount < MAXBPAMMO[weapon])
{
new args[1]
args[0] = weapon
set_task(0.1, "refill_bpammo", id, args, sizeof args)
}
}

// Refill BP Ammo Task
public refill_bpammo(const args[], id)
{
// Player died or turned into a zombie
if (!is_user_alive(id) || zp_core_is_zombie(id))
return;

new block_status = get_msg_block(g_MsgAmmoPickup)
set_msg_block(g_MsgAmmoPickup, BLOCK_ONCE)
ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[REFILL_WEAPONID], AMMOTYPE[REFILL_WEAPONID], MAXBPAMMO[REFILL_WEAPONID])
set_msg_block(g_MsgAmmoPickup, block_status)
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
// Prevent server crash if entity's private data not initalized
if (pev_valid(id) != PDATA_SAFE)
return -1;

return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM);
}
