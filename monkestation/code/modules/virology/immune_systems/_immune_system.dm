/datum/immune_system
	var/mob/living/host = null
	var/strength = 1
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

/datum/immune_system/New(mob/living/source)
	..()
	if (!source)
		del(src)
		return
	host = source

	for (var/antibody in antibodies)
		if (antibody in rare_antigens)
			antibodies[antibody] = rand(1,15)
			if (prob(5))
				antibodies[antibody] += 10
		if (antibody in common_antigens)
			antibodies[antibody] = rand(10,30)
		if (antibody in blood_antigens)
			antibodies[antibody] = rand(10,20)
			if (host.dna && host.dna.b_type)
				if (antibody == ANTIGEN_O)
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_A && findtext(host.dna.blood_type,"A"))
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_B && findtext(host.dna.blood_type,"B"))
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_RH && findtext(host.dna.blood_type,"+"))
					antibodies[antibody] += rand(12,15)

/datum/immune_system/proc/transfer_to(mob/living/source)
	if (!source.immune_system)
		source.immune_system = new(source)

	source.immune_system.strength = strength
	source.immune_system.overloaded = overloaded
	source.immune_system.antibodies = antibodies.Copy()

/datum/immune_system/proc/GetImmunity()
	var/effective_strength = strength

	if(host)
		if(HAS_TRAIT(host, TRAIT_HULK))
			effective_strength *= 2

	return list(effective_strength, antibodies.Copy())

/datum/immune_system/proc/Overload()
	host.adjustToxLoss(100)
	target.AddComponent(/datum/component/irradiated)
	host.bodytemperature = max(host.bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT)
	to_chat(host, span_danger("A terrible fever assails your host, you feel ill as your immune system kicks into overdrive to drive away your infections."))
	if (ishuman(host))
		var/mob/living/carbon/human/H = host
		H.vomit(0,1)//hope you're wearing a biosuit or you'll get reinfected from your vomit, lol
	for(var/ID in host.virus2)
		var/datum/disease2/disease/D = host.virus2[ID]
		D.cure(host,2)
	strength = 0
	overloaded = TRUE


//If even one antibody hass sufficient concentration, the disease won't be able to infect
/datum/immune_system/proc/CanInfect(datum/disease2/disease/disease)
	if (overloaded)
		return TRUE

	for (var/antigen in disease.antigen)
		if ((strength * antibodies[antigen]) >= disease.strength)
			return FALSE
	return TRUE

/datum/immune_system/proc/ApplyAntipathogenics(threshold)
	if (overloaded)
		return

	for (var/ID in host.virus2)
		var/datum/disease2/disease/disease = host.virus2[ID]
		for (var/A in disease.antigen)
			var/tally = 0.5
			if (isturf(host.loc) && host.lying)
				tally += 0.5
				var/obj/structure/bed/B = locate() in host.loc
				if (B && B.mob_lock_type == /datum/locking_category/buckle/bed)//fucking chairs n stuff
					tally += 1
				if (host.sleeping)
					if (tally < 2)
						tally += 1
					else
						tally += 2//if we're sleeping in a bed, we get up to 4
			else if(istype(host.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				tally += 1.5

			if (antibodies[A] < threshold)
				antibodies[A] = min(antibodies[A] + tally, threshold)//no overshooting here
			else
				if (prob(threshold) && prob(tally * 10) && prob((100 - antibodies[A])*100/(100-threshold)))//smaller and smaller chance for further increase
					antibodies[A] = min(antibodies[A] + 1, 100)


/datum/immune_system/proc/ApplyVaccine(list/antigen)
	if (overloaded)
		return

	for (var/A in antigen)
		antibodies[A] = min(antibodies[A] + 20, 100)
