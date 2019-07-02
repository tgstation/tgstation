

// Hide a random object somewhere on the station:
//		var/turf/targetturf = get_random_station_turf()
//		var/turf/targetturf = get_safe_random_station_turf()




/datum/objective/bloodsucker
	martyr_compatible = TRUE

//						 GENERATE!
/datum/objective/bloodsucker/proc/generate_objective()
	update_explanation_text()

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//	//							 PROCS 									//	//


/datum/objective/bloodsucker/proc/return_possible_targets()
	var/list/possible_targets = list()

	 // Look at all crew members, and for/loop through.
	for(var/datum/mind/possible_target in get_crewmember_minds())
		// Check One: Default Valid User
		if(possible_target != owner && ishuman(possible_target.current) && possible_target.current.stat != DEAD)// && is_unique_objective(possible_target))
			// Check Two: Am Bloodsucker? OR in Bloodsucker list?
			if (possible_target.has_antag_datum(ANTAG_DATUM_BLOODSUCKER) || (possible_target in SSticker.mode.bloodsuckers))
				continue
			else
				possible_targets += possible_target

	return possible_targets



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker/lair

//						EXPLANATION
/datum/objective/bloodsucker/lair/update_explanation_text()
	explanation_text = "Create a lair by claiming a coffin."//  Make sure to keep it safe!"

//						WIN CONDITIONS?
/datum/objective/bloodsucker/lair/check_completion()
	var/datum/antagonist/bloodsucker/antagdatum = owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (antagdatum && antagdatum.coffin && antagdatum.lair)
		return TRUE
	return FALSE

	// Space_Station_13_areas.dm  <--- all the areas

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Vassal becomes a Head, or part of a department
/datum/objective/bloodsucker/protege

	// LOOKUP: /datum/crewmonitor/proc/update_data(z)  for .assignment to see how to get a person's PDA.
	var/list/roles = list(
		"Captain",
		"Head of Security",
		"Head of Personnel",
		"Research Director",
		"Chief Engineer",
		"Chief Medical Officer",
		"Quartermaster"
	)
	var/list/departs = list(
		"Head of Security",
		"Research Director",
		"Chief Engineer",
		"Chief Medical Officer",
		"Quartermaster"
	)


	var/target_role	// Equals "HEAD" when it's not a department role.
	var/department_string

//						 GENERATE!
/datum/objective/bloodsucker/protege/generate_objective()
	target_role = rand(0,2) == 0 ? "HEAD" : pick(departs)

	// Heads?
	if (target_role == "HEAD")
		target_amount = rand(1, round(SSticker.mode.num_players() / 20))
		target_amount = CLAMP(target_amount,1,3)
	// Department?
	else
		switch(target_role)
			if("Head of Security")
				department_string = "Security"
			if("Research Director")
				department_string = "Science"
			if("Chief Engineer")
				department_string = "Engineering"
			if("Chief Medical Officer")
				department_string = "Medical"
			if("Quartermaster")
				department_string = "Cargo"
		target_amount = rand(round(SSticker.mode.num_players() / 20), round(SSticker.mode.num_players() / 10))
		target_amount = CLAMP(target_amount, 2, 4)
	..()

//						EXPLANATION
/datum/objective/bloodsucker/protege/update_explanation_text()
	if (target_role == "HEAD")
		if (target_amount == 1)
			explanation_text = "Guarantee a Vassal ends up as a Department Head or in a Leadership role."
		else
			explanation_text = "Guarantee [target_amount] Vassals end up as different Leadership or Department Heads."
	else
		explanation_text = "Have [target_amount] Vassal[target_amount==1?"":"s"] in the [department_string] department."

