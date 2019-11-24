#include <amxmodx>
#include <engine>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <zp50_core>

#define PALLET_MINS Float:{ -27.260000, -22.280001, -22.290001 }
#define PALLET_MAXS Float:{  27.340000,  26.629999,  29.020000 }
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
#define fm_drop_to_floor(%1) engfunc(EngFunc_DropToFloor,%1)
new palletscout = 0;
new stuck[33],g_bolsas[33], g_GibModelIndex[7], g_ham_killed
new const Float:size[][3] = {
{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}
public plugin_init() 
{
register_logevent("logevent_round_end", 2, "1=Round_End")  	
register_menucmd(register_menuid("\ySand Bags:"), 1023, "menu_command")
register_clcmd("say /pb","show_the_menu")
register_clcmd("pallet","show_the_menu")
}
public plugin_natives()
{
register_native("give_item_sandbags", "native_sandbags", 1)
}

public plugin_precache()
{
new i, ii = 0, buffer[100]
for(i = 0; i < sizeof(g_GibModelIndex); i++)
{
ii++
formatex(buffer, charsmax(buffer), "models/items/gib/gib0%i.mdl", ii)
g_GibModelIndex[i] = precache_model(buffer)
}
}

public native_sandbags(player)
{	
g_bolsas[player] += 15
client_print(player, print_chat, "[ZPChile] You have %i sandbags, to use with the key 'L'", g_bolsas[player])
client_cmd(player, "bind L pallet")
set_task(0.3,"show_the_menu",player)
set_task(0.1,"checkstuck",0,"",0,"b")
}
public show_the_menu(id,level,cid)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED;

if (!zp_core_is_zombie(id))
{		
new szMenuBody[256];
new keys;

new nLen = format( szMenuBody, 255, "\ySand Bags:^n" );
nLen += format( szMenuBody[nLen], 255-nLen, "^n\w1. Place a Sandbags (%i Remaining)", g_bolsas[id] );
nLen += format( szMenuBody[nLen], 255-nLen, "^n^n\w0. Exit" );
keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9)
show_menu( id, keys, szMenuBody, -1 );
return PLUGIN_HANDLED;
}
return PLUGIN_HANDLED;
}

public menu_command(id,key,level,cid)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED;

switch(key)
{
case 0: 
{
if (!zp_core_is_zombie(id) )
{
new money = g_bolsas[id]
if ( money < 1 )
{
client_print(id, print_chat, "[ZPC] You do not have to place sandbags!")
return PLUGIN_CONTINUE
}
g_bolsas[id]-= 1
place_palletwbags(id);
show_the_menu(id,level,cid);
return PLUGIN_CONTINUE	
}
}
}
return PLUGIN_HANDLED;
}
public place_palletwbags(id)
{	
new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_wall"));
if(!pev_valid(ent)) 
return;
set_pev(ent,pev_classname,"amxx_pallets");
engfunc(EngFunc_SetModel,ent,"models/pallet_with_bags.mdl");
static Float:xorigin[3];
get_user_hitpoint(id,xorigin);
static Float:p_mins[3], Float:p_maxs[3];
p_mins = PALLET_MINS;
p_maxs = PALLET_MAXS;
engfunc(EngFunc_SetSize, ent, p_mins, p_maxs);
set_pev(ent, pev_mins, p_mins);
set_pev(ent, pev_maxs, p_maxs );
set_pev(ent, pev_absmin, p_mins);
set_pev(ent, pev_absmax, p_maxs );
engfunc(EngFunc_SetOrigin, ent, xorigin);
set_pev(ent,pev_solid,SOLID_BBOX);
set_pev(ent,pev_movetype,MOVETYPE_FLY); 
set_pev(ent,pev_health, 300.0);
set_pev(ent,pev_takedamage,DAMAGE_YES);
if(!g_ham_killed)
{
RegisterHamFromEntity(Ham_Killed, ent, "killed", 1)
g_ham_killed = true
}
static Float:rvec[3];
pev(id,pev_v_angle,rvec);
rvec[0] = 0.0;
set_pev(ent,pev_angles,rvec);
fm_drop_to_floor(ent);
palletscout++;
}
public killed(ent)
{
if(!pev_valid(ent)) return

static Float:originF[3]
entity_get_vector(ent,EV_VEC_origin,originF)

// New metod
for(new i = 0; i < sizeof(g_GibModelIndex); i++)
{
// New message FOX
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
write_byte(TE_BREAKMODEL) // TE id
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // x axis
engfunc(EngFunc_WriteCoord, originF[2]+20) // x axis
write_coord(16) // size x
write_coord(16) // size y
write_coord(16) // size z
write_coord(random_num(-20, 20)) // velocity x
write_coord(random_num(-20, 20)) // velocity y
write_coord(20) // velocity z
write_byte(10) // random velocity
write_short(g_GibModelIndex[i]) // model
write_byte(1) // count
write_byte(15 * 10) // life
write_byte(0x4F);
message_end()
}

}
stock get_user_hitpoint(id, Float:hOrigin[3]) 
{
if ( ! is_user_alive( id ))
return 0;
new Float:fOrigin[3], Float:fvAngle[3], Float:fvOffset[3], Float:fvOrigin[3], Float:feOrigin[3];
new Float:fTemp[3];
pev(id, pev_origin, fOrigin);
pev(id, pev_v_angle, fvAngle);
pev(id, pev_view_ofs, fvOffset);
xs_vec_add(fOrigin, fvOffset, fvOrigin);
engfunc(EngFunc_AngleVectors, fvAngle, feOrigin, fTemp, fTemp);
xs_vec_mul_scalar(feOrigin, 9999.9, feOrigin);
xs_vec_add(fvOrigin, feOrigin, feOrigin);
engfunc(EngFunc_TraceLine, fvOrigin, feOrigin, 0, id);
global_get(glb_trace_endpos, hOrigin);
return 1;
} 

public logevent_round_end() remove_allpalletswbags()
stock remove_allpalletswbags()
{
new pallets = -1;
while((pallets = fm_find_ent_by_class(pallets, "amxx_pallets")))
if(pev_valid(pallets)) fm_remove_entity(pallets);
palletscout = 0;
}

public checkstuck() 
{
static players[32], pnum, player
get_players(players, pnum)
static Float:origin[3]
static Float:mins[3], hull
static Float:vec[3]
static o,i
for(i=0; i<pnum; i++){
player = players[i]
if (is_user_connected(player) && is_user_alive(player)) {
pev(player, pev_origin, origin)
hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
if (!is_hull_vacant(origin, hull,player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT)) {
++stuck[player]
if(stuck[player] >= 5)
{
pev(player, pev_mins, mins)
vec[2] = origin[2]
for (o=0; o < sizeof size; ++o) {
vec[0] = origin[0] - mins[0] * size[o][0]
vec[1] = origin[1] - mins[1] * size[o][1]
vec[2] = origin[2] - mins[2] * size[o][2]
if (is_hull_vacant(vec, hull,player)) {
engfunc(EngFunc_SetOrigin, player, vec)
client_cmd(player,"spk fvox/blip.wav")
set_pev(player,pev_velocity,{0.0,0.0,0.0})
o = sizeof size
}
}
}
}
else
{
stuck[player] = 0
}
}
}
}
stock bool:is_hull_vacant(const Float:origin[3], hull,id) {
static tr
engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
return true

return false
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
