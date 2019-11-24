#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <ZombieMod5>

#define ROCKET_CLASSNAME "supplybox_rocket"
#define SUPPLYBOX_CLASSNAME "supplybox"
#define SPRITE_CLASSNAME "supplyboxSPR"

#define TASK_SUPPLYBOX 128256
#define TASK_SUPPLYBOX2 138266
#define TASK_SUPPLYBOX_WAIT 130259
#define TASK_MSG 152221

#define METR_UNITS 39.37
#define Z_AXIS 35.0
#define MIN_SCALE 0.5
#define MIN_SCALE_F 0.5
#define MAX_SCALE 0.5

#define MAX_BOMB_USE 2
#define MAX_BOMB_NUM 10
#define MAX_SUPPLYBOX 20

#define ID_BOMB_USE (taskid - TASK_BOMB_USE)
#define ID_BOMB_LAUNCH (taskid - TASK_BOMB_LAUNCH)
#define ID_BOMB_ATTACK (taskid - TASK_BOMB_ATTACK)

enum (+= 100)
{
TASK_BOMB_USE = 2000,
TASK_BOMB_LAUNCH,
TASK_BOMB_ATTACK
}

enum _:Supplybox
{
BOMB,	
WAIT,
BOMB_WAIT,
BOMB_NUM
}
enum Supplybox2
{
SUPPLY_TOTAL,
EXPLOSION,
QUANTITY,
COUNT,
TOTAL,
TRAIL,
MADE,
NUM
}
new const sound[][] ={"ZB5/rocket_exp.wav", "ZB5/bomb2.wav", "ZB5/supplybox_pickup.wav", "ZB5/supplybox_drop.wav" }
new const supplybox_spawn_file[] = "%s/zp_supplybox/%s.cfg"

new Float:g_supplybox_spawn[MAX_SUPPLYBOX][3], g_bomb_enemy[33][MAX_BOMB_NUM], supplybox_ent[MAX_SUPPLYBOX]
new g_had[33][Supplybox], g_had2[Supplybox2], Float:g_Origin[33][3]
new g_IsConnected, g_IsAlive, g_IsZombie
public plugin_init()
{
Register_SafetyFunc()
	
register_event("HLTV", "event_newround", "a", "1=0", "2=0")
register_touch(SUPPLYBOX_CLASSNAME, "*", "fw_supplybox_touch")	

register_forward(FM_AddToFullPack, "fm_fullpack", 1)
register_forward(FM_CheckVisibility, "check_visible")

register_touch(ROCKET_CLASSNAME, "*", "fw_Rocket_Touch")	
register_forward(FM_CmdStart, "fw_CmdStart")
}
public plugin_precache()
{
g_had2[TRAIL] = PrecacheModel("sprites/zbeam2.spr")	
g_had2[EXPLOSION] = PrecacheModel("sprites/ZB5/explodeup.spr")	

for(new i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])	

PrecacheModel("sprites/ZB5/supl_new.spr") 
PrecacheModel("models/rpgrocket.mdl") 	
load_supplybox_spawn()	
}
public zp_fw_round_start_post()remove_supplybox()	
public plugin_cfg()
{
set_task(0.5, "event_newround")
}
public event_newround()
{
g_had2[MADE] = false
g_had2[QUANTITY] = 0

remove_supplybox()
g_had2[COUNT] = 0

remove_task(TASK_MSG)
remove_task(TASK_SUPPLYBOX)
remove_task(TASK_SUPPLYBOX2)
}
public Reset_Bomb(id)
{	
remove_task(id+TASK_BOMB_USE)
remove_task(id+TASK_BOMB_ATTACK)
remove_task(id+TASK_BOMB_LAUNCH)

g_had[id][BOMB] = 0	
g_had[id][BOMB_NUM] = 0
g_had[id][BOMB_WAIT] = 0		
}
public remove_supplybox()
{
remove_ent_by_class("supplybox")	
remove_ent_by_class("supplyboxSPR")
}

