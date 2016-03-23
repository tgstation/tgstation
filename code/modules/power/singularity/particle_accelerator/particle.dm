/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
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
	src.dir = dir

	spawn(0)
		move(1)


/obj/effect/accelerated_particle/Bump(atom/A)
	if (A)
		if(ismob(A))
			toxmob(A)
		if((istype(A,/obj/machinery/the_singularitygen))||(istype(A,/obj/singularity/)))
			A:energy += energy


/obj/effect/accelerated_particle/Bumped(atom/A)
	if(ismob(A))
		Bump(A)


/obj/effect/accelerated_particle/ex_act(severity, target)
	qdel(src)

/obj/effect/accelerated_particle/proc/toxmob(mob/living/M)
	M.rad_act(energy*6)
	M.updatehealth()


/obj/effect/accelerated_particle/proc/move(lag)
	if(!step(src,dir))
		loc = get_step(src,dir)
	movement_range--
	if(movement_range == 0)
		qdel(src)
	else
		sleep(lag)
		move(lag)
