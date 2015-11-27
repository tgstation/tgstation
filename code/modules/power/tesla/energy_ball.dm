/obj/singularity/energy_ball
	name = "Energy Ball"
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	current_size = STAGE_TWO
	move_self = 1
	grav_pull = 0
	contained = 0
	density = 1

/obj/singularity/energy_ball/process()
	pixel_x = 0
	pixel_y = 0 // Lining up the beams properly.
	tesla_zap(src, 3, 3476520)
	pixel_x = -32
	pixel_y = -32
	var/move_dir = pick(alldirs)
	var/turf/T = get_step(src,move_dir)
	if(can_move(T))
		loc = get_step(src,move_dir)
	return

/obj/singularity/energy_ball/Bump(atom/A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		C.dust()
	return

/obj/singularity/energy_ball/Bumped(atom/A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		C.dust()
	return

proc/get_closest_atom(var/type, var/list, var/source)
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

proc/tesla_zap(var/atom/source, var/zap_range = 3, var/power)
	if(power < 1000)
		return
	var/list/tesla_coils = list()
	var/list/potential_machine_zaps = list()
	var/list/potential_mob_zaps = list()
	var/closest_atom
	for(var/atom/A in orange(source, zap_range))
		if(istype(A, /obj/machinery/power/tesla_coil))
			var/obj/machinery/power/tesla_coil/C = A
			if(C.being_shocked)
				continue
			tesla_coils.Add(C)
			continue
		if(istype(A, /obj/machinery))
			var/obj/machinery/M = A
			potential_machine_zaps.Add(M)
			continue
		if(istype(A, /mob/living))
			var/mob/living/L = A
			potential_mob_zaps.Add(L)
			continue
	closest_atom = get_closest_atom(/obj/machinery/power/tesla_coil, tesla_coils, source)
	if(closest_atom && istype(closest_atom, /obj/machinery/power/tesla_coil))
		var/obj/machinery/power/tesla_coil/C = closest_atom
		source.Beam(C,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
		C.tesla_act(power)
		return
	if(!closest_atom)
		closest_atom = get_closest_atom(/mob/living, potential_mob_zaps, source)
		if(closest_atom && istype(closest_atom, /mob/living))
			var/mob/living/L = closest_atom
			var/shock_damage = Clamp(round(power/400), 10, 200) + rand(-5,5)
			source.Beam(L,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
			L.electrocute_act(shock_damage, source, 1)
			return
	if(!closest_atom)
		closest_atom = get_closest_atom(/obj/machinery, potential_machine_zaps, source)
		if(closest_atom)
			source.Beam(closest_atom,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
			tesla_zap(closest_atom, 3, power / 4)
			return
