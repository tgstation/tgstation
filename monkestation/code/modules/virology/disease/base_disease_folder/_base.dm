GLOBAL_LIST_INIT(infected_contact_mobs, list())
GLOBAL_LIST_INIT(virusDB, list())

/datum/disease
	//the disease's antigens, that the body's immune_system will read to produce corresponding antibodies. Without antigens, a disease cannot be cured.
	var/list/antigen = list()
	//alters a pathogen's propensity to mutate. Set to FALSE to forbid a pathogen from ever mutating.
	var/mutation_modifier = TRUE
	//the antibody concentration at which the disease will fully exit the body
	var/strength = 100
	//the percentage of the strength at which effects will start getting disabled by antibodies.
	var/robustness = 100
	//chance to cure the disease at every proc when the body is getting cooked alive.
	var/max_bodytemperature = T0C+100
	//very low temperatures will stop the disease from activating/progressing
	var/min_bodytemperature = 120
	///split category used for predefined diseases atm
	var/category = DISEASE_NORMAL

	//logging
	var/log = ""
	var/origin = "Unknown"
	var/logged_virusfood = FALSE
	var/fever_warning = FALSE

	//cosmetic
	var/color
	var/pattern = 1
	var/pattern_color

	///pathogenic warfare - If you have a second disease of a form name in the list they will start fighting.
	var/list/can_kill = list("Bacteria")

	//When an opportunity for the disease to spread_flags to a mob arrives, runs this percentage through prob()
	//Ignored if infected materials are ingested (injected with infected blood, eating infected meat)
	var/infectionchance = 20
	var/infectionchance_base = 20

	//ticks increases by [speed] every time the disease activates. Drinking Virus Food also accelerates the process by 10.
	var/ticks = 0
	var/speed = 1

	var/stageprob = 25

	//when spreading to another mob, that new carrier has the disease's stage reduced by stage_variance
	var/stage_variance = -1

	var/uniqueID = 0// 0000 to 9999, set when the pathogen gets initially created
	var/subID = 0// 000 to 9999, set if the pathogen underwent effect or antigen mutation
	var/childID = 0// 01 to 99, incremented as the pathogen gets analyzed after a mutation
	//bitflag showing which transmission types are allowed for this disease
	var/allowed_transmission = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_AIRBORNE

/datum/disease/proc/roll_antigen(list/factors = list())
	if (factors.len <= 0)
		antigen = list(pick(GLOB.all_antigens))
		antigen |= pick(GLOB.all_antigens)
	else
		var/selected_first_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen = list(pick(antigen_family(selected_first_antigen)))

		var/selected_second_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen |= pick(antigen_family(selected_second_antigen))

/datum/disease/proc/get_effect(index)
	if(!index)
		return pick(symptoms)
	return symptoms[clamp(index,0,symptoms.len)]

/datum/disease/proc/GetImmuneData(mob/living/mob)
	var/lowest_stage = stage
	var/highest_concentration = 0

	if (mob.immune_system)
		var/immune_system = mob.immune_system.GetImmunity()
		var/list/antibodies = immune_system[2]
		var/subdivision = (strength - ((robustness * strength) / 100)) / max_stages
		//for each antigen, we measure the corresponding antibody concentration in the carrier's immune system
		//the less robust the pathogen, the more likely that further stages' effects won't activate at a given concentration
		for (var/A in antigen)
			var/concentration = antibodies[A]
			highest_concentration = max(highest_concentration,concentration)
			var/i = lowest_stage
			while (i > 0)
				if (concentration > (strength - i * subdivision))
					lowest_stage = i-1
				i--

	return list(lowest_stage,highest_concentration)

/datum/disease/advanced/cure(add_resistance = TRUE, mob/living/carbon/target)
	target = target || affected_mob || usr
	if(!istype(affected_mob) || QDELING(affected_mob))
		return
	for(var/datum/symptom/symptom in symptoms)
		symptom.disable_effect(target, src)
	target.diseases -= src
	logger.Log(LOG_CATEGORY_VIRUS, "[affected_mob.name] was cured of virus [real_name()] at [loc_name(affected_mob.loc)]", list("disease_data" = admin_details(), "location" = loc_name(affected_mob.loc)))
	//--Plague Stuff--
	/*
	var/datum/faction/plague_mice/plague = find_active_faction_by_type(/datum/faction/plague_mice)
	if (plague && ("[uniqueID]-[subID]" == plague.diseaseID))
		plague.update_hud_icons()
	*/
	//----------------
	var/list/pathogen_info = filter_disease_by_spread(affected_mob.diseases, required = DISEASE_SPREAD_CONTACT_SKIN)
	if(!length(pathogen_info))
		GLOB.infected_contact_mobs -= affected_mob
		if(affected_mob.pathogen)
			for(var/mob/living/goggle_wearer in GLOB.science_goggles_wearers)
				goggle_wearer.client?.images -= affected_mob.pathogen

	// Add resistance by boosting whichever antigen is needed
	if(add_resistance && target.immune_system)
		var/boosted_antigen
		var/boosted_antigen_level
		for(var/antigen in src.antigen)
			var/level = target.immune_system.antibodies[antigen]
			if(level >= strength)
				return
			else if(!boosted_antigen || (boosted_antigen_level > level))
				boosted_antigen = antigen
				boosted_antigen_level = level
		if(boosted_antigen)
			target.immune_system.antibodies[boosted_antigen] = max(strength + 10, boosted_antigen_level)


