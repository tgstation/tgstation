/datum/mood_event
	var/description ///For descriptions, use the span classes bold green, green, none, warning and boldwarning in order from great to horrible.
	var/mood_change = 0
	var/timeout = 0
	var/mob/owner

/datum/mood_event/New(mob/M, param)
	owner = M
	add_effects(param)

/datum/mood_event/Destroy()
	remove_effects()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/remove_effects()
	return
