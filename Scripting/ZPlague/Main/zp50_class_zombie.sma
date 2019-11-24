#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_player_models_api>
#include <cs_weap_models_api>
#include <cs_maxspeed_api>
#include <cs_weap_restrict_api>
#include <zp50_core>
#include <zp50_class_zombie_const>

#define MAXPLAYERS 32
const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4)
const ZOMBIE_DEFAULT_ALLOWED_WEAPON = CSW_KNIFE
const OFFSET_CSMENUCODE = 205

#define MENU_PAGE_CLASS g_menu_data[id]
new g_menu_data[MAXPLAYERS+1]
new ef_blood[2]

enum _:TOTAL_FORWARDS
{
FW_CLASS_SELECT_PRE = 0,
FW_CLASS_SELECT_POST
}
new g_Forwards[TOTAL_FORWARDS]
new g_ForwardResult

new g_ZombieClassCount
new Array:g_ZombieClassRealName
new Array:g_ZombieClassName
new Array:g_ZombieClassDesc
new Array:g_ZombieClassHealth
new Array:g_ZombieClassSpeed
new Array:g_ZombieClassGravity
new Array:g_ZombieClassModelsFile
new Array:g_ZombieClassModelsHandle
new Array:g_ZombieClassClawsFile
new Array:g_ZombieClassClawsHandle
new g_ZombieClass[MAXPLAYERS+1]
new g_ZombieClassNext[MAXPLAYERS+1]
new g_AdditionalMenuText[32]

public plugin_init()
{
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	
g_Forwards[FW_CLASS_SELECT_PRE] = CreateMultiForward("zp_fw_class_zombie_select_pre", ET_CONTINUE, FP_CELL, FP_CELL)
g_Forwards[FW_CLASS_SELECT_POST] = CreateMultiForward("zp_fw_class_zombie_select_post", ET_CONTINUE, FP_CELL, FP_CELL)
}
public plugin_natives()
{
register_library("zp50_class_zombie")
register_native("zp_class_zombie_get_current", "native_class_zombie_get_current")
register_native("zp_class_zombie_get_next", "native_class_zombie_get_next")
register_native("zp_class_zombie_set_next", "native_class_zombie_set_next")
register_native("zp_class_zombie_get_max_health", "_class_zombie_get_max_health")
register_native("zp_class_zombie_register", "native_class_zombie_register")
register_native("zp_class_zombie_register_model", "_class_zombie_register_model")
register_native("zp_class_zombie_register_claw", "_class_zombie_register_claw")
register_native("zp_class_zombie_get_id", "native_class_zombie_get_id")
register_native("zp_class_zombie_get_name", "native_class_zombie_get_name")
register_native("zp_class_zombie_get_real_name", "_class_zombie_get_real_name")
register_native("zp_class_zombie_get_desc", "native_class_zombie_get_desc")
register_native("zp_class_zombie_get_count", "native_class_zombie_get_count")
register_native("zp_class_zombie_show_menu", "native_class_zombie_show_menu")
register_native("zp_class_zombie_menu_text_add", "_class_zombie_menu_text_add")

// Initialize dynamic arrays
g_ZombieClassRealName = ArrayCreate(32, 1)
g_ZombieClassName = ArrayCreate(32, 1)
g_ZombieClassDesc = ArrayCreate(32, 1)
g_ZombieClassHealth = ArrayCreate(1, 1)
g_ZombieClassSpeed = ArrayCreate(1, 1)
g_ZombieClassGravity = ArrayCreate(1, 1)
g_ZombieClassModelsHandle = ArrayCreate(1, 1)
g_ZombieClassModelsFile = ArrayCreate(1, 1)
g_ZombieClassClawsHandle = ArrayCreate(1, 1)
g_ZombieClassClawsFile = ArrayCreate(1, 1)
}

public plugin_precache()
{	
ef_blood[0] = precache_model("sprites/blood.spr")
ef_blood[1] = precache_model("sprites/bloodspray.spr")
}

public client_putinserver(id)
{
g_ZombieClass[id] = ZP_INVALID_ZOMBIE_CLASS
g_ZombieClassNext[id] = ZP_INVALID_ZOMBIE_CLASS
}

public client_disconnected(id)
{
// Reset remembered menu pages
MENU_PAGE_CLASS = 0
}

public show_class_menu(id)
{
if (zp_core_is_zombie(id))
show_menu_zombieclass(id)
}

