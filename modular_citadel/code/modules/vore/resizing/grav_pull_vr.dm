//
//	Gravity Pull effect which draws in movable objects to its center.
//	In this case, "number" refers to the range.  directions is ignored.
//
/datum/effect/effect/system/grav_pull
	var/pull_radius = 3
	var/pull_anchored = 0
	var/break_windows = 0

/datum/effect/effect/system/grav_pull/set_up(range, num, loca)
	pull_radius = range
	number = num
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effect/effect/system/grav_pull/start()
	spawn(0)
		if(holder)
			src.location = get_turf(holder)
		for(var/i=0, i < number, i++)
			do_pull()
			sleep(25)

/datum/effect/effect/system/grav_pull/proc/do_pull()
	//following is adapted from supermatter and singulo code
	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 1

	// Let's just make this one loop.
	for(var/atom/X in orange(pull_radius, location))
		// Movable atoms only
		if(istype(X, /atom/movable))
			if(istype(X, /obj/effect/overlay)) continue
			if(X && !istype(X, /mob/living/carbon/human))
				if(break_windows && istype(X, /obj/structure/window)) //shatter windows
					var/obj/structure/window/W = X
					W.ex_act(2.0)

				if(istype(X, /obj))
					var/obj/O = X
					if(O.anchored)
						if (!pull_anchored) continue // Don't pull anchored stuff unless configured
						step_towards(X, location)  // step just once if anchored
						continue

				step_towards(X, location) // Step twice
				step_towards(X, location)

			else if(istype(X,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = X
				if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						step_towards(H, location) //step just once with magboots
						continue
				step_towards(H, location) //step twice
				step_towards(H, location)

	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 0
	return
