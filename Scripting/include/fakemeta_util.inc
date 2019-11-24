/**
* This file provides various utility functions that use the Fakemeta module.
* This file is created and maintained by VEN.
* For support and issues, see:
* http://forums.alliedmods.net/showthread.php?t=28284
*/


/* Fakemeta Utilities
*
* by VEN
*
* This file is provided as is (no warranties).
*/

#if !defined _fakemeta_included
#include <fakemeta>
#endif

#if defined _fakemeta_util_included
#endinput
#endif
#define _fakemeta_util_included

#include <xs>
#include <hamsandwich>
#include <cstrike>
#include <ScenarioMod>

stock const Float:g_fDelay[CSW_P90+1] = {
0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}

#define PLAYER_LINUX_XTRA_OFF 5
#define WEAP_LINUX_XTRA_OFF 4
#define m_iClip	51
#define m_fInReload 54
#define m_flNextPrimaryAttack 46
#define m_flNextSecondaryAttack 47
#define m_flTimeWeaponIdle 48
#define m_flNextAttack 83

/* Engine functions */

#define fm_precache_generic(%1) engfunc(EngFunc_PrecacheGeneric, %1)
/* stock fm_precache_generic(const file[])
return engfunc(EngFunc_PrecacheGeneric, file) */

#define fm_precache_event(%1,%2) engfunc(EngFunc_PrecacheEvent, %1, %2)
/* stock fm_precache_event(type, const name[])
return engfunc(EngFunc_PrecacheEvent, type, name) */

// ported by v3x
#define fm_drop_to_floor(%1) engfunc(EngFunc_DropToFloor, %1)
/* stock fm_drop_to_floor(entity)
return engfunc(EngFunc_DropToFloor, entity) */

#define fm_force_use(%1,%2) dllfunc(DLLFunc_Use, %2, %1)
/* stock fm_force_use(user, used)
return dllfunc(DLLFunc_Use, used, user) */

#define fm_entity_set_size(%1,%2,%3) engfunc(EngFunc_SetSize, %1, %2, %3)
/* stock fm_entity_set_size(index, const Float:mins[3], const Float:maxs[3])
return engfunc(EngFunc_SetSize, index, mins, maxs) */

#define fm_get_decal_index(%1) engfunc(EngFunc_DecalIndex, %1)
/* stock fm_get_decal_index(const decalname[])
return engfunc(EngFunc_DecalIndex, decalname) */

stock Float:fm_entity_range(ent1, ent2) {
new Float:origin1[3], Float:origin2[3];
pev(ent1, pev_origin, origin1);
pev(ent2, pev_origin, origin2);

return get_distance_f(origin1, origin2);
}

// based on KoST's port, upgraded version fits into the macros
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))
/* stock fm_create_entity(const classname[])
return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname)) */

#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
/* stock fm_find_ent_by_class(index, const classname[])
return engfunc(EngFunc_FindEntityByString, index, "classname", classname) */

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
new strtype[11] = "classname", ent = index;
switch (jghgtype) {
case 1: strtype = "target";
case 2: strtype = "targetname";
}

while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

return ent;
}

#define fm_find_ent_by_target(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "target", %2)
/* stock fm_find_ent_by_target(index, const target[])
return engfunc(EngFunc_FindEntityByString, index, "target", target) */

#define fm_find_ent_by_tname(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "targetname", %2)
/* stock fm_find_ent_by_tname(index, const targetname[])
return engfunc(EngFunc_FindEntityByString, index, "targetname", targetname) */

stock fm_find_ent_by_model(index, const classname[], const model[]) {
new ent = index, mdl[72];
while ((ent = fm_find_ent_by_class(ent, classname))) {
pev(ent, pev_model, mdl, sizeof mdl - 1);
if (equal(mdl, model))
return ent;
}

return 0;
}

#define fm_find_ent_in_sphere(%1,%2,%3) engfunc(EngFunc_FindEntityInSphere, %1, %2, %3)
/* stock fm_find_ent_in_sphere(index, const Float:origin[3], Float:radius)
return engfunc(EngFunc_FindEntityInSphere, index, origin, radius) */

#define fm_call_think(%1) dllfunc(DLLFunc_Think, %1)
/* stock fm_call_think(entity)
return dllfunc(DLLFunc_Think, entity) */

#define fm_is_valid_ent(%1) pev_valid(%1)
/* stock fm_is_valid_ent(index)
return pev_valid(index) */

stock fm_entity_set_origin(index, const Float:origin[3]) {
new Float:mins[3], Float:maxs[3];
pev(index, pev_mins, mins);
pev(index, pev_maxs, maxs);
engfunc(EngFunc_SetSize, index, mins, maxs);

return engfunc(EngFunc_SetOrigin, index, origin);
}

#define fm_entity_set_model(%1,%2) engfunc(EngFunc_SetModel, %1, %2)
/* stock fm_entity_set_model(index, const model[])
return engfunc(EngFunc_SetModel, index, model) */

// ported by v3x
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
/* stock fm_remove_entity(index)
return engfunc(EngFunc_RemoveEntity, index) */

