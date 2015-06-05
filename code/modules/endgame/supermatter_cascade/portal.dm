/*** EXIT PORTAL ***/

/obj/singularity/narsie/large/exit
	name = "Bluespace Rift"
	desc = "NO TIME TO EXPLAIN, JUMP IN"
	icon = 'icons/obj/rift.dmi'
	icon_state = "rift"

	move_self = 0
	announce=0
	narnar=0

	layer=LIGHTING_LAYER+2 // ITS SO BRIGHT

	consume_range = 6

/obj/singularity/narsie/large/exit/New()
	..()
	SSobj.processing |= src

/obj/singularity/narsie/large/exit/update_icon()
	overlays = 0

/obj/singularity/narsie/large/exit/eat()
	set background = BACKGROUND_ENABLED
	for(var/atom/X in orange(grav_pull,src))
		var/dist = get_dist(X, src)
		var/obj/singularity/S = src
		if(dist <= consume_range)
			consume(X)
	return


/obj/singularity/narsie/large/exit/process()
	eat()

/obj/singularity/narsie/large/exit/acquire(var/mob/food)
	return

/obj/singularity/narsie/large/exit/Bump(atom/A)
	A.rift_act(src)

/obj/singularity/narsie/large/exit/Bumped(atom/A)
	A.rift_act(src)
	return

///obj/singularity/narsie/large/exit/consume(const/atom/A)
//	A.rift_act(src)


/obj/singularity/narsie/large/exit/event()
	return

/obj/singularity/narsie/large/exit/toxmob()
	return

/obj/singularity/narsie/large/exit/consume(const/atom/A)
	if (istype(A, /mob/living/))
		var/mob/living/L = A
		if(L.buckled && istype(L.buckled,/obj/structure/stool/bed/))
			var/turf/O = L.buckled
			do_teleport(O, pick(endgame_safespawns))
			L.loc = O.loc
		else
			do_teleport(L, pick(endgame_safespawns)) //dead-on precision

	else if (istype(A, /obj/mecha/))
		do_teleport(A, pick(endgame_safespawns)) //dead-on precision

	else if (isturf(A))
		var/turf/T = A
		var/dist = get_dist(T, src)
		if (dist <= consume_range && T.density)
			T.density = 0

		for (var/atom/movable/AM in T.contents)
			if (AM == src) // This is the snowflake.
				continue

			if (dist <= consume_range)
				consume(AM)
				continue

			if (dist > consume_range && !AM.anchored)
				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)


/obj/singularity/narsie/large/exit/admin_investigate_setup()
	return