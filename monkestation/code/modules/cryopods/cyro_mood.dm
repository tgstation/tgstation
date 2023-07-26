/datum/mood_event/tucked_in
	description = "I feel better having tucked someone in for a good night's rest!"
	mood_change = 3
	timeout = 2 MINUTES

/datum/mood_event/tucked_in/add_effects(mob/tuckee)
	if(!tuckee)
		return
	description = "I feel better having tucked in [tuckee.name] for a good night's rest!"
