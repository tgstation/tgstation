/datum/status_effect/revival_shock
	id = "revival_shock"
	alert_type = /atom/movable/screen/alert/status_effect/revival_shock
	duration = 5 MINUTES
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/revival_shock/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_EASILY_WOUNDED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/revival_shock/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_EASILY_WOUNDED, TRAIT_STATUS_EFFECT(id))

/atom/movable/screen/alert/status_effect/revival_shock
	name = "Revival"
	desc = "Your body is still recovering after being revived, making you easier to wound."
	icon_state = "weaken"
