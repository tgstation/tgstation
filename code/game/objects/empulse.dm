proc/empulse(turf/epicenter, heavy_range, light_range)
	if(!epicenter) return
	message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")

	if (!istype(epicenter, /turf))
		epicenter = epicenter.loc
		return empulse(epicenter, heavy_range, light_range)

	if(heavy_range > 1)
		var/obj/overlay/pulse = new/obj/overlay ( epicenter )
		pulse.icon = 'effects.dmi'
		pulse.icon_state = "emppulse"
		pulse.name = "emp pulse"
		pulse.anchored = 1
		spawn(20)
			del(pulse)

	if(heavy_range > light_range)
		light_range = heavy_range

	for(var/atom/T in range(light_range, epicenter))
		var/distance = get_dist(epicenter, T)
		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			T.emp_act(1)
		else if(distance == heavy_range)
			if(prob(50))
				T.emp_act(1)
			else
				T.emp_act(2)
		else if(distance <= light_range)
			T.emp_act(2)
	return 1