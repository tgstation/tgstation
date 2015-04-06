/*** EXIT PORTAL ***/

/obj/machinery/singularity/narsie/large/exit
	name = "Bluespace Rift"
	desc = "NO TIME TO EXPLAIN, JUMP IN"
	icon = 'icons/obj/rift.dmi'
	icon_state = "rift"

	move_self = 0
	announce=0
	narnar=0

	layer=LIGHTING_LAYER+2 // ITS SO BRIGHT

	consume_range = 6

/obj/machinery/singularity/narsie/large/exit/New()
	..()
	processing_objects.Add(src)

/obj/machinery/singularity/narsie/large/exit/update_icon()
	overlays = 0

/obj/machinery/singularity/narsie/large/exit/process()
	for(var/mob/M in player_list)
		if(M.client)
			M.see_rift(src)
	eat()

/obj/machinery/singularity/narsie/large/exit/acquire(var/mob/food)
	return

/obj/machinery/singularity/narsie/large/exit/consume(const/atom/A)
	if(!(A.singuloCanEat()))
		return 0

	if (istype(A, /mob/living/))
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

			if (dist > consume_range && canPull(AM))
				if(!(AM.singuloCanEat()))
					continue

				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)