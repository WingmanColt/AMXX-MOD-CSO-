#if defined _zp50_class_sniper_included
  #endinput
#endif
#define _zp50_class_sniper_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib zp50_class_sniper
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib zp50_class_sniper
	#endif
#else
	#pragma library zp50_class_sniper
#endif


/**
 * Returns whether a player is a sniper.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
native zp_class_sniper_get(id)

/**
 * Forces a player to become a sniper.
 *
 * @param id		Player index.
 * @return			True on success, false otherwise.
 */
native zp_class_sniper_set(id)

/**
 * Returns number of alive sniper.
 *
 * @return		sniper count.
 */
native zp_class_sniper_get_count()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
