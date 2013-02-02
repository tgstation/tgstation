/datum/event/radiation_storm
	announceWhen	= 5
	oneShot			= 1


/datum/event/radiation_storm/announce()
	command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange.", "Anomaly Alert")
	world << sound('sound/AI/radiation.ogg')


/datum/event/radiation_storm/start()
	for(var/mob/living/carbon/human/H in living_mob_list)
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(T.z != 1)
			continue
		if(istype(H,/mob/living/carbon/human))
			H.apply_effect((rand(15,75)),IRRADIATE,0)
			if(prob(5))
				H.apply_effect((rand(90,150)),IRRADIATE,0)
			if(prob(25))
				if (prob(75))
					randmutb(H)
					domutcheck(H,null,1)
				else
					randmutg(H)
					domutcheck(H,null,1)

	for(var/mob/living/carbon/monkey/M in living_mob_list)
		var/turf/T = get_turf(M)
		if(!T)
			continue
		if(T.z != 1)
			continue
		M.apply_effect((rand(15,75)),IRRADIATE,0)