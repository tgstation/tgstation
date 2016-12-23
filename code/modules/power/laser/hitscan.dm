#define PTL_TRACER 1	//Tracer beam, minimal damage
#define PTL_PULSE 2		//Burst of damage
#define PTL_PRIMARY 3	//Primary firing, continuous effect application


/obj/machinery/power/PTL/laser_beam(direction, power, type = PTL_PRIMARY, turf/turf_override = null, hitscan_override = FALSE)
	var/yes = 1
	var/atom/atom_direct_hit
	var/list/atom/atoms_impacted = list()
	var/turf/current_turf
	var/beam_delay = FALSE
	var/beam_delay_additional = 0
	if(!turf_override)
		current_turf = get_turf(src)
	else
		current_turf = turf_override
	if(hitscan_override)
		beam_delay = hitscan_override
	if(yes)	//Hitscan loop
		sleep(beam_delay)
		current_turf = get_step(current_turf, direction)
		if(locate(var/obj/structure/reflector/R in current_turf))
			if(!R.can_reflect_PTL)
				atoms_impacted |= R
			else
				direction = R.get_reflection(R.dir, direction)
		for(var/obj/O in current_turf)
			atoms_impacted |= O
		switch(type)	//Determine effects and sprites
			if(PTL_TRACER)
				if(isclosedturf(current_turf))
					atoms_impacted |= current_turf
				PoolOrNew(/obj/effect/overlay/temp/PTL/tracer, current_turf)
				for(atom/A in atoms_impacted)
					if(!check_safe_atom(A))
						tracer_hit(direction, power, A)
			if(PTL_PULSE)
				PoolOrNew(/obj/effect/overlay/temp/PTL/pulse, current_turf)
				if(isclosedturf(current_turf))
					atom_direct_hit = current_turf
				for(atom/A in atoms_impacted)
					if(A.density && A.opacity && !check_safe_atom(A) && !atom_direct_hit)
						atom_direct_hit = A
					else if(!check_safe_atom(A))
						pulse_hit(A)
				if(atom_direct_hit)
					yes = FALSE
					pulse_blast(direction, power, atom_direct_hit)
			if(PTL_PRIMARY)
				PoolOrNew(/obj/effect/overlay/temp/PTL/continuous, current_turf)
				atoms_impacted |= current_turf
				for(atom/A in atoms_impacted)
					if((A.density && A.opacity && !check_safe_atom(A) && !atom_direct_hit) || (isclosedturf(A) && !check_safe_atom(A)))
						atom_direct_hit = A
					else if(!check_safe_atom(A))
						primary_hit(A)
				if(atom_direct_hit)
					primary_hit(A)
					yes = FALSE
		sleep(beam_delay_additional)
		beam_delay_additional = 0

/obj/machinery/power/PTL/proc/tracer_hit(direction, power, atom/A)

/obj/machinery/power/PTL/proc/pulse_hit(direction, power, atom/A)

/obj/machinery/power/PTL/proc/pulse_blast(direction, power, atom/A)

/obj/machinery/power/PTL/proc/primary_hit(direction, power, atom/A)



/obj/machinery/power/PTL/proc/power_beam(dir, strength)
	var/obj/item/projectile/beam/PTLbeam/P = new /obj/item/projectile/beam/PTLbeam(src.loc)
	P.power_strength = laser_beam_strength
	P.speed = 0	//Fast!
	P.damage = 0	//Calculated in projectile
	P.nodamage = 0
	P.legacy = 1
	P.setDir(src.dir)
	P.starting = loc
	P.fire()