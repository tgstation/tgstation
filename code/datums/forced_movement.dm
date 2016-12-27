//usage new /datum/forced_movement(victim, target, steps_per_tick, allow_tabling, spin)

/datum/forced_movement
	var/atom/movable/victim
	var/atom/target
	var/stunned
	var/last_processed
	var/steps_per_tick
	var/moved_y_last
	var/allow_tabling
	var/spin
															//as fast as ssfastprocess
/datum/forced_movement/New(mob/avictim, atom/movable/atarget, asteps_per_tick = 0.5, aallow_tabling = FALSE, aspin = FALSE)
	victim = avictim
	target = atarget
	steps_per_tick = asteps_per_tick
	allow_tabling = aallow_tabling
	spin = aspin

	last_processed = world.time
	moved_y_last = FALSE

	. = ..()

	if(!avictim.force_moving)
		avictim.force_moving = src
		START_PROCESSING(SSfastprocess, src)
	else
		qdel(src)	//caller can check qdeleted(us) if they wanna know

/datum/forced_movement/Destroy()
	victim = null
	target = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/forced_movement/process()
	if(qdeleted(victim) || !victim.loc || qdeleted(target) || !target.loc)
		qdel(src)
		return
	var/steps_to_take = round(steps_per_tick * (world.time - last_processed))
	if(steps_to_take)
		for(var/i in 0 to steps_to_take)
			if(!TryMove())
				victim.force_moving = null
				victim.forceMove(victim.loc)	//get the side effects of moving here that require us to currently not be force_moving aka reslipping on ice
				qdel(src)
				return
		last_processed = world.time

/datum/forced_movement/proc/TryMove(recursive = FALSE)
	var/atom/movable/vic = victim	//sanic
	var/atom/tar = target

	if(iscarbon(vic))
		var/mob/living/carbon/C = vic
		if(spin)
			C.spin(1,1)

	moved_y_last = !moved_y_last

	if(moved_y_last)
		if(tar.x > vic.x)
			if(step(vic, EAST))
				return TRUE
		else if(tar.x < vic.x)
			if(step(vic, WEST))
				return TRUE
	else
		if(tar.y > vic.y)
			if(step(vic, NORTH))
				return TRUE
		else if(tar.y < vic.y)
			if(step(vic, SOUTH))
				return TRUE

	if(recursive)
		return FALSE
	else
		return TryMove(TRUE)

/mob/Bump(atom/A)
	. = ..()
	if(force_moving && force_moving.allow_tabling && istype(A,/obj/structure))
		var/obj/structure/S = A
		if(S.climbable)
			S.do_climb(src)

#ifdef DEBUG
/mob/verb/forcemoveto(atom/A as mob|obj|turf in view())
	set name = "Force Move To"
	set category = "IC"
	var/result = text2num(input(usr, "Enter a speed in steps per tick", "Debug forced_movement"))
	if(isnum(result))
		new /datum/forced_movement(src, A, result, TRUE, TRUE)
#endif