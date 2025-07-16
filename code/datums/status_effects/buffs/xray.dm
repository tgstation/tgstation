/**
 * Effectively grants a temporary form of x-ray with a cooldown period.
 */
/datum/status_effect/temporary_xray
	id = "temp xray"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	duration = 10 SECONDS
	show_duration = TRUE

/datum/status_effect/temporary_xray/on_creation(mob/living/new_owner)
	. = ..()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()

/datum/status_effect/temporary_xray/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()

/datum/status_effect/temporary_xray/eldritch // Heretic subtype that plays a sound and screen alert
	alert_type = /atom/movable/screen/alert/status_effect/temporary_xray

/datum/status_effect/temporary_xray/eldritch/on_creation(mob/living/new_owner)
	. = ..()
	SEND_SOUND(owner, 'sound/effects/hallucinations/i_see_you1.ogg')

/atom/movable/screen/alert/status_effect/temporary_xray
	name = "Eldritch Sight"
	desc = "You get a glimpse of something new..."
	icon_state = "influence"
