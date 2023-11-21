/mob/living
	///our immune system
	var/datum/immune_system/immune_system
	///image
	var/image/pathogen

/mob/living/carbon/proc/spread_airborne_diseases()
	//spreading our own airborne viruses
	if (diseases && diseases.len > 0)
		var/list/airborne_viruses = filter_disease_by_spread(diseases, required = DISEASE_SPREAD_AIRBORNE)
		if (airborne_viruses && airborne_viruses.len > 0)
			var/strength = 0
			for (var/datum/disease/advanced/V as anything in airborne_viruses)
				strength += V.infectionchance
			strength = round(strength/airborne_viruses.len)
			while (strength > 0)//stronger viruses create more clouds at once
				new /obj/effect/pathogen_cloud/core(get_turf(src), src, airborne_viruses)
				strength -= 40

/mob/living/carbon/infect_disease(datum/disease/advanced/disease, forced = FALSE, notes = "", decay = TRUE)
	if(!istype(disease))
		return FALSE
	if(!disease.spread)
		return FALSE

	if(immune_system && !immune_system.CanInfect(disease))
		return FALSE
	if(prob(disease.infectionchance) || forced)
		var/datum/disease/advanced/D = disease.Copy()
		if (D.infectionchance > 10)
			D.infectionchance = max(10, D.infectionchance - 10)//The virus gets weaker as it jumps from people to people

		D.stage = clamp(D.stage+D.stage_variance, 1, D.max_stages)
		D.log += "<br />[ROUND_TIME()] Infected [key_name(src)] [notes]. Infection chance now [D.infectionchance]%"

		LAZYADD(diseases, D)
		D.affected_mob = src
		SSdisease.active_diseases += D
		D.after_add()
		src.med_hud_set_status()

		log_virus("[key_name(src)] was infected by virus: [D.admin_details()] at [loc_name(loc)]")

		D.AddToGoggleView(src)
