proc/empulse(turf/epicenter, heavy_range, light_range, log=0)
	if(!epicenter) return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ")

	if(heavy_range > 1)
		var/obj/effect/overlay/pulse = new/obj/effect/overlay ( epicenter )
		pulse.icon = 'icons/effects/effects.dmi'
		pulse.icon_state = "emppulse"
		pulse.name = "emp pulse"
		pulse.anchored = 1
		spawn(20)
			pulse.delete()

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

proc/empulse_target(atom/A, heavy = 1, light = 0, log=0)
	if(!A)
		return
	if(log)
		message_admins("Targeted EMP with severity ([heavy >= light & heavy ? "strong" : "weak"]) on [A.name]")
		log_game("Targeted EMP with severity ([heavy >= light & heavy ? "strong" : "weak"]) on [A.name]")

	var/severity = heavy - light
	switch(severity)
		if(0)
			return 0
		if(1)
			for(var/obj/O in A.contents)
				O.emp_act(1)
		if(-1)
			for(var/obj/O in A.contents)
				O.emp_act(2)
	var/obj/effect/overlay/pulse = new/obj/effect/overlay(get_turf(A))
	pulse.icon = 'icons/effects/effects.dmi'
	pulse.icon_state = "emppulse"
	spawn(20)
		pulse.delete()
	return 1