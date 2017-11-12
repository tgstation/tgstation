GLOBAL_LIST_EMPTY(smoke)
/obj/effect/particle_effect/smoke/New()
	..()
	LAZYADD(GLOB.smoke, src)
	create_reagents(500)
	START_PROCESSING(SSreagent_states, src)


/obj/effect/particle_effect/smoke/Destroy()
	LAZYREMOVE(GLOB.smoke, src)
	STOP_PROCESSING(SSreagent_states, src)
	return ..()

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	LAZYREMOVE(GLOB.smoke, src)
	STOP_PROCESSING(SSreagent_states, src)
	INVOKE_ASYNC(src, .proc/fade_out)
	QDEL_IN(src, 10)

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