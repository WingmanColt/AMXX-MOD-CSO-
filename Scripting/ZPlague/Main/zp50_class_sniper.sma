#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <cs_weap_models_api>
#include <xs>
#include <ZP_Shop>
#include <zp50_core>


#define TASK_AURA 514
#define ID_AURA (taskid - TASK_AURA)
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

new g_MaxPlayers, g_IsSniper, m_spriteTexture, g_exp, Float:StartOrigin2[3]
public plugin_init()
{
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)		
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")	
RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
register_clcmd("drop", "clcmd_drop")
g_MaxPlayers = get_maxplayers()
}
public plugin_precache()
{
m_spriteTexture = precache_model("sprites/dot.spr")
g_exp =  precache_model("sprites/ZPlague/explosion_1.spr")
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_sniper_get", "native_class_sniper_get")
register_native("zp_class_sniper_set", "native_class_sniper_set")
register_native("zp_class_sniper_get_count", "native_class_sniper_get_count")
}
public zp_fw_core_cure_post(id, attacker)
{
if (!flag_get(g_IsSniper, id))
return;

drop_weapons(id, 1)
set_user_health(id, 2000)
set_user_gravity(id, 0.7)
cs_set_player_maxspeed_auto(id, 1.20)
cs_set_player_model(id, "ZP_Crysis01")
give_item(id, "weapon_awp")
cs_set_user_bpammo(id, CSW_AWP, 30)
set_task(0.1, "aura", id+TASK_AURA, _, _, "b")
}
public client_disconnect(id)
{
if (flag_get(g_IsSniper, id))
{
remove_task(id+TASK_AURA)
}
}

public fw_ClientDisconnect_Post(id)
{
flag_unset(g_IsSniper, id)
}

public clcmd_drop(id)
{
if (flag_get(g_IsSniper, id))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}

public fw_TouchWeapon(weapon, id)
{
if (is_user_alive(id) && flag_get(g_IsSniper, id))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_IsSniper, id))
{
flag_unset(g_IsSniper, id)
remove_task(id+TASK_AURA)
}
}
public zp_fw_core_infect(id, attacker)
{
if (flag_get(g_IsSniper, id))
{
flag_unset(g_IsSniper, id)
remove_task(id+TASK_AURA)
}
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (flag_get(g_IsSniper, attacker) && zp_core_is_zombie(victim))
{
if (inflictor == attacker)
{
if(get_user_weapon(attacker) == CSW_AWP)ExecuteHamB(Ham_Killed, victim, attacker, 0)
return HAM_HANDLED;
}
}

return HAM_IGNORED;
}
public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
if(!is_user_alive(iAttacker))
return

new g_currentweapon = get_user_weapon(iAttacker)

if(g_currentweapon != CSW_AWP || !flag_get(g_IsSniper, iAttacker))
return

static Float:flEnd[3]
get_tr2(ptr, TR_vecEndPos, flEnd)

get_position(iAttacker, 20.0, 5.0, 5.0, StartOrigin2)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMPOINTS)
engfunc(EngFunc_WriteCoord, StartOrigin2[0])
engfunc(EngFunc_WriteCoord, StartOrigin2[1])
engfunc(EngFunc_WriteCoord, StartOrigin2[2] - 10.0)
engfunc(EngFunc_WriteCoord, flEnd[0])
engfunc(EngFunc_WriteCoord, flEnd[1])
engfunc(EngFunc_WriteCoord, flEnd[2])
write_short(m_spriteTexture)
write_byte(0) // start frame
write_byte(0) // framerate
write_byte(5) // life
write_byte(5) // line width
write_byte(0) // amplitude
write_byte(230)     // r
write_byte(180)       //g
write_byte(0)       // b
write_byte(255) // brightness
write_byte(0) // speed
message_end()

static Float:Origin[3], TE_FLAG
pev(iEnt, pev_origin, Origin)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND
TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(g_exp)
write_byte(7)
write_byte(35)
write_byte(TE_FLAG)
message_end()	
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
if (flag_get(g_IsSniper, victim))
{
remove_task(victim+TASK_AURA)
}
}
public native_class_sniper_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_IsSniper, id);
}

public native_class_sniper_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_IsSniper, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a sniper (%d)", id)
return false;
}

flag_set(g_IsSniper, id)
zp_core_force_cure(id)
return true;
}

public native_class_sniper_get_count(plugin_id, num_params)
{
return GetsniperCount();
}
stock drop_weapons(id, dropwhat)
{
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

static weapons[32], num, i, weaponid
num = 0
get_user_weapons(id, weapons, num)

for (i = 0; i < num; i++)
{
weaponid = weapons[i]

if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
{
static wname[32]
get_weaponname(weaponid, wname, sizeof wname - 1)
engclient_cmd(id, "drop", wname)
}
}
}
GetsniperCount()
{
new isnipers, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_IsSniper, id))
isnipers++
}

return isnipers;
}
stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

pev(id, pev_origin, vOrigin)
pev(id, pev_view_ofs, vUp) //for player
xs_vec_add(vOrigin, vUp, vOrigin)
pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles

angle_vector(vAngle,ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
angle_vector(vAngle,ANGLEVECTOR_RIGHT, vRight)
angle_vector(vAngle,ANGLEVECTOR_UP, vUp)

vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}
public aura(taskid)
{
// Get player's origin
static origin[3]
get_user_origin(ID_AURA, origin)

// Colored Aura
message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(15) // radius
write_byte(120) // r
write_byte(100) // g
write_byte(0) // b
write_byte(2) // life
write_byte(3) // decay rate
message_end()
}
