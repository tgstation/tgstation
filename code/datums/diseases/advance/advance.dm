/*

	Advance Disease is a system for Virologist to Engineer their own disease with symptoms that have effects and properties
	which add onto the overall disease.

	If you need help with creating new symptoms or expanding the advance disease, ask for Giacom on #coderbus.

*/

#define SYMPTOM_LIMIT 8



/*

	PROPERTIES

 */

/datum/disease/advance

	name = "Unknown" // We will always let our Virologist name our disease.
	desc = "An engineered disease which can contain a multitude of symptoms."
	form = "Advance Disease" // Will let med-scanners know that this disease was engineered.
	agent = "advance microbes"
	max_stages = 5
	spread_text = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

	// NEW VARS
	var/list/properties = list()
	var/list/symptoms = list() // The symptoms of the disease.
	var/id = ""
	var/processing = FALSE

	// The order goes from easy to cure to hard to cure.
	var/static/list/advance_cures = 	list(
									"sodiumchloride", "sugar", "orangejuice",
									"spaceacillin", "salglu_solution", "ethanol",
									"leporazine", "synaptizine", "lipolicide",
									"silver", "gold"
								)

/*

	OLD PROCS

 */

/datum/disease/advance/New(var/process = 1, var/datum/disease/advance/D)
	if(!istype(D))
		D = null
	// Generate symptoms if we weren't given any.

	if(!symptoms || !symptoms.len)

		if(!D || !D.symptoms || !D.symptoms.len)
			symptoms = GenerateSymptoms(0, 2)
		else
			for(var/datum/symptom/S in D.symptoms)
				symptoms += new S.type

	Refresh()
	..(process, D)
	return

/datum/disease/advance/Destroy()
	if(processing)
		for(var/datum/symptom/S in symptoms)
			S.End(src)
	return ..()

// Randomly pick a symptom to activate.
/datum/disease/advance/stage_act()
	..()
	if(symptoms && symptoms.len)

		if(!processing)
			processing = TRUE
			for(var/datum/symptom/S in symptoms)
				S.Start(src)

		for(var/datum/symptom/S in symptoms)
			S.Activate(src)
	else
		CRASH("We do not have any symptoms during stage_act()!")

// Compares type then ID.
/datum/disease/advance/IsSame(datum/disease/advance/D)

	if(!(istype(D, /datum/disease/advance)))
		return 0

	if(src.GetDiseaseID() != D.GetDiseaseID())
		return 0
	return 1

// To add special resistances.
/datum/disease/advance/cure(resistance=1)
	if(affected_mob)
		var/id = "[GetDiseaseID()]"
		if(resistance && !(id in affected_mob.resistances))
			affected_mob.resistances[id] = id
		remove_virus()
	qdel(src)	//delete the datum to stop it processing

// Returns the advance disease with a different reference memory.
/datum/disease/advance/Copy(process = 0)
	return new /datum/disease/advance(process, src, 1)

/*

	NEW PROCS

 */

// Mix the symptoms of two diseases (the src and the argument)
/datum/disease/advance/proc/Mix(datum/disease/advance/D)
	if(!(src.IsSame(D)))
		var/list/possible_symptoms = shuffle(D.symptoms)
		for(var/datum/symptom/S in possible_symptoms)
			AddSymptom(new S.type)

/datum/disease/advance/proc/HasSymptom(datum/symptom/S)
	for(var/datum/symptom/symp in symptoms)
		if(symp.id == S.id)
			return 1
	return 0

// Will generate new unique symptoms, use this if there are none. Returns a list of symptoms that were generated.
/datum/disease/advance/proc/GenerateSymptoms(level_min, level_max, amount_get = 0)

	var/list/generated = list() // Symptoms we generated.

	// Generate symptoms. By default, we only choose non-deadly symptoms.
	var/list/possible_symptoms = list()
	for(var/symp in SSdisease.list_symptoms)
		var/datum/symptom/S = new symp
		if(S.level >= level_min && S.level <= level_max)
			if(!HasSymptom(S))
				possible_symptoms += S

	if(!possible_symptoms.len)
		return generated

	// Random chance to get more than one symptom
	var/number_of = amount_get
	if(!amount_get)
		number_of = 1
		while(prob(20))
			number_of += 1

	for(var/i = 1; number_of >= i && possible_symptoms.len; i++)
		generated += pick_n_take(possible_symptoms)

	return generated