//						WIN CONDITIONS?
/datum/objective/bloodsucker/protege/check_completion()

	var/datum/antagonist/bloodsucker/antagdatum = owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (!antagdatum || antagdatum.vassals.len == 0)
		return FALSE

	// Get list of all jobs that are qualified (for HEAD, this is already done)
	var/list/valid_jobs
	if (target_role == "HEAD")
		valid_jobs = roles
	else
		valid_jobs = list()
		var/list/alljobs = subtypesof(/datum/job) // This is just a list of TYPES, not the actual variables!
		for(var/T in alljobs)
			var/datum/job/J = SSjob.GetJobType(T) //
			if (!istype(J))
				continue
			// Found a job whose Dept Head matches either list of heads, or this job IS the head
			if ((target_role in J.department_head) || target_role == J.title)
				valid_jobs += J.title


	// Check Vassals, and see if they match
	var/objcount = 0
	var/list/counted_roles = list() // So you can't have more than one Captain count.
	for(var/datum/antagonist/vassal/V in antagdatum.vassals)
		if (!V || !V.owner)	// Must exist somewhere, and as a vassal.
			continue

		var/thisRole = "none"

		// Mind Assigned
		if ((V.owner.assigned_role in valid_jobs) && !(V.owner.assigned_role in counted_roles))
			//to_chat(owner, "<span class='userdanger'>PROTEGE OBJECTIVE: (MIND ROLE)</span>")
			thisRole = V.owner.assigned_role
		// Mob Assigned
		else if ((V.owner.current.job in valid_jobs) && !(V.owner.current.job in counted_roles))
			//to_chat(owner, "<span class='userdanger'>PROTEGE OBJECTIVE: (MOB JOB)</span>")
			thisRole = V.owner.current.job
		// PDA Assigned
		else if (V.owner.current && ishuman(V.owner.current))
			var/mob/living/carbon/human/H = V.owner.current
			var/obj/item/card/id/I =  H.wear_id ? H.wear_id.GetID() : null
			if (I && (I.assignment in valid_jobs) && !(I.assignment in counted_roles))
				//to_chat(owner, "<span class='userdanger'>PROTEGE OBJECTIVE: (GET ID)</span>")
				thisRole = I.assignment

		// NO MATCH
		if (thisRole == "none")
			continue

		// SUCCESS!
		objcount ++
		if (target_role == "HEAD")
			counted_roles += thisRole // Add to list so we don't count it again (but only if it's a Head)

	// 			NOTE!!!!!!!!!!!

	//			Look for jobs value on mobs! This is assigned at start, but COULD be assigned from HoP?
	//
	//			ALSO - Search through all jobs (look for prefs earlier that look for all jobs, and search through all jobs to see if their head matches the head listed, or it IS the head)
	//
	//			ALSO - registered_account in _vending.dm for banks, and assigning new ones.

	//to_chat(antagdatum.owner, "<span class='userdanger'>PROTEGE OBJECTIVE: Final Count: [objcount] of [antagdatum.vassals.len] vassals</span>")
	return objcount >= target_amount

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Eat blood from a lot of people
/datum/objective/bloodsucker/gourmand

// HOW: Track each feed (if human). Count victory.


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Convert a crewmate
/datum/objective/bloodsucker/embrace

// HOW: Find crewmate. Check if person is a bloodsucker

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Defile a facility with blood
/datum/objective/bloodsucker/desecrate

	// Space_Station_13_areas.dm  <--- all the areas

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Destroy the Solar Arrays
/datum/objective/bloodsucker/solars

// Space_Station_13_areas.dm  <--- all the areas
/datum/objective/bloodsucker/solars/update_explanation_text()
	explanation_text = "Prevent all solar arrays on the station from functioning."

/datum/objective/bloodsucker/solars/check_completion()
	// Sort through all /obj/machinery/power/solar_control in the station ONLY, and check that they are functioning.
	// Make sure that lastgen is 0 or connected_panels.len is 0. Doesnt matter if it's tracking.
	for (var/obj/machinery/power/solar_control/SC in SSsun.solars)
		if (SC && SC.lastgen > 0 && SC.connected_panels.len > 0 && SC.connected_tracker)
			return FALSE
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Steal hearts. You just really wanna have some hearts.
/datum/objective/bloodsucker/heartthief
	// NOTE: Look up /steal in objective.dm for inspiration.

