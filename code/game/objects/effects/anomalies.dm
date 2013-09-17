//Anomalies, used for events. Note that these won't work by themselves; their procs are called by the event datum.

/obj/effect/anomaly
	name = "anomaly"
	icon = 'icons/effects/effects.dmi'
	desc = "A mysterious anomaly seen in the region of space that the station orbits."
	icon_state = "bhole3"
	unacidable = 1
	density = 0
	anchored = 1

/obj/effect/anomaly/proc/anomalyEffect()
	if(prob(50))
		step(src,pick(alldirs))

///////////////////////

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "shield2"
	density = 1

/obj/effect/anomaly/grav/anomalyEffect()
	..()

	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in orange(4, src))
		step_towards(M,src)

/obj/effect/anomaly/grav/Bump(mob/A)
	gravShock(A)
	return

/obj/effect/anomaly/grav/Bumped(mob/A)
	gravShock(A)
	return

/obj/effect/anomaly/grav/proc/gravShock(var/mob/A)
	if(isliving(A) && !A.stat)
		A.Weaken(4)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		return

/////////////////////

obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity"

/////////////////////

obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "mustard"

obj/effect/anomaly/pyro/anomalyEffect()
	..()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("fire", 3)

/////////////////////

/obj/effect/anomaly/bhole //TODO: Make this start out weaker, building power until critical mass
	name = "vortex anomaly"
	icon_state = "bhole3"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		del(src)
		return

	//DESTROYING STUFF AT THE EPICENTER
	for(var/mob/living/M in orange(1,src))
		M.gib()
	for(var/obj/O in orange(1,src))
		del(O)
	for(var/turf/simulated/ST in orange(1,src))
		ST.ChangeTurf(/turf/space)

	grav(rand(2,4), rand(2,4), rand(10,75), rand(0, 25))
//	grav(rand(2,10), rand(2,4), rand(10,75), rand(0, 25))

/obj/effect/anomaly/bhole/proc/grav(var/r, var/ex_act_force, var/pull_chance, var/turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x+t, y-r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-t, y+r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x+r, y+t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-r, y-t, ex_act_force, pull_chance, turf_removal_chance)
	return

/obj/effect/anomaly/bhole/proc/affect_coord(var/x, var/y, var/ex_act_force, var/pull_chance, var/turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))	return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if( prob(pull_chance) )
		for(var/obj/O in T.contents)
			if(O.anchored)
				O.ex_act(ex_act_force)
			else
				step_towards(O,src)
		for(var/mob/living/M in T.contents)
			step_towards(M,src)

	//Destroying the turf
	if( T && istype(T,/turf/simulated) && prob(turf_removal_chance) )
		var/turf/simulated/ST = T
		ST.ChangeTurf(/turf/space)
	return