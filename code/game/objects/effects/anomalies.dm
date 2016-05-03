//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "bhole3"
	unacidable = 1
	density = 0
	anchored = 1
	luminosity = 3
	var/movechance = 70
	var/obj/item/device/assembly/signaler/anomaly/aSignal = null

/obj/effect/anomaly/New()
	..()
	poi_list |= src
	SetLuminosity(initial(luminosity))
	aSignal = new(src)
	aSignal.code = rand(1,100)

	aSignal.frequency = rand(1200, 1599)
	if(IsMultiple(aSignal.frequency, 2))//signaller frequencies are always uneven!
		aSignal.frequency++

/obj/effect/anomaly/Destroy()
	poi_list.Remove(src)
	return ..()

/obj/effect/anomaly/proc/anomalyEffect()
	if(prob(movechance))
		step(src,pick(alldirs))


/obj/effect/anomaly/ex_act(severity, target)
	if(severity == 1)
		qdel(src)

/obj/effect/anomaly/proc/anomalyNeutralize()
	PoolOrNew(/obj/effect/particle_effect/smoke/bad, loc)

	for(var/atom/movable/O in src)
		O.loc = src.loc

	qdel(src)


/obj/effect/anomaly/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/analyzer))
		user << "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code].</span>"

///////////////////////

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "shield2"
	density = 0
	var/boing = 0

/obj/effect/anomaly/grav/New()
	..()
	aSignal.origin_tech = "magnets=5;powerstorage=4"

/obj/effect/anomaly/grav/anomalyEffect()
	..()
	boing = 1
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in range(0, src))
		gravShock(M)
	for(var/mob/living/M in orange(4, src))
		step_towards(M,src)
	for(var/obj/O in range(0,src))
		if(!O.anchored)
			var/mob/living/target = locate() in view(4,src)
			if(target && !target.stat)
				O.throw_at(target, 5, 10)

/obj/effect/anomaly/grav/Crossed(mob/A)
	gravShock(A)

/obj/effect/anomaly/grav/Bump(mob/A)
	gravShock(A)

/obj/effect/anomaly/grav/Bumped(mob/A)
	gravShock(A)

/obj/effect/anomaly/grav/proc/gravShock(mob/A)
	if(boing && isliving(A) && !A.stat)
		A.Weaken(2)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = 0
		return

/////////////////////

/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity2"
	density = 1
	var/canshock = 0
	var/shockdamage = 20

/obj/effect/anomaly/flux/New()
	..()
	aSignal.origin_tech = "powerstorage=6;programming=4;plasmatech=4"

/obj/effect/anomaly/flux/anomalyEffect()
	..()
	canshock = 1
	for(var/mob/living/M in range(0, src))
		mobShock(M)

/obj/effect/anomaly/flux/Crossed(mob/living/M)
	mobShock(M)

/obj/effect/anomaly/flux/Bump(mob/living/M)
	mobShock(M)

/obj/effect/anomaly/flux/Bumped(mob/living/M)
	mobShock(M)

/obj/effect/anomaly/flux/proc/mobShock(mob/living/M)
	if(canshock && istype(M))
		canshock = 0 //Just so you don't instakill yourself if you slam into the anomaly five times in a second.
		if(iscarbon(M))
			if(ishuman(M))
				M.electrocute_act(shockdamage, "[name]", safety=1)
				return
			M.electrocute_act(shockdamage, "[name]")
			return
		else
			M.adjustFireLoss(shockdamage)
			M.visible_message("<span class='danger'>[M] was shocked by \the [name]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='italics'>You hear a heavy electrical crack.</span>")

/////////////////////

/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	density = 1

/obj/effect/anomaly/bluespace/New()
	..()
	aSignal.origin_tech = "bluespace=5;magnets=5;powerstorage=3"

/obj/effect/anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/M in range(1,src))
		do_teleport(M, locate(M.x, M.y, M.z), 4)

/obj/effect/anomaly/bluespace/Bumped(atom/A)
	if(isliving(A))
		do_teleport(A, locate(A.x, A.y, A.z), 8)
	return

/////////////////////

/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "mustard"

/obj/effect/anomaly/pyro/New()
	..()
	aSignal.origin_tech = "plasmatech=5;powerstorage=4;biotech=6"

/obj/effect/anomaly/pyro/anomalyEffect()
	..()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("o2=15;plasma=15;TEMP=1000")

/////////////////////

/obj/effect/anomaly/bhole
	name = "vortex anomaly"
	icon_state = "bhole3"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."

/obj/effect/anomaly/bhole/New()
	..()
	aSignal.origin_tech = "materials=5;combat=4;engineering=4"

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		qdel(src)
		return

	grav(rand(0,3), rand(2,3), 50, 25)

	//Throwing stuff around!
	for(var/obj/O in range(2,src))
		if(O == src)
			return //DON'T DELETE YOURSELF GOD DAMN
		if(!O.anchored)
			var/mob/living/target = locate() in view(4,src)
			if(target && !target.stat)
				O.throw_at(target, 7, 5)
		else
			O.ex_act(2)

/obj/effect/anomaly/bhole/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x+t, y-r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-t, y+r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x+r, y+t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-r, y-t, ex_act_force, pull_chance, turf_removal_chance)
	return

/obj/effect/anomaly/bhole/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))
		return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				O.ex_act(ex_act_force)
			else
				step_towards(O,src)
		for(var/mob/living/M in T.contents)
			step_towards(M,src)

	//Damaging the turf
	if( T && prob(turf_removal_chance) )
		T.ex_act(ex_act_force)
	return