/datum/disease/advance/proc/Refresh(new_name = 0)
	//to_chat(world, "[src.name] \ref[src] - REFRESH!")
	GenerateProperties()
	AssignProperties()
	id = null

	if(!SSdisease.archive_diseases[GetDiseaseID()])
		if(new_name)
			AssignName()
		SSdisease.archive_diseases[GetDiseaseID()] = src // So we don't infinite loop
		SSdisease.archive_diseases[GetDiseaseID()] = new /datum/disease/advance(0, src, 1)

	var/datum/disease/advance/A = SSdisease.archive_diseases[GetDiseaseID()]
	AssignName(A.name)

//Generate disease properties based on the effects. Returns an associated list.
/datum/disease/advance/proc/GenerateProperties()

	if(!symptoms || !symptoms.len)
		CRASH("We did not have any symptoms before generating properties.")
		return

	properties = list("resistance" = 0, "stealth" = 0, "stage_rate" = 0, "transmittable" = 0, "severity" = 0)

	for(var/datum/symptom/S in symptoms)
		properties["resistance"] += S.resistance
		properties["stealth"] += S.stealth
		properties["stage_rate"] += S.stage_speed
		properties["transmittable"] += S.transmittable
		properties["severity"] = max(properties["severity"], S.severity) // severity is based on the highest severity symptom
	return

// Assign the properties that are in the list.
/datum/disease/advance/proc/AssignProperties()

	if(properties && properties.len)
		switch(properties["stealth"])
			if(2,3)
				visibility_flags = HIDDEN_SCANNER
			if(4 to INFINITY)
				visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC

		// The more symptoms we have, the less transmittable it is but some symptoms can make up for it.
		SetSpread(Clamp(2 ** (properties["transmittable"] - symptoms.len), BLOOD, AIRBORNE))
		permeability_mod = max(Ceiling(0.4 * properties["transmittable"]), 1)
		cure_chance = 15 - Clamp(properties["resistance"], -5, 5) // can be between 10 and 20
		stage_prob = max(properties["stage_rate"], 2)
		SetSeverity(properties["severity"])
		GenerateCure(properties)
	else
		CRASH("Our properties were empty or null!")


// Assign the spread type and give it the correct description.
/datum/disease/advance/proc/SetSpread(spread_id)
	switch(spread_id)
		if(NON_CONTAGIOUS)
			spread_text = "None"
		if(SPECIAL)
			spread_text = "None"
		if(CONTACT_GENERAL, CONTACT_HANDS, CONTACT_FEET)
			spread_text = "On contact"
		if(AIRBORNE)
			spread_text = "Airborne"
		if(BLOOD)
			spread_text = "Blood"

	spread_flags = spread_id

/datum/disease/advance/proc/SetSeverity(level_sev)

	switch(level_sev)

		if(-INFINITY to 0)
			severity = NONTHREAT
		if(1)
			severity = MINOR
		if(2)
			severity = MEDIUM
		if(3)
			severity = HARMFUL
		if(4)
			severity = DANGEROUS
		if(5 to INFINITY)
			severity = BIOHAZARD
		else
			severity = "Unknown"


// Will generate a random cure, the less resistance the symptoms have, the harder the cure.
/datum/disease/advance/proc/GenerateCure()
	if(properties && properties.len)
		var/res = Clamp(properties["resistance"] - (symptoms.len / 2), 1, advance_cures.len)
		//to_chat(world, "Res = [res]")
		cures = list(advance_cures[res])

		// Get the cure name from the cure_id
		var/datum/reagent/D = GLOB.chemical_reagents_list[cures[1]]
		cure_text = D.name


	return

// Randomly generate a symptom, has a chance to lose or gain a symptom.
/datum/disease/advance/proc/Evolve(min_level, max_level)
	var/s = safepick(GenerateSymptoms(min_level, max_level, 1))
	if(s)
		AddSymptom(s)
		Refresh(1)
	return

// Randomly remove a symptom.
/datum/disease/advance/proc/Devolve()
	if(symptoms.len > 1)
		var/s = safepick(symptoms)
		if(s)
			RemoveSymptom(s)
			Refresh(1)
	return

// Name the disease.
/datum/disease/advance/proc/AssignName(name = "Unknown")
	src.name = name
	return

