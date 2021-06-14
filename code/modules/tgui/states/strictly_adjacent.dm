/**
 * tgui state: strictly_adjacent_state
 *
 * In addition to not incapacitated checks, only allows the interface to
 * be open for an adjacent user. Will close the UI if adjacency check fails.
 * There is no middleground for UI_UPDATE. This is a strict adjacency check.
 * Ignores TK.
 */

GLOBAL_DATUM_INIT(strictly_adjacent_state, /datum/ui_state/strictly_adjacent_state, new)

/datum/ui_state/strictly_adjacent_state/can_use_topic(src_object, mob/user)
	. = user.not_incapacitated_can_use_topic(src_object)

	if(. != UI_INTERACTIVE)
		return UI_CLOSE

	var/dist = get_dist(src_object, user)
	if(dist > 1)
		return UI_CLOSE
