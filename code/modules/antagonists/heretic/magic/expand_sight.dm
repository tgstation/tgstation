// Action for Raw Prophets that boosts up or shrinks down their sight range.
/datum/action/innate/expand_sight
	name = "Expand Sight"
	desc = "Boosts your sight range considerably, allowing you to see enemies from much further away."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	/// How far we expand the range to.
	var/boost_to = 5
	/// A cooldown for the last time we toggled it, to prevent spam.
	COOLDOWN_DECLARE(last_toggle)

/datum/action/innate/expand_sight/IsAvailable(feedback = FALSE)
	return ..() && COOLDOWN_FINISHED(src, last_toggle)

/datum/action/innate/expand_sight/Activate()
	active = TRUE
	owner.client?.view_size.setTo(boost_to)
	playsound(owner, SFX_HALLUCINATION_I_SEE_YOU, 50, TRUE, ignore_walls = FALSE)
	COOLDOWN_START(src, last_toggle, 8 SECONDS)

/datum/action/innate/expand_sight/Deactivate()
	active = FALSE
	owner.client?.view_size.resetToDefault()
	COOLDOWN_START(src, last_toggle, 4 SECONDS)
