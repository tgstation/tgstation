/obj/machinery/camera

	var/list/motionTargets = list()
	var/detectTime = 0
	var/locked = 1

/obj/machinery/camera/motion/New()
	..()
	assembly.upgrades.Add(new /obj/item/device/assembly/prox_sensor(assembly))

/obj/machinery/camera/process()
	// motion camera event loop
	if(!isMotion())
		..()
		return
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > 300)
			triggerAlarm()
	else if (detectTime == -1)
		for (var/mob/target in motionTargets)
			if (target.stat == 2) lostTarget(target)

/obj/machinery/camera/proc/newTarget(var/mob/target)
	if (istype(target, /mob/living/silicon/ai)) return 0
	if (detectTime == 0)
		detectTime = world.time // start the clock
	if (!(target in motionTargets))
		motionTargets += target
	return 1

/obj/machinery/camera/proc/lostTarget(var/mob/target)
	if (target in motionTargets)
		motionTargets -= target
	if (motionTargets.len == 0)
		cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if (detectTime == -1)
		for (var/mob/living/silicon/aiPlayer in player_list)
			if (status) aiPlayer.cancelAlarm("Motion", src.loc.loc)
	detectTime = 0
	return 1

/obj/machinery/camera/proc/triggerAlarm()
	if (!detectTime) return 0
	for (var/mob/living/silicon/aiPlayer in player_list)
		if (status) aiPlayer.triggerAlarm("Motion", src.loc.loc, src)
	detectTime = -1
	return 1

/obj/machinery/camera/proc/isMotion()
	var/O = locate(/obj/item/device/assembly/prox_sensor) in assembly.upgrades
	return O