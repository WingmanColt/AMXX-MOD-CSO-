#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>

#define TASK_IDLE_SOUNDS 100
#define ID_IDLE_SOUNDS (taskid - TASK_IDLE_SOUNDS)

new const sound_zombie_pain[][] = { "ZPlague/Pain/zombie_pain1.wav", "ZPlague/Pain/zombie_pain2.wav", "ZPlague/Pain/zombie_pain3.wav", "ZPlague/Pain/zombie_pain4.wav", "ZPlague/Pain/zombie_pain5.wav" }
new const sound_nemesis_pain[][] = { "ZPlague/Pain/nemesis_pain1.wav", "ZPlague/Pain/nemesis_pain2.wav" }
new const sound_nemesis_die[][] = { "ZPlague/Die/nemesis_die1.wav", "ZPlague/Die/nemesis_die2.wav" }
new const sound_zombie_die[][] = { "ZPlague/Die/zombie_die1.wav", "ZPlague/Die/zombie_die2.wav", "ZPlague/Die/zombie_die3.wav", "ZPlague/Die/zombie_die4.wav" }
new const sound_zombie_knife[][] = { "ZPlague/Knife/hit01.wav", "ZPlague/Knife/hit02.wav", "ZPlague/Knife/hit03.wav" }
new const sound_zombie_idle[][] = { "ZPlague/Idle/zombie_idle1.wav", "ZPlague/Idle/zombie_idle2.wav" }
public plugin_init()
{	
register_forward(FM_EmitSound, "fw_EmitSound")
RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
}
/*public plugin_precache()
{	
for(new i = 0; i < sizeof(sound_zombie_pain); i++)
PrecacheSound(sound_zombie_pain[i])	

for(new i = 0; i < sizeof(sound_nemesis_pain); i++)
PrecacheSound(sound_nemesis_pain[i])	

for(new i = 0; i < sizeof(sound_nemesis_die); i++)
PrecacheSound(sound_nemesis_die[i])	

for(new i = 0; i < sizeof(sound_zombie_die); i++)
PrecacheSound(sound_zombie_die[i])	

for(new i = 0; i < sizeof(sound_zombie_knife); i++)
PrecacheSound(sound_zombie_knife[i])
	
for(new i = 0; i < sizeof(sound_zombie_idle); i++)
PrecacheSound(sound_zombie_idle[i])	
}*/
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
emit_sound(id, channel, sound_zombie_pain[random_num(0, sizeof sound_zombie_pain - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}

// Zombie dies
if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
{
if (zp_class_nemesis_get(id))
{
emit_sound(id, channel, sound_nemesis_die[random_num(0, sizeof sound_nemesis_die - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}	
emit_sound(id, channel, sound_zombie_die[random_num(0, sizeof sound_zombie_die - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
// Zombie attacks with knife
if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
{
if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
{
if (sample[17] == 'w') // wall
{
emit_sound(id, channel, sound_zombie_knife[random_num(0, sizeof sound_zombie_knife - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
else
{
emit_sound(id, channel, sound_zombie_knife[random_num(0, sizeof sound_zombie_knife - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
}
if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
{
emit_sound(id, channel, sound_zombie_knife[random_num(0, sizeof sound_zombie_knife - 1)], volume, attn, flags, pitch)
return FMRES_SUPERCEDE;
}
}

return FMRES_IGNORED;
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
remove_task(victim+TASK_IDLE_SOUNDS)
}
public client_disconnected(id)
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