public show_menu_zombieclass(id)
{
static menu[128], name[32], description[32]
new menuid, itemdata[2], index

formatex(menu, charsmax(menu), "\y[NS2] \rZombie Classes", id)
menuid = menu_create(menu, "menu_zombieclass")

for (index = 0; index < g_ZombieClassCount; index++)
{
// Additional text to display
g_AdditionalMenuText[0] = 0

// Execute class select attempt forward
ExecuteForward(g_Forwards[FW_CLASS_SELECT_PRE], g_ForwardResult, id, index)

// Show class to player?
if (g_ForwardResult >= ZP_CLASS_DONT_SHOW)
continue;

ArrayGetString(g_ZombieClassName, index, name, charsmax(name))
ArrayGetString(g_ZombieClassDesc, index, description, charsmax(description))

// Class available to player?
if (g_ForwardResult >= ZP_CLASS_NOT_AVAILABLE)
formatex(menu, charsmax(menu), "\d%s %s %s", name, description, g_AdditionalMenuText)
// Class is current class?
else if (index == g_ZombieClassNext[id])
formatex(menu, charsmax(menu), "\r%s \y%s \w%s", name, description, g_AdditionalMenuText)
else
formatex(menu, charsmax(menu), "%s \y%s \w%s", name, description, g_AdditionalMenuText)

itemdata[0] = index
itemdata[1] = 0
menu_additem(menuid, menu, itemdata)
}

// No classes to display?
if (menu_items(menuid) <= 0)
{
menu_destroy(menuid)
return;
}

// Back - Next - Exit
formatex(menu, charsmax(menu), "Back", id)
menu_setprop(menuid, MPROP_BACKNAME, menu)
formatex(menu, charsmax(menu), "Next", id)
menu_setprop(menuid, MPROP_NEXTNAME, menu)
formatex(menu, charsmax(menu), "Exit", id)
menu_setprop(menuid, MPROP_EXITNAME, menu)

// If remembered page is greater than number of pages, clamp down the value
MENU_PAGE_CLASS = min(MENU_PAGE_CLASS, menu_pages(menuid)-1)

// Fix for AMXX custom menus
set_pdata_int(id, OFFSET_CSMENUCODE, 0)
menu_display(id, menuid, MENU_PAGE_CLASS)
}

public menu_zombieclass(id, menuid, item)
{
// Menu was closed
if (item == MENU_EXIT)
{
MENU_PAGE_CLASS = 0
menu_destroy(menuid)
return PLUGIN_HANDLED;
}

// Remember class menu page
MENU_PAGE_CLASS = item / 7

// Retrieve class index
new itemdata[2], dummy, index
menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
index = itemdata[0]

// Execute class select attempt forward
ExecuteForward(g_Forwards[FW_CLASS_SELECT_PRE], g_ForwardResult, id, index)

// Class available to player?
if (g_ForwardResult >= ZP_CLASS_NOT_AVAILABLE)
{
menu_destroy(menuid)
return PLUGIN_HANDLED;
}

// Make selected class next class for player
g_ZombieClassNext[id] = index

new name[32]
ArrayGetCell(g_ZombieClassSpeed, g_ZombieClassNext[id])
ArrayGetString(g_ZombieClassName, g_ZombieClassNext[id], name, charsmax(name))
ExecuteForward(g_Forwards[FW_CLASS_SELECT_POST], g_ForwardResult, id, index)

menu_destroy(menuid)
return PLUGIN_HANDLED;
}

public zp_fw_core_infect_post(id, attacker)
{
// Show zombie class menu if they haven't chosen any (e.g. just connected)
if (g_ZombieClassNext[id] == ZP_INVALID_ZOMBIE_CLASS)
{
if (g_ZombieClassCount > 1)
show_menu_zombieclass(id)
else // If only one class is registered, choose it automatically
g_ZombieClassNext[id] = 0
}

// Set selected zombie class. If none selected yet, use the first one
g_ZombieClass[id] = g_ZombieClassNext[id]
if (g_ZombieClass[id] == ZP_INVALID_ZOMBIE_CLASS) g_ZombieClass[id] = 0

// Apply zombie attributes
set_user_health(id, ArrayGetCell(g_ZombieClassHealth, g_ZombieClass[id]))
set_user_gravity(id, Float:ArrayGetCell(g_ZombieClassGravity, g_ZombieClass[id]))
cs_set_player_maxspeed_auto(id, Float:ArrayGetCell(g_ZombieClassSpeed, g_ZombieClass[id]))

// Apply zombie player model
new Array:class_models = ArrayGetCell(g_ZombieClassModelsHandle, g_ZombieClass[id])
new index = random_num(0, ArraySize(class_models) - 1)
new player_model[32]
ArrayGetString(class_models, index, player_model, charsmax(player_model))
cs_set_player_model(id, player_model)

// Apply zombie claw model
new claw_model[64], Array:class_claws = ArrayGetCell(g_ZombieClassClawsHandle, g_ZombieClass[id])
ArrayGetString(class_claws, index, claw_model, charsmax(claw_model))
cs_set_player_view_model(id, CSW_KNIFE, claw_model)
cs_set_player_weap_model(id, CSW_KNIFE, "")
cs_set_player_weap_restrict(id, true, ZOMBIE_ALLOWED_WEAPONS_BITSUM, ZOMBIE_DEFAULT_ALLOWED_WEAPON)
}

