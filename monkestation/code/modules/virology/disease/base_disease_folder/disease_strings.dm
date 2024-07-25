/datum/disease/proc/get_antigen_string()
	var/dat = ""
	for (var/A in antigen)
		dat += "[A]"
	return dat

/datum/disease/proc/name(override=FALSE)
	if(disease_flags & DISEASE_DORMANT)
		.= "DORMANT - [form] #["[uniqueID]"][childID ? "-["[childID]"]" : ""]"
	else
		.= "[form] #["[uniqueID]"][childID ? "-["[childID]"]" : ""]"

	if (!override && ("[uniqueID]-[subID]" in GLOB.virusDB))
		var/datum/data/record/V = GLOB.virusDB["[uniqueID]-[subID]"]
		.= V.fields["name"]

/datum/disease/proc/real_name()
	if(disease_flags & DISEASE_DORMANT)
		.= "DORMANT - [form] #["[uniqueID]"]-["[subID]"]"
	else
		.= "[form] #["[uniqueID]"]-["[subID]"]"
	if ("[uniqueID]-[subID]" in GLOB.virusDB)
		var/datum/data/record/v = GLOB.virusDB["[uniqueID]-[subID]"]
		var/nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
		. += nickname

/datum/disease/proc/get_subdivisions_string()
	var/subdivision = (strength - ((robustness * strength) / 100)) / max_stages
	var/dat = "("
	for (var/i = 1 to max_stages)
		dat += "[round(strength - i * subdivision)]"
		if (i < max_stages)
			dat += ", "
	dat += ")"
	return dat

/datum/disease/proc/get_info()
	var/r = "GNAv3 [name()]"
	r += "<BR>Strength / Robustness : <b>[strength]% / [robustness]%</b> - [get_subdivisions_string()]"
	r += "<BR>Infectability : <b>[infectionchance]%</b>"
	r += "<BR>Spread forms : <b>[get_spread_string()]</b>"
	r += "<BR>Progress Speed : <b>[stageprob]%</b>"
	r += "<dl>"
	for(var/datum/symptom/e in symptoms)
		r += "<dt> &#x25CF; <b>Stage [e.stage] - [e.name]</b> (Danger: [e.badness]). Strength: <b>[e.multiplier]</b>. Occurrence: <b>[e.chance]%</b>.</dt>"
		r += "<dd>[e.desc]</dd>"
	r += "</dl>"
	r += "<BR>Antigen pattern: [get_antigen_string()]"
	r += "<BR><i>last analyzed at: [worldtime2text()]</i>"
	return r

/datum/disease/proc/get_spread_string()
	var/dat = ""
	var/check = 0
	if (spread_flags & DISEASE_SPREAD_BLOOD)
		dat += "Blood"
		check += DISEASE_SPREAD_BLOOD
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
		dat += "Skin Contact"
		check += DISEASE_SPREAD_CONTACT_SKIN
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_AIRBORNE)
		dat += "Airborne"
		check += DISEASE_SPREAD_AIRBORNE
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
		dat += "Fluid Contact"
		check += DISEASE_SPREAD_CONTACT_FLUIDS
		if(spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS)
		dat += "Non Contagious"
		check += DISEASE_SPREAD_NON_CONTAGIOUS
		if(spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_SPECIAL)
		dat += "UNKNOWN SPREAD"
		check += DISEASE_SPREAD_SPECIAL
		if(spread_flags > check)
			dat += ", "
	/*
	if (spread_flags & SPREAD_COLONY)
		dat += "Colonizing"
		check += SPREAD_COLONY
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & SPREAD_MEMETIC)
		dat += "Memetic"
		check += SPREAD_MEMETIC
		if (spread_flags > check)
			dat += ", "
	*/
	return dat

/datum/disease/proc/addToDB()
	if ("[uniqueID]-[subID]" in GLOB.virusDB)
		return 0
	childID = 0
	for (var/virus_file in GLOB.virusDB)
		var/datum/data/record/v = GLOB.virusDB[virus_file]
		if (v.fields["id"] == uniqueID)
			childID++
	var/datum/data/record/v = new()
	v.fields["id"] = uniqueID
	v.fields["sub"] = subID
	v.fields["child"] = childID
	v.fields["form"] = form
	v.fields["name"] = name()
	v.fields["nickname"] = ""
	v.fields["description"] = get_info()
	v.fields["description_hidden"] = get_info(TRUE)
	v.fields["custom_desc"] = "No comments yet."
	v.fields["antigen"] = get_antigen_string()
	v.fields["spread_flags_type"] = get_spread_string()
	v.fields["danger"] = "Undetermined"
	GLOB.virusDB["[uniqueID]-[subID]"] = v
	return 1
