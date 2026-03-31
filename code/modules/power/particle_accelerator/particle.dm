/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	anchored = TRUE
	density = FALSE
	var/movement_range = 10
	var/energy = 10
	var/speed = 1

/obj/effect/accelerated_particle/weak
	movement_range = 8
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 15
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 20
	energy = 50


/obj/effect/accelerated_particle/New(loc)
	..()

	addtimer(CALLBACK(src, PROC_REF(move)), 1)


/obj/effect/accelerated_particle/Bump(atom/A)
	if(!A)
		return

	if(isliving(A))
		toxmob(A)
	else if(istype(A, /obj/machinery/the_singularitygen))
		var/obj/machinery/the_singularitygen/S = A
		S.energy += energy
	else if(istype(A, /obj/singularity))
		var/obj/singularity/S = A
		S.energy += energy
	else if(istype(A, /obj/structure/blob))
		var/obj/structure/blob/B = A
		B.take_damage(energy*0.6)
		movement_range = 0

/obj/effect/accelerated_particle/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	for(var/mob/living/guy in old_loc)
		toxmob(guy)


/obj/effect/accelerated_particle/ex_act(severity, target)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull()
	return

/obj/effect/accelerated_particle/proc/toxmob(mob/living/M)
	if(!SSradiation.can_irradiate_basic(M))
		return

	if(ishuman(M) && SSradiation.wearing_rad_protected_clothing(M))
		return

	radiation_pulse(
		source = M,
		max_range = 0,
		threshold = RAD_LIGHT_INSULATION,
		chance = energy,
	)

/obj/effect/accelerated_particle/proc/move()
	if(!step(src, dir))
		var/next = get_step(src, dir)
		if(next)
			forceMove(get_step(src,dir))
		else
			qdel(src)
			return

	movement_range--
	if(movement_range == 0)
		qdel(src)
	else
		sleep(speed)
		move()
