#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

new g_fwSpawn
public plugin_init()
{					
unregister_forward(FM_Spawn, g_fwSpawn) 
new szModel[2],
iEntity = get_maxplayers(),
iMaxEntities = get_global_int(GL_maxEntities);
while( ++iEntity <= iMaxEntities) 
{
if(is_valid_ent(iEntity) && entity_get_int(iEntity, EV_INT_rendermode) == kRenderGlow) 
{
entity_get_string(iEntity, EV_SZ_model, szModel, 1);
if(szModel[0] == '*')
entity_set_int(iEntity, EV_INT_rendermode, kRenderNormal);
}
}
}
public plugin_precache()
{	
load_maps()
g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")			
}
load_maps()
{
new file[41], mapname[64]
get_mapname(mapname, charsmax(mapname))
format(file, charsmax(file), "addons/amxmodx/configs/map_fog_color.ini")

if(file_exists(file))
{
new map[64],fog_color[12],fog_density[12]
for(new i=0;i <= file_size(file, 1) - 1;i++)
{
new data[38],buffer
read_file(file, i, data, charsmax(data), buffer)
parse(data, map, charsmax(map), fog_color, charsmax(fog_color), fog_density, charsmax(fog_density)) 

if(equal(mapname, map))
{
new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))	
fm_set_kvd(ent, "density", fog_density, "env_fog")
fm_set_kvd(ent,"rendercolor",fog_color,"env_fog")
} 
}
}
else
log_amx("[NS2] Sorry, but I can't find configs/map_fog_color.ini!")	
}
public fw_Spawn(entity)
{
// Invalid entity
if (!pev_valid(entity))
return FMRES_IGNORED;

// Get classname
new classname[32]
pev(entity, pev_classname, classname, charsmax(classname))

if (equal(classname, "env_fog"))
{
engfunc(EngFunc_RemoveEntity, entity)
return FMRES_SUPERCEDE;
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
