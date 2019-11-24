#if defined _zp50_admin_commands_included
  #endinput
#endif
#define _zp50_admin_commands_included

#include <zp50_core>

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib zp50_admin_commands
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib zp50_admin_commands
	#endif
#else
	#pragma library zp50_admin_commands
#endif


native zp_admin_commands_zombie(id, player)
native zp_admin_commands_human(id, player)
native zp_admin_commands_nemesis(id, player)
native zp_admin_commands_assassin(id, player)
native zp_admin_commands_clown(id, player)
native zp_admin_commands_carlito(id, player)
native zp_admin_commands_survivor(id, player)
native zp_admin_commands_sniper(id, player)
native zp_admin_commands_respawn(id, player)
native zp_admin_commands_start_mode(id, game_mode_id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