public zp_fw_gamemodes_start()
{
if(!g_had2[MADE])
{
g_had2[MADE] = true

if(task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)

if(g_had2[TOTAL])
set_task(20.0, "create_supplybox", TASK_SUPPLYBOX)
}
}

public load_supplybox_spawn()
{
// Check for spawns points of the current map
new cfgdir[32], mapname[32], filepath[100], linedata[64]
get_configsdir(cfgdir, charsmax(cfgdir))
get_mapname(mapname, charsmax(mapname))
formatex(filepath, charsmax(filepath), supplybox_spawn_file, cfgdir, mapname)

// Load spawns points
if (file_exists(filepath))
{
new file = fopen(filepath,"rt"), row[4][6]

while (file && !feof(file))
{
fgets(file, linedata, charsmax(linedata))

// invalid spawn
if(!linedata[0] || str_count(linedata,' ') < 2) continue;

// get spawn point data
parse(linedata,row[0],5,row[1],5,row[2],5)

// origin
g_supplybox_spawn[g_had2[TOTAL]][0] = floatstr(row[0])
g_supplybox_spawn[g_had2[TOTAL]][1] = floatstr(row[1])
g_supplybox_spawn[g_had2[TOTAL]][2] = floatstr(row[2])

g_had2[TOTAL]++
if (g_had2[TOTAL] >= MAX_SUPPLYBOX) 
break
}
if (file) fclose(file)
}
}
public create_supplybox(id)
{	
if (g_had2[COUNT] >= 4 || zp_core_endround()) 
return

if (task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
set_task(40.0, "create_supplybox", TASK_SUPPLYBOX)

if (get_total_supplybox() >= 1) 
return

g_had2[NUM] = 0
create_supplybox2()

for(new i = 1; i <= get_maxplayers(); i++)
{
if(!is_user_connected(i))
continue

if(zp_core_round() == MODE_AMBUSH)
set_task(0.5, "MSG", i+TASK_MSG)

client_print(i, print_center, "Supplybox has arrived!")
}

PlaySound(0, "ZB5/supplybox_drop.wav")
if (task_exists(TASK_SUPPLYBOX2)) remove_task(TASK_SUPPLYBOX2)
set_task(0.5, "create_supplybox2", TASK_SUPPLYBOX2, _, _, "b")	
}

public create_supplybox2()
{
if (g_had2[COUNT] >= 4 || get_total_supplybox() >= 1 || zp_core_endround())
{
remove_task(TASK_SUPPLYBOX2)
return
}

g_had2[COUNT]++
g_had2[NUM]++

new Float:Mins[3] = {-2.0,-2.0,-2.0}
new Float:Maxs[3] = {5.0,5.0,5.0}

static ent, allocString	
static MaxEnt; MaxEnt = get_global_int(GL_maxEntities)	
if(GetEntityCount() < MaxEnt)
{
allocString = engfunc(EngFunc_AllocString, "info_target")		
ent = engfunc(EngFunc_CreateNamedEntity, allocString)
}
if(!pev_valid(ent))
return;

set_pev(ent, pev_classname, SUPPLYBOX_CLASSNAME)
engfunc(EngFunc_SetModel, ent,"models/ZB5/Items/ZB5_Items_NEW.mdl")	
set_pev(ent, pev_body, 2 - 1)
set_pev(ent, pev_solid, 1)
set_pev(ent, pev_movetype, 6)
set_pev(ent, pev_iuser2, g_had2[COUNT])
set_pev(ent, pev_nextthink, 1.0)
engfunc(EngFunc_SetSize,ent,Mins,Maxs)

static Float:Origin[3]
collect_spawn_point(Origin)
engfunc(EngFunc_SetOrigin, ent, Origin)
supplybox_ent[g_had2[COUNT]] = ent
if ((g_had2[NUM] >= 1) && task_exists(TASK_SUPPLYBOX2))
remove_task(TASK_SUPPLYBOX2)

fm_set_rendering(ent, kRenderFxGlowShell, 10, 255, 10, kRenderNormal, 0)
spawn_sprite(ent)
}
get_total_supplybox()
{
new total
for (new i = 1; i <= g_had2[COUNT]; i++)
{
if (supplybox_ent[i]) total += 1
}
return total
}

str_count(const str[], searchchar) // By Twilight Suzuka
{
new count, i, len = strlen(str)

for (i = 0; i <= len; i++)
{
if(str[i] == searchchar)
count++
}

return count;
}
public fw_supplybox_touch(ent, id)
{
if (!pev_valid(ent) || !is_user_alive(id) || zp_core_is_zombie(id) || g_had[id][WAIT]) 
return 

if(pev(ent, pev_movetype) == MOVETYPE_NONE)
return

static name[32]
get_user_name(id, name, 31)

if(zp_core_round() != MODE_AMBUSH)
{	
if(!zp_core_is_hero(id))
{			
switch(random_num(0,4))
{	
case 0:
{
if(zb5_had_dmp7a1(id))
return

get_weapon_subgun(id, 1)
client_print(0, print_center, "%s has received Double MP7A1 from SupplyBox !", name)
}
case 1:
{
if(zb5_had_cv47(id))
return	

get_weapon_scope(id, 1)
client_print(0, print_center, "%s has received CV47 Long from SupplyBox !", name)
}
case 2:
{
if(zb5_had_ddeagle(id))
return

get_weapon_pistol(id, 1)
client_print(0, print_center, "%s has received Double NightHawks .40 from SupplyBox !!!", name)
}
case 3:
{
get_weapon_grenade(id, 2)
get_weapon_grenade(id, 7)
get_weapon_grenade(id, 6)
client_print(0, print_center, "%s has received Grenade and Magazine set from SupplyBox !!!", name)
}
case 4:
{
zb5_set_user_nvg(id, 1, 1, 0, 1)
client_print(0, print_center, "%s has received NightVision from SupplyBox !!!", name)
}
}
}else{
get_weapon_grenade(id, 2)
get_weapon_grenade(id, 7)
get_weapon_grenade(id, 6)
client_print(0, print_center, "%s has received Grenade and Magazine set from SupplyBox !!!", name)
}
for(new i = 1; i <= get_maxplayers(); i++)
{
if(is_user_connected(i))
zb5_restock_ammo(i)
}
}
else
{
if(g_had2[QUANTITY]< 4)
{	
g_had2[QUANTITY]++	
}
if(g_had2[QUANTITY] == 4)
{
for(new i = 1; i <= get_maxplayers(); i++)
{
if(is_user_alive(i) && zp_core_is_zombie(i))
{
user_kill(i)
Make_ScreenFade(i,6.0, 0, 0, 0, 250, FADE_IN, 1)
}
}
}
}
if (g_had[id][BOMB] < 1) 
{
g_had[id][BOMB]++	
zp_colored_print(id, "^3Hold ^4ATTACK2 ^3to make rocket storm !!!")
}

zb5_set_user_quest(id, QUEST_SUPPLYBOX, 1)
PlaySound(id, "ZB5/supplybox_pickup.wav")
new num_box = entity_get_int(ent, EV_INT_iuser2)

supplybox_ent[num_box] = 0
g_had[id][WAIT] = 1

remove_supplybox()

if (task_exists(id+TASK_SUPPLYBOX_WAIT)) remove_task(id+TASK_SUPPLYBOX_WAIT)
set_task(2.0, "remove_supplybox_wait", id+TASK_SUPPLYBOX_WAIT)
}
public MSG(id)
{
id -= TASK_MSG

if(!is_user_connected(id))
return;

if(zp_core_endround())
{
remove_task(id+TASK_MSG)
return;	
}

if(!zp_core_is_zombie(id))
client_print(id, print_center, "Your team collected %i / 4 Supplyboxes!!!", g_had2[QUANTITY])
else
client_print(id, print_center, "Remaining %i / 4 Supplyboxes for humans win !!!", g_had2[QUANTITY])	

set_task(0.5, "MSG", id+TASK_MSG)
}
public remove_supplybox_wait(id)
{
id -= TASK_SUPPLYBOX_WAIT

g_had[id][WAIT] = 0

if (task_exists(id+TASK_SUPPLYBOX_WAIT))
remove_task(id+TASK_SUPPLYBOX_WAIT)
}
public fw_CmdStart(id, uc_handle, seed)
{			
if (!zp_core_is_human(id, 1)) 
return;

if (g_had[id][BOMB] < 1) 
return;
	
static buttons; buttons = get_uc(uc_handle, UC_Buttons)	
if (buttons & IN_ATTACK2)
{
if (!g_had[id][BOMB_WAIT])
{
g_had[id][BOMB_WAIT] = 1
sendmsg_BarTime(id, 2)

if (task_exists(id+TASK_BOMB_USE)) remove_task(id+TASK_BOMB_USE)
set_task(2.0, "task_bomb_use", id+TASK_BOMB_USE)
}
}
else
{
g_had[id][BOMB_WAIT] = 0
sendmsg_BarTime(id, 0)
if (task_exists(id+TASK_BOMB_USE)) remove_task(id+TASK_BOMB_USE)
}
}

public task_bomb_use(taskid)
{
if (!zp_core_is_human(ID_BOMB_USE, 1)) 
return;

g_had[ID_BOMB_USE][BOMB] = 0
g_had[ID_BOMB_USE][BOMB_WAIT] = 0
sendmsg_BarTime(ID_BOMB_USE, 0)
emit_sound(ID_BOMB_USE, CHAN_AUTO, "ZB5/bomb2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	

fm_get_aim_origin2(ID_BOMB_USE, g_Origin[ID_BOMB_USE])

new Float:StartOrigin[3]
get_position(ID_BOMB_USE, 40.0, 6.0, -7.0, StartOrigin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMPOINTS)
engfunc(EngFunc_WriteCoord, StartOrigin[0])
engfunc(EngFunc_WriteCoord, StartOrigin[1])
engfunc(EngFunc_WriteCoord, StartOrigin[2])
engfunc(EngFunc_WriteCoord, g_Origin[ID_BOMB_USE][0])
engfunc(EngFunc_WriteCoord, g_Origin[ID_BOMB_USE][1])
engfunc(EngFunc_WriteCoord, g_Origin[ID_BOMB_USE][2])
write_short(g_had2[TRAIL])
write_byte(0) // start frame
write_byte(0) // framerate
write_byte(4) // life
write_byte(15) // line width
write_byte(0) // amplitude
write_byte(20) // red
write_byte(255) // green
write_byte(20) // blue
write_byte(150) // brightness
write_byte(0) // speed
message_end()


if (task_exists(ID_BOMB_USE+TASK_BOMB_LAUNCH)) remove_task(ID_BOMB_USE+TASK_BOMB_LAUNCH)
set_task(2.0, "task_bomb_launch", ID_BOMB_USE+TASK_BOMB_LAUNCH)
}
public task_bomb_launch(taskid)
{
if (!zp_core_is_human(ID_BOMB_LAUNCH, 1)) 
return;

bomb_find_enemy(ID_BOMB_LAUNCH)
g_had[ID_BOMB_LAUNCH][BOMB_NUM] = 0

if (task_exists(ID_BOMB_LAUNCH+TASK_BOMB_ATTACK)) remove_task(ID_BOMB_LAUNCH+TASK_BOMB_ATTACK)
set_task(0.25, "task_bomb_attack", ID_BOMB_LAUNCH+TASK_BOMB_ATTACK, _,_, "b")
}

public task_bomb_attack(taskid)
{
if (!zp_core_is_human(ID_BOMB_ATTACK, 1) && g_had[ID_BOMB_ATTACK][BOMB_NUM] >= MAX_BOMB_NUM)
{
remove_task(ID_BOMB_ATTACK+TASK_BOMB_ATTACK)
return;
}

static enemy; enemy = g_bomb_enemy[ID_BOMB_ATTACK][g_had[ID_BOMB_ATTACK][BOMB_NUM]]
if(!is_user_alive(enemy))
return

if(pev_valid(enemy))
{
static Float:originB[3]
originB = g_Origin[ID_BOMB_ATTACK]

originB[0] += float(200)*0.2
originB[1] += float(200)*0.2
originB[2] += float(200)

rocket_create(ID_BOMB_ATTACK, enemy, originB)
g_had[ID_BOMB_ATTACK][BOMB_NUM]++
}
else
{
client_print(ID_BOMB_ATTACK, print_center, "No enemy found !!!")
remove_task(ID_BOMB_ATTACK+TASK_BOMB_ATTACK)
}
}
rocket_create(attacker, victim, Float:origin[3])
{
new ent, allocString	
static MaxEnt; MaxEnt = get_global_int(GL_maxEntities)	
if(GetEntityCount() < MaxEnt)
{
allocString = engfunc(EngFunc_AllocString, "info_target")		
ent = engfunc(EngFunc_CreateNamedEntity, allocString)
}
if(!pev_valid(ent))
return;

set_pev(ent, pev_classname, ROCKET_CLASSNAME)
engfunc(EngFunc_SetModel, ent, "models/grenade.mdl")
set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0})
set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0})
set_pev(ent, pev_origin, origin)
set_pev(ent, pev_movetype, MOVETYPE_FLY)
set_pev(ent, pev_effects, EF_LIGHT)
set_pev(ent, pev_solid, SOLID_BBOX)
set_pev(ent, pev_gravity, 0.01)
set_pev(ent, pev_owner, attacker)

