#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#define LIBRARY_GRENADE_FROST "zp50_grenade_frost"
#include <zp50_grenade_frost>

#define TASK_MADNESS 100
#define TASK_AURA 200
#define ID_MADNESS (taskid - TASK_MADNESS)
#define ID_AURA (taskid - TASK_AURA)

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_MadnessBlockDamage
public plugin_init()
{
RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
}
public plugin_natives()
{
register_native("give_item_madness", "Get_Madness", 1)
}
public Get_Madness(id)
{
if (!is_user_alive(id))
return;

flag_set(g_MadnessBlockDamage, id)
set_task(0.1, "madness_aura", id+TASK_AURA, _, _, "b")
emit_sound(id, CHAN_VOICE, "ZPlague/madness.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
set_task(5.0, "remove_zombie_madness", id+TASK_MADNESS)
}

public fw_PlayerSpawn_Post(id)
{
if (!is_user_alive(id) || !cs_get_user_team(id))
return;

remove_task(id+TASK_MADNESS)
remove_task(id+TASK_AURA)
flag_unset(g_MadnessBlockDamage, id)
}

public fw_TraceAttack(victim, attacker)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (flag_get(g_MadnessBlockDamage, victim))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}

public fw_TakeDamage(victim, inflictor, attacker)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (flag_get(g_MadnessBlockDamage, victim))
return HAM_SUPERCEDE;

return HAM_IGNORED;
}

public zp_fw_grenade_frost_pre(id)
{
if (flag_get(g_MadnessBlockDamage, id))
return PLUGIN_HANDLED;

return PLUGIN_CONTINUE;
}

public zp_fw_core_cure(id, attacker)
{
remove_task(id+TASK_MADNESS)
remove_task(id+TASK_AURA)
flag_unset(g_MadnessBlockDamage, id)
}
public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
remove_task(victim+TASK_MADNESS)
remove_task(victim+TASK_AURA)
flag_unset(g_MadnessBlockDamage, victim)
}

public remove_zombie_madness(taskid)
{
remove_task(ID_MADNESS+TASK_AURA)
flag_unset(g_MadnessBlockDamage, ID_MADNESS)
}

public client_disconnect(id)
{
remove_task(id+TASK_MADNESS)
remove_task(id+TASK_AURA)
flag_unset(g_MadnessBlockDamage, id)
}
public madness_aura(taskid)
{
static origin[3]
get_user_origin(ID_AURA, origin)

message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0]) // x
write_coord(origin[1]) // y
write_coord(origin[2]) // z
write_byte(10) // radius
write_byte(200) // r
write_byte(150) // g
write_byte(0) // b
write_byte(2) // life
write_byte(0) // decay rate
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/
