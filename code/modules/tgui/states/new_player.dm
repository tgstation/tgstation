/**
 * tgui state: new_player_state
 *
 * Checks that the user is a /mob/dead/new_player
 */

GLOBAL_DATUM_INIT(new_player_state, /datum/ui_state/new_player_state, new)

/datum/ui_state/new_player_state/can_use_topic(src_object, mob/user)
	return isnewplayer(user) ? UI_INTERACTIVE : UI_CLOSE