new Float:originV[3]
pev(victim, pev_origin, originV)
ent_move_to(ent, originV, 2000)
}

public fw_Rocket_Touch(ent)
{
if(!pev_valid(ent))
return
if(pev(ent, pev_movetype) == MOVETYPE_NONE)
return

static Float:Origin[3]
pev(ent, pev_origin, Origin)

// Explosion
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2] + 30.0)
write_short(g_had2[EXPLOSION])
write_byte(50)
write_byte(40)
write_byte(TE_EXPLFLAG_NOSOUND)
message_end()	

emit_sound(ent, CHAN_AUTO, "ZB5/rocket_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)	

static id; id = pev(ent, pev_owner)

if(zp_core_is_human(id, 1))
check_radius_damage(ent, id)

engfunc(EngFunc_RemoveEntity, ent)
}
public check_radius_damage(ent, attacker)
{
if(!pev_valid(ent)) 
return;	

for(new i = 0; i < get_maxplayers(); i++)
{
if(!is_user_alive(i))
continue
if(!zp_core_is_zombie(i))
continue
if(entity_range(ent, i) > 200.0)
continue

CreateScreenShake(i)
Make_ScreenFade(i, 0.5, 200, 0, 0, 200, FADE_IN, 1)
ExecuteHamB(Ham_TakeDamage, i, ent, attacker, 500.0, DMG_BULLET)
}
}
bomb_find_enemy(id)
{
new Float:originV[3], Float:originB[3], total, g_bomb_enemy_r[MAX_BOMB_NUM]

new Float:origin[3]
pev(id, pev_origin, origin)

// reset g_bomb_enemy
g_bomb_enemy[id] = g_bomb_enemy_r

// find enemy
new victim = -1
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 1000.0)) != 0)
{	
if (!is_user_alive(victim))
continue;
if (!zp_core_is_zombie(victim))
continue;
if (id == victim)
continue;

if (total >= 10) 
break;

pev(victim, pev_origin, originV)
originB = originV

originB[2] += 150.0
originV[2] += 150.0

if (get_can_see(originB, originV))
{
g_bomb_enemy[id][total] = victim
total ++
}
}
}
// SPRITES
public check_visible(ent, pSet)
{
if(!pev_valid(ent))
return FMRES_IGNORED

static classname[32]
pev(ent, pev_classname, classname, 31)

if(!equal(classname, SPRITE_CLASSNAME))
return FMRES_IGNORED

forward_return(FMV_CELL, 1)

return FMRES_SUPERCEDE
}

