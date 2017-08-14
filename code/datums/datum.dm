/datum
    var/gc_destroyed //Time when this object was destroyed.
    var/list/active_timers  //for SStimer
    var/list/datum_components //for /datum/components
    var/ui_screen = "home"  //for tgui

#ifdef TESTING
    var/running_find_references
    var/last_find_references = 0
#endif

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force=FALSE)
	tag = null
	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if (timer.spent)
			continue
		qdel(timer)
	var/list/dc = datum_components
	for(var/I in dc)
		var/datum/component/C = I
		C._RemoveNoSignal()
		qdel(C)
	if(dc)
		dc.Cut()
	return QDEL_HINT_QUEUE