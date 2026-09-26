/**
 * Trigger an emp pulse over a location
 *
 * * epicenter: Required the atom to center the emp pulse on
 * * heavy_range: Heavy range of the EMP
 * * light_range: Light range of the EMP
 * * emp_source: Optional, string to log the source of the emp
 * * euclidean: If TRUE we use euclidean distance, making the affected area a diamond instead of square
 * * use_explosion_resistance: If TRUE the explosion resistance of turfs affects the range of the emp pulse
 */
/proc/empulse(atom/epicenter, heavy_range = 0, light_range = 0, emp_source = "", euclidean = FALSE, use_explosion_resistance = FALSE)
	if(isnull(epicenter))
		stack_trace("empulse called without an epicenter")
		return FALSE

	epicenter = get_turf(epicenter)
	heavy_range = max(heavy_range, 0)
	light_range = max(heavy_range, light_range)

	if(emp_source)
		message_admins("EMP with size ([heavy_range], [light_range]) in [ADMIN_VERBOSEJMP(epicenter)], caused by [emp_source] ")
		log_game("EMP with size ([heavy_range], [light_range]) in [ADMIN_VERBOSEJMP(epicenter)], caused by [emp_source] ")

	if(heavy_range > 1)
		new /obj/effect/temp_visual/emp/pulse(epicenter)

	var/list/turf_resistances
	for(var/turf/to_emp_turf as anything in spiral_range_turfs(light_range, epicenter))
		var/distance = max(0, euclidean ? floor(get_dist_euclidean(epicenter, to_emp_turf)) : get_dist(epicenter, to_emp_turf))
		if(use_explosion_resistance)
			LAZYSET(turf_resistances, to_emp_turf, to_emp_turf.explosive_resistance)
			if(to_emp_turf != epicenter)
				var/protection_in_between = LAZYACCESS(turf_resistances, get_step_towards(to_emp_turf, epicenter))
				distance += protection_in_between
				LAZYADDASSOC(turf_resistances, to_emp_turf, protection_in_between)

		for(var/atom/to_emp as anything in to_emp_turf)
			if(distance < heavy_range)
				to_emp.emp_act(EMP_HEAVY)
			else if(distance == heavy_range)
				to_emp.emp_act(prob(50) ? EMP_HEAVY : EMP_LIGHT)
			else if(distance <= light_range)
				to_emp.emp_act(EMP_LIGHT)

	return TRUE
