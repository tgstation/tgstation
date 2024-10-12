/datum/status_effect/revival_shock
	id = "revival_shock"
	alert_type = /atom/movable/screen/alert/status_effect/revival_shock
	duration = 10 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	remove_on_fullheal = TRUE

/datum/status_effect/revival_shock/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_EASILY_WOUNDED, TRAIT_STATUS_EFFECT(id))
	if (!isnull(owner.mob_mood))
		owner.add_mood_event("revival", /datum/mood_event/revival_shock)
		owner.mob_mood.set_sanity(SANITY_CRAZY)

/datum/status_effect/revival_shock/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_EASILY_WOUNDED, TRAIT_STATUS_EFFECT(id))
	if (!isnull(owner.mob_mood))
		owner.clear_mood_event("revival")

/atom/movable/screen/alert/status_effect/revival_shock
	name = "Revival"
	desc = "Your body is still recovering after being revived, making you easier to wound."
	icon_state = "weaken"
