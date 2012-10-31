/*

	Advance Disease is a system for Virologist to Engineer their own disease with symptoms that have effects and properties
	which add onto the overall disease.

	If you need help with creating new symptoms or expanding the advance disease, ask for Giacom on #coderbus.

*/

#define RANDOM_STARTING_LEVEL 2

/*

	PROPERTIES

 */

/datum/disease/advance

	name = "Unknown" // We will always let our Virologist name our disease.
	desc = "An engineered disease which can contain a multitude of symptoms."
	form = "Advance Disease" // Will let med-scanners know that this disease was engineered.
	agent = "advance microbes"
	max_stages = 5


	// NEW VARS

	var/alpha_level = 0 // To determine if the advanced disease will overwrite another advance disease.
	var/list/symptoms = list() // The symptoms of the disease.

/*

	OLD PROCS

 */

/datum/disease/advance/New(var/process = 1, var/datum/disease/advance/D)
	if(!istype(D))
		D = null
	// Generate symptoms if we weren't given any.
	if(!symptoms || !symptoms.len)
		if(!D || !D.symptoms || !D.symptoms.len)
			symptoms = GenerateSymptoms()
		else
			symptoms = D.symptoms
	Refresh() // Refresh our properties and cure.
	..(process, D)
	return

// Randomly pick a symptom to activate.
/datum/disease/advance/stage_act()
	..()
	if(symptoms && symptoms.len)
		for(var/datum/symptom/S in symptoms)
			S.Activate(src)
	else
		CRASH("We do not have any symptoms during stage_act()!")

// Compares type then ID.
/datum/disease/advance/IsSame(var/datum/disease/advance/D)
	if(!(istype(D, /datum/disease/advance)))
		return 0
	if(src.GetDiseaseID() != D.GetDiseaseID())
		return 0
	return 1

// To add special resistances.
/datum/disease/advance/cure(var/resistance=1)
	if(affected_mob)
		var/id = "[GetDiseaseID()]"
		if(resistance && !(id in affected_mob.resistances))
			affected_mob.resistances[id] = /datum/disease/advance
		affected_mob.viruses -= src		//remove the datum from the list
	del(src)	//delete the datum to stop it processing
	return


/*

	NEW PROCS

 */

// Mix the symptoms of two diseases (the src and the argument)
/datum/disease/advance/proc/Mix(var/datum/disease/advance/D)
	if(!(src.IsSame(D)))
		var/list/possible_symptoms = shuffle(D.symptoms)
		for(var/datum/symptom/S in possible_symptoms)
			AddSymptom(new S.type)

// Will generate new unique symptoms, use this if there are none. Returns a list of symptoms that were generated.
/datum/disease/advance/proc/GenerateSymptoms(var/type_level_limit = RANDOM_STARTING_LEVEL, var/amount_get = 0)

	var/list/generated = list() // Symptoms we generated.

	// Generate symptoms. By default, we only choose non-deadly symptoms.
	var/list/possible_symptoms = list()
	for(var/symp in list_symptoms)
		var/datum/symptom/S = new symp
		if((S.level <= type_level_limit) && !(S in symptoms))
			possible_symptoms += S

	// Random chance to get more than one symptom
	var/number_of = amount_get
	if(!amount_get)
		number_of = 1
		while(prob(10))
			number_of += 1

	for(var/i = 0; number_of >= i; i++)
		var/datum/symptom/S = pick(possible_symptoms)
		generated += S
		possible_symptoms -= S

	return generated

/datum/disease/advance/proc/Refresh()
	//world << "[src.name] \ref[src] - REFRESH!"
	var/list/properties = GenerateProperties()
	AssignProperties(properties)

//Generate disease properties based on the effects. Returns an associated list.
/datum/disease/advance/proc/GenerateProperties()

	if(!symptoms || !symptoms.len)
		CRASH("We did not have any symptoms before generating properties.")
		return

	var/list/properties = list("resistance" = 0, "stealth" = 0, "stage_rate" = 0, "tansmittable" = 0, "severity" = 0)

	for(var/datum/symptom/S in symptoms)

		properties["resistance"] += S.resistance
		properties["stealth"] += S.stealth
		properties["stage_rate"] += S.stage_speed
		properties["tansmittable"] += S.transmittable
		properties["severity"] = max(properties["severity"], S.level) // severity is based on the highest level symptom

	return properties