#define fm_entity_count() engfunc(EngFunc_NumberOfEntities)
/* stock fm_entity_count()
return engfunc(EngFunc_NumberOfEntities) */

#define fm_fake_touch(%1,%2) dllfunc(DLLFunc_Touch, %1, %2)
/* stock fm_fake_touch(toucher, touched)
return dllfunc(DLLFunc_Touch, toucher, touched) */

#define fm_DispatchSpawn(%1) dllfunc(DLLFunc_Spawn, %1)
/* stock fm_DispatchSpawn(entity)
return dllfunc(DLLFunc_Spawn, entity) */

// ported by v3x
#define fm_point_contents(%1) engfunc(EngFunc_PointContents, %1)
/* stock fm_point_contents(const Float:point[3])
return engfunc(EngFunc_PointContents, point) */

stock fm_trace_line(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3]) {
engfunc(EngFunc_TraceLine, start, end, ignoreent == -1 ? 1 : 0, ignoreent, 0);

new ent = get_tr2(0, TR_pHit);
get_tr2(0, TR_vecEndPos, ret);

return pev_valid(ent) ? ent : 0;
}

stock fm_trace_hull(const Float:origin[3], hull, ignoredent = 0, ignoremonsters = 0) {
new result = 0;
engfunc(EngFunc_TraceHull, origin, origin, ignoremonsters, hull, ignoredent > 0 ? ignoredent : 0, 0);

if (get_tr2(0, TR_StartSolid))
result += 1;
if (get_tr2(0, TR_AllSolid))
result += 2;
if (!get_tr2(0, TR_InOpen))
result += 4;

return result;
}

stock fm_trace_normal(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3]) {
engfunc(EngFunc_TraceLine, start, end, 0, ignoreent, 0);
get_tr2(0, TR_vecPlaneNormal, ret);

new Float:fraction;
get_tr2(0, TR_flFraction, fraction);
if (fraction >= 1.0)
return 0;

return 1;
}

// note that for CS planted C4 has a "grenade" classname as well
stock fm_get_grenade_id(id, model[], len, grenadeid = 0) {
new ent = fm_find_ent_by_owner(grenadeid, "grenade", id);
if (ent && len > 0)
pev(ent, pev_model, model, len);

return ent;
}

#define fm_halflife_time() get_gametime()
/* stock Float:fm_halflife_time()
return get_gametime() */

#define fm_attach_view(%1,%2) engfunc(EngFunc_SetView, %1, %2)
/* stock fm_attach_view(index, entity)
return engfunc(EngFunc_SetView, index, entity) */

stock fm_playback_event(flags, invoker, eventindex, Float:delay, const Float:origin[3], const Float:angles[3], Float:fparam1, Float:fparam2, iparam1, iparam2, bparam1, bparam2) {
return engfunc(EngFunc_PlaybackEvent, flags, invoker, eventindex, delay, origin, angles, fparam1, fparam2, iparam1, iparam2, bparam1, bparam2);
}

#define fm_eng_get_string(%1,%2,%3) engfunc(EngFunc_SzFromIndex, %1, %2, %3)
/* stock fm_eng_get_string(istring, string[], len)
return engfunc(EngFunc_SzFromIndex, istring, string, len) */


/* HLSDK functions */

// the dot product is performed in 2d, making the view cone infinitely tall
stock bool:fm_is_in_viewcone(index, const Float:point[3]) {
new Float:angles[3];
pev(index, pev_angles, angles);
engfunc(EngFunc_MakeVectors, angles);
global_get(glb_v_forward, angles);
angles[2] = 0.0;

new Float:origin[3], Float:diff[3], Float:norm[3];
pev(index, pev_origin, origin);
xs_vec_sub(point, origin, diff);
diff[2] = 0.0;
xs_vec_normalize(diff, norm);

new Float:dot, Float:fov;
dot = xs_vec_dot(norm, angles);
pev(index, pev_fov, fov);
if (dot >= floatcos(fov * M_PI / 360))
return true;

return false;
}

stock bool:fm_is_visible(index, const Float:point[3], ignoremonsters = 0) {
new Float:start[3], Float:view_ofs[3];
pev(index, pev_origin, start);
pev(index, pev_view_ofs, view_ofs);
xs_vec_add(start, view_ofs, start);

engfunc(EngFunc_TraceLine, start, point, ignoremonsters, index, 0);

new Float:fraction;
get_tr2(0, TR_flFraction, fraction);
if (fraction == 1.0)
return true;

return false;
}


/* Engine_stocks functions */

stock fm_fakedamage(victim, const classname[], Float:takedmgdamage, damagetype) {
new class[] = "trigger_hurt";
new entity = fm_create_entity(class);
if (!entity)
return 0;

new value[16];
float_to_str(takedmgdamage * 2, value, sizeof value - 1);
fm_set_kvd(entity, "dmg", value, class);

num_to_str(damagetype, value, sizeof value - 1);
fm_set_kvd(entity, "damagetype", value, class);

fm_set_kvd(entity, "origin", "8192 8192 8192", class);
fm_DispatchSpawn(entity);

set_pev(entity, pev_classname, classname);
fm_fake_touch(entity, victim);
fm_remove_entity(entity);

return 1;
}