public fm_fullpack(es, e, ent, host, hostflags, player, pSet)
{
if(!is_user_connected(host))
return FMRES_IGNORED

if(!is_user_alive(host))
return FMRES_IGNORED

if(!pev_valid(ent))
return FMRES_IGNORED

static classname[32]
pev(ent, pev_classname, classname, 31)

if(!equal(classname, SPRITE_CLASSNAME))
return FMRES_IGNORED

if(!pev_valid(ent))
return FMRES_IGNORED
if(zp_core_round() == MODE_AMBUSH)
{
if(!is_user_alive(host))
set_es(es, ES_Effects, get_es(es, ES_Effects) | EF_NODRAW)
}else{
if(!is_user_alive(host) || zp_core_is_zombie(host))
set_es(es, ES_Effects, get_es(es, ES_Effects) | EF_NODRAW)
else if(is_user_alive(host) && !zp_core_is_zombie(host))
set_es(es, ES_Effects, get_es(es, ES_Effects) & ~EF_NODRAW)
else if(!is_user_alive(host) && !zp_core_is_zombie(host))
set_es(es, ES_Effects, get_es(es, ES_Effects) & ~EF_NODRAW)
}	
static ptr; ptr = create_tr2()
static Float:start[3], Float:end[3], Float:fVecEnd[3], Float:vNormal[3]

pev(host, pev_origin, start)
pev(ent, pev_origin, end)

engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, ent, ptr)
new Float:fFraction;
get_tr2(ptr, TR_flFraction, fFraction);		