public zp_fw_core_cure(id, attacker)
{
cs_reset_player_view_model(id, CSW_KNIFE)
cs_reset_player_weap_model(id, CSW_KNIFE)
cs_set_player_weap_restrict(id, false)
}

public native_class_zombie_get_current(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return ZP_INVALID_ZOMBIE_CLASS;
}

return g_ZombieClass[id];
}

public native_class_zombie_get_next(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return ZP_INVALID_ZOMBIE_CLASS;
}

return g_ZombieClassNext[id];
}

public native_class_zombie_set_next(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

new classid = get_param(2)

if (classid < 0 || classid >= g_ZombieClassCount)
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
return false;
}

g_ZombieClassNext[id] = classid
return true;
}

public _class_zombie_get_max_health(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

new classid = get_param(2)

if (classid < 0 || classid >= g_ZombieClassCount)
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
return -1;
}

return ArrayGetCell(g_ZombieClassHealth, classid);
}

public native_class_zombie_register(plugin_id, num_params)
{
new name[32]
get_string(1, name, charsmax(name))

if (strlen(name) < 1)
{
log_error(AMX_ERR_NATIVE, "[ZP] Can't register zombie class with an empty name")
return ZP_INVALID_ZOMBIE_CLASS;
}

new index, zombieclass_name[32]
for (index = 0; index < g_ZombieClassCount; index++)
{
ArrayGetString(g_ZombieClassRealName, index, zombieclass_name, charsmax(zombieclass_name))
if (equali(name, zombieclass_name))
{
log_error(AMX_ERR_NATIVE, "[ZP] Zombie class already registered (%s)", name)
return ZP_INVALID_ZOMBIE_CLASS;
}
}

new description[32]
get_string(2, description, charsmax(description))
new health = get_param(3)
new Float:speed = get_param_f(4)
new Float:gravity = get_param_f(5)

// Load settings from zombie classes file
new real_name[32]
copy(real_name, charsmax(real_name), name)
ArrayPushString(g_ZombieClassRealName, real_name)
ArrayPushString(g_ZombieClassName, name)
ArrayPushString(g_ZombieClassDesc, description)

// Models
new Array:class_models = ArrayCreate(32, 1)
if (ArraySize(class_models) > 0)
{
ArrayPushCell(g_ZombieClassModelsFile, true)

// Precache player models
new index, player_model[32], model_path[128]
for (index = 0; index < ArraySize(class_models); index++)
{
ArrayGetString(class_models, index, player_model, charsmax(player_model))
formatex(model_path, charsmax(model_path), "models/player/%s/%s.mdl", player_model, player_model)
precache_model(model_path)
// Support modelT.mdl files
formatex(model_path, charsmax(model_path), "models/player/%s/%sT.mdl", player_model, player_model)
if (file_exists(model_path)) precache_model(model_path)
}
}
else
{
ArrayPushCell(g_ZombieClassModelsFile, false)
ArrayDestroy(class_models)
}
ArrayPushCell(g_ZombieClassModelsHandle, class_models)

// Claw models
new Array:class_claws = ArrayCreate(64, 1)
if (ArraySize(class_claws) > 0)
{
ArrayPushCell(g_ZombieClassClawsFile, true)

// Precache claw models
new index, claw_model[64]
for (index = 0; index < ArraySize(class_claws); index++)
{
ArrayGetString(class_claws, index, claw_model, charsmax(claw_model))
precache_model(claw_model)
}
}
else
{
ArrayPushCell(g_ZombieClassClawsFile, false)
ArrayDestroy(class_claws)
}
ArrayPushCell(g_ZombieClassClawsHandle, class_claws)
ArrayPushCell(g_ZombieClassHealth, health)
ArrayPushCell(g_ZombieClassSpeed, speed)
ArrayPushCell(g_ZombieClassGravity, gravity)

g_ZombieClassCount++
return g_ZombieClassCount - 1;
}

