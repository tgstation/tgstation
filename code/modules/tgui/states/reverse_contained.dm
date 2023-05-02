/*!
 * Not copyrighted, but magatsuchi made it.
 *
 */

/**
 * tgui state: reverse_contained_state
 *
 *
 * Checks if src_object is inside of user.
 */

GLOBAL_DATUM_INIT(reverse_contained_state, /datum/ui_state/reverse_contained_state, new)

/datum/ui_state/reverse_contained_state/can_use_topic(atom/src_object, mob/user)
	if(!user.contains(src_object))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
