/obj/machinery/camera

	var/list/datum/weakref/localMotionTargets = list()
	var/detectTime = 0
	var/area/ai_monitored/area_motion = null
	var/alarm_delay = 30 // Don't forget, there's another 3 seconds in queueAlarm()

/obj/machinery/camera/process()
	// motion camera event loop
	if(!isMotion())
		. = PROCESS_KILL
		return
	if(stat & EMPED)
		return
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > alarm_delay)
			triggerAlarm()
	else if (detectTime == -1)
		for (var/datum/weakref/targetref in getTargetList())
			var/mob/target = targetref.resolve()
			if(QDELETED(target) || target.stat == DEAD || (!area_motion && !in_range(src, target)))
				//If not part of a monitored area and the camera is not in range or the target is dead
				lostTargetRef(targetref)

/obj/machinery/camera/proc/getTargetList()
	if(area_motion)
		return area_motion.motionTargets
	return localMotionTargets

/obj/machinery/camera/proc/newTarget(mob/target)
	if(isAI(target))
		return FALSE
	if (detectTime == 0)
		detectTime = world.time // start the clock
	var/list/targets = getTargetList()
	targets |= WEAKREF(target)
	return TRUE

/obj/machinery/camera/Destroy()
	var/area/ai_monitored/A = get_area(src)
	localMotionTargets = null
	if(istype(A))
		A.motioncameras -= src
	cancelAlarm()
	return ..()

/obj/machinery/camera/proc/lostTargetRef(datum/weakref/R)
	var/list/targets = getTargetList()
	targets -= R
	if (targets.len == 0)
		cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if (detectTime == -1)
		for (var/i in GLOB.silicon_mobs)
			var/mob/living/silicon/aiPlayer = i
			if (status)
				aiPlayer.cancelAlarm("Motion", get_area(src), src)
	detectTime = 0
	return TRUE

/obj/machinery/camera/proc/triggerAlarm()
	if (!detectTime)
		return FALSE
	for (var/mob/living/silicon/aiPlayer in GLOB.player_list)
		if (status)
			aiPlayer.triggerAlarm("Motion", get_area(src), list(src), src)
			visible_message("<span class='warning'>A red light flashes on the [src]!</span>")
	detectTime = -1
	return TRUE

/obj/machinery/camera/HasProximity(atom/movable/AM as mob|obj)
	// Motion cameras outside of an "ai monitored" area will use this to detect stuff.
	if (!area_motion)
		if(isliving(AM))
			newTarget(AM)
