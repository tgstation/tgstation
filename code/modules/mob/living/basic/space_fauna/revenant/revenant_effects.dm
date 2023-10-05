/datum/status_effect/incapacitating/paralyzed/revenant
	id = "revenant-paralyzed"

/datum/status_effect/incapacitating/paralyzed/revenant/on_apply()
	. = ..()
	if(!.)
		return FALSE

	ADD_TRAIT(owner, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert(owner, "can't move!")
	owner.update_appearance(UPDATE_ICON)
	owner.orbiting?.end_orbit(src)

/datum/status_effect/incapacitating/paralyzed/revenant/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert(owner, "can move again")

	return ..()
