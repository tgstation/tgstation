/obj/effect/particle_effect/smoke
	alpha = 0


/obj/effect/particle_effect/smoke/New(loc)
	..()
	addtimer(CALLBACK(src, /obj/effect/particle_effect/.proc/smokefoam_fade_in), 0)

/obj/effect/particle_effect/smoke/kill_smoke()
	..()
	animate(src, alpha = 0, time = 10)

/obj/effect/particle_effect/smoke/chem/process()
	if(..() && reagents)
		var/turf/T = get_turf(src)
		var/fraction = 1/initial(lifetime)
		for(var/atom/movable/AM in T)
			if(AM.type == src.type)
				continue
			if(T.intact && AM.level == 1) //hidden under the floor
				continue
			reagents.reaction(AM, TOUCH, fraction)

		reagents.reaction(T, TOUCH, fraction)
		CHECK_TICK
		return 1

/obj/effect/particle_effect/smoke/ex_act()
	return