get_tr2(ptr, TR_vecEndPos, fVecEnd)
get_tr2(ptr, TR_vecPlaneNormal, vNormal)

xs_vec_mul_scalar(vNormal, 7.0, vNormal)

xs_vec_add(fVecEnd, vNormal, vNormal)

set_es(es, ES_Origin, vNormal)
new Float:dist, Float:scale

pev(ent, pev_origin, start)
pev(host, pev_origin, end)
dist = get_distance_f(start, end)

if(dist<=METR_UNITS*100.0 && pev_valid(pev(ent, pev_iuser1)))
{
if(dist > 1.0) set_es(es, ES_Frame, float(101 - floatround(dist/METR_UNITS)) )
else set_es(es, ES_Frame, 0.0 )

dist = get_distance_f(fVecEnd, end)
scale = 10.0 / dist

if(scale > MAX_SCALE)	// Max Scale
scale = MAX_SCALE

if(fFraction != 1.0) {	
if(scale < MIN_SCALE_F)	// Min Scale
scale = MIN_SCALE_F
}
else {
if(scale < MIN_SCALE)	// Min Scale
scale = MIN_SCALE
}

set_es(es, ES_Scale, scale)
}
else
{
set_es(es, ES_Effects, get_es(es, ES_Effects) | EF_NODRAW)
remove_entity(ent)
}

