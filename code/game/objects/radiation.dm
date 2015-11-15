/proc/radiation_pulse(turf/epicenter, heavy_range, light_range, severity, log=0)
	if(!epicenter || !severity) return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(heavy_range > light_range)
		light_range = heavy_range

	var/light_severity = severity * 0.5
	var/bother_admins = 0
	for(var/atom/T in range(light_range, epicenter))
		var/distance = get_dist(epicenter, T)
		if(distance < 0)
			distance = 0
		if(distance < heavy_range)
			T.rad_act(severity)
		else if(distance == heavy_range)
			if(prob(50))
				T.rad_act(severity)
			else
				T.rad_act(light_severity)
		else if(distance <= light_range)
			T.rad_act(light_severity)
		if(isliving(T))
			bother_admins = 1

	if(log)
		log_game("Radiation pulse with size ([heavy_range], [light_range]) and severity [severity] in area [epicenter.loc.name] ")
		if(bother_admins)
			message_admins("Radiation pulse with size ([heavy_range], [light_range]) and severity [severity] in area [epicenter.loc.name] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>(JMP)</a>")

	return 1

/atom/proc/rad_act(var/severity)
	return 1

/mob/living/rad_act(amount)
	if(amount)
		var/blocked = run_armor_check(null, "rad", "Your clothes feel warm.", "Your clothes feel warm.")
		apply_effect(amount, IRRADIATE, blocked)
		for(var/obj/I in src) //Radiation is also applied to items held by the mob
			I.rad_act(amount)
