#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core_const>

new const hk[][] ={"gfx/env/hkbk.tga","gfx/env/hkdn.tga","gfx/env/hkft.tga","gfx/env/hklf.tga","gfx/env/hkrt.tga","gfx/env/hkup.tga"}
new g_fwSpawn
public plugin_init()
{		
server_cmd("sv_skyname hk")			
unregister_forward(FM_Spawn, g_fwSpawn) 
}
public plugin_precache()
{
for(new i = 0; i < sizeof(hk); i++)
engfunc(EngFunc_PrecacheGeneric, hk[i])		
load_maps()
load_maps2()		
g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")			
}
load_maps()
{
new map[32]
get_mapname(map, 31)	
if(equal(map, "zm_army_tn_beta3") || equal(map, "zm_cpl_mill_kamp") || equal(map, "zm_zombattack_new") || equal(map, "zm_toxichouse_new") || equal(map, "zm_AandD_extended") || equal(map, "zm_aztec_temple")
|| equal(map, "zm_evil-ice_attack2") || equal(map, "zm_battle_ground2") || equal(map, "zm_snowbase4_zp") || equal(map, "zm_toxic_house2")) 	
return; 
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
load_maps2()
{
new map[32]
get_mapname(map, 31)
if(equal(map, "zm_army_tn_beta3") || equal(map, "zm_cpl_mill_kamp") || equal(map, "zm_zombattack_new") || equal(map, "zm_toxichouse_new"))
{	
new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))			
fm_set_kvd(ent, "density", "0.0013", "env_fog")
fm_set_kvd(ent, "rendercolor", "220 180 50", "env_fog")	
}
if(equal(map, "zm_evil-ice_attack2") || equal(map, "zm_battle_ground2") || equal(map, "zm_snowbase4_zp") || equal(map, "zm_AandD_extended") || equal(map, "zm_aztec_temple"))
{	
new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))			
fm_set_kvd(ent, "density", "0.0016", "env_fog")
fm_set_kvd(ent, "rendercolor", "150 190 230", "env_fog")	
}
if(equal(map, "zm_toxic_house2"))
{	
new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))			
fm_set_kvd(ent, "density", "0.0015", "env_fog")
fm_set_kvd(ent, "rendercolor", "150 180 240", "env_fog")	
}
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
