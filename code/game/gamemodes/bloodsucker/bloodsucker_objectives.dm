
/datum/objective/bloodsucker

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

//						EXPLANATION
/datum/objective/bloodsucker/coffin/update_explanation_text()
	explanation_text = "Use your blood to claim a Coffin as your secret lair. Make sure to keep it safe!"

//						WIN CONDITIONS?
/datum/objective/bloodsucker/coffin/check_completion()
	var/datum/antagonist/bloodsucker/antagdatum = owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (antagdatum && antagdatum.coffin)
		return 1
	return 0

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/datum/objective/bloodsucker/embrace
	//dangerrating = 4
	martyr_compatible = 1


//						 GENERATE!
/datum/objective/bloodsucker/embrace/proc/generate_objective()
	var/list/possible_targets = return_possible_targets()

	target_amount = Clamp(possible_targets.len / 8, 1, 3)
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

/*
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

*/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



// Defile a facility with your blood.
/datum/objective/bloodsucker/desecrate
	//dangerrating = 4
	martyr_compatible = 1
	var/area/target_area 				//Name of the area to desecrate.


//						 GENERATE!
/datum/objective/bloodsucker/desecrate/proc/generate_objective()

	// List of BASE TYPES. Find one that qualifies in GLOB.sortedAreas.
	var/list/area/As = list(
		/area/library,
		/area/chapel,
		/area/crew_quarters,
		/area/engine,
		/area/medical/medbay,
		/area/security,
		/area/quartermaster,
		/area/hydroponics,
		/area/science,
		/area/bridge
	)

	//message_admins("[owner] DEBUG OBJECTIVE: New DESECRATE objective.")
	// Find Valids					// TODO: Turn this into a single global list
	var/list/area/valid_areas = list()
	for (var/area/A in GLOB.sortedAreas)
		var/turf/T = locate(/turf) in A
		// Is Station
		if ((T.z in GLOB.station_z_levels)) // && locate(A.type) in As) // NOTE : Cannot do this. If an area's type is /area/library/special then it does NOT appear in As.
			//message_admins("[owner] Checking [A] with turf [T] / [T.z]")
			// Does this type appear in our list?
			for (var/check_type in As)
				if (istype(A,check_type))
					valid_areas += A
					break
	// Make Selection
	target_area = pick(valid_areas)
	//message_admins("[owner] Found [valid_areas.len] valid areas, selected [target_area]")

	/* METHOD ONE: Pick typesof()
	while (A == null && safety < 25)
		// Expand List
		var/list/moreAs = typesof(pick(As)) // This picks something from As, and expands it to include all derived room types.
		var/a_type = pick(moreAs)			// Pick one of those expanded room types.
		var/area/check_area = locate(a_type) in GLOB.sortedAreas	// Find that room type (this station may not have one)
		message_admins("[owner] DEBUG OBJECTIVE: Checking for [a_type], found area [check_area]...")
		if (check_area == null)
			continue
		var/turf/T = locate(/turf) in check_area
		if (T.z in GLOB.station_z_levels)
			A = check_area
		safety ++
	*/

	// Never found anything? Default to Bridge
	if (target_area == null)
		target_area = locate(/area/bridge) in GLOB.sortedAreas
		message_admins("[owner] DEBUG OBJECTIVE: Found nothing. Defaulted to [target_area]")

			// Pick Room Type
	//var/a_type = pick(As)
	//	// Find all Rooms that Qualify
	//	for(var/a_type in As)
	//		if( istype(check_area, a_type) )
	//		for (var/obj/effect/proc_holder/spell/bloodsucker/feed/feedpower in powers)




	//r/area/A
	//var/safety = 0
	//while (A == null && safety < 50)
		//var/area/check_area = pick(GLOB.sortedAreas)
		//message_admins("[owner] DEBUG OBJECTIVE: Checking area [check_area]...")
		//var/turf/T = locate(/turf) in check_area
		//if (T.z in GLOB.station_z_levels && locate(check_area.type) in As)
		//	A = check_area
		//message_admins("[owner] DEBUG OBJECTIVE: Trying [A], [check_area.type] / [T.z].")

		//var/a_type =
		//	for(var/a_type in As)
		//		if( istype(check_area, a_type) )

			//message_admins("[owner] DEBUG OBJECTIVE: Searching for [a_type]...")
			//A = locate(a_type) in GLOB.sortedAreas
			//message_admins("[owner] DEBUG OBJECTIVE: Trying [A] out of [GLOB.sortedAreas.len] possible areas.")

	//	safety ++

	target_amount = rand(3,5)
	update_explanation_text()

	// UPDATE: Different Maps lack certain rooms! THIS IS HOW WE SHOULD DO IT INSTEAD OF PICKING SET NAMES...
	//
	// 1) Pick random areas and make sure they apply to any of the /area/ datums in Space_Station_13_areas.dm
	// 2) Sort through (area/A in GLOB.sortedAreas), or (var/area/A in world) to find areas that ACTUALLY exist in this map

	// adminjump.dm    game.dm    weather.dm    space_station_13_areas.dm    areas.dm

