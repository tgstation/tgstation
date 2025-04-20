/datum/status_effect/pranked
	id = "pranked"
	duration = 20 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	///increments every time the status effect is refreshed. Higher counter == more powerful clown combos.
	var/prank_counter = 1

/datum/status_effect/pranked/refresh()
	. = ..()
	prank_counter++
