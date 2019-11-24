#if defined _zp50_class_nemesis_included
  #endinput
#endif
#define _zp50_class_nemesis_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib zp50_class_nemesis
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib zp50_class_nemesis
	#endif
#else
	#pragma library zp50_class_nemesis
#endif


/**
 * Returns whether a player is a Nemesis.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
native zp_class_nemesis_get(id)

/**
 * Forces a player to become a Nemesis.
 *
 * @param id		Player index.
 * @return			True on success, false otherwise.
 */
native zp_class_nemesis_set(id)

/**
 * Returns number of alive nemesis.
 *
 * @return		Nemesis count.
 */
native zp_class_nemesis_get_count()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
