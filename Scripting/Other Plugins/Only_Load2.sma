#include <amxmodx>
#include <amxmisc>
#include <engine>

new g_SpawnFile[256]
new bool:g_LoadSuccessed = false
new bool:g_LoadInit = false
new bool:g_bDeAbyss = false

public plugin_precache()
{
new szMap[13] 
get_mapname(szMap, charsmax(szMap))

if(!equali(szMap, "zm_abyss2"))
return 

g_bDeAbyss = true
	
new configdir[128]
get_configsdir(configdir, 127 )
new spawndir[256]
format(spawndir,255,"%s/zp_supplybox",configdir)

new MapName[32]
get_mapname(MapName, 31)
format(g_SpawnFile, 255, "%s/%s_spawns.cfg",spawndir, MapName)

if (Load_SpawnFlie(1))
g_LoadSuccessed = true
else
g_LoadSuccessed = false
}
public plugin_init()
{
if(!g_bDeAbyss)	
return;

g_LoadInit = true 
register_event("TextMsg", "event_restartgame", "a", "2&#Game_C","2&#Game_w")
}
stock Load_SpawnFlie(type) 
{
if(!g_bDeAbyss)	
return 1;
	
if (file_exists(g_SpawnFile))
{
new ent_T, ent_CT
new Data[128], len, line = 0
new team[8], p_origin[3][8], p_angles[3][8]
new Float:origin[3], Float:angles[3]

while((line = read_file(g_SpawnFile , line , Data , 127 , len) ) != 0 ) 
{
if (strlen(Data)<2) continue

parse(Data, team,7, p_origin[0],7, p_origin[1],7, p_origin[2],7, p_angles[0],7, p_angles[1],7, p_angles[2],7)

origin[0] = str_to_float(p_origin[0]); origin[1] = str_to_float(p_origin[1]); origin[2] = str_to_float(p_origin[2]);
angles[0] = str_to_float(p_angles[0]); angles[1] = str_to_float(p_angles[1]); angles[2] = str_to_float(p_angles[2]);

if (equali(team,"T")){
if (type==1) ent_T = create_entity("info_player_deathmatch")
else ent_T = find_ent_by_class(ent_T, "info_player_deathmatch")
if (ent_T>0){
entity_set_int(ent_T,EV_INT_iuser1,1) 
entity_set_origin(ent_T,origin)
entity_set_vector(ent_T, EV_VEC_angles, angles)
}
}
else if (equali(team,"CT")){
if (type==1) ent_CT = create_entity("info_player_start")
else ent_CT = find_ent_by_class(ent_CT, "info_player_start")
if (ent_CT>0){
entity_set_int(ent_CT,EV_INT_iuser1,1) 
entity_set_origin(ent_CT,origin)
entity_set_vector(ent_CT, EV_VEC_angles, angles)
}
}
}
return 1
}
return 0
}

public pfn_keyvalue(entid)
{  
if(!g_bDeAbyss)	
return PLUGIN_CONTINUE;

if (g_LoadSuccessed && !g_LoadInit){
new classname[32], key[32], value[32]
copy_keyvalue(classname, 31, key, 31, value, 31)

if (equal(classname, "info_player_deathmatch") || equal(classname, "info_player_start")){
if (is_valid_ent(entid) && entity_get_int(entid,EV_INT_iuser1)!=1) 
remove_entity(entid)
}
}
return PLUGIN_CONTINUE
}


public event_restartgame()
{
if(!g_bDeAbyss)	
return;	

Load_SpawnFlie(0)
}
