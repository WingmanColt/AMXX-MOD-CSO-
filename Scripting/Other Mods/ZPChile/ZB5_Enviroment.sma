#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core_const>

new const hk[][] ={"gfx/env/hkbk.tga","gfx/env/hkdn.tga","gfx/env/hkft.tga","gfx/env/hklf.tga","gfx/env/hkrt.tga","gfx/env/hkup.tga"}
new const g_ambience_ents[][] = {"env_fog", "env_snow" , "env_rain"}
new HamHook:fwHamSpawn
new bool:g_bDeSurvivor = false
new g_fwSpawn

public plugin_init()
{		
server_cmd("sv_skyname hk")			
unregister_forward(FM_Spawn, g_fwSpawn)
if(g_bDeSurvivor)
DisableHamForward(fwHamSpawn) 
}
public plugin_precache()
{
for(new i = 0; i < sizeof(hk); i++)
engfunc(EngFunc_PrecacheGeneric, hk[i])				
g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")		
load_maps2()
}

load_maps2()
{
new map[32]
get_mapname(map, 31)	

new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))	
fm_set_kvd(ent, "density", "0.0008", "env_fog")
fm_set_kvd(ent,"rendercolor","0 0 0","env_fog")	

if(equal(map, "de_survivor"))
{	
engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))		
g_bDeSurvivor = true
fwHamSpawn = RegisterHam(Ham_Spawn, "env_sprite", "fwHam_envSpriteSpawn")
} 	

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

public fw_Spawn(entity)
{
if (!pev_valid(entity))
return FMRES_IGNORED;

new classname[32]
pev(entity, pev_classname, classname, charsmax(classname))

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
public fwHam_envSpriteSpawn(ent)
{
new szModel[19]
entity_get_string(ent, EV_SZ_model, szModel, charsmax(szModel))
if(equal(szModel, "sprites/snow.spr") || equal(szModel, "sprites/shadow_circle.spr") || equal(szModel, "sprites/flare1.spr"))
{
remove_entity(ent)
return HAM_SUPERCEDE
}
return HAM_IGNORED
}
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
set_kvd(0, KV_ClassName, classname)
set_kvd(0, KV_KeyName, key)
set_kvd(0, KV_Value, value)
set_kvd(0, KV_fHandled, 0)

dllfunc(DLLFunc_KeyValue, entity, 0)
}