//						 GENERATE!
/datum/objective/bloodsucker/heartthief/generate_objective()
	target_amount = rand(2,3)

	update_explanation_text()
	//dangerrating += target_amount * 2

//						EXPLANATION
/datum/objective/bloodsucker/heartthief/update_explanation_text()
	explanation_text = "Steal and keep [target_amount] heart[target_amount == 1 ? "" : "s"]."			// TO DO:     Limit them to Human Only!

//						WIN CONDITIONS?
/datum/objective/bloodsucker/heartthief/check_completion()
	// -Must have a body.
	if (!owner.current)
		return FALSE
	// Taken from /steal in objective.dm
	var/list/all_items = owner.current.GetAllContents() // Includes items inside other items.
	var/itemcount = FALSE
	for(var/obj/I in all_items) //Check for items
		if(istype(I, /obj/item/organ/heart))
			itemcount ++
			if (itemcount >= target_amount) // Got the right amount?
				return TRUE

	return FALSE

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker/survive
	martyr_compatible = FALSE


//						EXPLANATION
/datum/objective/bloodsucker/survive/update_explanation_text()
	explanation_text = "Survive the entire shift without succumbing to Final Death."

//						WIN CONDITIONS?
/datum/objective/bloodsucker/survive/check_completion()
	// -Must have a body.
	if (!owner.current || !isliving(owner.current))
		return FALSE
	// Dead, without a head or heart? Cya
	return owner.current.stat != DEAD// || owner.current.HaveBloodsuckerBodyparts()

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker/vamphunter

//						 GENERATE!
/datum/objective/bloodsucker/vamphunter/generate_objective()
	update_explanation_text()

//						EXPLANATION
/datum/objective/bloodsucker/vamphunter/update_explanation_text()
	explanation_text = "Destroy all Bloodsuckers on [station_name()]."

//						WIN CONDITIONS?
/datum/objective/bloodsucker/vamphunter/check_completion()
	for (var/datum/mind/M in SSticker.mode.bloodsuckers)
		if (M && M.current && M.current.stat != DEAD && get_turf(M.current))
			return FALSE
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker/monsterhunter

//						 GENERATE!
/datum/objective/bloodsucker/monsterhunter/generate_objective()
	update_explanation_text()

//						EXPLANATION
/datum/objective/bloodsucker/monsterhunter/update_explanation_text()
	explanation_text = "Destroy all monsters on [station_name()]."

//						WIN CONDITIONS?
/datum/objective/bloodsucker/monsterhunter/check_completion()
	var/list/datum/mind/monsters = list()
	monsters += SSticker.mode.bloodsuckers
	monsters += SSticker.mode.devils
	monsters += SSticker.mode.cult
	monsters += SSticker.mode.wizards
	monsters += SSticker.mode.apprentices
	monsters += SSticker.mode.servants_of_ratvar
	monsters += SSticker.mode.changelings

	for (var/datum/mind/M in monsters)
		if (M && M.current && M.current.stat != DEAD && get_turf(M.current))
			return FALSE
	return TRUE


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker/vassal

//						 GENERATE!
/datum/objective/bloodsucker/vassal/generate_objective()
	update_explanation_text()

//						EXPLANATION
/datum/objective/bloodsucker/vassal/update_explanation_text()
	explanation_text = "Guarantee the success of your Master's mission!"

//						WIN CONDITIONS?
/datum/objective/bloodsucker/vassal/check_completion()
	var/datum/antagonist/vassal/antag_datum = owner.has_antag_datum(ANTAG_DATUM_VASSAL)
	return antag_datum.master && antag_datum.master.owner && antag_datum.master.owner.current && antag_datum.master.owner.current.stat != DEAD
