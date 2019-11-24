#include <amxmodx>
#include <fakemeta>

new const objective_ents[][] = {"func_buyzone", "operaWav", "func_vehicle", "item_longjump", "armoury_entity","trigger_hurt","func_bomb_target","info_bomb_target","info_vip_start","func_vip_safetyzone","func_escapezone","hostage_entity","monster_scientist","func_hostage_rescue","info_hostage_rescue" }
#define CLASSNAME_MAX_LENGTH 32
new Array:g_objective_ents

new g_fwSpawn
public plugin_init()
{
unregister_forward(FM_Spawn, g_fwSpawn)
register_forward(FM_EmitSound, "fw_EmitSound")
register_message(get_user_msgid("Scenario"), "message_scenario")
register_message(get_user_msgid("HostagePos"), "message_hostagepos")
register_message(get_user_msgid("StatusIcon"), "message_status_icon")
}

public plugin_precache()
{
// Initialize arrays
g_objective_ents = ArrayCreate(CLASSNAME_MAX_LENGTH, 1)

new index
if (ArraySize(g_objective_ents) == 0)
{
for (index = 0; index < sizeof objective_ents; index++)
ArrayPushString(g_objective_ents, objective_ents[index])
}

new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
if (pev_valid(ent))
{
engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
dllfunc(DLLFunc_Spawn, ent)
}

// Prevent objective entities from spawning
g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
}
public plugin_cfg()
{
server_cmd("mp_buytime 1")
}
// Entity Spawn Forward
public fw_Spawn(entity)
{
// Invalid entity
if (!pev_valid(entity))
return FMRES_IGNORED;

// Get classname
new classname[32], objective[32], size = ArraySize(g_objective_ents)
pev(entity, pev_classname, classname, charsmax(classname))

// Check whether it needs to be removed
new index
for (index = 0; index < size; index++)
{
ArrayGetString(g_objective_ents, index, objective, charsmax(objective))

if (equal(classname, objective))
{
engfunc(EngFunc_RemoveEntity, entity)
return FMRES_SUPERCEDE;
}
}

return FMRES_IGNORED;
}

// Emit Sound Forward
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
// Block all those unneeeded hostage sounds
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
return FMRES_SUPERCEDE;

return FMRES_IGNORED;
}

// Block hostage HUD display
public message_scenario()
{
if (get_msg_args() > 1)
{
static sprite[8]
get_msg_arg_string(2, sprite, charsmax(sprite))

if (equal(sprite, "hostage"))
return PLUGIN_HANDLED;
}

return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public message_hostagepos()
{
return PLUGIN_HANDLED;
}
public message_status_icon(msg_id, msg_dest, msg_entity)
{
if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
return;

static sprite[10]
get_msg_arg_string(2, sprite, charsmax(sprite))

if (!equal(sprite, "buyzone"))
return;

//if (get_gametime() < g_BuyTimeStart[msg_entity] + 1)
//return;

// Hide buyzone icon after buyzone time is over (bugfix)
set_msg_arg_int(1, get_msg_argtype(1), 0)
}
