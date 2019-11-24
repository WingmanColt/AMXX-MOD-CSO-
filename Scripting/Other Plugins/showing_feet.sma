#include <amxmodx>
#include <fakemeta>
#include <xs>

new g_feet[33]
new g_infotarget_string_t

new g_oldmodel[33][32]

public plugin_init()
{
register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
register_forward(FM_ClientUserInfoChanged, "fw_InfoChanged_Post", 1)
g_infotarget_string_t = engfunc(EngFunc_AllocString, "info_target")
}

// Create new legs when a client has joined the server
public client_putinserver(id)
{
create_feet(id)
}

// Legs of a client should be deleted after the client exited the game
public client_disconnect(id)
{
if (!g_feet[id])
return;

engfunc(EngFunc_RemoveEntity, g_feet[id])
g_feet[id] = 0

copy(g_oldmodel[id], charsmax(g_oldmodel[]), "")
}

public fw_AddToFullPack_Post(es, e, ent, host, host_flags, player, p_set)
{
if (player)
return;

if (ent != g_feet[host])
return;

if (!is_user_alive(host))
return;

static Float:origin[3], Float:angles[3], Float:offset[3], Float:framerate
pev(host, pev_origin, origin)
pev(host, pev_v_angle, angles)
pev(host, pev_framerate, framerate)

if (angles[0] > 60.0)
{
set_es(es, ES_RenderFx, kRenderFxNone)
set_es(es, ES_RenderColor, {255, 255, 255})
set_es(es, ES_RenderMode, kRenderNormal)
set_es(es, ES_RenderAmt, 16)
}

angles[0] = 0.0

angle_vector(angles, ANGLEVECTOR_FORWARD, offset)
xs_vec_mul_scalar(offset, -32.0, offset)
xs_vec_add(origin, offset, origin)

pev(host, pev_velocity, offset)
xs_vec_mul_scalar(offset, 0.15, offset)
xs_vec_add(origin, offset, origin)

angles[0] = 30.0

engfunc(EngFunc_SetOrigin, ent, origin)
set_es(es, ES_Angles, angles)
set_es(es, ES_FrameRate, framerate)
set_es(es, ES_Sequence, pev(host, pev_gaitsequence))
}

public fw_InfoChanged_Post(id)
{
// Prevent that the server crashes when a player set his "model" info. himself and connects to the server..
if (!is_user_connected(id))
return;

static model[32]
get_user_info(id, "model", model, charsmax(model))

if (!equal(model, g_oldmodel[id]))
{
copy(g_oldmodel[id], charsmax(g_oldmodel[]), model)
update_feet(id, model)
}
}

// Reusable codes..
create_feet(id)
{
g_feet[id] = engfunc(EngFunc_CreateNamedEntity, g_infotarget_string_t)

if (!pev_valid(g_feet[id]))
{
g_feet[id] = 0
return;
}

static Float:origin[3]
pev(id, pev_origin, origin)
engfunc(EngFunc_SetOrigin, g_feet[id], Float:{8192.0,8192.0,8192.0})

set_pev(g_feet[id], pev_movetype, MOVETYPE_PUSHSTEP)
set_pev(g_feet[id], pev_owner, id)

set_pev(g_feet[id], pev_renderfx, kRenderFxGlowShell)
set_pev(g_feet[id], pev_rendercolor, {0, 0, 0})
set_pev(g_feet[id], pev_rendermode, kRenderTransAlpha)
set_pev(g_feet[id], pev_renderamt, 175)
}

update_feet(id, const feet_mdl[])
{
static model[128]
formatex(model, charsmax(model), "models/player/%s/%s.mdl", feet_mdl, feet_mdl)
engfunc(EngFunc_SetModel, g_feet[id], model)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
