/obj/machinery/camera

	var/list/localMotionTargets = list()
	var/detectTime = 0
	var/area/ai_monitored/area_motion = null
	var/alarm_delay = 30 // Don't forget, there's another 3 seconds in queueAlarm()

/obj/machinery/camera/process()
	// motion camera event loop
	if(!isMotion())
		. = PROCESS_KILL
		return
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > alarm_delay)
			triggerAlarm()
	else if (detectTime == -1)
		for (var/mob/target in getTargetList())
			if (target.stat == DEAD || (!area_motion && !in_range(src, target)))
				//If not part of a monitored area and the camera is not in range or the target is dead
				lostTarget(target)

/obj/machinery/camera/proc/getTargetList()
	if(area_motion)
		return area_motion.motionTargets
	return localMotionTargets

/obj/machinery/camera/proc/newTarget(mob/target)
	if(isAI(target))
		return 0
	if (detectTime == 0)
		detectTime = world.time // start the clock
	var/list/targets = getTargetList()
	if (!(target in targets))
		targets += target
	return 1

/obj/machinery/camera/proc/lostTarget(mob/target)
	var/list/targets = getTargetList()
	if (target in targets)
		targets -= target
	if (targets.len == 0)
		cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if (detectTime == -1)
		for (var/mob/living/silicon/aiPlayer in player_list)
			if (status)
				aiPlayer.cancelAlarm("Motion", get_area(src), src)
	detectTime = 0
	return 1

/obj/machinery/camera/proc/triggerAlarm()
	if (!detectTime) return 0
	for (var/mob/living/silicon/aiPlayer in player_list)
		if (status)
			aiPlayer.triggerAlarm("Motion", get_area(src), list(src), src)
	detectTime = -1
	return 1

/obj/machinery/camera/HasProximity(atom/movable/AM as mob|obj)
	// Motion cameras outside of an "ai monitored" area will use this to detect stuff.
	if (!area_motion)
		if(isliving(AM))
			newTarget(AM)

