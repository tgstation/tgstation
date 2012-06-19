//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'particle_accelerator.dmi'
	icon_state = "particle"//Need a new icon for this
	anchored = 1
	density = 1
	var/movement_range = 10
	var/energy = 10

	weak
		movement_range = 8
		energy = 5

	strong
		movement_range = 15
		energy = 15


	New(loc, dir = 2)
		src.loc = loc
		src.dir = dir
		if(movement_range > 20)
			movement_range = 20
		spawn(0)
			move(1)
		return


	Bump(atom/A)
		if (A)
			if(ismob(A))
				toxmob(A)
			if((istype(A,/obj/machinery/the_singularitygen))||(istype(A,/obj/machinery/singularity/)))
				A:energy += energy
		return


	Bumped(atom/A)
		if(ismob(A))
			Bump(A)
		return


	ex_act(severity)
		del(src)
		return


	proc
		toxmob(var/mob/living/M)
			var/radiation = (energy*2)
/*			if(istype(M,/mob/living/carbon/human))
				if(M:wear_suit) //TODO: check for radiation protection
					radiation = round(radiation/2,1)
			if(istype(M,/mob/living/carbon/monkey))
				if(M:wear_suit) //TODO: check for radiation protection
					radiation = round(radiation/2,1)*/
			M.apply_effect((radiation*3),IRRADIATE,0)
			M.updatehealth()
			//M << "\red You feel odd."
			return


		move(var/lag)
			if(!step(src,dir))
				src.loc = get_step(src,dir)
			movement_range--
			if(movement_range <= 0)
				del(src)
			else
				sleep(lag)
				move(lag)
