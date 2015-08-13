//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"//Need a new icon for this
	anchored = 1
	density = 1
	var/movement_range = 10
	var/energy = 10

/obj/effect/accelerated_particle/weak
	movement_range = 8
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 15
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 20
	energy = 50


/obj/effect/accelerated_particle/New(loc, dir = 2)
	src.loc = loc
	src.dir = dir

	if(movement_range > 20)
		movement_range = 20
	spawn(0)
		move(1)
	return


/obj/effect/accelerated_particle/Bump(atom/A)
	if (A)
		if(ismob(A))
			toxmob(A)
		if((istype(A,/obj/machinery/the_singularitygen))||(istype(A,/obj/singularity/)))
			A:energy += energy
	return


/obj/effect/accelerated_particle/Bumped(atom/A)
	if(ismob(A))
		Bump(A)
	return


/obj/effect/accelerated_particle/ex_act(severity, target)
	loc = null
	return



/obj/effect/accelerated_particle/proc/toxmob(mob/living/M)
	M.irradiate(energy*6)
	M.updatehealth()
	return


/obj/effect/accelerated_particle/proc/move(lag)
	if(loc == null)
		return
	if(!step(src,dir))
		src.loc = get_step(src,dir)
	movement_range--
	if(movement_range <= 0)
		loc = null
	else
		sleep(lag)
		move(lag)
