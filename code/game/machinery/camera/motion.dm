/obj/machinery/camera/process()
	// motion camera event loop
	if(!isMotion())
		return PROCESS_KILL
	if(machine_stat & EMPED)
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
	localMotionTargets = null
	if(area_motion)
		LAZYREMOVE(area_motion.motioncameras, src)
	cancelAlarm()
	return ..()

/obj/machinery/camera/proc/lostTargetRef(datum/weakref/R)
	var/list/targets = getTargetList()
	targets -= R
	if (targets.len == 0)
		cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if (detectTime == -1 && camera_enabled)
		alarm_manager.clear_alarm(ALARM_MOTION)
	detectTime = 0
	return TRUE

/obj/machinery/camera/proc/triggerAlarm()
	if (!detectTime)
		return FALSE
	if(camera_enabled)
		if(alarm_manager.send_alarm(ALARM_MOTION, src, src))
			visible_message(span_warning("A red light flashes on [src]!"))
	detectTime = -1
	return TRUE

/obj/machinery/camera/HasProximity(atom/movable/AM as mob|obj)
	// Motion cameras outside of an "ai monitored" area will use this to detect stuff.
	if (!area_motion)
		if(isliving(AM))
			newTarget(AM)

/obj/machinery/camera/motion/thunderdome
	name = "entertainment camera"
	network = list(CAMERANET_NETWORK_THUNDERDOME)
	c_tag = "Arena"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/machinery/camera/motion/thunderdome/Initialize(mapload)
	. = ..()
	proximity_monitor.set_range(7)

/obj/machinery/camera/motion/thunderdome/HasProximity(atom/movable/AM as mob|obj)
	if (!isliving(AM) || get_area(AM) != get_area(src))
		return
	localMotionTargets |= WEAKREF(AM)
	if (!detectTime)
		for(var/obj/machinery/computer/security/telescreen/entertainment/TV as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/security/telescreen/entertainment))
			TV.notify(TRUE)
	detectTime = world.time + 30 SECONDS

/obj/machinery/camera/motion/thunderdome/process()
	if (!detectTime)
		return

	for (var/datum/weakref/targetref in localMotionTargets)
		var/mob/target = targetref.resolve()
		if(QDELETED(target) || target.stat == DEAD || get_dist(src, target) > 7 || get_area(src) != get_area(target))
			localMotionTargets -= targetref

	if (localMotionTargets.len)
		detectTime = world.time + 30 SECONDS
	else if (world.time > detectTime)
		detectTime = 0
		for(var/obj/machinery/computer/security/telescreen/entertainment/TV as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/security/telescreen/entertainment))
			TV.notify(FALSE)