#define fm_find_ent(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
/* stock fm_find_ent(index, const classname[])
return engfunc(EngFunc_FindEntityByString, index, "classname", classname) */

#define fm_get_user_button(%1) pev(%1, pev_button)
/* stock fm_get_user_button(index)
return pev(index, pev_button) */

#define fm_get_user_oldbutton(%1) pev(%1, pev_oldbuttons)
/* stock fm_get_user_oldbutton(index)
return pev(index, pev_oldbuttons) */

#define fm_get_entity_flags(%1) pev(%1, pev_flags)
/* stock fm_get_entity_flags(index)
return pev(index, pev_flags) */

#define fm_get_entity_distance(%1,%2) floatround(fm_entity_range(%1, %2))
/* stock fm_get_entity_distance(ent1, ent2)
return floatround(fm_entity_range(ent1, ent2)) */

#define fm_get_grenade(%1) fm_get_grenade_id(%1, "", 0)
/* stock fm_get_grenade(id)
return fm_get_grenade_id(id, "", 0) */

// optimization idea by Orangutanz
stock fm_get_brush_entity_origin(index, Float:origin[3]) {
new Float:mins[3], Float:maxs[3];

pev(index, pev_origin, origin);
pev(index, pev_mins, mins);
pev(index, pev_maxs, maxs);

origin[0] += (mins[0] + maxs[0]) * 0.5;
origin[1] += (mins[1] + maxs[1]) * 0.5;
origin[2] += (mins[2] + maxs[2]) * 0.5;

return 1;
}

// based on v3x's port, upgraded version returns number of removed entities
stock fm_remove_entity_name(const classname[]) {
new ent = -1, num = 0;
while ((ent = fm_find_ent_by_class(ent, classname)))
num += fm_remove_entity(ent);

return num;
}

stock fm_ViewContents(id) {
new origin[3], Float:Orig[3];
get_user_origin(id, origin, 3);
IVecFVec(origin, Orig);

return fm_point_contents(Orig);
}

stock fm_get_speed(entity) {
new Float:Vel[3];
pev(entity, pev_velocity, Vel);

return floatround(vector_length(Vel));
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
new Float:RenderColor[3];
RenderColor[0] = float(r);
RenderColor[1] = float(g);
RenderColor[2] = float(b);

set_pev(entity, pev_renderfx, fx);
set_pev(entity, pev_rendercolor, RenderColor);
set_pev(entity, pev_rendermode, render);
set_pev(entity, pev_renderamt, float(amount));

return 1;
}

stock fm_set_entity_flags(index, flag, onoff) {
new flags = pev(index, pev_flags);
if ((flags & flag) > 0)
return onoff == 1 ? 2 : 1 + 0 * set_pev(index, pev_flags, flags - flag);
else
return onoff == 0 ? 2 : 1 + 0 * set_pev(index, pev_flags, flags + flag);

return 0;
}

stock fm_set_entity_visibility(index, visible = 1)
{
if(pev_valid(index))	
set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW);

return 1;
}

#define fm_get_entity_visibility(%1) (!(pev(%1, pev_effects) & EF_NODRAW))
/* stock fm_get_entity_visibility(index)
return !(pev(index, pev_effects) & EF_NODRAW) */

stock fm_set_user_velocity(entity, const Float:vector[3]) {
set_pev(entity, pev_velocity, vector);

return 1;
}

#define fm_get_user_velocity(%1,%2) pev(%1, pev_velocity, %2)
/* stock fm_get_user_velocity(entity, Float:vector[3])
return pev(entity, pev_velocity, vector) */


/* Fun functions */

#define fm_get_client_listen(%1,%2) engfunc(EngFunc_GetClientListening, %1, %2)
/* stock fm_get_client_listen(receiver, sender)
return engfunc(EngFunc_GetClientListening, receiver, sender) */

#define fm_set_client_listen(%1,%2,%3) engfunc(EngFunc_SetClientListening, %1, %2, %3)
/* stock fm_set_client_listen(receiver, sender, listen)
return engfunc(EngFunc_SetClientListening, receiver, sender, listen) */

stock fm_get_user_godmode(index) {
new Float:val;
pev(index, pev_takedamage, val);

return (val == DAMAGE_NO);
}

stock fm_set_user_godmode(index, godmode = 0) {
set_pev(index, pev_takedamage, godmode == 1 ? DAMAGE_NO : DAMAGE_AIM);

return 1;
}

stock fm_set_user_armor(index, armor) {
set_pev(index, pev_armorvalue, float(armor));

return 1;
}

stock fm_set_user_health(index, health) {
health > 0 ? set_pev(index, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, index);

return 1;
}

stock fm_set_user_origin(index, /* const */ origin[3]) {
new Float:orig[3];
IVecFVec(origin, orig);

return fm_entity_set_origin(index, orig);
}

