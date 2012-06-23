/area/ai_monitored
	name = "AI Monitored Area"
	var/obj/machinery/camera/motion/motioncamera = null


/area/ai_monitored/New()
	..()
	// locate and store the motioncamera
	spawn (20) // spawn on a delay to let turfs/objs load
		for (var/obj/machinery/camera/motion/M in src)
			motioncamera = M
			return
	return

/area/ai_monitored/Entered(atom/movable/O)
	..()
	if (istype(O, /mob) && motioncamera)
		motioncamera.newTarget(O)

/area/ai_monitored/Exited(atom/movable/O)
	if (istype(O, /mob) && motioncamera)
		motioncamera.lostTarget(O)

/obj/machinery/camera/motion
	name = "Motion Security Camera"
	var/list/motionTargets = list()
	var/detectTime = 0
	var/locked = 1

/obj/machinery/camera/motion/process()
	// motion camera event loop
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > 300)
			triggerAlarm()
	else if (detectTime == -1)
		for (var/mob/target in motionTargets)
			if (target.stat == 2) lostTarget(target)

/obj/machinery/camera/motion/proc/newTarget(var/mob/target)
	if (istype(target, /mob/living/silicon/ai)) return 0
	if (detectTime == 0)
		detectTime = world.time // start the clock
	if (!(target in motionTargets))
		motionTargets += target
	return 1

/obj/machinery/camera/motion/proc/lostTarget(var/mob/target)
	if (target in motionTargets)
		motionTargets -= target
	if (motionTargets.len == 0)
		cancelAlarm()

/obj/machinery/camera/motion/proc/cancelAlarm()
	if (detectTime == -1)
		for (var/mob/living/silicon/aiPlayer in world)
			if (status) aiPlayer.cancelAlarm("Motion", src.loc.loc)
	detectTime = 0
	return 1

/obj/machinery/camera/motion/proc/triggerAlarm()
	if (!detectTime) return 0
	for (var/mob/living/silicon/aiPlayer in world)
		if (status) aiPlayer.triggerAlarm("Motion", src.loc.loc, src)
	detectTime = -1
	return 1

/obj/machinery/camera/motion/attackby(W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters) && locked == 1) return
	if (istype(W, /obj/item/weapon/screwdriver))
		var/turf/T = user.loc
		user << text("\blue []ing the access hatch... (this is a long process)", (locked) ? "Open" : "Clos")
		sleep(100)
		if ((user.loc == T && user.get_active_hand() == W && !( user.stat )))
			src.locked ^= 1
			user << text("\blue The access hatch is now [].", (locked) ? "closed" : "open")

	..() // call the parent to (de|re)activate

	if (istype(W, /obj/item/weapon/wirecutters)) // now handle alarm on/off...
		if (status) // ok we've just been reconnected... send an alarm!
			detectTime = world.time - 301
			triggerAlarm()
		else
			for (var/mob/living/silicon/aiPlayer in world) // manually cancel, to not disturb internal state
				aiPlayer.cancelAlarm("Motion", src.loc.loc)
