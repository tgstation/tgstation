//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05


/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen/
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Gravitational Singularity when set up."
	icon = 'singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = 0
	var/energy = 0

//////////////////////Singularity gen START

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(src.energy >= 200)
		new /obj/machinery/singularity/(T, 50)
		spawn(0)
			del(src)
		return
/*
	if (singularity_is_surrounded(T))
		new /obj/machinery/singularity/(T, 200)
		spawn(0)
			del(src)
		return
*/

///obj/machinery/the_singularitygen/Bumped(atom/A)
//	if(istype(A,/obj/effect/accelerated_particle))
//		src.energy += A:energy
//		return
//	..()


/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		playsound(src.loc, 'Ratchet.ogg', 75, 1)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear a ratchet")
		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear a ratchet")
		return
	return ..()


/proc/singularity_is_surrounded(turf/T)//TODO:Add a timer so we dont need this
	var/checkpointC = 0
	for (var/obj/X in orange(4,T)) //TODO: do we need requirement to singularity be actually _surrounded_ by field?
		if(istype(X, /obj/machinery/containment_field) || istype(X, /obj/machinery/shieldwall))
			checkpointC ++
	return checkpointC >= 20