stock fm_set_user_rendering(index, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
return fm_set_rendering(index, fx, r, g, b, render, amount);
}

stock fm_give_item(index, const item[]) {
if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
return 0;

new ent = fm_create_entity(item);
if (!pev_valid(ent))
return 0;

new Float:origin[3];
pev(index, pev_origin, origin);
set_pev(ent, pev_origin, origin);
set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
dllfunc(DLLFunc_Spawn, ent);

new save = pev(ent, pev_solid);
dllfunc(DLLFunc_Touch, ent, index);
if (pev(ent, pev_solid) != save)
return ent;

engfunc(EngFunc_RemoveEntity, ent);

return -1;
}

stock fm_set_user_maxspeed(index, Float:speed = -1.0) {
engfunc(EngFunc_SetClientMaxspeed, index, speed);
set_pev(index, pev_maxspeed, speed);

return 1;
}

stock Float:fm_get_user_maxspeed(index) {
new Float:speed;
pev(index, pev_maxspeed, speed);

return speed;
}

stock fm_set_user_gravity(index, Float:gravity = 1.0) {
set_pev(index, pev_gravity, gravity);

return 1;
}

stock Float:fm_get_user_gravity(index) {
new Float:gravity;
pev(index, pev_gravity, gravity);

return gravity;
}

/* interferes with FM_Spawn enum, just use fm_DispatchSpawn
stock fm_spawn(entity) {
return dllfunc(DLLFunc_Spawn, entity)
}
*/

stock fm_set_user_noclip(index, noclip = 0) {
set_pev(index, pev_movetype, noclip == 1 ? MOVETYPE_NOCLIP : MOVETYPE_WALK);

return 1;
}

#define fm_get_user_noclip(%1) (pev(%1, pev_movetype) == MOVETYPE_NOCLIP)
/* stock fm_get_user_noclip(index)
return (pev(index, pev_movetype) == MOVETYPE_NOCLIP) */

// note: get_user_weapon will still return former weapon index
stock fm_strip_user_weapons(index) {
new ent = fm_create_entity("player_weaponstrip");
if (!pev_valid(ent))
return 0;

dllfunc(DLLFunc_Spawn, ent);
dllfunc(DLLFunc_Use, ent, index);
engfunc(EngFunc_RemoveEntity, ent);

return 1;
}

stock fm_set_user_frags(index, frags) {
set_pev(index, pev_frags, float(frags));

return 1;
}


/* Cstrike functions */

stock fm_cs_user_spawn(index) {
set_pev(index, pev_deadflag, DEAD_RESPAWNABLE);
dllfunc(DLLFunc_Spawn, index);
set_pev(index, pev_iuser1, 0);

return 1;
}


/* Custom functions */

// based on Basic-Master's set_keyvalue, upgraded version accepts an optional classname (a bit more efficient if it is passed)
stock fm_set_kvd(entity, const key[], const value[], const classname[] = "") {
if (classname[0])
set_kvd(0, KV_ClassName, classname);
else {
new class[32];
pev(entity, pev_classname, class, sizeof class - 1);
set_kvd(0, KV_ClassName, class);
}

set_kvd(0, KV_KeyName, key);
set_kvd(0, KV_Value, value);
set_kvd(0, KV_fHandled, 0);

return dllfunc(DLLFunc_KeyValue, entity, 0);
}

stock fm_find_ent_by_integer(index, pev_field, value) {
static maxents;
if (!maxents)
maxents = global_get(glb_maxEntities);

for (new i = index + 1; i < maxents; ++i) {
if (pev_valid(i) && pev(i, pev_field) == value)
return i;
}

return 0;
}

stock fm_find_ent_by_flags(index, pev_field, flags) {
static maxents;
if (!maxents)
maxents = global_get(glb_maxEntities);

for (new i = index + 1; i < maxents; ++i) {
if (pev_valid(i) && (pev(i, pev_field) & flags) == flags)
return i;
}

return 0;
}

stock Float:fm_distance_to_box(const Float:point[3], const Float:mins[3], const Float:maxs[3]) {
new Float:dist[3];
for (new i = 0; i < 3; ++i) {
if (point[i] > maxs[i])
dist[i] = point[i] - maxs[i];
else if (mins[i] > point[i])
dist[i] = mins[i] - point[i];
}

return vector_length(dist);
}

stock Float:fm_boxes_distance(const Float:mins1[3], const Float:maxs1[3], const Float:mins2[3], const Float:maxs2[3]) {
new Float:dist[3];
for (new i = 0; i < 3; ++i) {
if (mins1[i] > maxs2[i])
dist[i] = mins1[i] - maxs2[i];
else if (mins2[i] > maxs1[i])
dist[i] = mins2[i] - maxs1[i];
}

return vector_length(dist);
}

stock Float:fm_distance_to_boxent(entity, boxent) {
new Float:point[3];
pev(entity, pev_origin, point);

new Float:mins[3], Float:maxs[3];
pev(boxent, pev_absmin, mins);
pev(boxent, pev_absmax, maxs);

return fm_distance_to_box(point, mins, maxs);
}

