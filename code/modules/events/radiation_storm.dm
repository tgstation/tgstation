/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 1

/datum/round_event/radiation_storm
	announceWhen	= 5


/datum/round_event/radiation_storm/announce()
	command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange.", "Anomaly Alert")
	world << sound('sound/AI/radiation.ogg')


/datum/round_event/radiation_storm/start()
	for(var/mob/living/carbon/C in living_mob_list)
		var/turf/T = get_turf(C)
		if(!T)			continue
		if(T.z != 1)	continue

		if(istype(C, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			H.apply_effect((rand(15, 75)), IRRADIATE, 0)
			if(prob(5))
				H.apply_effect((rand(90, 150)), IRRADIATE, 0)
			if(prob(25))
				if(prob(75))
					randmutb(H)
					domutcheck(H, null, 1)
				else
					randmutg(H)
					domutcheck(H, null, 1)

		else if(istype(C, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = C
			M.apply_effect((rand(15, 75)), IRRADIATE, 0)