// Assign the properties that are in the list.
/datum/disease/advance/proc/AssignProperties(var/list/properties = list())

	if(properties && properties.len)

		hidden = list( (properties["stealth"] > 2), (properties["stealth"] > 3) )
		// The more symptoms we have, the less transmittable it is but some symptoms can make up for it.
		SetSpread(max(BLOOD, min(properties["tansmittable"] - symptoms.len, AIRBORNE)))
		permeability_mod = 0.5 * properties["transmittable"]
		stage_prob = max(properties["stage_rate"], 1)
		SetSeverity(properties["severity"])
		GenerateCure(properties)


// Assign the spread type and give it the correct description.
/datum/disease/advance/proc/SetSpread(var/spread_id)
	//world << "Setting spread type to [spread_id]"
	switch(spread_id)

		if(NON_CONTAGIOUS)
			spread = "None"
		if(SPECIAL)
			spread = "None"
		if(CONTACT_GENERAL, CONTACT_HANDS, CONTACT_FEET)
			spread = "On contact"
		if(AIRBORNE)
			spread = "Airborne"
		if(BLOOD)
			spread = "Blood"

	spread_type = spread_id

/datum/disease/advance/proc/SetSeverity(var/level_sev)

	switch(level_sev)

		if(0)
			severity = "Non-Threat"
		if(1)
			severity = "Minor"
		if(2)
			severity = "Medium"
		if(3)
			severity = "Harmful"
		if(4)
			severity = "Dangerous!"
		if(5)
			severity = "BIOHAZARD THREAT!"
		else
			severity = "Unknown"


// Will generate a random cure, the less resistance the symptoms have, the harder the cure.
/datum/disease/advance/proc/GenerateCure(var/list/properties = list())
	if(properties && properties.len)
		var/res = max(properties["resistance"] - symptoms.len, 1)
		//world << "Res = [res]"
		switch(res)
			// Due to complications, I cannot randomly generate cures or randomly give cures.
			if(0)
				cure_id = "nutriment"

			if(1)
				cure_id = "sodiumchloride"

			if(2)
				cure_id = "orangejuice"

			if(3)
				cure_id = "spaceacillin"

			if(4)
				cure_id = "ethanol"

			if(5)
				cure_id = "ethylredoxrazine"

			if(6)
				cure_id = "silver"

			if(7)
				cure_id = "gold"

			if(8)
				cure_id = "plasma"

		// Get the cure name from the cure_id
		var/datum/reagent/D = chemical_reagents_list[cure_id]
		cure = D.name


	return

// Randomly generate a symptom, has a chance to lose or gain a symptom.
/datum/disease/advance/proc/Evolve(var/level = 2)
	AddSymptom(pick(GenerateSymptoms(level, 1)))
	Refresh()
	return

// Name the disease.
/datum/disease/advance/proc/AssignName(var/name = "Unknown")
	src.name = name
	return

/datum/disease/advance/proc/GetDiseaseID()
	var/list/L = list()
	for(var/datum/symptom/S in symptoms)
		L += S.id
	L = sortList(L) // Sort the list so it doesn't matter which order the symptoms are in.
	return dd_list2text(L, ":")

// Add a symptom, if it is over the limit (with a small chance to be able to go over)
// we take a random symptom away and add the new one.
/datum/disease/advance/proc/AddSymptom(var/datum/symptom/S)

	for(var/datum/symptom/symp in symptoms)
		if(S.id == symp.id)
			return

	if(symptoms.len < 4 + rand(-1, 1))
		symptoms += S
	else
		RemoveSymptom(pick(symptoms))
		symptoms += S
	return

// Simply removes the symptom at the moment.
/datum/disease/advance/proc/RemoveSymptom(var/datum/symptom/S)
	symptoms -= S
	return

/*

	Static Procs

*/

// Mix a list of advance diseases and return the mixed result.
/proc/Advance_Mix(var/list/D_list)

	var/list/diseases = list()
	for(var/datum/disease/advance/A in D_list)
		diseases += A
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
		D_list -= D1

		var/datum/disease/advance/D2 = pick(diseases)
		D2.Mix(D1)

	 // Should be only 1 entry left, but if not let's only return a single entry
	var/datum/disease/advance/to_return = pick(diseases)
	to_return.Refresh()
	return to_return


#undef RANDOM_STARTING_LEVEL