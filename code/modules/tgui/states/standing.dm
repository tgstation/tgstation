/**
 * tgui state: standing_state
 *
 * Checks that the user isn't incapacitated and is standing upright
 */

GLOBAL_DATUM_INIT(standing_state, /datum/ui_state/not_incapacitated_state/standing, new)

/datum/ui_state/not_incapacitated_state/standing

/datum/ui_state/not_incapacitated_state/standing/can_use_topic(src_object, mob/user)
	if (!isliving(user))
		return ..()
	var/mob/living/living_user = user
	if (living_user.body_position)
		return UI_DISABLED
	return ..()
