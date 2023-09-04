/datum/status_effect/rust_corruption
	id = "rust_turf_effects"
	tick_interval = 2 SECONDS
	remove_on_fullheal = TRUE

/datum/status_effect/rust_corruption/on_apply()
	owner.add_mood_event("rust_corruption", /datum/mood_event/rust_corruption)
	return TRUE

/datum/status_effect/rust_corruption/tick(seconds_between_ticks)
	var/mob/living/carbon/person = owner
	person.shoes.take_damage(25)
	person.adjustStaminaLoss(3)
