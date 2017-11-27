//var/datum/mind/owner = null		//Who owns the objective.
//var/explanation_text = "Nothing"	//What that person is supposed to do.
//var/datum/mind/target = null		//If they are focused on a particular person.
//var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
//var/completed = 0					//currently only used for custom objectives.
//var/dangerrating = 0				//How hard the objective is, essentially. Used for dishing out objectives and checking overall victory.
//var/martyr_compatible = 0			//If the objective is compatible with martyr objective, i.e. if you can still do it while dead.
//
//
// Sort through all crew and return non-vampires that have blood and can be objective targets.
/datum/objective/bloodsucker/proc/return_possible_targets()
	var/list/possible_targets = list()

	 // Look at all crew members, and for/loop through.
	for(var/datum/mind/possible_target in get_crewmember_minds())
		// Check One: Default Valid User
		if(possible_target != owner && ishuman(possible_target.current) && possible_target.current.stat != DEAD && is_unique_objective(possible_target))
			// Check Two: Am Bloodsucker? OR in Bloodsucker list?

			if (possible_target.has_antag_datum(ANTAG_DATUM_BLOODSUCKER) || (possible_target in SSticker.mode.bloodsuckers))
				continue
			else
				possible_targets += possible_target

	return possible_targets




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker/coffin
	//dangerrating = 4
	martyr_compatible = 1

//						 GENERATE!
/datum/objective/bloodsucker/coffin/proc/generate_objective()
	update_explanation_text()

/datum/objective/bloodsucker/embrace/update_explanation_text()
	explanation_text = "Embrace [target_amount] crewmember[target_amount == 1 ? "" : "s"] into a creature of the night."


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/datum/objective/bloodsucker/embrace
	//dangerrating = 4
	martyr_compatible = 1


//						 GENERATE!
/datum/objective/bloodsucker/embrace/proc/generate_objective()
	var/list/possible_targets = return_possible_targets()

	target_amount = Clamp(possible_targets.len / 8, 1, 3)
	//dangerrating = 3 + target_amount * 3

	update_explanation_text()


//						EXPLANATION
/datum/objective/bloodsucker/embrace/update_explanation_text()
	if (target_amount > 0)
		explanation_text = "Embrace [target_amount] crewmember[target_amount == 1 ? "" : "s"] into a creature of the night."
	else
		explanation_text = "Free Objective"


//						WIN CONDITIONS?
/datum/objective/bloodsucker/embrace/check_completion()
	var/datum/antagonist/bloodsucker/antagdatum = owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	if (antagdatum && antagdatum.vampsMade >= target_amount)
		return 1
	return 0


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/datum/objective/bloodsucker/embracetarget
	//dangerrating = 5
	martyr_compatible = 1
	//var/target_role_type=0


//						 GENERATE!
/datum/objective/bloodsucker/embracetarget/proc/generate_objective()
	var/list/possible_targets = return_possible_targets()

	if(possible_targets.len > 0)
		target = pick(possible_targets)

	update_explanation_text()


//						EXPLANATION
/datum/objective/bloodsucker/embracetarget/update_explanation_text()
	if (target)
		explanation_text = "Embrace [target.name], the [target.assigned_role], into a creature of the night."
	else
		explanation_text = "Free Objective"

//	explanation_text = "Embrace [target.name], the [!target_role_type ? target.assigned_role : target.special_role], into a creature of the night."



