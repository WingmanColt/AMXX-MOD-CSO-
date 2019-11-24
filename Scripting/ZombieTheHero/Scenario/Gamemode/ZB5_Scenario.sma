#include <amxmodx>
#include <cs_teams_api>
#include <ZombieMod5>
#include <infinitygame>

#define TASK_SCENE 51816
#define TASK_RECHECK 52001
#define TASK_REVIVE 51817

#define PREPARE "rex/game/Scenario_Ready.mp3"
#define FIGHT "rex/game/Scenario_Rush.mp3"

#define RESPAWN_TIME 60
#define DOOR_HEALTH 5000

new g_Respawn_Time[33], g_IsAlive, g_IsConnected
new Door

public plugin_init()
{	
register_think("func_breakable", "FwdThinkBreak");
if(zbs_is_scenario() == 0) return	

Register_SafetyFunc()

//Find_MainDoor()
//Initialize_Door(1)

server_cmd("mp_freezetime 20")
server_cmd("mp_timelimit 9000")
server_cmd("mp_maxrounds 0")
server_cmd("mp_winlimit 0")
server_cmd("mp_fraglimit 0")
server_cmd("mp_friendlyfire 0")
}

public Reset_Value()
{
//remove_task(TASK_SCENE)	
}

public ChangeMap()
{
server_cmd("changelevel cs_italy")	
}

// RESPAWN
public zp_fw_core_dead_post(id)
{
if(zbs_is_scenario() == 0) return		
g_Respawn_Time[id] = RESPAWN_TIME
Start_Revive(id)
}
public Start_Revive(id)
{
id -= TASK_REVIVE

if(!is_user_connected(id))
return

if(g_Respawn_Time[id] <= 0)
{
Revive_Now(id)
return
}

client_print(id, print_center, "You will be Revived after: %i Second(s)", g_Respawn_Time[id])
g_Respawn_Time[id]--
set_task(1.0, "Start_Revive", id+TASK_REVIVE)
}

public Revive_Now(id)
{
if(!is_connected(id))
return	

if(is_alive(id))
return

remove_task(id+TASK_REVIVE)
//IG_TeamSet(id, CS_TEAM_CT)	
//ExecuteHamB(Ham_CS_RoundRespawn, id)
}
// DOOR AND CUTSCENE
public FwdThinkBreak(iEntity) 
{
if(!pev_valid(iEntity))
return

if(entity_get_int(iEntity, EV_INT_solid ) == SOLID_NOT) 
{
static iEffects
iEffects = entity_get_int(iEntity, EV_INT_effects);

if(!(iEffects & EF_NODRAW))
entity_set_int(iEntity, EV_INT_effects, iEffects | EF_NODRAW);

if(entity_get_int(iEntity, EV_INT_deadflag ) != DEAD_DEAD)
entity_set_int(iEntity, EV_INT_deadflag, DEAD_DEAD );

remove_entity(iEntity)
}
}
public Find_MainDoor()
{
static Classname[32]

for(new i = 0; i < entity_count(); i++)
{
if(!pev_valid(i))
continue

pev(i, pev_classname, Classname, sizeof(Classname))
if(!equal(Classname, "func_breakable"))
continue

pev(i, pev_targetname, Classname, sizeof(Classname))
if(!equal(Classname, "door_brk"))
continue

Door = i
server_print("[CSO] Dr.Rex: Found Door (%i)", Door)
}
}
public Initialize_Door(First)
{
if(!pev_valid(Door))
return

set_pev(Door, pev_takedamage, DAMAGE_YES)
set_pev(Door, pev_health, float(DOOR_HEALTH))
fm_set_rendering(Door, kRenderFxNone, 120, 0, 0, kRenderTransColor, 200)

if(First) 
{
RegisterHamFromEntity(Ham_TakeDamage, Door, "fw_Door_TakeDamage")
RegisterHamFromEntity(Ham_TakeDamage, Door, "fw_Door_TakeDamage_Post", 1)
}
}

public fw_Door_TakeDamage(Victim, Inflictor, Attacker, Float:Damage, DamageBits)
{
return HAM_IGNORED
}

public fw_Door_TakeDamage_Post(Victim, Inflictor, Attacker, Float:Damage, DamageBits)
{
static Float:Health; pev(Victim, pev_health, Health)
if(Health <= 0.0) 
{
//Activate_Cutscene()
return
}
static Float:g_fHaveDamage[33]

g_fHaveDamage[Attacker] += Damage;

if (g_fHaveDamage[Attacker] >= 2000.0)
{
zb5_set_user_exp(Attacker, 1, 0)
g_fHaveDamage[Attacker] = 0.0	
}

client_print(Attacker, print_center, "Health: %i", floatround(Health))
}


// NATIVES 
public plugin_natives()
{
register_native("zbs_is_door", "native_door", 1)
register_native("zbs_is_boss", "native_boss", 1)
register_native("zbs_is_zombie", "native_npc", 1)
}

public native_door(ent)return is_door(ent);
public native_npc(bot) return is_npc(bot);
public native_boss(bot) return is_boss(bot);

// STOCKS
stock is_boss(ent)
{
if (!pev_valid(ent)) 
return 0;

static classname[32]
pev(ent, pev_classname, classname, charsmax(classname))

if (equal(classname, "BOSS"))return 1;
return 0;
}

stock is_npc(ent)
{
if (!pev_valid(ent)) 
return 0;

static classname[32]
pev(ent, pev_classname, classname, charsmax(classname))

if (equal(classname, "ZOMBIE"))return 1;

return 0;
}

stock is_door(ent)
{
if (!pev_valid(ent)) 
return 0;

static Classname[32]
pev(ent, pev_classname, Classname, sizeof(Classname))

if (equal(Classname, "door_brk") || equal(Classname, "func_breakable")) return 1;
return 0;
}

stock StopSound() 
{
client_cmd(0, "mp3 stop; stopsound")
}

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)
{
if(zbs_is_scenario() == 0) return

Safety_Connected(id)
}
Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}
Safety_Connected(id)
{
if(zbs_is_scenario() == 0) return
		
remove_task(id+TASK_REVIVE)
	
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)

if(zp_GameStart())
{
g_Respawn_Time[id] = RESPAWN_TIME
Start_Revive(id)
}else Revive_Now(id)

}

Safety_Disconnected(id)
{	
if(zbs_is_scenario() == 0) return

UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)

remove_task(id+TASK_REVIVE)	
g_Respawn_Time[id] = 0
}

public fw_Safety_Spawn_Post(id)
{		
if(!is_user_alive(id))
return

remove_task(id+TASK_RECHECK)
Set_BitVar(g_IsAlive, id)
}
public fw_Safety_Killed_Post(id)
{		
UnSet_BitVar(g_IsAlive, id)
}
public is_connected(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0

return 1
}

public is_alive(id)
{
if(!is_connected(id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
