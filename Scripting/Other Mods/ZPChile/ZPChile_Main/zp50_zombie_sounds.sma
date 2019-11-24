#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>

#define TASK_IDLE_SOUNDS 100
#define ID_IDLE_SOUNDS (taskid - TASK_IDLE_SOUNDS)

new const sound_nemesis_pain[][] = { "ZPChile/Nemesis/pain1.wav", "ZPChile/Nemesis/pain2.wav" }
new const sound_assassin_pain[][] = { "ZPChile/Assassin/pain1.wav", "ZPChile/Assassin/pain2.wav", "ZPChile/Assassin/pain3.wav" }
new const sound_zombie_idle[][] = { "ZPChile/Zombie/idle1.wav", "ZPChile/Zombie/idle2.wav" }

public plugin_init()
{	
register_forward(FM_EmitSound, "fw_EmitSound")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
// Replace these next sounds for zombies only
if (!is_user_connected(id) || !zp_core_is_zombie(id))
return FMRES_IGNORED;

// Zombie being hit
if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
{
// Nemesis Class loaded?
if (zp_class_nemesis_get(id))
{
emit_sound(id, channel, sound_nemesis_pain[random_num(0, sizeof sound_nemesis_pain - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
if (zp_class_assassin_get(id))
{
emit_sound(id, channel, sound_assassin_pain[random_num(0, sizeof sound_assassin_pain - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
return FMRES_SUPERCEDE;
}

// Zombie dies
if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
{
if (zp_class_nemesis_get(id))
{
emit_sound(id, channel, "ZPChile/Nemesis/death1.wav", volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}	
if (zp_class_assassin_get(id))
{
emit_sound(id, channel, "ZPChile/Assassin/death1.wav", volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
return FMRES_SUPERCEDE;
}
return FMRES_IGNORED;
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
remove_task(victim+TASK_IDLE_SOUNDS)
}
public client_disconnect(id)
{
remove_task(id+TASK_IDLE_SOUNDS)
}

public zp_fw_core_infect_post(id, attacker)
{
remove_task(id+TASK_IDLE_SOUNDS)

if (!zp_class_nemesis_get(id))
{
set_task(random_float(50.0, 70.0), "zombie_idle_sounds", id+TASK_IDLE_SOUNDS, _, _, "b")
}
}

public zp_fw_core_cure_post(id, attacker)
{
remove_task(id+TASK_IDLE_SOUNDS)
}
public zombie_idle_sounds(taskid)
{
if (zp_core_is_zombie(ID_IDLE_SOUNDS))
{
emit_sound(ID_IDLE_SOUNDS, CHAN_VOICE, sound_zombie_idle[random_num(0, sizeof sound_zombie_idle - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
}
}
