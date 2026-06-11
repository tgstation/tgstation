/proc/empulse(turf/epicenter, heavy_range, light_range, emp_source)
	if(!epicenter)
		return

	if(!isturf(epicenter))
		epicenter = get_turf(epicenter.loc)

	if(emp_source)
		message_admins("EMP with size ([heavy_range], [light_range]) in [ADMIN_VERBOSEJMP(epicenter)], caused by [emp_source] ")
		log_game("EMP with size ([heavy_range], [light_range]) in [ADMIN_VERBOSEJMP(epicenter)], caused by [emp_source] ")

	if(heavy_range > 1)
		new /obj/effect/temp_visual/emp/pulse(epicenter)

	if(heavy_range > light_range)
		light_range = heavy_range

	for(var/A in spiral_range(light_range, epicenter))
		var/atom/T = A
		var/distance = get_dist(epicenter, T)
		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			T.emp_act(EMP_HEAVY)
		else if(distance == heavy_range)
			if(prob(50))
				T.emp_act(EMP_HEAVY)
			else
				T.emp_act(EMP_LIGHT)
		else if(distance <= light_range)
			T.emp_act(EMP_LIGHT)
	return 1
