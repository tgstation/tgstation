/**
 * tgui state: new_player_state
 *
 * Checks that the user is a new_player, or if user is an admin
 */

GLOBAL_DATUM_INIT(new_player_state, /datum/ui_state/new_player_state, new)

/datum/ui_state/new_player_state/can_use_topic(src_object, mob/user)
	if(isnewplayer(user) || check_rights_for(user.client, R_ADMIN))
		return UI_INTERACTIVE
	return UI_CLOSE

