#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <ZombieMod5>
#include <ScenarioMod>

#define SUPPLY_CLASSNAME "supplybox"
#define SUPPLYBOX_TEAM CS_TEAM_CT

#define TASK_SUPPLYBOX 18707
#define MAX_SUPPLYBOX 10

enum _:Supplybox
{
COUNT,
SUPPLYBOX,
QUANTITY
}
new const sound[][] ={"ZB5/supplybox_pickup.wav", "ZB5/supplybox_drop.wav" }

new g_PlayerSpawn_Count, Float:g_PlayerSpawn_Point[64][3]
new g_had[Supplybox], g_MaxPlayers
new g_IsConnected, g_IsAlive, g_IsZombie

public plugin_init()
{
if(zbs_is_scenario()) return		
Register_SafetyFunc()

register_touch(SUPPLY_CLASSNAME, "player", "fw_SupplyTouch")
collect_spawns_ent("info_player_start")
collect_spawns_ent("info_player_deathmatch")

g_MaxPlayers = get_maxplayers()
}
public plugin_precache()
{
if(zbs_is_scenario()) return	
	
for(new i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])	

PrecacheModel("sprites/ZB5/supplybox_spr.spr") 	
}
public zp_fw_round_new()
{
if(zbs_is_scenario()) return	
	
remove_entity_name(SUPPLY_CLASSNAME)
}
public zp_fw_game_start()
{
if(zbs_is_scenario()) return	
	
remove_task(TASK_SUPPLYBOX)
set_task(60.0, "SupplyBox_Drop", TASK_SUPPLYBOX, _, _, "b")	
}	
public zp_fw_game_end()
{
if(zbs_is_scenario()) return	
	
remove_task(TASK_SUPPLYBOX)
g_had[COUNT] = 0
}
public SupplyBox_Drop()
{
for(new i = 0; i < 2; i++) // drop per 
{
if(g_had[COUNT] >= 2) // drop per
return

SupplyBox_Create()
}

// Play Sound
for(new id = 0; id < g_MaxPlayers; id++)
{
if(!is_alive(id))
continue
if(!(cs_get_user_team(id) & SUPPLYBOX_TEAM))
continue

PlaySound(id, "ZB5/supplybox_drop.wav")
client_print(id, print_center, "Supplybox has arrived!")
}
}

public SupplyBox_Create()
{
if(g_had[COUNT] <= MAX_SUPPLYBOX)
{	
static Supply; Supply = create_entity("info_target")
set_pev(Supply, pev_classname, SUPPLY_CLASSNAME)

engfunc(EngFunc_SetModel, Supply, "models/ZB5/Items/ZB5_Items_NEW.mdl")	
set_pev(Supply, pev_body, 2 - 1)
engfunc(EngFunc_SetSize, Supply, Float:{-10.0,-10.0,0.0}, Float:{10.0,10.0,6.0})

set_pev(Supply, pev_solid, SOLID_TRIGGER)
set_pev(Supply, pev_movetype, MOVETYPE_TOSS)

static Float:Origin[3]
Origin[2] += 8.0
engfunc(EngFunc_SetOrigin, Supply, Origin)

g_had[COUNT]++

Ent_SpawnRandom(Supply)
zb5_AddTofull_eIcon(Supply, 220, 0.5, 10.0, "sprites/ZB5/supplybox_spr.spr")
}
}
public fw_SupplyTouch(Ent, id)
{
if(!is_valid_ent(Ent))
return
if(!is_alive(id))
return

// Effect & Sound
EmitSound(id, CHAN_ITEM, "ZB5/supplybox_pickup.wav")
SupplyBox_GiveItem(id)

g_had[COUNT]--

if(pev_valid(zb5_valid_eIcon(Ent)))
remove_entity(zb5_valid_eIcon(Ent))

set_pev(Ent, pev_flags, FL_KILLME)
set_pev(Ent, pev_nextthink, get_gametime() + 0.01)
}

public SupplyBox_GiveItem(id)
{
static name[32]
get_user_name(id, name, 31)

// Nightvision
if(!zb5_get_user_nvg(id))
zb5_set_user_nvg(id, 1, 0, 1, 1)

// Give Grenades
get_weapon_grenade_he(id, 2)
get_weapon_grenade_flash(id, 2)
get_weapon_grenade_smoke(id, 3)

// Refill Ammo
zb5_restock_ammo(id)

zb5_set_user_quest(id, QUEST_SUPPLYBOX, 1)

if(zp_core_round() != MODE_AMBUSH)
{	
if(!zp_core_is_hero(id))
{	
switch(random_num(0,2))
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
}
}else client_print(0, print_center, "%s has received Grenade and Magazine set from SupplyBox !!!", name)
}else{
if(g_had[QUANTITY]< 4)
{	
g_had[QUANTITY]++
client_print(id, print_center, "Your team collected %i / 4 Supplyboxes!!!", g_had[QUANTITY])	
}
if(g_had[QUANTITY] == 4)
{
for(new i = 1; i <= g_MaxPlayers; i++)
{
if(is_alive(i) && zp_core_is_zombie(i))
{
user_kill(i)
Make_ScreenFade(i,6.0, 0, 0, 0, 250, FADE_IN)
}
}
}
}
}
/// STOCK
public Ent_SpawnRandom(id)
{
if (!g_PlayerSpawn_Count)
return;	

static hull, sp_index, i

hull = HULL_HUMAN
sp_index = random_num(0, g_PlayerSpawn_Count - 1)

for (i = sp_index + 1; /*no condition*/; i++)
{
if(i >= g_PlayerSpawn_Count) i = 0

if(is_hull_vacant(g_PlayerSpawn_Point[i], hull))
{
engfunc(EngFunc_SetOrigin, id, g_PlayerSpawn_Point[i])
break
}

if (i == sp_index) break
}
}
stock is_hull_vacant(Float:Origin[3], hull)
{
engfunc(EngFunc_TraceHull, Origin, Origin, 0, hull, 0, 0)

if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
return true

return false
}
stock collect_spawns_ent(const classname[])
{
static ent; ent = -1
while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
{
// get origin
static Float:originF[3]
pev(ent, pev_origin, originF)

g_PlayerSpawn_Point[g_PlayerSpawn_Count][0] = originF[0]
g_PlayerSpawn_Point[g_PlayerSpawn_Count][1] = originF[1]
g_PlayerSpawn_Point[g_PlayerSpawn_Count][2] = originF[2]

// increase spawn count
g_PlayerSpawn_Count++
if(g_PlayerSpawn_Count >= sizeof g_PlayerSpawn_Point) break;
}
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
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return
	
Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)
}

is_alive(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0
if(Get_BitVar(g_IsZombie, id))
return 0

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/
