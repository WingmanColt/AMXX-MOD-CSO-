#include <amxmodx>
#include <zp50_items>
#include <zp50_ammopacks>

public zp_fw_items_select_pre(id, itemid, ignorecost)
{
// Ignore item costs?
if (ignorecost)
return ZP_ITEM_AVAILABLE;

// Get current and required ammo packs
new current_ammopacks = zp_ammopacks_get(id)
new required_ammopacks = zp_items_get_cost(itemid)

// Not enough ammo packs
if (current_ammopacks < required_ammopacks)
return ZP_ITEM_NOT_AVAILABLE;

return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(id, itemid, ignorecost)
{
// Ignore item costs?
if (ignorecost)
return;

// Get current and required ammo packs
new current_ammopacks = zp_ammopacks_get(id)
new required_ammopacks = zp_items_get_cost(itemid)

// Deduct item's ammo packs after purchase event
zp_ammopacks_set(id, current_ammopacks - required_ammopacks)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
