/datum/component/wanderlust
	var/minimum_time = 10 MINUTES
	var/maximum_time = 10 MINUTES

	var/turf/last_turf

/datum/component/wanderlust/Initialize(_min_time = 10 MINUTES, _max_time = 10 MINUTES)
	if(!ismovableatom(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("[type] added to a [parent.type]")	

	minimum_time = _min_time
	maximum_time = _max_time

	START_PROCESSING(SSprocessing, src)

/datum/component/wanderlust/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	last_turf = null
	. = ..()

/datum/component/wanderlust/process()
	var/atom/movable/AM = parent
	var/current_turf = get_turf(parent)
	if(last_turf != current_turf)
		addtimer(CALLBACK(src, .proc/Relocate), rand(minimum_time, maximum_time), TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT)

	last_turf = current_turf

/datum/component/proc/Relocate()
	var/atom/movable/AM = parent
	. = AM.relocate()
	
