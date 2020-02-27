

// Created by claiming a Coffin.



// 		THINGS TO SPAWN:
//
//	/obj/effect/decal/cleanable/cobweb && /obj/effect/decal/cleanable/cobweb/cobweb2
//	/obj/effect/decal/cleanable/generic
//	/obj/effect/decal/cleanable/dirt/dust <-- Pretty cool, just stains the tile itself.
//	/obj/effect/decal/cleanable/blood/old

/*
/area/
	// All coffins assigned to this area
	var/list/obj/structure/closet/crate/laircoffins = new list()

// Called by Coffin when an area is claimed as a vamp's lair
/area/proc/ClaimAsLair(/obj/structure/closet/crate/inClaimant)
	set waitfor = FALSE // Don't make on_gain() wait for this function to finish. This lets this code run on the side.

	laircoffins += laircoffins
	sleep()

	// Cancel!
	if (laircoffins.len == 0)
		return
		*/




/datum/antagonist/bloodsucker/proc/RunLair()
	set waitfor = FALSE // Don't make on_gain() wait for this function to finish. This lets this code run on the side.

	while (!AmFinalDeath() && coffin && lair)

		// WAit 10 Sec and Repeat
		sleep(100)

		// Coffin Moved SOMEHOW?
		if (lair != get_area(coffin))
			if (coffin)
				coffin.UnclaimCoffin()
			//lair = get_area(coffin)
			break // DONE

		var/list/turf/area_turfs = get_area_turfs(lair)


		// Create Dirt etc.
		var/turf/T_Dirty = pick(area_turfs)
		if (T_Dirty && !T_Dirty.density)
			// Default: Dirt

			// CHECK: Cobweb already there?
			//if (!locate(var/obj/effect/decal/cleanable/cobweb) in T_Dirty)	// REMOVED! Cleanables don't stack.

			// STEP ONE: COBWEBS

			// CHECK: Wall to North?
			var/turf/check_N = get_step(T_Dirty, NORTH)
			if (istype(check_N, /turf/closed/wall))
				// CHECK: Wall to West?
				var/turf/check_W = get_step(T_Dirty, WEST)
				if (istype(check_W, /turf/closed/wall))
					new /obj/effect/decal/cleanable/cobweb (T_Dirty)
				// CHECK: Wall to East?
				var/turf/check_E = get_step(T_Dirty, EAST)
				if (istype(check_E, /turf/closed/wall))
					new /obj/effect/decal/cleanable/cobweb/cobweb2 (T_Dirty)

			// STEP TWO: DIRT
			new /obj/effect/decal/cleanable/dirt/dust (T_Dirty)


		// Find Animals in Area
		if (rand(0,2) == 0)
			var/mobCount = 0
			var/mobMax = clamp(area_turfs.len / 25, 1, 4)
			for (var/turf/T in area_turfs)
				if (!T) continue
				var/mob/living/simple_animal/SA = locate() in T
				if (SA)
					mobCount ++
					if (mobCount >= mobMax) // Already at max
						break
			// Spawn One
			if (mobCount < mobMax)
				// Seek Out Location
				while (area_turfs.len > 0)
					var/turf/T = pick(area_turfs) // We use while&pick instead of a for/loop so it's random, rather than from the top of the list.
					if (T && !T.density)
						var/mob/living/simple_animal/SA = /mob/living/simple_animal/mouse // pick(/mob/living/simple_animal/mouse,/mob/living/simple_animal/mouse,/mob/living/simple_animal/mouse, /mob/living/simple_animal/hostile/retaliate/bat) //prob(300) /mob/living/simple_animal/mouse,
						new SA (T)
						break
					area_turfs -= T

		// NOTE: area_turfs is now cleared out!
	if (coffin)
		coffin.UnclaimCoffin()

	// Done (somehow)
	lair = null


