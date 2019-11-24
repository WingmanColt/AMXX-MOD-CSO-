#if defined _zp50_class_assassin_included
  #endinput
#endif
#define _zp50_class_assassin_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib zp50_class_assassin
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib zp50_class_assassin
	#endif
#else
	#pragma library zp50_class_assassin
#endif


/**
 * Returns whether a player is a assassin.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
native zp_class_assassin_get(id)

/**
 * Forces a player to become a assassin.
 *
 * @param id		Player index.
 * @return			True on success, false otherwise.
 */
native zp_class_assassin_set(id)

/**
 * Returns number of alive assassin.
 *
 * @return		assassin count.
 */
native zp_class_assassin_get_count()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
