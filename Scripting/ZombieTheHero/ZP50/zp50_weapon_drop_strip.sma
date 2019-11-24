#include <amxmodx>
#include <cstrike>
#include <ZombieMod5>

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

// HACK: pev_ field used to store additional ammo on weapons
const PEV_ADDITIONAL_AMMO = pev_iuser1

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const GRENADES_WEAPONS_BIT_SUM = (1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)

// Ammo Type Names for weapons
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }

// Max BP ammo for weapons
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

#define PRIMARY_ONLY 1
#define SECONDARY_ONLY 2
#define PRIMARY_AND_SECONDARY 3
#define GRENADES_ONLY 4
public plugin_init()
{
RegisterHam(Ham_AddPlayerItem, "player", "fw_AddPlayerItem")
RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
}

public zp_fw_core_infect(id, attacker)
{
drop_weapons(id, PRIMARY_ONLY)
strip_weapons(id, PRIMARY_ONLY)
drop_weapons(id, SECONDARY_ONLY)
strip_weapons(id, SECONDARY_ONLY)
strip_weapons(id, GRENADES_ONLY)
cs_set_user_armor(id, 0, CS_ARMOR_NONE)
}

// Ham Weapon Touch Forward
public fw_TouchWeapon(weapon, id)
{
// Block weapon pickup for zombies?
if (is_user_alive(id) && zp_core_is_zombie(id))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}

// Ham Weapon Pickup Forward
public fw_AddPlayerItem(id, weapon_ent)
{
if(!pev_valid(weapon_ent))	
return
// HACK: Retrieve our custom extra ammo from the weapon
new extra_ammo = pev(weapon_ent, PEV_ADDITIONAL_AMMO)

// If present
if (extra_ammo)
{
// Get weapon's id
new weaponid = cs_get_weapon_id(weapon_ent)

// Add to player's bpammo
ExecuteHamB(Ham_GiveAmmo, id, extra_ammo, AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, 0)
}
}

// Strip primary/secondary/grenades
stock strip_weapons(id, stripwhat)
{
// Get user weapons
new weapons[32], num_weapons, index, weaponid
get_user_weapons(id, weapons, num_weapons)

// Loop through them and drop primaries or secondaries
for (index = 0; index < num_weapons; index++)
{
// Prevent re-indexing the array
weaponid = weapons[index]

if ((stripwhat == PRIMARY_ONLY && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
|| (stripwhat == SECONDARY_ONLY && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM))
|| (stripwhat == GRENADES_ONLY && ((1<<weaponid) & GRENADES_WEAPONS_BIT_SUM)))
{
// Get weapon name
new wname[32]
get_weaponname(weaponid, wname, charsmax(wname))

// Strip weapon and remove bpammo
ham_strip_weapon(id, wname)
cs_set_user_bpammo(id, weaponid, 0)
}
}
}

stock ham_strip_weapon(index, const weapon[])
{
// Get weapon id
new weaponid = get_weaponid(weapon)
if (!weaponid)
return false;

// Get weapon entity
new weapon_ent = fm_find_ent_by_owner(-1, weapon, index)
if (!weapon_ent)
return false;

// If it's the current weapon, retire first
new current_weapon_ent = fm_cs_get_current_weapon_ent(index)
new current_weapon = pev_valid(current_weapon_ent) ? cs_get_weapon_id(current_weapon_ent) : -1
if (current_weapon == weaponid)
ExecuteHamB(Ham_Weapon_RetireWeapon, weapon_ent)

// Remove weapon from player
if (!ExecuteHamB(Ham_RemovePlayerItem, index, weapon_ent))
return false;

// Kill weapon entity and fix pev_weapons bitsum
ExecuteHamB(Ham_Item_Kill, weapon_ent)
set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<weaponid))
return true;
}


// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
// Prevent server crash if entity's private data not initalized
if (pev_valid(id) != PDATA_SAFE)
return -1;

return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM);
}
