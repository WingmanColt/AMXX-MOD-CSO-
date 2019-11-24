#include <amxmodx>
#include <ZombieMod5>

new Float:g_Delay_ComeSound, g_MsgDeathMsg,g_MsgScoreAttrib, g_infect

new const human_death[][] = {"ZB5/human_death_01.wav","ZB5/human_death_02.wav"}
new const female_death[][] = {"ZB5/human_death_female_01.wav","ZB5/human_death_female_02.wav"}
new const coming[][] = {"ZB5/zombi_coming_1.wav", "ZB5/zombi_coming_2.wav", "ZB5/zombi_coming_3.wav", "ZB5/zombi_coming_4.wav"}

public plugin_init()
{
g_MsgDeathMsg = get_user_msgid("DeathMsg")
g_MsgScoreAttrib = get_user_msgid("ScoreAttrib")
}
public plugin_precache()
{
for(new i = 0; i < sizeof(human_death); i++)
PrecacheSound(human_death[i])
for(new i = 0; i < sizeof(female_death); i++)
PrecacheSound(female_death[i])	
for(new i = 0; i < sizeof(coming); i++)
PrecacheSound(coming[i])	
				
g_infect = PrecacheModel("sprites/ZB5/ef_infect.spr")	
}
public zp_fw_core_infect_post(id, attacker)
{		
if (attacker != id)
{
static attacker_name[32], victim_name[32]
get_user_name(attacker, attacker_name, charsmax(attacker_name))
get_user_name(id, victim_name, charsmax(victim_name))

zombie_appear_sound()
SendDeathMsg(attacker, id)
FixDeadAttrib(id)
}
EmitSound(id, CHAN_AUTO, human_death[random_num(0, sizeof human_death - 1)])
zb5_set_user_quest(id, QUEST_INFECT, 1)

Make_Dlight(id, 10, 200, 10, 10, 2, 2)
Make_Elight(id, 10, 200, 10, 10, 15, 15)

Make_ScreenShake(id, 4, 1, 3)
Make_Sprite(id, g_infect, 2, 4, 35, 2, -15)
}
public zombie_appear_sound()
{
if(get_gametime() - 0.5 > g_Delay_ComeSound)
{
EmitSound(0, CHAN_AUTO, coming[random_num(0, sizeof coming - 1)])
client_print(0, print_center, "Zombie Infection!")
g_Delay_ComeSound = get_gametime()
}
}
SendDeathMsg(attacker, victim)
{
message_begin(MSG_BROADCAST, g_MsgDeathMsg)
write_byte(attacker) // killer
write_byte(victim) // victim
write_byte(1) // headshot flag
write_string("infection") // killer's weapon
message_end()
}

FixDeadAttrib(id)
{
message_begin(MSG_BROADCAST, g_MsgScoreAttrib)
write_byte(id) // id
write_byte(0) // attrib
message_end()
}