//						EXPLANATION
/datum/objective/bloodsucker/desecrate/update_explanation_text()
	explanation_text = "Desecrate the [target_area.name] with your accursed blood [target_amount] times."
	// NOTE: Make sure "Expel Blood" checks the current location you're bleeding against this objective, and runs check_completion() to know if you've done enough.


//						WIN CONDITIONS?
/datum/objective/bloodsucker/desecrate/check_completion()
	//get_area_by_name(area)
	var/area/A
	var/checkamount = 0
	var/datum/antagonist/bloodsucker/antagdatum = owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	for (var/obj/effect/decal/cleanable/blood/vampblood/B in antagdatum.desecrateBlood)
		A = get_area(B)
		message_admins("[owner] DEBUG OBJECTIVE: [src] [A] / [A.name] / [target_area].")
		if (A.name == target_area.name)
			checkamount ++
			//return 1
	message_admins("[owner] DEBUG OBJECTIVE: [src] Found [checkamount] of [target_amount].")
	return checkamount >= target_amount


// LOOK UP:
// get_area() (in game.dm) to find the area you're in.
//
// obj/effect/decal/cleanable/crayon/gang to see how territory is tracked





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
// Vampires hate solar arrays.
/datum/objective/bloodsucker/destroysolars
	//dangerrating = 4
	martyr_compatible = 1


/datum/objective/bloodsucker/destroysolars/update_explanation_text()
	explanation_text = "Keep all Solar Arrays out of commission for good."
	// NOTE: Make sure "Expel Blood" checks the current location you're bleeding against this objective, and runs check_completion() to know if you've done enough.
*/

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
	if (!owner.current || !isliving(owner.current))
		return 0
	// Dead, without a head or heart? Cya
	//message_admins("[owner] DEBUG OBJECTIVE: Survive: [owner.current.stat] / [owner.current.BloodsuckerCanUsePowers()] .")
	return owner.current.stat != DEAD || owner.current.HaveBloodsuckerBodyparts()



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/objective/bloodsucker/vassal
	//dangerrating = 4
	martyr_compatible = 1

//						 GENERATE!
/datum/objective/bloodsucker/vassal/proc/generate_objective()
	update_explanation_text()

//						EXPLANATION
/datum/objective/bloodsucker/vassal/update_explanation_text()
	explanation_text = "Serve the wishes of your master, and guarantee their survival and success."

//						WIN CONDITIONS?
/datum/objective/bloodsucker/vassal/check_completion()
	var/datum/antagonist/vassal/antagdatum = owner.has_antag_datum(ANTAG_DATUM_VASSAL)
	if (antagdatum && antagdatum.master && !antagdatum.master.AmFinalDeath())
		return 1
	return 0