/datum/disease/proc/activate(mob/living/mob, starved = FALSE, seconds_per_tick)
	if(!affected_mob)
		return_parent()
	if((mob.stat == DEAD) && !process_dead)
		return

	//Searing body temperatures cure diseases, on top of killing you.
	if(mob.bodytemperature > max_bodytemperature)
		cure(target = mob)
		return

	if(disease_flags & DISEASE_DORMANT)
		return

	if(!(infectable_biotypes & mob.mob_biotypes))
		return

	if(mob.immune_system)
		if(prob(10 - (robustness * 0.01))) //100 robustness don't auto cure
			mob.immune_system.NaturalImmune()

	if(!mob.immune_system.CanInfect(src))
		cure(target = mob)
		return

	//Freezing body temperatures halt diseases completely
	if(mob.bodytemperature < min_bodytemperature)
		return

	//Virus food speeds up disease progress
	if(!ismouse(mob))
		if(mob.reagents?.has_reagent(/datum/reagent/consumable/virus_food))
			mob.reagents.remove_reagent(/datum/reagent/consumable/virus_food, 0.1)
			if(!logged_virusfood)
				log += "<br />[ROUND_TIME()] Virus Fed ([mob.reagents.get_reagent_amount(/datum/reagent/consumable/virus_food)]U)"
				logged_virusfood=1
			ticks += 10
		else
			logged_virusfood=0
	if(prob(strength * 0.1))
		incubate(mob, 1)

	//Moving to the next stage
	if(ticks > stage*100 && prob(stageprob))
		incubate(mob, 1)
		if(stage < max_stages)
			log += "<br />[ROUND_TIME()] NEXT STAGE ([stage])"
			stage++
		ticks = 0

	//Pathogen killing each others
	for (var/datum/disease/advanced/enemy_pathogen as anything in mob.diseases)
		if(enemy_pathogen == src)
			continue

		if ((enemy_pathogen.form in can_kill) && strength > enemy_pathogen.strength)
			log += "<br />[ROUND_TIME()] destroyed enemy [enemy_pathogen.form] #[enemy_pathogen.uniqueID]-[enemy_pathogen.subID] ([strength] > [enemy_pathogen.strength])"
			enemy_pathogen.cure(target = mob)

	// This makes it so that <mob> only ever gets affected by the equivalent of one virus so antags don't just stack a bunch
	if(starved)
		return

	var/list/immune_data = GetImmuneData(mob)

	if(!istype(mob, /mob/living/basic/mouse/plague)) //plague mice don't trigger effects to not kill em
		for(var/datum/symptom/e in symptoms)
			if (e.can_run_effect(immune_data[1], seconds_per_tick))
				e.run_effect(mob, src)

	//fever is a reaction of the body's immune system to the infection. The higher the antibody concentration (and the disease still not cured), the higher the fever
	if (mob.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)//but we won't go all the way to burning up just because of a fever, probably
		var/fever = round((robustness / 100) * (immune_data[2] / 10) * (stage / max_stages))
		switch (mob.mob_size)
			if (MOB_SIZE_TINY)
				mob.bodytemperature += fever*0.2
			if (MOB_SIZE_SMALL)
				mob.bodytemperature += fever*0.5
			if (MOB_SIZE_HUMAN)
				mob.bodytemperature += fever
			if (MOB_SIZE_LARGE)
				mob.bodytemperature += fever*1.5
			if (MOB_SIZE_HUGE)
				mob.bodytemperature += fever*2

		if (fever > 0  && prob(3))
			switch (fever_warning)
				if (0)
					to_chat(mob, span_warning("You feel a fever coming on, your body warms up and your head hurts a bit."))
					fever_warning++
				if (1)
					if (mob.bodytemperature > 320)
						to_chat(mob, span_warning("Your palms are sweaty."))
						fever_warning++
				if (2)
					if (mob.bodytemperature > 335)
						to_chat(mob, span_warning("Your knees are weak."))
						fever_warning++
				if (3)
					if (mob.bodytemperature > 350)
						to_chat(mob, span_warning("Your arms are heavy."))
						fever_warning++


	ticks += speed
