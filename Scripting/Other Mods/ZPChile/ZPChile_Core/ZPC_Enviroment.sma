#include <amxmodx>
#include <engine>
#include <fakemeta>
new const hk[][] ={"gfx/env/hkbk.tga","gfx/env/hkdn.tga","gfx/env/hkft.tga","gfx/env/hklf.tga","gfx/env/hkrt.tga","gfx/env/hkup.tga"}
new const g_ambience_ents[][] = {"env_fog", "env_snow" , "env_rain"}
new HamHook:fwHamSpawn
new g_fwSpawn

public plugin_init()
{		
server_cmd("sv_skyname hk")			
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
for(new i = 0; i < sizeof(hk); i++)
engfunc(EngFunc_PrecacheGeneric, hk[i])
g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))	
fm_set_kvd(ent, "density", "0.0008", "env_fog")
fm_set_kvd(ent,"rendercolor","173 255 47","env_fog")				
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
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
set_kvd(0, KV_ClassName, classname)
set_kvd(0, KV_KeyName, key)
set_kvd(0, KV_Value, value)
set_kvd(0, KV_fHandled, 0)

dllfunc(DLLFunc_KeyValue, entity, 0)
}