stock Float:fm_boxents_distance(boxent1, boxent2) {
new Float:mins1[3], Float:maxs1[3];
pev(boxent1, pev_absmin, mins1);
pev(boxent1, pev_absmax, maxs1);

new Float:mins2[3], Float:maxs2[3];
pev(boxent2, pev_absmin, mins2);
pev(boxent2, pev_absmax, maxs2);

return fm_boxes_distance(mins1, maxs1, mins2, maxs2);
}

// projects a center of a player's feet base (originally by P34nut, improved)
stock Float:fm_distance_to_floor(index, ignoremonsters = 1) {
new Float:start[3], Float:dest[3], Float:end[3];
pev(index, pev_origin, start);
dest[0] = start[0];
dest[1] = start[1];
dest[2] = -8191.0;

engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);
get_tr2(0, TR_vecEndPos, end);

pev(index, pev_absmin, start);
new Float:ret = start[2] - end[2];

return ret > 0 ? ret : 0.0;
}

// potential to crash (?) if used on weaponbox+weapon_* entity pair (use fm_remove_weaponbox instead)
stock fm_kill_entity(index) {
set_pev(index, pev_flags, pev(index, pev_flags) | FL_KILLME);

return 1;
}

// if weapon index isn't passed then assuming that it's the current weapon
stock fm_get_user_weapon_entity(id, wid = 0) {
new weap = wid, clip, ammo;
if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
return 0;

new class[32];
get_weaponname(weap, class, sizeof class - 1);

return fm_find_ent_by_owner(-1, class, id);
}

// only weapon index or its name can be passed, if neither is passed then the current gun will be stripped
stock bool:fm_strip_user_gun(index, wid = 0, const wname[] = "") {
new ent_class[32];
if (!wid && wname[0])
copy(ent_class, sizeof ent_class - 1, wname);
else {
new weapon = wid, clip, ammo;
if (!weapon && !(weapon = get_user_weapon(index, clip, ammo)))
return false;

get_weaponname(weapon, ent_class, sizeof ent_class - 1);
}

new ent_weap = fm_find_ent_by_owner(-1, ent_class, index);
if (!ent_weap)
return false;

engclient_cmd(index, "drop", ent_class);

new ent_box = pev(ent_weap, pev_owner);
if (!ent_box || ent_box == index)
return false;

dllfunc(DLLFunc_Think, ent_box);

return true;
}

// only weapon index or its name can be passed, if neither is passed then the current gun will be transferred
stock bool:fm_transfer_user_gun(index1, index2, wid = 0, const wname[] = "") {
new ent_class[32];
if (!wid && wname[0])
copy(ent_class, sizeof ent_class - 1, wname);
else {
new weapon = wid, clip, ammo;
if (!weapon && !(weapon = get_user_weapon(index1, clip, ammo)))
return false;

get_weaponname(weapon, ent_class, sizeof ent_class - 1);
}

new ent_weap = fm_find_ent_by_owner(-1, ent_class, index1);
if (!ent_weap)
return false;

engclient_cmd(index1, "drop", ent_class);

new ent_box = pev(ent_weap, pev_owner);
if (!ent_box || ent_box == index1)
return false;

set_pev(ent_box, pev_flags, pev(ent_box, pev_flags) | FL_ONGROUND);
dllfunc(DLLFunc_Touch, ent_box, index2);
if (pev(ent_weap, pev_owner) != index2)
return false;

return true;
}

stock bool:fm_is_ent_visible(index, entity, ignoremonsters = 0) {
new Float:start[3], Float:dest[3];
pev(index, pev_origin, start);
pev(index, pev_view_ofs, dest);
xs_vec_add(start, dest, start);

pev(entity, pev_origin, dest);
engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);

new Float:fraction;
get_tr2(0, TR_flFraction, fraction);
if (fraction == 1.0 || get_tr2(0, TR_pHit) == entity)
return true;

return false;
}

// ported from AMXX's core get_user_origin(..., 3) (suggested by Greenberet)
stock fm_get_aim_origin(index, Float:origin[3]) {
new Float:start[3], Float:view_ofs[3];
pev(index, pev_origin, start);
pev(index, pev_view_ofs, view_ofs);
xs_vec_add(start, view_ofs, start);

new Float:dest[3];
pev(index, pev_v_angle, dest);
engfunc(EngFunc_MakeVectors, dest);
global_get(glb_v_forward, dest);
xs_vec_mul_scalar(dest, 9999.0, dest);
xs_vec_add(start, dest, dest);

engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
get_tr2(0, TR_vecEndPos, origin);

return 1;
}

stock bool:fm_get_user_longjump(index) {
new value[2];
engfunc(EngFunc_GetPhysicsKeyValue, index, "slj", value, 1);
switch (value[0]) {
case '1': return true;
}

return false;
}