public _class_zombie_register_model(plugin_id, num_params)
{
new classid = get_param(1)

if (classid < 0 || classid >= g_ZombieClassCount)
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
return false;
}

// Player models already loaded from file
if (ArrayGetCell(g_ZombieClassModelsFile, classid))
return true;

new player_model[32]
get_string(2, player_model, charsmax(player_model))

new model_path[128]
formatex(model_path, charsmax(model_path), "models/player/%s/%s.mdl", player_model, player_model)

precache_model(model_path)

// Support modelT.mdl files
formatex(model_path, charsmax(model_path), "models/player/%s/%sT.mdl", player_model, player_model)
if (file_exists(model_path)) precache_model(model_path)

new Array:class_models = ArrayGetCell(g_ZombieClassModelsHandle, classid)

// No models registered yet?
if (class_models == Invalid_Array)
{
class_models = ArrayCreate(32, 1)
ArraySetCell(g_ZombieClassModelsHandle, classid, class_models)
}
ArrayPushString(class_models, player_model)
return true;
}

public _class_zombie_register_claw(plugin_id, num_params)
{
new classid = get_param(1)

if (classid < 0 || classid >= g_ZombieClassCount)
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
return false;
}

// Claw models already loaded from file
if (ArrayGetCell(g_ZombieClassClawsFile, classid))
return true;

new claw_model[64]
get_string(2, claw_model, charsmax(claw_model))

precache_model(claw_model)

new Array:class_claws = ArrayGetCell(g_ZombieClassClawsHandle, classid)

// No models registered yet?
if (class_claws == Invalid_Array)
{
class_claws = ArrayCreate(64, 1)
ArraySetCell(g_ZombieClassClawsHandle, classid, class_claws)
}
ArrayPushString(class_claws, claw_model)
return true;
}

public native_class_zombie_get_id(plugin_id, num_params)
{
new real_name[32]
get_string(1, real_name, charsmax(real_name))

// Loop through every class
new index, zombieclass_name[32]
for (index = 0; index < g_ZombieClassCount; index++)
{
ArrayGetString(g_ZombieClassRealName, index, zombieclass_name, charsmax(zombieclass_name))
if (equali(real_name, zombieclass_name))
return index;
}

return ZP_INVALID_ZOMBIE_CLASS;
}

public native_class_zombie_get_name(plugin_id, num_params)
{
new classid = get_param(1)

if (classid < 0 || classid >= g_ZombieClassCount)
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
return false;
}

new name[32]
ArrayGetString(g_ZombieClassName, classid, name, charsmax(name))

new len = get_param(3)
set_string(2, name, len)
return true;
}


public _class_zombie_get_real_name(plugin_id, num_params)
{
new classid = get_param(1)

if (classid < 0 || classid >= g_ZombieClassCount)
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
return false;
}

new real_name[32]
ArrayGetString(g_ZombieClassRealName, classid, real_name, charsmax(real_name))

new len = get_param(3)
set_string(2, real_name, len)
return true;
}

public native_class_zombie_get_desc(plugin_id, num_params)
{
new classid = get_param(1)

if (classid < 0 || classid >= g_ZombieClassCount)
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
return false;
}

new description[32]
ArrayGetString(g_ZombieClassDesc, classid, description, charsmax(description))

new len = get_param(3)
set_string(2, description, len)
return true;
}

public native_class_zombie_get_count(plugin_id, num_params)
{
return g_ZombieClassCount;
}

public native_class_zombie_show_menu(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

show_menu_zombieclass(id)
return true;
}

public _class_zombie_menu_text_add(plugin_id, num_params)
{
static text[32]
get_string(1, text, charsmax(text))
format(g_AdditionalMenuText, charsmax(g_AdditionalMenuText), "%s%s", g_AdditionalMenuText, text)
}

public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], trace, damage_type)
{
if(!is_user_alive(victim))
return HAM_IGNORED
	
if (!zp_core_is_zombie(victim))
return HAM_IGNORED

//Retrieve the end of the trace
static Float: end[3]
get_tr2(trace, TR_vecEndPos, end);

//This message will draw blood sprites at the end of the trace
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, end[0])
engfunc(EngFunc_WriteCoord, end[1])
engfunc(EngFunc_WriteCoord, end[2]+5.0)
write_short(ef_blood[1])
write_short(ef_blood[0])
write_byte(random_num(0, 255)) // color index
write_byte(random_num(5, 10)) // size
message_end()

return HAM_IGNORED;
}
