#define EMPULSE_MAX_LEVELS_AFFECT 2
/proc/empulse(turf/epicenter, heavy_range, light_range, log=0)
	if(!epicenter)
		return

	if(!isturf(epicenter))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")

	if(heavy_range > 1)
		new /obj/effect/temp_visual/emp/pulse(epicenter)

	if(heavy_range > light_range)
		light_range = heavy_range

	var/turf/new_location_above = epicenter
	var/turf/new_location_below = epicenter
	var/base_level_pulsed = FALSE
	for(var/levels in 1 to EMPULSE_MAX_LEVELS_AFFECT)
		if(!base_level_pulsed)
			empulse_call(epicenter, heavy_range, light_range)
			base_level_pulsed = TRUE

		heavy_range *= 0.25
		light_range *= 0.25
		var/turf/above_level = SSmapping.get_turf_above(new_location_above)
		var/turf/below_level = SSmapping.get_turf_below(new_location_below)

		if(above_level && isturf(above_level))
			empulse_call(above_level, heavy_range, light_range)
			new_location_above = above_level
		if(below_level && isturf(below_level))
			empulse_call(below_level, heavy_range, light_range)
			new_location_below = below_level

	return TRUE

/proc/empulse_call(turf/epicenter, heavy_range, light_range)
	for(var/atom in spiral_range(light_range, epicenter))
		var/atom/considered_atom = atom
		var/distance = get_dist(epicenter, considered_atom)
		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			considered_atom.emp_act(EMP_HEAVY)
		else if(distance == heavy_range)
			if(prob(50))
				considered_atom.emp_act(EMP_HEAVY)
			else
				considered_atom.emp_act(EMP_LIGHT)
		else if(distance <= light_range)
			considered_atom.emp_act(EMP_LIGHT)

#undef EMPULSE_MAX_LEVELS_AFFECT
