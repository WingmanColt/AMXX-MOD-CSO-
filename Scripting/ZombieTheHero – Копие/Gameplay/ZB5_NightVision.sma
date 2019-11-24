#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>
#include <fvault>

enum _:OPT
{
NVG,
USING
}

new const g_vault_name[] = "ZB5_Enviroment";

new const SoundNVG[2][] = { "items/nvg_off.wav", "items/nvg_on.wav"}
new const hk[][] ={"gfx/env/hkbk.tga","gfx/env/hkdn.tga","gfx/env/hkft.tga","gfx/env/hklf.tga","gfx/env/hkrt.tga","gfx/env/hkup.tga"}

new g_had[33][OPT], g_GameLight[2]
new g_MsgScreenFade, g_fwSpawn

public plugin_init() 
{	
set_cvar_num("sv_skycolor_r", 0)
set_cvar_num("sv_skycolor_g", 0)
set_cvar_num("sv_skycolor_b", 0)
server_cmd("sv_skyname hk")	

register_clcmd("nightvision", "CMD_NightVision")
unregister_forward(FM_Spawn, g_fwSpawn)

g_MsgScreenFade = get_user_msgid("ScreenFade")
}
public plugin_precache()
{
for(new i = 0; i < sizeof(hk); i++)
engfunc(EngFunc_PrecacheGeneric, hk[i])	

g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")

LoadData()	
Fog()
}
public client_putinserver(id)
{
SetPlayerLight(id, g_GameLight)	
}
public zp_fw_core_cure_post(id)
{	
SetPlayerLight(id, g_GameLight)		
Set_PlayerNVG(id, 0, 0, 0, 0)	
}
public zp_fw_core_spawn_post(id)
{
Set_PlayerNVG(id, 0, 0, 0, 0)
	
if(zp_core_is_zombie(id))
Set_PlayerNVG(id, 1, 0, 0, 1)
}
public zp_fw_core_infect_post(id)
{
if(zp_core_is_zombie(id))
Set_PlayerNVG(id, 1, 1, 0, 1)	
}
public zp_fw_core_dead_post(id)
{
SetPlayerLight(id, g_GameLight)		
Set_PlayerNVG(id, 0, 0, 0, 0)	
}
public CMD_NightVision(id)
{
if(!g_had[id][NVG])
return PLUGIN_HANDLED

if(!g_had[id][USING]) set_user_nightvision(id, 1, 1, 0)
else set_user_nightvision(id, 0, 1, 0)

return PLUGIN_HANDLED;
}
public Set_PlayerNVG(id, Give, On, OnSound, Ignored_HadNVG)
{
if(Give) g_had[id][NVG] = true
set_user_nightvision(id, On, OnSound, Ignored_HadNVG)
}

public set_user_nightvision(id, On, OnSound, Ignored_HadNVG)
{
if(!Ignored_HadNVG)
{
if(!g_had[id][NVG])
return
}

if(On) g_had[id][USING] = true
else g_had[id][USING] = false

if(OnSound) PlaySound(id, SoundNVG[On])
set_user_nvision(id)

return
}

public set_user_nvision(id)
{	
static Alpha
if(is_user_alive(id))
Alpha = g_had[id][USING] ? 80:0
else Alpha = 0
message_begin(MSG_ONE_UNRELIABLE, g_MsgScreenFade, _, id)
write_short(0) // duration
write_short(0) // hold time
write_short(0x0004) // fade type
if(!zp_core_is_zombie(id))
{
write_byte(125) // r
write_byte(170) // g
write_byte(10) // b
} else {
write_byte(170) // r
write_byte(20) // g
write_byte(0) // b
}
write_byte(Alpha) // alpha
message_end()

if(is_user_alive(id))
SetPlayerLight(id, g_had[id][USING]? "#" : g_GameLight)
}
// NATIVE
public plugin_natives()
{
register_native("zb5_get_user_nvg", "Native_GetNVG", 1)
register_native("zb5_set_user_nvg", "Native_SetNVG", 1)
}

public Native_GetNVG(id) return g_had[id][NVG]
public Native_SetNVG(id, Give, On, Sound, IgnoredHad)
{
if(!is_user_connected(id))
return

if(Give) g_had[id][NVG] = true
set_user_nightvision(id, On, Sound, IgnoredHad)
}

//// ENVIROMENT
public Fog()
{
new file[512], mapname[25]
get_mapname(mapname, charsmax(mapname))
format(file, charsmax(file), "addons/amxmodx/configs/map_options.ini")

if(file_exists(file))
{
new map[30],fog_color[12],fog_density[10]
for(new i=0;i <= file_size(file, 1) - 1;i++)
{
static data[128],buffer
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
else log_amx("[ZB5] Sorry, but I can't find configs/map_options.ini!")	
}
public fw_Spawn(entity)
{
if (!pev_valid(entity))
return FMRES_IGNORED;

static classname[32]
pev(entity, pev_classname, classname, charsmax(classname))

if (equal(classname, "env_fog"))
{
engfunc(EngFunc_RemoveEntity, entity)
return FMRES_SUPERCEDE;
}

return FMRES_IGNORED;
}

// STOCK 
stock SetPlayerLight(id, const LightStyle[])
{
if(id != 0)
{
message_begin(MSG_ONE_UNRELIABLE, SVC_LIGHTSTYLE, .player = id)
write_byte(0)
write_string(LightStyle)
message_end()		
} else {
message_begin(MSG_BROADCAST, SVC_LIGHTSTYLE)
write_byte(0)
write_string(LightStyle)
message_end()	
}
}

// FVAULT
public SaveData()
{	
static szName[25], szData[64]
get_mapname(szName, charsmax(szName))

format(szData, charsmax(szData), "%d", g_GameLight);
fvault_set_data(g_vault_name, szName, szData);
}
public LoadData()
{
static szName[25], szData[64]
get_mapname(szName, charsmax(szName))

format(szData, charsmax(szData), "%d", g_GameLight);

if(fvault_get_data(g_vault_name, szName, szData, sizeof(szData) - 1) )
{
switch(zp_core_round())	
{
case MODE_AMBUSH:g_GameLight = "b"
default:
{
if(equal(szData, "1"))
g_GameLight = "z"
else if(equal(szData, "2"))
g_GameLight = "i"
else if(equal(szData, "3"))
g_GameLight = "e"
else if(equal(szData, "4"))
g_GameLight = "c"	
}
}	
}
}

