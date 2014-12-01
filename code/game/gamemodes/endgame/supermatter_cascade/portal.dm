/*** EXIT PORTAL ***/

/obj/machinery/singularity/narsie/large/exit
	name = "Bluespace Rift"
	desc = "NO TIME TO EXPLAIN, JUMP IN"
	icon = 'icons/obj/mrclean.dmi' // Placeholder.
	icon_state = ""

	move_self = 0
	announce=0

/obj/machinery/singularity/narsie/large/exit/New()
	..(cultspawn=0)

/obj/machinery/singularity/narsie/large/exit/update_icon()
	overlays = 0

	//if (target && !isturf(target))
	//	overlays += "eyes"

/obj/machinery/singularity/narsie/large/exit/process()
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
		T.clean_blood()
		var/dist = get_dist(T, src)

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