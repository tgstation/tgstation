/**
 * tgui state: strictly_adjacent_state
 *
 * In addition to default checks, only allows the interface to be open
 * for an adjacent user. Will close the UI if adjacency check fails.
 * There is no middleground for UI_UPDATE. This is a strict adjacency
 * check. Ignores TK.
 */

GLOBAL_DATUM_INIT(strictly_adjacent_state, /datum/ui_state/strictly_adjacent_state, new)

/datum/ui_state/strictly_adjacent_state/can_use_topic(src_object, mob/user)
	if(get_dist(src_object, user) > 1)
		return UI_CLOSE

	return user.default_can_use_topic(src_object)
