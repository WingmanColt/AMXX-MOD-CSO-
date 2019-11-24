#if defined _zp50_core_included
  #endinput
#endif
#define _zp50_core_included

#include <zp50_core_const>

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib zp50_core
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib zp50_core
	#endif
#else
	#pragma library zp50_core
#endif


native zp_admin_menu_show(id)
native zp_ammopacks_get(id)
native zp_ammopacks_set(id, amount)
native grenade_antidote(id, mode)
native grenade_flare(id, mode)
native zp_grenade_fire_get(id)
native zp_grenade_fire_set(id, set = true)
native zp_remove_fire_aura(id)
native zp_core_is_first_zombie(id)
native zp_core_is_zombie(id)
native zp_core_is_last_zombie(id)
native zp_core_is_last_human(id)
native zp_core_get_zombie_count()
native zp_core_get_human_count()
native zp_core_infect(id, attacker = 0)
native zp_core_cure(id, attacker = 0)
native zp_core_force_infect(id)
native zp_core_force_cure(id)
native zp_core_respawn_as_zombie(id, zombie = true)

native zp_class_nemesis_get(id)
native zp_class_nemesis_set(id)
native zp_class_nemesis_get_count()
native zp_class_assassin_get(id)
native zp_class_assassin_set(id)
native zp_class_assassin_get_count()
native zp_class_survivor_get(id)
native zp_class_survivor_set(id)
native zp_class_survivor_get_count()
native zp_class_sniper_get(id)
native zp_class_sniper_set(id)
native zp_class_sniper_get_count()

native PrecacheModel(const szFile[])
native PrecacheSound(const szFile[])
native PrecacheGeneric(const szFile[])

forward zp_fw_core_infect(id, attacker)
forward zp_fw_core_infect_post(id, attacker)
forward zp_fw_core_cure(id, attacker)
forward zp_fw_core_cure_post(id, attacker)
forward zp_fw_core_infect_pre(id, attacker)
forward zp_fw_core_cure_pre(id, attacker)
forward zp_fw_core_last_zombie(id)
forward zp_fw_core_last_human(id)
forward zp_fw_core_spawn_post(id)
forward RuningTime()
forward RuningTime_Player(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
