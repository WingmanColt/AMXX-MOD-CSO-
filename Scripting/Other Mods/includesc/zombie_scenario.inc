native zbs_is_zombie(ent) // Check if ent is zombie
native zbs_is_valid_zombie(ent) // Check if is valid zombie
native zbs_get_class(ent) // Get ent class zombie
native zbs_get_current_target(ent) // Return the victim of ent
native zbs_make_sprite(id, sprite, scale, frame, x, y, z)
native zbs_make_icon_sprite(id, sprite, scale, brightness)
native zbs_get_round() // Get ent class zombie
forward zbs_round_start_pre(id) // Called when zombie appear
forward zbs_round_start_post(id) // Called when zombie appear
forward zbs_npc_killed_post(ent, attacker) // Called when zombie appear
forward zbs_spawn_post(id) // Called when zombie appear

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang13322\\ f0\\ fs16 \n\\ par }
*/
