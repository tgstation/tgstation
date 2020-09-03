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

///What happens when this event is added
/datum/pocket_event/proc/on_add(datum/pocket_dim_customizer/dim)

///What happens when this event is removed
/datum/pocket_event/proc/on_remove()

///What happens when this event is triggered for the first tim in the duration
/datum/pocket_event/proc/on_trigger(pocket_dim)

///What happens when this event is triggered for the last time in the duration
/datum/pocket_event/proc/on_disable(pocket_dim)

///What happens every tick of the duration
/datum/pocket_event/proc/on_tick(pocket_dim)

///What happens when the pocket dim is breached
/datum/pocket_event/proc/on_breach(datum/pocket_dim_customizer/dim,turf/cause)

///What happens when the walls of the pocket dim are bumped
/datum/pocket_event/proc/on_bump(datum/pocket_dim_customizer/dim,turf/cause)
