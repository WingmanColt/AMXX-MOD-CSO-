#if defined _registration_system_included
	#endinput
#endif
#define _registration_system_included

/**
 * Returns whether a player is logged.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native reg_open_menu(id)
native reg_is_user_logged(id)

/**
 * Returns whether a player is registered.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native reg_is_user_registered(id)

/**
 * Returns whether a player is invited.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native reg_is_user_invited(id)

/**
 * Called when a player gets register.
 *
 * @param id		Player index.
 */
forward reg_user_register(id)

/**
 * Called when a player gets logged.
 *
 * @param id		Player index.
 */
forward reg_user_logged(id)

/**
 * Called when a player gets invited.
 *
 * @param id		Player index.
 */
forward reg_user_logged_invited(id)

/**
 * Called when a player gets deleted.
 *
 * @param id		Player index.
 */
forward reg_user_account_deleted(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
