/// Parent type for all unique revenant status effects
/datum/status_effect/revenant
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null

/datum/status_effect/revenant/on_creation(mob/living/new_owner, duration)
	if(isnum(duration))
		src.duration = duration
	return ..()

/datum/status_effect/revenant/revealed
	id = "revenant_revealed"

/datum/status_effect/revenant/revealed/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.orbiting?.end_orbit(src)

	ADD_TRAIT(owner, TRAIT_REVENANT_REVEALED, TRAIT_STATUS_EFFECT(id))
	owner.SetInvisibility(INVISIBILITY_NONE, id=type, priority=INVISIBILITY_PRIORITY_BASIC_ANTI_INVISIBILITY)
	owner.incorporeal_move = FALSE
	owner.update_appearance(UPDATE_ICON)
	owner.update_mob_action_buttons()

/datum/status_effect/revenant/revealed/on_remove()
	REMOVE_TRAIT(owner, TRAIT_REVENANT_REVEALED, TRAIT_STATUS_EFFECT(id))

	owner.incorporeal_move = INCORPOREAL_MOVE_JAUNT
	owner.RemoveInvisibility(type)
	owner.update_appearance(UPDATE_ICON)
	owner.update_mob_action_buttons()
	return ..()

/datum/status_effect/revenant/inhibited
	id = "revenant_inhibited"

/datum/status_effect/revenant/inhibited/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.orbiting?.end_orbit(src)

	ADD_TRAIT(owner, TRAIT_REVENANT_INHIBITED, TRAIT_STATUS_EFFECT(id))
	owner.update_appearance(UPDATE_ICON)

	owner.balloon_alert(owner, "inhibited!")

/datum/status_effect/revenant/inhibited/on_remove()
	REMOVE_TRAIT(owner, TRAIT_REVENANT_INHIBITED, TRAIT_STATUS_EFFECT(id))
	owner.update_appearance(UPDATE_ICON)

	owner.balloon_alert(owner, "uninhibited")
	return ..()

/datum/status_effect/incapacitating/paralyzed/revenant
	id = "revenant_paralyzed"

/datum/status_effect/incapacitating/paralyzed/revenant/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.orbiting?.end_orbit(src)

	ADD_TRAIT(owner, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert(owner, "can't move!")
	owner.update_mob_action_buttons()
	owner.update_appearance(UPDATE_ICON)

/datum/status_effect/incapacitating/paralyzed/revenant/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	owner.update_mob_action_buttons()
	owner.balloon_alert(owner, "can move again")

	return ..()
