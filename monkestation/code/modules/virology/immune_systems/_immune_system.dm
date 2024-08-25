/datum/immune_system
	var/mob/living/carbon/host = null
	var/strength = 1
	var/boost = 1
	var/overloaded = FALSE
	var/list/antibodies = list(
		ANTIGEN_O	= 0,
		ANTIGEN_A	= 0,
		ANTIGEN_B	= 0,
		ANTIGEN_RH	= 0,
		ANTIGEN_Q	= 0,
		ANTIGEN_U	= 0,
		ANTIGEN_V	= 0,
		ANTIGEN_M	= 0,
		ANTIGEN_N	= 0,
		ANTIGEN_P	= 0,
		ANTIGEN_X	= 0,
		ANTIGEN_Y	= 0,
		ANTIGEN_Z	= 0,
		)

/datum/immune_system/Destroy()
	host = null
	antibodies = null
	return ..()

/datum/immune_system/New(mob/living/carbon/host, boost = 1)
	..()
	if(QDELETED(host))
		stack_trace("Attempted to initialize immune system on invalid entity!")
		qdel(src)
		return
	src.host = host
	src.boost = boost
	for(var/antibody in antibodies)
		if(antibody in GLOB.rare_antigens)
			antibodies[antibody] = rand(1, 15) * boost
			if (prob(5))
				antibodies[antibody] += 10 * boost
		if(antibody in GLOB.common_antigens)
			antibodies[antibody] = rand(10, 30) * boost
		if(antibody in GLOB.blood_antigens)
			antibodies[antibody] = rand(10, 20) * boost
			var/blood_type = host.has_dna()?.blood_type
			if(blood_type)
				switch(antibody)
					if(ANTIGEN_O)
						antibodies[antibody] += rand(12, 15) * boost
					if(ANTIGEN_A)
						if(findtext(blood_type, "A"))
							antibodies[antibody] += rand(12, 15) * boost
					if(ANTIGEN_B)
						if(findtext(blood_type, "B"))
							antibodies[antibody] += rand(12, 15) * boost
					if(ANTIGEN_RH)
						if(findtext(blood_type, "+"))
							antibodies[antibody] += rand(12, 15) * boost
		if(boost > 1)
			antibodies[antibody] = min(antibodies[antibody], boost)

/datum/immune_system/proc/transfer_to(mob/living/carbon/source)
	if(QDELETED(source))
		CRASH("Attempted to transfer immune system to non-existant mob")
	if(QDELETED(source.immune_system))
		source.immune_system = new(source)

	source.immune_system.strength = strength
	source.immune_system.boost = boost
	source.immune_system.overloaded = overloaded
	source.immune_system.antibodies = antibodies.Copy()

/datum/immune_system/proc/change_boost(new_boost = 1)
	var/old_boost = boost
	if(new_boost == old_boost)
		return
	for(var/antibody in antibodies)
		antibodies[antibody] /= old_boost
		antibodies[antibody] *= new_boost
	boost = new_boost

/datum/immune_system/proc/GetImmunity()
	return list(strength, antibodies.Copy())

/datum/immune_system/proc/Overload()
	host.adjustToxLoss(100)
	host.AddComponent(/datum/component/irradiated)
	host.bodytemperature = max(host.bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT)
	to_chat(host, span_danger("A terrible fever assails your host, you feel ill as your immune system kicks into overdrive to drive away your infections."))
	if (ishuman(host))
		var/mob/living/carbon/human/H = host
		H.vomit(0,1)//hope you're wearing a biosuit or you'll get reinfected from your vomit, lol
	for(var/ID in host.diseases)
		var/datum/disease/advanced/D = host.diseases[ID]
		D.cure(target = host)
	strength = 0
	overloaded = TRUE


