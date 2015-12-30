#define TESLA_DEFAULT_POWER 3476520
#define TESLA_MINI_POWER 1738260

var/list/blacklisted_tesla_types = list(/obj/machinery/atmospherics,
										/obj/machinery/power/emitter,
										/obj/machinery/field/generator,
										/mob/living/simple_animal,
										/obj/machinery/particle_accelerator/control_box,
										/obj/structure/particle_accelerator/fuel_chamber,
										/obj/structure/particle_accelerator/particle_emitter/center,
										/obj/structure/particle_accelerator/particle_emitter/left,
										/obj/structure/particle_accelerator/particle_emitter/right,
										/obj/structure/particle_accelerator/power_box,
										/obj/structure/particle_accelerator/end_cap,
										/obj/machinery/field/containment,
										/obj/structure/disposalpipe)

/obj/singularity/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	current_size = STAGE_TWO
	move_self = 1
	grav_pull = 0
	contained = 0
	density = 1
	var/list/orbiting_balls = list()
	var/produced_power
	var/is_orbiting

/obj/singularity/energy_ball/Destroy()
	for(var/obj/singularity/energy_ball/EB in orbiting_balls)
		qdel(EB)
	..()

/obj/singularity/energy_ball/process()
	if(!is_orbiting)
		handle_energy()
		var/amount_to_move = 2 + orbiting_balls.len * 2
		var/what_does_the_scouter_say_about_the_balls_power_level = (TESLA_DEFAULT_POWER + (TESLA_MINI_POWER * orbiting_balls.len))
		move_the_basket_ball(amount_to_move)
		pixel_x = 0
		pixel_y = 0
		playsound(src.loc, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 5)
		tesla_zap(src, 7, what_does_the_scouter_say_about_the_balls_power_level)
		pixel_x = -32
		pixel_y = -32
		energy += rand(1,3) // ensure it generates energy without needing to be blasted by the PA too much due to its size, and that a tesla engine will always get bigger over time
	else
		energy = 0 // ensure we dont have miniballs of miniballs
	return

/obj/singularity/energy_ball/examine(mob/user)
	..()
	if(orbiting_balls.len)
		user << "The amount of orbiting mini-balls is [orbiting_balls.len]."


/obj/singularity/energy_ball/proc/move_the_basket_ball(var/move_amount)
	for(var/i = 0, i < move_amount, i++)
		var/move_dir = pick(alldirs)
		var/turf/T = get_step(src,move_dir)
		if(can_move(T))
			loc = get_step(src,move_dir)

/obj/singularity/energy_ball/proc/handle_energy()
	if(energy >= 300)
		energy -= 300
		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 5)
		spawn(100)
			var/obj/singularity/energy_ball/EB = new(loc)
			orbiting_balls.Add(EB)
			EB.transform *= pick(0.3,0.4,0.5,0.6,0.7)
			EB.is_orbiting = 1
			var/icon/I = icon(icon,icon_state,dir)

			var/orbitsize = (I.Width()+I.Height())*pick(0.5,0.6,0.7)
			orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)
			spawn(1)
				EB.orbit(src,orbitsize, pick(FALSE,TRUE), rand(10,25), pick(3,4,5,6,36))



/obj/singularity/energy_ball/Bump(atom/A)
	dust_mobs(A)

/obj/singularity/energy_ball/Bumped(atom/A)
	dust_mobs(A)

/obj/singularity/energy_ball/proc/dust_mobs(atom/A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		C.dust()
	return

/proc/get_closest_atom(type, list, source)
	var/closest_atom
	var/closest_distance
	for(var/A in list)
		if(!istype(A, type))
			continue
		var/distance = get_dist(source, A)
		if(!closest_distance)
			closest_distance = distance
			closest_atom = A
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = A
	return closest_atom

/proc/tesla_zap(var/atom/source, zap_range = 3, power)
	if(power < 500)
		return
	var/list/tesla_coils = list()
	var/list/grounding_rods = list()
	var/list/potential_machine_zaps = list()
	var/list/potential_mob_zaps = list()
	var/list/potential_structure_zaps = list()
	var/closest_atom
	for(var/atom/A in oview(source, zap_range))
		if(istype(A, /obj/machinery/power/tesla_coil))
			var/obj/machinery/power/tesla_coil/C = A
			if(C.being_shocked)
				continue
			tesla_coils.Add(C)
			continue
		if(istype(A, /obj/machinery/power/grounding_rod))
			var/obj/machinery/power/grounding_rod/R = A
			grounding_rods.Add(R)
			continue
		if(istype(A, /obj/machinery))
			var/obj/machinery/M = A
			if(is_type_in_list(M, blacklisted_tesla_types))
				continue
			if(M.being_shocked)
				continue
			potential_machine_zaps.Add(M)
			continue
		if(istype(A, /obj/structure))
			var/obj/structure/M = A
			if(is_type_in_list(M, blacklisted_tesla_types))
				continue
			if(M.being_shocked)
				continue
			potential_structure_zaps.Add(M)
			continue
		if(istype(A, /mob/living))
			var/mob/living/L = A
			if(L.stat == DEAD)
				continue
			if(is_type_in_list(L, blacklisted_tesla_types))
				continue
			potential_mob_zaps.Add(L)
			continue
	closest_atom = get_closest_atom(/obj/machinery/power/tesla_coil, tesla_coils, source)
	if(closest_atom && istype(closest_atom, /obj/machinery/power/tesla_coil))
		var/obj/machinery/power/tesla_coil/C = closest_atom
		source.Beam(C,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5)
		C.tesla_act(power)
		return
	if(!closest_atom)
		closest_atom = get_closest_atom(/obj/machinery/power/grounding_rod, grounding_rods, source)
		if(closest_atom && istype(closest_atom, /obj/machinery/power/grounding_rod))
			var/obj/machinery/power/grounding_rod/R = closest_atom
			source.Beam(R,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5)
			R.tesla_act(power)
			return
	if(!closest_atom)
		closest_atom = get_closest_atom(/mob/living, potential_mob_zaps, source)
		if(closest_atom && istype(closest_atom, /mob/living))
			var/mob/living/L = closest_atom
			var/shock_damage = Clamp(round(power/400), 10, 90) + rand(-5,5)
			source.Beam(L,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5)
			L.electrocute_act(shock_damage, source, 1, tesla_shock = 1)
			if(istype(L, /mob/living/silicon))
				var/mob/living/silicon/S = L
				S.emp_act(2)
				tesla_zap(S, 7, power / 1.5) // metallic folks bounce it further
			else
				tesla_zap(L, 5, power / 1.5)
			return
	if(!closest_atom)
		closest_atom = get_closest_atom(/obj/machinery, potential_machine_zaps, source)
		if(closest_atom)
			var/obj/machinery/M = closest_atom
			source.Beam(M,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5)
			M.tesla_act(power)
			if(prob(85))
				M.emp_act(2)
			else
				if(prob(50))
					M.ex_act(3)
				else
					if(prob(90))
						M.ex_act(2)
					else
						M.ex_act(1)
			return
	if(!closest_atom)
		closest_atom = get_closest_atom(/obj/structure, potential_structure_zaps, source)
		if(closest_atom)
			var/obj/structure/S = closest_atom
			source.Beam(S,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5)
			S.tesla_act(power)
			return