stock fm_set_user_longjump(index, bool:longjump = true, bool:tempicon = true) {
if (longjump == fm_get_user_longjump(index))
return;

if (longjump) {
engfunc(EngFunc_SetPhysicsKeyValue, index, "slj", "1");
if (tempicon) {
static msgid_itempickup;
if (!msgid_itempickup)
msgid_itempickup = get_user_msgid("ItemPickup");

message_begin(MSG_ONE, msgid_itempickup, _, index);
write_string("item_longjump");
message_end();
}
}
else
engfunc(EngFunc_SetPhysicsKeyValue, index, "slj", "0");
}

#define WEAPON_SUIT 31

stock bool:fm_get_user_suit(index) {
return bool:(!(!(pev(index, pev_weapons) & (1<<WEAPON_SUIT)))); // i'm not insane, this is a trick!
}

stock fm_set_user_suit(index, bool:suit = true, bool:sound = true) {
new weapons = pev(index, pev_weapons);
if (!suit)
set_pev(index, pev_weapons, weapons & ~(1<<WEAPON_SUIT));
else if (!(weapons & (1<<WEAPON_SUIT))) {
set_pev(index, pev_weapons, weapons | (1<<WEAPON_SUIT));
if (sound)
emit_sound(index, CHAN_VOICE, "items/tr_kevlar.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}
}

#define FEV_RELIABLE (1<<1)
#define FEV_GLOBAL (1<<2)

// removes all created decals and players' corpses from the world
// set a specific index to remove decals only for the given client
stock fm_cs_remove_decals(index = 0) {
static eventindex_decal_reset;
if (!eventindex_decal_reset)
eventindex_decal_reset = engfunc(EngFunc_PrecacheEvent, 1, "events/decal_reset.sc");

new flags = FEV_RELIABLE;
if (!index)
flags |= FEV_GLOBAL;

engfunc(EngFunc_PlaybackEvent, flags, index, eventindex_decal_reset, 0.0, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, 0, 0);
}

// checks whether the entity's classname is equal to the passed classname
stock bool:fm_is_ent_classname(index, const classname[]) {
if (!pev_valid(index))
return false;

new class[32];
pev(index, pev_classname, class, sizeof class - 1);
if (equal(class, classname))
return true;

return false;
}

// the same as AMXX's core user_kill but fixes the issue when the scoreboard doesn't update immediately if flag is set to 1
stock fm_user_kill(index, flag = 0) {
if (flag) {
new Float:frags;
pev(index, pev_frags, frags);
set_pev(index, pev_frags, ++frags);
}

dllfunc(DLLFunc_ClientKill, index);

return 1;
}

// returns a degree angle between player-to-point and player's view vectors
stock Float:fm_get_view_angle_diff(index, const Float:point[3]) {
new Float:vec[3], Float:ofs[3], Float:aim[3];
pev(index, pev_origin, vec);
pev(index, pev_view_ofs, ofs);
xs_vec_add(vec, ofs, vec);
xs_vec_sub(point, vec, vec);
xs_vec_normalize(vec, vec);

pev(index, pev_v_angle, aim);
engfunc(EngFunc_MakeVectors, aim);
global_get(glb_v_forward, aim);

return xs_vec_angle(vec, aim);
}

// gets a weapon type of the linked to weaponbox weapon_* entity
stock fm_get_weaponbox_type(entity) {
static max_clients, max_entities;
if (!max_clients)
max_clients = global_get(glb_maxClients);
if (!max_entities)
max_entities = global_get(glb_maxEntities);

for (new i = max_clients + 1; i < max_entities; ++i) {
if (pev_valid(i) && entity == pev(i, pev_owner)) {
new wname[32];
pev(i, pev_classname, wname, sizeof wname - 1);
return get_weaponid(wname);
}
}

return 0;
}

stock set_weapon_anim(id, anim)
{
set_pev(id, pev_weaponanim, anim)

message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
write_byte(anim)
write_byte(pev(id,pev_body))
message_end()
}

stock set_player_nextattack(player, Float:NextTime)
{
set_pdata_float(player, m_flNextAttack, NextTime, 4) // linux - 5 / windows - 4
}
stock set_weapons_timeidle(id, WeaponId ,Float:TimeIdle)
{
static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
if(!pev_valid(entwpn)) 
return

set_pdata_float(entwpn, 46, TimeIdle, 4)
set_pdata_float(entwpn, 47, TimeIdle, 4)
set_pdata_float(entwpn, 48, TimeIdle + 0.5, 4)
}
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_USP)|(1<<CSW_DEAGLE)|(1<<CSW_GLOCK18)|(1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)	
const GRENADES_WEAPONS_BIT_SUM = (1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)

stock drop_weapons(id, dropwhat)
{
static weapons[32], num, i, weaponid
num = 0
get_user_weapons(id, weapons, num)

for (i = 0; i < num; i++)
{
weaponid = weapons[i]

switch(dropwhat)
{
case 1:
{	
if ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)
{
static wname[32]
get_weaponname(weaponid, wname, sizeof wname - 1)
engclient_cmd(id, "drop", wname)
}
}
case 2:
{	
if ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)
{
static wname[32]
get_weaponname(weaponid, wname, sizeof wname - 1)
engclient_cmd(id, "drop", wname)
}
}
case 3:
{	
if ((1<<weaponid) & GRENADES_WEAPONS_BIT_SUM)
{
static wname[32]
get_weaponname(weaponid, wname, sizeof wname - 1)
engclient_cmd(id, "drop", wname)
}
}
}
}
}
stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
new_velocity[0] = origin2[0] - origin1[0]
new_velocity[1] = origin2[1] - origin1[1]
new_velocity[2] = origin2[2] - origin1[2]
static Float:num; num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
new_velocity[0] *= num
new_velocity[1] *= num
new_velocity[2] *= num

