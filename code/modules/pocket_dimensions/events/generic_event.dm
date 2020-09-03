/datum/pocket_event
	///Name
	var/name = "Pocket Evenet"
	///Desc
	var/desc = "Does literally nothing"
	///How often does it trigger
	var/period = 0
	///How long does the effect last, use -1 for always
	var/duration = 0
	///How much of the duration is left
	var/duration_left = 0
	///How much of the period is left
	var/period_left = 0

/datum/pocket_event/proc/on_add(datum/pocket_dim_customizer/dim)

/datum/pocket_event/proc/on_remove()

/datum/pocket_event/proc/on_trigger(pocket_dim)

/datum/pocket_event/proc/on_disable(pocket_dim)

/datum/pocket_event/proc/on_tick(pocket_dim)

/datum/pocket_event/proc/on_breach(turf/cause)

/datum/pocket_event/proc/on_bump(turf/cause)
