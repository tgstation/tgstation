/**
 * tgui state: horizontal_state
 *
 * Similar to the regular UI check, but also allows them to use UI in a laying down position. (Think handheld like tablets.)
 */

GLOBAL_DATUM_INIT(horizontal_state, /datum/ui_state/horizontal_state, new)

/datum/ui_state/horizontal_state/can_use_topic(atom/src_object, mob/user)
	return user.horizontal_can_use_topic(src_object)

/mob/proc/horizontal_can_use_topic(src_object)
	return UI_CLOSE // Don't allow interaction by default.

/mob/living/horizontal_can_use_topic(src_object)
	if(loc) //must not be in nullspace.
		. = shared_living_ui_distance(src_object) // Check the distance...
	if(!ISADVANCEDTOOLUSER(src))
		return UI_UPDATE
	// Close UIs if mindless.
	if(!client && !HAS_TRAIT(src, TRAIT_PRESERVE_UI_WITHOUT_CLIENT))
		return UI_CLOSE
	// Disable UIs if unconscious.
	else if(stat)
		return UI_DISABLED
	// Update UIs if incapicitated but concious.
	else if(incapacitated())
		return UI_UPDATE