free_tr2(ptr)

return FMRES_IGNORED

}
public spawn_sprite(id)
{
static ent; ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

if(!pev_valid(ent))
return

static Float:orig[3]
pev(id, pev_origin, orig)

orig[2] += Z_AXIS

set_pev(ent, pev_classname, SPRITE_CLASSNAME)
set_pev(ent, pev_origin, orig)
set_pev(id, pev_iuser1, ent)
set_pev(ent, pev_iuser1, id)

engfunc(EngFunc_SetModel, ent, "sprites/ZB5/supl_new.spr")
fm_set_rendering(ent, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 240)
set_pev(ent, pev_solid, SOLID_NOT)
set_pev(ent, pev_movetype, MOVETYPE_NONE)

if(is_user_alive(id) && !zp_core_is_zombie(id))
{
fm_set_entity_visibility(ent, 0)
set_task(20.0, "ShowSupply", ent)
}
}
stock aim_at_origin(id, Float:target[3], Float:angles[3])
{
static Float:vec[3]
pev(id,pev_origin,vec)
vec[0] = target[0] - vec[0]
vec[1] = target[1] - vec[1]
vec[2] = target[2] - vec[2]
engfunc(EngFunc_VecToAngles,vec,angles)
angles[0] *= -1.0, angles[2] = 0.0
}
stock get_can_see(Float:ent_origin[3], Float:target_origin[3])
{
new Float:hit_origin[3]
trace_line(-1, ent_origin, target_origin, hit_origin)						

if (!vector_distance(hit_origin, target_origin)) return 1;

return 0;
}
stock ent_move_to(ent, Float:target[3], speed)
{
// set vel
static Float:vec[3]
aim_at_origin(ent,target,vec)
engfunc(EngFunc_MakeVectors, vec)
global_get(glb_v_forward, vec)
vec[0] *= speed
vec[1] *= speed
vec[2] *= speed
set_pev(ent, pev_velocity, vec)

// turn to target
new Float:angle[3]
aim_at_origin(ent, target, angle)
angle[0] = 0.0
entity_set_vector(ent, EV_VEC_angles, angle)
}
stock fm_get_aim_origin2(index, Float:origin[3]) {
new Float:start[3], Float:view_ofs[3];
pev(index, pev_origin, start);
pev(index, pev_view_ofs, view_ofs);
xs_vec_add(start, view_ofs, start);

new Float:dest[3];
pev(index, pev_v_angle, dest);
engfunc(EngFunc_MakeVectors, dest);
global_get(glb_v_forward, dest);
xs_vec_mul_scalar(dest, 500.0, dest);
xs_vec_add(start, dest, dest);

engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
get_tr2(0, TR_vecEndPos, origin);

return 1;
}
remove_ent_by_class(classname[])
{
new nextitem  = find_ent_by_class(-1, classname)
if(!pev_valid(nextitem))
return
while(nextitem)
{
if(pev_valid(nextitem))
remove_entity(nextitem)
nextitem = find_ent_by_class(-1, classname)
}
}
sendmsg_BarTime(id, wait_time)
{
static g_msgBarTime; g_msgBarTime = get_user_msgid("BarTime")	
message_begin(MSG_ONE, g_msgBarTime, _, id)
write_short(wait_time)
message_end()
}
check_spawn_box(Float:origin[3]) // By Sontung0
{
new Float:originE[3], Float:origin1[3], Float:origin2[3]
new ent = -1
while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", SUPPLYBOX_CLASSNAME)) != 0)
{
pev(ent, pev_origin, originE)

// xoy
origin1 = origin
origin2 = originE
origin1[2] = origin2[2] = 0.0
if (vector_distance(origin1, origin2) <= 32.0) return 0;
}
return 1;
}
collect_spawn_point(Float:origin[3]) // By Sontung0
{
for (new i = 1; i <= g_had2[TOTAL]*3 ; i++)
{
origin = g_supplybox_spawn[random(g_had2[TOTAL])]
if (check_spawn_box(origin)) return 1;
}

return 0;
}
stock CreateScreenShake(id)
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, id)
write_short((1<<12) * random_num(2,20))
write_short((1<<12) * random_num(2,5))
write_short((1<<12) * random_num(2,20))
message_end()
}

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)

Register_SafetyFunc()
{

RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Reset_Bomb(id)

Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

Safety_Disconnected(id)
{
Reset_Bomb(id)

UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Spawn_Post(id)
{
Reset_Bomb(id)
Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)
}
public zp_fw_core_cure_post(id)
{
Reset_Bomb(id)
	
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
Reset_Bomb(id)
	
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Reset_Bomb(id)
Set_BitVar(g_IsZombie, id)
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
