#include <amxmodx> 
#include <fakemeta> 
#include <zp50_core> 

new const g_survivor_pain_sound[][] = { "ZB5/human/f_bhit_flesh-1.wav" , "ZB5/human/f_bhit_flesh-2.wav", "ZB5/human/f_bhit_flesh-3.wav", "player/bhit_flesh-1.wav" , "player/bhit_flesh-2.wav", "player/bhit_flesh-3.wav" } 
new const g_survivor_die_sound[][] = { "ZB5/human/f_die1.wav", "ZB5/human/f_die2.wav", "ZB5/human/f_die3.wav", "player/die1.wav", "player/die2.wav", "player/die3.wav" } 

public plugin_init()  
{ 
register_forward(FM_EmitSound, "fw_EmitSounHuman") 
} 


public plugin_precache() 
{ 
for(new iPlayer = 0; iPlayer < sizeof g_survivor_pain_sound; iPlayer ++)  
{
precache_sound(g_survivor_pain_sound[iPlayer])  
}		
for(new iPlayer = 0; iPlayer < sizeof g_survivor_die_sound; iPlayer ++) 
{	
precache_sound(g_survivor_die_sound[iPlayer]) 
}
} 


public fw_EmitSounHuman(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if (!is_user_connected(id)) 
return FMRES_IGNORED; 
if(!zp_core_is_zombie(id)) 
{
if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, g_survivor_pain_sound[random_num(0, sizeof g_survivor_pain_sound - 1)] , volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, g_survivor_die_sound[random_num(0, sizeof g_survivor_die_sound - 1)] , volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
}
return FMRES_IGNORED 
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
