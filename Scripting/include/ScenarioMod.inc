enum 
{
NONE = 0,	
DOOR,
NPC,
BOSS
}

native zbs_is_scenario()
native zbs_is_game_started()
native zp_round_terminate(end)

native zbs_is_zombie(ent)
native zbs_is_boss(ent)
native zbs_is_door(ent)
native zbs_enemy()

forward zbs_gamemode_start()
forward zbs_gamemode_end()

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