//						WIN CONDITIONS?
/datum/objective/bloodsucker/embracetarget/check_completion()
	//if (target.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)) // && target.bloodsuckerinfo.creator == owner)  // NOTE: Probably don't want to make creation exclusive to one person.
	if (target in SSticker.mode.bloodsuckers || target.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return 1
	return 0



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/objective/bloodsucker/drinkbloodtarget
	//dangerrating = 5
	martyr_compatible = 1
	//var/target_role_type = 0

//						 GENERATE!
/datum/objective/bloodsucker/drinkbloodtarget/proc/generate_objective()
	var/list/possible_targets = return_possible_targets()

	if(possible_targets.len > 0)
		target = pick(possible_targets)

	update_explanation_text()


//						EXPLANATION
/datum/objective/bloodsucker/drinkbloodtarget/update_explanation_text()
	if (target)
		explanation_text = "Feed from the heartsblood of [target.assigned_role]."
	else
		explanation_text = "Free Objective"

//	explanation_text = "Embrace [target.name], the [!target_role_type ? target.assigned_role : target.special_role], into a creature of the night."



//						WIN CONDITIONS?
/datum/objective/bloodsucker/embracetarget/check_completion()
	return 0



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/objective/bloodsucker/survive
	//dangerrating = 3
	martyr_compatible = 0


//						 GENERATE!
/datum/objective/bloodsucker/survive/proc/generate_objective()
	update_explanation_text()

//						EXPLANATION
/datum/objective/bloodsucker/survive/update_explanation_text()
	explanation_text = "Survive the entire shift without succumbing to Final Death."

//						WIN CONDITIONS?
/datum/objective/bloodsucker/survive/check_completion()
	// -Must have a body.
	if (!owner.current)
		return 0
	// Dead, without a head or heart? Cya
	//message_admins("[owner] DEBUG OBJECTIVE: Survive: [owner.current.stat] / [owner.current.BloodsuckerCanUsePowers()] .")
	return owner.current.stat != DEAD || owner.current.HaveBloodsuckerBodyparts()




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



// Defile a facility with your blood.
/datum/objective/bloodsucker/desecrate
	//dangerrating = 4
	martyr_compatible = 1
	var/target_area 				//Name of the area to desecrate.


//						 GENERATE!
/datum/objective/bloodsucker/desecrate/proc/generate_objective()
	// Look up: Space_Station_13_areas.dm for all areas.
	var/list/areas_easy = list("Chapel","Bar","Cafeteria","Locker Room","Dormitories","Theatre","Kitchen","Fitness Room","Morgue","Chemistry","Genetics Lab")
	var/list/areas_hard = list("Detective's Office","Teleporter Room","Cargo Bay")
	if (prob(75))
		target_area = pick(areas_easy)
	else
		target_area = pick(areas_hard)
	target_amount = rand(3,5)
	update_explanation_text()


//						EXPLANATION
/datum/objective/bloodsucker/desecrate/update_explanation_text()
	explanation_text = "Desecrate the [target_area] with your accursed blood [target_amount] times."
	// NOTE: Make sure "Expel Blood" checks the current location you're bleeding against this objective, and runs check_completion() to know if you've done enough.


//						WIN CONDITIONS?
/datum/objective/bloodsucker/desecrate/check_completion()
	//get_area_by_name(area)
	var/area/A
	var/checkamount = 0
	var/datum/antagonist/bloodsucker/antagdatum = owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	for (var/obj/effect/decal/cleanable/blood/vampblood/B in antagdatum.desecrateBlood)
		A = get_area(B)
		//message_admins("[owner] DEBUG OBJECTIVE: [A] / [A.name] / [target_area].")
		if (A.name == target_area)
			checkamount ++
			//return 1
	return checkamount >= target_amount


// LOOK UP:
// get_area() (in game.dm) to find the area you're in.
//
// obj/effect/decal/cleanable/crayon/gang to see how territory is tracked





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



// Vampires hate solar arrays.
/datum/objective/bloodsucker/destroysolars
	//dangerrating = 4
	martyr_compatible = 1


/datum/objective/bloodsucker/destroysolars/update_explanation_text()
	explanation_text = "Keep all Solar Arrays out of commission for good."
	// NOTE: Make sure "Expel Blood" checks the current location you're bleeding against this objective, and runs check_completion() to know if you've done enough.


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



// Steal hearts. You just really wanna have some hearts.
/datum/objective/bloodsucker/heartthief
	//dangerrating = 10
	martyr_compatible = 1
														// NOTE: Look up /steal in objective.dm for inspiration.


//						 GENERATE!
/datum/objective/bloodsucker/heartthief/proc/generate_objective()
	target_amount = rand(3,5)
	update_explanation_text()
	//dangerrating += target_amount * 2

//						EXPLANATION
/datum/objective/bloodsucker/heartthief/update_explanation_text()
	if (target_amount > 0)
		explanation_text = "Steal and keep [target_amount] heart[target_amount == 1 ? "" : "s"]."			// TO DO:     Limit them to Human Only!
	else
		explanation_text = "Free Objective"


//						WIN CONDITIONS?
/datum/objective/bloodsucker/heartthief/check_completion()
	// -Must have a body.
	if (!owner.current)
		return 0
	// Taken from /steal in objective.dm
	var/list/all_items = owner.current.GetAllContents() // Includes items inside other items.
	var/itemcount = 0
	for(var/obj/I in all_items) //Check for items
		if(istype(I, /obj/item/organ/heart))
			itemcount ++
			if (itemcount >= target_amount) // Got the right amount?
				return 1

	return 0
