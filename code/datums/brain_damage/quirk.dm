// Quirk brain traumas are ungainable through play, but a player may start
// with a number of them through quirks.

/datum/brain_trauma/quirk
	random_gain = FALSE

/datum/brain_trauma/quirk/mood
	// What makes a man turn neutral?
	name = "Neutral Mood"
	desc = "Patient occasionally feels neutral."
	scan_desc = "neutrality"
	gain_text = "<span class='danger'>You start feeling neutral.</span>"
	lose_text = "<span class='notice'>You no longer feel neutral.</span>"

	var/mood_event = /datum/mood_event/neutral
	// mild depression/jolly mood lasts 2 minutes
	// with average of 4 minutes between firing, you'll be affected 50% of the time
	var/lower_bound = 2 MINUTES
	var/upper_bound = 6 MINUTES

/datum/brain_trauma/quirk/mood/on_gain()
	..()
	episode()

/datum/brain_trauma/quirk/mood/proc/episode()
	if(QDELETED(src) || QDELETED(owner))
		return

	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, name, mood_event)

	addtimer(CALLBACK(src, .proc/episode), rand(lower_bound, upper_bound))

/datum/brain_trauma/quirk/mood/on_lose()
	..()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, name)


/datum/brain_trauma/quirk/mood/depression
	name = "Depression"
	desc = "Patient has a mood disorder causing them to experience acute episodes of depression."
	scan_desc = "depressive disorder"
	gain_text = "<span class='danger'>You start feeling depressed.</span>"
	// Not that easy in real life.
	lose_text = "<span class='notice'>You no longer feel depressed.</span>"

	mood_event = /datum/mood_event/depression_mild

/datum/brain_trauma/quirk/mood/jolly
	name = "Irrational Optimism"
	desc = "Patient demonstrates constant euthymia irregular for environment."
	scan_desc = "neurochemical euphoria"
	gain_text = "<span class='notice'>You feel cheerful.<span>"
	lose_text = "<span class='danger'>You feel less cheerful.</span>"

	mood_event = /datum/mood_event/jolly
