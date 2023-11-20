/mob/living/carbon/proc/spread_airborne_diseases()
	//spreading our own airborne viruses
	if (diseases && diseases.len > 0)
		var/list/airborne_viruses = filter_disease_by_spread(diseases, required = DISEASE_SPREAD_AIRBORNE)
		if (airborne_viruses && airborne_viruses.len > 0)
			var/strength = 0
			for (var/datum/disease/V as anything in airborne_viruses)
				strength += V.infectionchance
			strength = round(strength/airborne_viruses.len)
			while (strength > 0)//stronger viruses create more clouds at once
				new /obj/effect/pathogen_cloud/core(get_turf(src), src, airborne_viruses)
				strength -= 40