// Return a unique ID of the disease.
/datum/disease/advance/GetDiseaseID()
	if(!id)
		var/list/L = list()
		for(var/datum/symptom/S in symptoms)
			L += S.id
		L = sortList(L) // Sort the list so it doesn't matter which order the symptoms are in.
		var/result = jointext(L, ":")
		id = result
	return id


// Add a symptom, if it is over the limit (with a small chance to be able to go over)
// we take a random symptom away and add the new one.
/datum/disease/advance/proc/AddSymptom(datum/symptom/S)

	if(HasSymptom(S))
		return

	if(symptoms.len < (SYMPTOM_LIMIT - 1) + rand(-1, 1))
		symptoms += S
	else
		RemoveSymptom(pick(symptoms))
		symptoms += S
	return

// Simply removes the symptom.
/datum/disease/advance/proc/RemoveSymptom(datum/symptom/S)
	symptoms -= S
	return

/*

	Static Procs

*/

// Mix a list of advance diseases and return the mixed result.
/proc/Advance_Mix(var/list/D_list)

	//to_chat(world, "Mixing!!!!")

	var/list/diseases = list()

	for(var/datum/disease/advance/A in D_list)
		diseases += A.Copy()

	if(!diseases.len)
		return null
	if(diseases.len <= 1)
		return pick(diseases) // Just return the only entry.

	var/i = 0
	// Mix our diseases until we are left with only one result.
	while(i < 20 && diseases.len > 1)

		i++

		var/datum/disease/advance/D1 = pick(diseases)
		diseases -= D1

		var/datum/disease/advance/D2 = pick(diseases)
		D2.Mix(D1)

	 // Should be only 1 entry left, but if not let's only return a single entry
	//to_chat(world, "END MIXING!!!!!")
	var/datum/disease/advance/to_return = pick(diseases)
	to_return.Refresh(1)
	return to_return

/proc/SetViruses(datum/reagent/R, list/data)
	if(data)
		var/list/preserve = list()
		if(istype(data) && data["viruses"])
			for(var/datum/disease/A in data["viruses"])
				preserve += A.Copy()
			R.data = data.Copy()
		if(preserve.len)
			R.data["viruses"] = preserve

/proc/AdminCreateVirus(client/user)

	if(!user)
		return

	var/i = SYMPTOM_LIMIT

	var/datum/disease/advance/D = new(0, null)
	D.symptoms = list()

	var/list/symptoms = list()
	symptoms += "Done"
	symptoms += SSdisease.list_symptoms.Copy()
	do
		if(user)
			var/symptom = input(user, "Choose a symptom to add ([i] remaining)", "Choose a Symptom") in symptoms
			if(isnull(symptom))
				return
			else if(istext(symptom))
				i = 0
			else if(ispath(symptom))
				var/datum/symptom/S = new symptom
				if(!D.HasSymptom(S))
					D.symptoms += S
					i -= 1
	while(i > 0)

	if(D.symptoms.len > 0)

		var/new_name = stripped_input(user, "Name your new disease.", "New Name")
		if(!new_name)
			return
		D.AssignName(new_name)
		D.Refresh()

		for(var/datum/disease/advance/AD in SSdisease.processing)
			AD.Refresh()

		for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list))
			if(H.z != ZLEVEL_STATION)
				continue
			if(!H.HasDisease(D))
				H.ForceContractDisease(D)
				break

		var/list/name_symptoms = list()
		for(var/datum/symptom/S in D.symptoms)
			name_symptoms += S.name
		message_admins("[key_name_admin(user)] has triggered a custom virus outbreak of [D.name]! It has these symptoms: [english_list(name_symptoms)]")

/*
/mob/verb/test()

	for(var/datum/disease/D in SSdisease.processing)
		to_chat(src, "<a href='?_src_=vars;Vars=\ref[D]'>[D.name] - [D.holder]</a>")
*/


/datum/disease/advance/proc/totalStageSpeed()
	return properties["stage_rate"]

/datum/disease/advance/proc/totalStealth()
	return properties["stealth"]

/datum/disease/advance/proc/totalResistance()
	return properties["resistance"]

/datum/disease/advance/proc/totalTransmittable()
	return properties["transmittable"]

#undef RANDOM_STARTING_LEVEL
