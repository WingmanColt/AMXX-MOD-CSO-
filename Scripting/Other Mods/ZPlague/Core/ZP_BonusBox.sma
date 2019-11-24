#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include <zp50_gamemodes>
#include <zp50_core>

#define CLASSNAME "dm_item"
public plugin_init()
{
register_event("HLTV", "round_start", "a", "1=0", "2=0")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
register_forward(FM_Touch, "fwd_Touch")
}

public fwd_Touch(toucher, touched)
{
if (!is_user_alive(toucher) || !pev_valid(touched))
return FMRES_IGNORED

new classname[32]	
pev(touched, pev_classname, classname, 31)
if (!equal(classname, CLASSNAME))
return FMRES_IGNORED

give_item(toucher)
PlaySound(toucher,"ZPlague/supplybox_pickup.wav")
set_pev(touched, pev_effects, EF_NODRAW)
set_pev(touched, pev_solid, SOLID_NOT)
return FMRES_IGNORED
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (!is_user_connected(attacker) || !is_user_connected(victim) || attacker == victim || !attacker)
return HAM_IGNORED
new random = random_num(0, 10)
if (random == 1 || random == 4 || random == 6)
{
new origin[3]
get_user_origin(victim, origin, 0)
addItem(origin)
}
return HAM_IGNORED
}

public removeEntity(ent)
{
if (!pev_valid(ent))
return;
engfunc(EngFunc_RemoveEntity, ent)
}

public addItem(origin[3])
{
new ent = fm_create_entity("info_target")
if (!pev_valid(ent))
return;
set_pev(ent, pev_classname, CLASSNAME)
engfunc(EngFunc_SetModel,ent, "models/ZPlague/Items/Box.mdl")
set_pev(ent,pev_mins,Float:{-10.0,-10.0,0.0})
set_pev(ent,pev_maxs,Float:{10.0,10.0,25.0})
set_pev(ent,pev_size,Float:{-10.0,-10.0,0.0,10.0,10.0,25.0})
engfunc(EngFunc_SetSize,ent,Float:{-10.0,-10.0,0.0},Float:{10.0,10.0,25.0})
set_pev(ent,pev_solid,SOLID_BBOX)
set_pev(ent, pev_movetype, 6)
new Float:fOrigin[3]
IVecFVec(origin, fOrigin)
set_pev(ent, pev_origin, fOrigin)
set_pev(ent,pev_renderfx,kRenderFxGlowShell)
set_pev(ent,pev_rendercolor,Float:{200.0,200.0,200.0})
}

public give_item(id)
{
if(!is_user_alive(id))
return;	
if (zp_gamemodes_get_current() == ZP_NO_GAME_MODE)
{
zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
ChatColor(id, "!g[NS2]!y Now You Got + 5 Ammo Packs.")	
return;
}
	
if(!zp_core_is_zombie(id))
{
new i = random_num(1, 4)
switch (i)
{
case 1:
{
fm_set_user_health(id, get_user_health(id) + 200)
ChatColor(id, "!g[NS2]!y Now You Got + 200 Health.")
}
case 2:
{
zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
ChatColor(id, "!g[NS2]!y Now You Got + 5 Ammo Packs.")
}
case 3:
{
fm_set_user_armor(id, get_user_armor(id) + 100)
ChatColor(id, "!g[NS2]!y Now You Got + 100 Armor.")
}
case 4:
{
fm_give_item(id, "weapon_flashbang")
fm_give_item(id, "weapon_smokegrenade")
fm_give_item(id, "weapon_hegrenade")
ChatColor(id, "!g[NS2]!y Now You Got Full Grenades Pack.")
}
}
}
if(zp_core_is_zombie(id) && !zp_class_assassin_get(id) && !zp_class_nemesis_get(id) && !zp_class_clown_get(id))
{
new i = random_num(1, 3)
switch (i)
{
case 1:
{
fm_set_user_health(id, get_user_health(id) + 2000)
ChatColor(id, "!g[NS2]!y Now You Got + 2000 Health.")
}
case 2:
{
zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
ChatColor(id, "!g[NS2]!y Now You Got + 5 Ammo Packs.")
}
case 3:
{
zp_core_cure(id, id)
ChatColor(id, "!g[NS2]!y Now You Have Antidote.")
}
}
}
if(zp_class_nemesis_get(id) || zp_class_clown_get(id))
{
new i = random_num(1, 2)
switch (i)
{
case 1:
{
fm_set_user_health(id, get_user_health(id) + 5000)
ChatColor(id, "!g[NS2]!y Now You Got + 5000 Health.")
}
case 2:
{
zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
ChatColor(id, "!g[NS2]!y Now You Got + 5 Ammo Packs.")
}
}
}
else if(zp_class_assassin_get(id))
{
zp_ammopacks_set(id, zp_ammopacks_get(id) + 3)
ChatColor(id, "!g[NS2]!y Now You Got + 3 Ammo Packs.")
}
}

public round_start()
{
new ent = FM_NULLENT
if(!pev_valid(ent)) return;
static string_class[] = "classname"
while ((ent = engfunc(EngFunc_FindEntityByString, ent, string_class, CLASSNAME))) 
set_pev(ent, pev_flags, FL_KILLME)
}
stock ChatColor(const id, const input[], any:...)
{
new count = 1, players[32]
static msg[191]
vformat(msg, 190, input, 3)

replace_all(msg, 190, "!g", "^4") // Green Color
replace_all(msg, 190, "!y", "^1") // Default Color
replace_all(msg, 190, "!team", "^3") // Team Color
replace_all(msg, 190, "!team2", "^0") // Team2 Color

if (id) players[0] = id; else get_players(players, count, "ch")
{
for (new i = 0; i < count; i++)
{
if (is_user_connected(players[i]))
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
write_byte(players[i]);
write_string(msg);
message_end();
}
}
}
}
PlaySound(id, const sound[])
{
client_cmd(id, "spk ^"%s^"", sound)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
