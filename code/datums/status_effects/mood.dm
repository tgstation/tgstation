/datum/status_effect/recurring_mood
	id = "Recurring Mood"
	alert_type = null

	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE

	// What mood event will be given when the episode occurs
	var/mood_event = /datum/mood_event/neutral

	// If not null, if the owner does not have the given trait
	// when the next episode occurs, the status effect will stop.
	var/associated_trait = TRAIT_NEUTRAL

	// mild depression/jolly mood lasts 2 minutes
	// with average of 4 minutes between firing, you'll be affected 50% of the time
	var/lower_bound = 2 MINUTES
	var/upper_bound = 6 MINUTES

/datum/status_effect/recurring_mood/on_apply()
	. = ..()
	episode()

/datum/status_effect/recurring_mood/proc/episode()
	if(QDELETED(src) || QDELETED(owner))
		return

	if(associated_trait && !HAS_TRAIT(owner, associated_trait))
		qdel(src)
		return


	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, mood_event)

	addtimer(CALLBACK(src, .proc/episode), rand(lower_bound, upper_bound))

/datum/status_effect/recurring_mood/on_remove()
	..()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)


/datum/status_effect/recurring_mood/depression
	id = "Recurring Depression"
	mood_event = /datum/mood_event/depression_mild
	associated_trait = TRAIT_DEPRESSION


/datum/status_effect/recurring_mood/jolly
	id = "Recurring Jolly Mood"
	mood_event = /datum/mood_event/jolly
	associated_trait = TRAIT_JOLLY


/datum/status_effect/recurring_mood/neutral
	// It's mild weather
	// I am fine
	id = "Recurring Neutral Mood"
