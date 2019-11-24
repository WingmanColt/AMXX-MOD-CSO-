#include <amxmodx>
#include <fakemeta>
#include <ZombieMod5>

new const Float:size[][3] = {
{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}
public zp_fw_core_spawn_post(id)
{ 
if(!is_user_bot(id))
set_task(random_float(0.3, 2.0), "Stuck", id)
else
set_task(random_float(5.0, 10.0), "Stuck", id)
}
public Stuck(id)
checkstuck(id) 
public checkstuck(player) 
{
static Float:origin[3]
static Float:mins[3], hull
static Float:vec[3], o
if (is_user_connected(player) && is_user_alive(player)) 
{
pev(player, pev_origin, origin)
hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
if (!fm_get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT)) 
{
pev(player, pev_mins, mins)
vec[2] = origin[2]
for (o=0; o < sizeof size; ++o) 
{
vec[0] = origin[0] - mins[0] * size[o][0]
vec[1] = origin[1] - mins[1] * size[o][1]
vec[2] = origin[2] - mins[2] * size[o][2]
//if (is_hull_vacant(vec, hull,player)) 
//{
engfunc(EngFunc_SetOrigin, player, vec)
fm_set_user_noclip(player, 1)
set_pev(player,pev_velocity,random_float(200.0, 400.0),random_float(150.0, 300.0),random_float(50.0, 100.0))
fm_set_user_noclip(player, 0)
o = sizeof size
//}
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
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