return 1;
}

stock do_attack(Attacker, Victim, Inflictor, Float:fDamage, fake)
{
if(Attacker == Victim)
return 
	
fake_player_trace_attack(Attacker, Victim, fDamage, fake)
fake_take_damage(Attacker, Victim, fDamage, Inflictor)
}

stock fake_player_trace_attack (iAttacker, iVictim, &Float:fDamage, fake)
{
// get fDirection
static Float:fAngles[3], Float:fDirection[3]
pev(iAttacker, pev_angles, fAngles)
angle_vector(fAngles, ANGLEVECTOR_FORWARD, fDirection)

// get fStart
static Float:fStart[3], Float:fViewOfs[3]
pev(iAttacker, pev_origin, fStart)
pev(iAttacker, pev_view_ofs, fViewOfs)
xs_vec_add(fViewOfs, fStart, fStart)

// get aimOrigin
static iAimOrigin[3], Float:fAimOrigin[3]
get_user_origin(iAttacker, iAimOrigin, 3)
IVecFVec(iAimOrigin, fAimOrigin)

// TraceLine from fStart to AimOrigin
static ptr; ptr = create_tr2() 
engfunc(EngFunc_TraceLine, fStart, fAimOrigin, DONT_IGNORE_MONSTERS, iAttacker, ptr)
static pHit; pHit = get_tr2(ptr, TR_pHit)
static iHitgroup; iHitgroup = get_tr2(ptr, TR_iHitgroup)
static Float:fEndPos[3]
get_tr2(ptr, TR_vecEndPos, fEndPos)

// get target & body at aiming
static iTarget, iBody
get_user_aiming(iAttacker, iTarget, iBody)

// if aiming find target is iVictim then update iHitgroup
if (iTarget == iVictim)
{
iHitgroup = iBody
}

// if ptr find target not is iVictim
else if (pHit != iVictim)
{
// get AimOrigin in iVictim
static Float:fVicOrigin[3], Float:fVicViewOfs[3], Float:fAimInVictim[3]
pev(iVictim, pev_origin, fVicOrigin)
pev(iVictim, pev_view_ofs, fVicViewOfs) 
xs_vec_add(fVicViewOfs, fVicOrigin, fAimInVictim)
fAimInVictim[2] = fStart[2]
fAimInVictim[2] += get_distance_f(fStart, fAimInVictim) * floattan( fAngles[0] * 2.0, degrees )

// check aim in size of iVictim
static iAngleToVictim; iAngleToVictim = get_angle_to_target(iAttacker, fVicOrigin)
iAngleToVictim = abs(iAngleToVictim)
static Float:fDis; fDis = 2.0 * get_distance_f(fStart, fAimInVictim) * floatsin( float(iAngleToVictim) * 0.5, degrees )
static Float:fVicSize[3]
pev(iVictim, pev_size , fVicSize)
if ( fDis <= fVicSize[0] * 0.5 )
{
// TraceLine from fStart to aimOrigin in iVictim
static ptr2; ptr2 = create_tr2() 
engfunc(EngFunc_TraceLine, fStart, fAimInVictim, DONT_IGNORE_MONSTERS, iAttacker, ptr2)
static pHit2; pHit2 = get_tr2(ptr2, TR_pHit)
static iHitgroup2; iHitgroup2 = get_tr2(ptr2, TR_iHitgroup)

// if ptr2 find target is iVictim
if ( pHit2 == iVictim && (iHitgroup2 != HIT_HEAD || fDis <= fVicSize[0] * 0.25) )
{
pHit = iVictim
iHitgroup = iHitgroup2
get_tr2(ptr2, TR_vecEndPos, fEndPos)
}

free_tr2(ptr2)
}

// if pHit still not is iVictim then set default HitGroup
if (pHit != iVictim)
{
// set default iHitgroup
iHitgroup = HIT_GENERIC

static ptr3; ptr3 = create_tr2() 
engfunc(EngFunc_TraceLine, fStart, fVicOrigin, DONT_IGNORE_MONSTERS, iAttacker, ptr3)
get_tr2(ptr3, TR_vecEndPos, fEndPos)

// free ptr3
free_tr2(ptr3)
}
}

// set new Hit & Hitgroup & EndPos
set_tr2(ptr, TR_pHit, iVictim)
set_tr2(ptr, TR_iHitgroup, iHitgroup)
set_tr2(ptr, TR_vecEndPos, fEndPos)

// hitgroup multi fDamage
static Float:fMultifDamage 
switch(iHitgroup)
{
case HIT_HEAD: fMultifDamage  = 2.5
case HIT_STOMACH: fMultifDamage  = 1.80
case HIT_LEFTLEG: fMultifDamage  = 1.00
case HIT_RIGHTLEG: fMultifDamage  = 1.00
default: fMultifDamage  = 1.0
}

fDamage *= fMultifDamage

// ExecuteHam
if(fake)
fake_trake_attack(iAttacker, iVictim, fDamage, fDirection, ptr)

// free ptr
free_tr2(ptr)
}