//If even one antibody hass sufficient concentration, the disease won't be able to infect
/datum/immune_system/proc/CanInfect(datum/disease/advanced/disease)
	if (overloaded)
		return TRUE

	if(HAS_TRAIT(host, TRAIT_VIRUSIMMUNE))
		return FALSE

	for (var/antigen in disease.antigen)
		if ((antibodies[antigen]) >= disease.strength)
			return FALSE
	return TRUE

/datum/immune_system/proc/ApplyAntipathogenics(threshold)
	if(overloaded)
		return

	for(var/datum/disease/advanced/disease as anything in host.diseases)
		for(var/A in disease.antigen)
			var/tally = 0.5
			if (isturf(host.loc) && (host.body_position == LYING_DOWN))
				tally += 0.5
				var/obj/structure/bed/B = locate() in host.loc
				if (host.buckled == B)//fucking chairs n stuff
					tally += 1
				if (host.IsUnconscious())
					if (tally < 2)
						tally += 1
					else
						tally += 2//if we're sleeping in a bed, we get up to 4
			else if(istype(host.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
				tally += 2.5

			tally *= boost

			if (antibodies[A] < threshold)
				antibodies[A] = min(antibodies[A] + tally, threshold)//no overshooting here
			else
				if (prob(threshold) && prob(tally * 10) && prob((100 - antibodies[A])*100/(100-threshold)))//smaller and smaller chance for further increase
					antibodies[A] = min(antibodies[A] + 1, 100)

/datum/immune_system/proc/NaturalImmune() //called with a 8% chance every time a virus activates
	for (var/datum/disease/advanced/disease as anything in host.diseases)
		for (var/A in disease.antigen)
			var/tally = 1.5
			if (isturf(host.loc) && (host.body_position == LYING_DOWN))
				tally += 0.5
				var/obj/structure/bed/B = locate() in host.loc
				if (host.buckled == B)//fucking chairs n stuff
					tally += 0.5
				if (host.IsUnconscious() || host.IsSleeping())
					if (tally < 2.5)
						tally += 1
					else
						tally += 2//if we're sleeping in a bed, we get up to 5.5
			else if(istype(host.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
				tally += 3.5

			if(!HAS_TRAIT(host, TRAIT_NOHUNGER))
				switch(host.nutrition)
					if(NUTRITION_LEVEL_FAT to INFINITY)
						tally -= 0.5
					if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
						tally += 1.5
					if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
						tally += 1
					if(0 to NUTRITION_LEVEL_STARVING)
						tally = max(tally - 1.5, 0.5)
					else
						EMPTY_BLOCK_GUARD

			tally *= boost

			if (antibodies[A] < 69)
				antibodies[A] = min(antibodies[A] + tally * strength, 70)
			else
				if(strength < 0.7) //stop trying at all once below 70% strength and above 70% antibodies
					return
				if(prob(80)) //immune system begins gaining attrition over 70% antigen.
					strength = max(strength - 0.05, 0)
				antibodies[A] = min(antibodies[A] + tally * strength, 100)

// fix immune system damage
/datum/immune_system/proc/ImmuneRepair(level, threshold)
	if(level < 0)
		strength = max(strength + level, 0)
		return
	if(strength > threshold) //do not turn 500% into 100% because you drank a lower level immune healer
		return
	strength = min(strength + level, threshold)

//instantly maxxes the antibodies for any disease in your body
/datum/immune_system/proc/AntibodyCure()
	if (overloaded)
		return

	for (var/datum/disease/advanced/disease as anything in host.diseases)
		for (var/A in disease.antigen)
			antibodies[A] = 100

/datum/immune_system/proc/ApplyVaccine(list/antigen, amount = 1, decay = 0)
	if (overloaded)
		return

	for (var/A in antigen)
		antibodies[A] = min(antibodies[A] + 5 * amount, 100)
	if(decay)
		addtimer(CALLBACK(src, PROC_REF(decay_vaccine), antigen, amount), decay)

/datum/immune_system/proc/decay_vaccine(list/antigens, amount = 1)
	for (var/A in antigens)
		antibodies[A] = max(antibodies[A] - 2.5 * amount, 10)
