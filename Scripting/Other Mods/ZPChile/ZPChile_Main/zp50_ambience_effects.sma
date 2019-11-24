#include <amxmodx>
#include <fakemeta>
#include <zp50_core_const>

new const g_ambience_ents[][] = { "env_fog"}
new g_fwSpawn

public plugin_init()
{
unregister_forward(FM_Spawn, g_fwSpawn)
}

public plugin_precache()
{
new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
if (pev_valid(ent))
{
fm_set_kvd(ent, "density", "0.0010", "env_fog")
fm_set_kvd(ent, "rendercolor", "0 0 0", "env_fog")
}
g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
}

// Entity Spawn Forward
public fw_Spawn(entity)
{
// Invalid entity
if (!pev_valid(entity))
return FMRES_IGNORED;

// Get classname
new classname[32]
pev(entity, pev_classname, classname, charsmax(classname))

// Check whether it needs to be removed
new index
for (index = 0; index < sizeof g_ambience_ents; index++)
{
if (equal(classname, g_ambience_ents[index]))
{
engfunc(EngFunc_RemoveEntity, entity)
return FMRES_SUPERCEDE;
}
}

return FMRES_IGNORED;
}

// Set an entity's key value (from fakemeta_util)
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
set_kvd(0, KV_ClassName, classname)
set_kvd(0, KV_KeyName, key)
set_kvd(0, KV_Value, value)
set_kvd(0, KV_fHandled, 0)

dllfunc(DLLFunc_KeyValue, entity, 0)
}