stock fake_trake_attack(iAttacker, iVictim, Float:fDamage, Float:fDirection[3], iTraceHandle, iDamageBit = (DMG_NEVERGIB | DMG_BULLET))
ExecuteHamB(Ham_TraceAttack, iVictim, iAttacker, fDamage, fDirection, iTraceHandle, iDamageBit)

stock fake_take_damage(iAttacker, iVictim, Float:fDamage, iInflictor)
ExecuteHamB(Ham_TakeDamage, iVictim, iInflictor, iAttacker, fDamage, DMG_BULLET)

stock get_angle_to_target(id, const Float:fTarget[3], Float:TargetSize = 0.0)
{
static Float:fOrigin[3], iAimOrigin[3], Float:fAimOrigin[3], Float:fV1[3]
pev(id, pev_origin, fOrigin)
get_user_origin(id, iAimOrigin, 3) // end position from eyes

IVecFVec(iAimOrigin, fAimOrigin)
xs_vec_sub(fAimOrigin, fOrigin, fV1)

static Float:fV2[3]
xs_vec_sub(fTarget, fOrigin, fV2)

static iResult; iResult = get_angle_between_vectors(fV1, fV2)
if(TargetSize > 0.0)
{
static Float:fTan; fTan = TargetSize / get_distance_f(fOrigin, fTarget)
static fAngleToTargetSize; fAngleToTargetSize = floatround(floatatan(fTan, degrees))
iResult -= (iResult > 0) ? fAngleToTargetSize : -fAngleToTargetSize
}

return iResult
}
stock get_angle_between_vectors(const Float:fV1[3], const Float:fV2[3])
{
static Float:fA1[3], Float:fA2[3]
engfunc(EngFunc_VecToAngles, fV1, fA1)
engfunc(EngFunc_VecToAngles, fV2, fA2)

static iResult; iResult = floatround(fA1[1] - fA2[1])
iResult = iResult % 360
iResult = (iResult > 180) ? (iResult - 360) : iResult

return iResult
}
stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

pev(id, pev_origin, vOrigin)
pev(id, pev_view_ofs, vUp) //for player
xs_vec_add(vOrigin, vUp, vOrigin)
pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles

angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
angle_vector(vAngle, ANGLEVECTOR_UP, vUp)

vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}
stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
new Float:vfEnd[3], viEnd[3] 
get_user_origin(id, viEnd, 3)  
IVecFVec(viEnd, vfEnd) 

new Float:fOrigin[3], Float:fAngle[3]

pev(id, pev_origin, fOrigin) 
pev(id, pev_view_ofs, fAngle)

xs_vec_add(fOrigin, fAngle, fOrigin) 

new Float:fAttack[3]

xs_vec_sub(vfEnd, fOrigin, fAttack)
xs_vec_sub(vfEnd, fOrigin, fAttack) 

new Float:fRate

fRate = fDis / vector_length(fAttack)
xs_vec_mul_scalar(fAttack, fRate, fAttack)

xs_vec_add(fOrigin, fAttack, output)
}
stock bool:can_see_fm(entindex1, entindex2)
{
if (!entindex1 || !entindex2)
return false

if (pev_valid(entindex1) && pev_valid(entindex1))
{
new flags = pev(entindex1, pev_flags)
if (flags & EF_NODRAW || flags & FL_NOTARGET)
{
return false
}

new Float:lookerOrig[3]
new Float:targetBaseOrig[3]
new Float:targetOrig[3]
new Float:temp[3]

pev(entindex1, pev_origin, lookerOrig)
pev(entindex1, pev_view_ofs, temp)
lookerOrig[0] += temp[0]
lookerOrig[1] += temp[1]
lookerOrig[2] += temp[2]

pev(entindex2, pev_origin, targetBaseOrig)
pev(entindex2, pev_view_ofs, temp)
targetOrig[0] = targetBaseOrig [0] + temp[0]
targetOrig[1] = targetBaseOrig [1] + temp[1]
targetOrig[2] = targetBaseOrig [2] + temp[2]

engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
{
return false
} 
else 
{
new Float:flFraction
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2]
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2] - 17.0
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
}
}
}
}
return false
}

// safe removal of weaponbox+weapon_* entity pair (delay =~= 0.03 second)
#define fm_remove_weaponbox(%1) dllfunc(DLLFunc_Think, %1)
/* stock fm_remove_weaponbox(entity)
return dllfunc(DLLFunc_Think, entity) */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
