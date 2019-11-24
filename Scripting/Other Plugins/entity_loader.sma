#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

enum entity_data
{
entity_index,
entity_solid
};

#define TASK_ID_CHECK	10000
new Array:g_class,Array:g_model,g_ent_class[33][32]
new g_total, szMap[13],bool:g_connected[33], g_save_file[200]
new g_ent[33], g_max_players,g_ent_model[33][32]
public plugin_init()
{
get_mapname(szMap, charsmax(szMap))	
if(!equali(szMap, "de_survivor"))
return 
register_event("HLTV", "EventNewRound", "a", "1=0", "2=0");
register_logevent("EventNewRound", 2, "1=Round_Start");
register_logevent("EventNewRound", 2, "1=Round_End");
g_max_players = global_get(glb_maxClients);
}

public plugin_precache()
{
get_mapname(szMap, charsmax(szMap))	
if(!equali(szMap, "de_survivor"))
return 	
g_class = ArrayCreate(32, 1);
g_model = ArrayCreate(32, 1);
get_datadir(g_save_file, 199);
add(g_save_file, 199, "/removed_entities", 0);
if( !dir_exists(g_save_file) )
{
mkdir(g_save_file);
}
format(g_save_file, 199, "%s/de_survivor.txt", g_save_file);
LoadEntities();
register_forward(FM_Spawn, "FwdSpawn", 0);
}
public FwdSpawn(ent)
{
if( pev_valid(ent) )
{
set_task(0.1, "TaskDelayedCheck", ent + TASK_ID_CHECK, "", 0, "", 0);

return FMRES_HANDLED;
}

return FMRES_IGNORED;
}

public TaskDelayedCheck(ent)
{
ent -= TASK_ID_CHECK;

if( !pev_valid(ent) )
{
return PLUGIN_CONTINUE;
}

new class[32], sModel[32];
pev(ent, pev_classname, class, 32);
pev(ent, pev_model, sModel, 32);

new saved_class[32], saved_model[32];
for( new i; i < g_total; i++ )
{
ArrayGetString(g_class, i, saved_class, 32);
ArrayGetString(g_model, i, saved_model, 32);

if( equal(class, saved_class, 0) && equal(sModel, saved_model, 0) )
{
RemoveEntity(ent);
break;
}
}

return PLUGIN_CONTINUE;
}

public client_connect(plr)
{
g_ent[plr] = 0;
g_ent_class[plr][0] = '^0';
g_ent_model[plr][0] = '^0';

return PLUGIN_CONTINUE;
}

public client_putinserver(plr)
{
g_connected[plr] = true;

return PLUGIN_CONTINUE;
}

public client_disconnect(plr)
{
g_connected[plr] = false;

return PLUGIN_CONTINUE;
}
public EventNewRound()
{
if( !g_total )
{
return PLUGIN_CONTINUE;
}

new ent, class[32], saved_model[32], ent_model[32];
for( new i = 0; i < g_total; i++ )
{
ArrayGetString(g_class, i, class, 31);
ArrayGetString(g_model, i, saved_model, 31);

ent = g_max_players;
while( (ent = engfunc(EngFunc_FindEntityByString, ent, "classname", class)) )
{
pev(ent, pev_model, ent_model, 31);

if( equal(saved_model, ent_model, 0) )
{
RemoveEntity(ent);
break;
}
}
}

return PLUGIN_CONTINUE;
}

LoadEntities()
{
if( file_exists(g_save_file) )
{
new f = fopen(g_save_file, "rt");

new data[70], class[32], model[32];

while( !feof(f) )
{
fgets(f, data, 69);

parse(data, class, 32, model, 32);

ArrayPushString(g_class, class);
ArrayPushString(g_model, model);
g_total++;
}

fclose(f);

return 1;
}

return 0;
}

RemoveEntity(ent)
{
set_pev(ent, pev_rendermode, kRenderTransAlpha);
set_pev(ent, pev_renderamt, 0);
set_pev(ent, pev_solid, SOLID_NOT);
return 1;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
