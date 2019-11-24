public AddToFullPack(es, e, ent, host, host_flags, player, p_set)
{
if(!is_user_connected(host) || !pev_valid(host) || !pev_valid(ent))
return FMRES_IGNORED

if (ent == g_player_hud[host])
{
static Float:origin[3], Float:forvec[3], Float:voffsets[3]

pev(host, pev_origin, origin)
pev(host, pev_view_ofs, voffsets)
xs_vec_add(origin, voffsets, origin)
velocity_by_aim(host, 12, forvec)
xs_vec_add(origin, forvec, origin)
engfunc(EngFunc_SetOrigin, ent, origin)
set_es(es, ES_Origin, origin)
set_es(es, ES_RenderMode, kRenderTransAdd)
set_es(es, ES_RenderAmt, 255)
}
return FMRES_IGNORED
}

public ShowSprite(id)
{
if(!is_user_connected(id))
return

if(!pev_valid(g_player_hud[id]))
g_player_hud[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
static Float:vecOrigin[3]
get_position(id, float(25), float(25), float(12), vecOrigin)
pev(g_player_hud[id], pev_origin, vecOrigin)
entity_set_origin(g_player_hud[id], vecOrigin)
set_pev(g_player_hud[id], pev_takedamage, 0.0)
set_pev(g_player_hud[id], pev_solid, SOLID_NOT)
set_pev(g_player_hud[id], pev_movetype, MOVETYPE_NOCLIP)
engfunc(EngFunc_SetModel, g_player_hud[id], "sprites/ZBS/kill_1.spr")
set_pev(g_player_hud[id], pev_rendermode, kRenderTransAdd)
set_pev(g_player_hud[id], pev_renderamt, 0.0)
set_pev(g_player_hud[id], pev_scale, 0.03) 
set_pev(g_player_hud[id], pev_animtime, 0.0)
set_pev(g_player_hud[id], pev_framerate, 0.0)
set_pev(g_player_hud[id], pev_spawnflags, SF_SPRITE_STARTON)
dllfunc(DLLFunc_Spawn, g_player_hud[id])
}
public RemoveSprite(id)
{
if(pev_valid(g_player_hud[id]))
{
engfunc(EngFunc_RemoveEntity, g_player_hud[id])
g_player_hud[id] = 0
remove_task(id)
}
else
{
g_player_hud[id] = 0
remove_task(id)
}
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
