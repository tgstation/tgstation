/*
 *	# Hide a random object somewhere on the station:
 *
 *	var/turf/targetturf = get_random_station_turf()
 *	var/turf/targetturf = get_safe_random_station_turf()
 */

/datum/objective/bloodsucker
	martyr_compatible = TRUE

// GENERATE
/datum/objective/bloodsucker/New()
	update_explanation_text()
	..()

//////////////////////////////////////////////////////////////////////////////
//	//							 PROCS 									//	//

/// Look at all crew members, and for/loop through.
/datum/objective/bloodsucker/proc/return_possible_targets()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		// Check One: Default Valid User
		if(possible_target != owner && ishuman(possible_target.current) && possible_target.current.stat != DEAD)
			// Check Two: Am Bloodsucker?
			if(IS_BLOODSUCKER(possible_target.current))
				continue
			possible_targets += possible_target

	return possible_targets

//////////////////////////////////////////////////////////////////////////////////////
//	//							 OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////
//    DEFAULT OBJECTIVES    //
//////////////////////////////

/datum/objective/bloodsucker/lair
	name = "claimlair"

// EXPLANATION
/datum/objective/bloodsucker/lair/update_explanation_text()
	explanation_text = "Claim a coffin by entering it to create your lair, and protect it until the end of the shift."//  Make sure to keep it safe!"

// WIN CONDITIONS?
/datum/objective/bloodsucker/lair/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && bloodsuckerdatum.coffin && bloodsuckerdatum.lair)
		return TRUE
	return FALSE

/// Space_Station_13_areas.dm  <--- all the areas

//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/survive/bloodsucker
	name = "bloodsuckersurvive"
	explanation_text = "Survive the entire shift without succumbing to Final Death."

// WIN CONDITIONS?
// Handled by parent

//////////////////////////////////////////////////////////////////////////////////////

#define VASSALIZE_COMMAND "command_vassalization"

/// Vassalize someone in charge (Head of Staff + QM)
/datum/objective/bloodsucker/protege
	name = "vassalization"

	var/list/heads = list(
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Research Director",
		"Chief Engineer",
		"Chief Medical Officer",
		"Quartermaster",
	)

	var/list/departments = list(
		"Security",
		"Supply",
		"Science",
		"Engineering",
		"Medical",
	)

	var/target_department	// Equals "HEAD" when it's not a department role.
	var/department_string

// GENERATE!
/datum/objective/bloodsucker/protege/New()
	switch(rand(0, 2))
		// Vasssalize Command/QM
		if(0)
			target_amount = 1
			target_department = VASSALIZE_COMMAND
		// Vassalize a certain department
		else
			target_amount = rand(2,3)
			target_department = pick(departments)
	..()

// EXPLANATION
/datum/objective/bloodsucker/protege/update_explanation_text()
	if(target_department == VASSALIZE_COMMAND)
		explanation_text = "Guarantee a Vassal ends up as a Department Head or in a Leadership role."
	else
		explanation_text = "Have [target_amount] Vassal[target_amount == 1 ? "" : "s"] in the [target_department] department."

// WIN CONDITIONS?
/datum/objective/bloodsucker/protege/check_completion()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum || !bloodsuckerdatum.vassals.len)
		return FALSE

	// Get list of all jobs that are qualified (for HEAD, this is already done)
	var/list/valid_jobs
	if(target_department == VASSALIZE_COMMAND)
		valid_jobs = heads
	else
		valid_jobs = list()
		var/list/alljobs = subtypesof(/datum/job) // This is just a list of TYPES, not the actual variables!
		for(var/listed_jobs in alljobs)
			var/datum/job/all_jobs = SSjob.GetJobType(listed_jobs)
			if(!istype(all_jobs))
				continue
			// Found a job whose Dept Head matches either list of heads, or this job IS the head. We exclude the QM from this, HoP handles Cargo.
			if((target_department in all_jobs.department_head) || target_department == all_jobs.title)
				valid_jobs += all_jobs.title

	// Check Vassals, and see if they match
	var/objcount = 0
	var/list/counted_roles = list() // So you can't have more than one Captain count.
	for(var/datum/antagonist/vassal/bloodsucker_vassals in bloodsuckerdatum.vassals)
		if(!bloodsucker_vassals || !bloodsucker_vassals.owner)	// Must exist somewhere, and as a vassal.
			continue

		var/this_role = "none"

		// Mind Assigned
		if((bloodsucker_vassals.owner.assigned_role in valid_jobs) && !(bloodsucker_vassals.owner.assigned_role in counted_roles))
			//to_chat(owner, span_userdanger("PROTEGE OBJECTIVE: (MIND ROLE)"))
			this_role = bloodsucker_vassals.owner.assigned_role
		// Mob Assigned
		else if((bloodsucker_vassals.owner.current.job in valid_jobs) && !(bloodsucker_vassals.owner.current.job in counted_roles))
			//to_chat(owner, span_userdanger("PROTEGE OBJECTIVE: (MOB JOB)"))
			this_role = bloodsucker_vassals.owner.current.job
		// PDA Assigned
		else if(bloodsucker_vassals.owner.current && ishuman(bloodsucker_vassals.owner.current))
			var/mob/living/carbon/human/vassal_users = bloodsucker_vassals.owner.current
			var/obj/item/card/id/id_cards = vassal_users.get_idcard(TRUE)
			if(id_cards && (id_cards.assignment in valid_jobs) && !(id_cards.assignment in counted_roles))
				//to_chat(owner, span_userdanger("PROTEGE OBJECTIVE: (GET ID)"))
				this_role = id_cards.assignment

		// NO MATCH
		if(this_role == "none")
			continue

		// SUCCESS!
		objcount++
		if(target_department == VASSALIZE_COMMAND)
			counted_roles += this_role // Add to list so we don't count it again (but only if it's a Head)

	return objcount >= target_amount
	/**
	 * # IMPORTANT NOTE!!
	 *
	 * Look for Job Values on mobs! This is assigned at the start, but COULD be changed via the HoP
	 * ALSO - Search through all jobs (look for prefs earlier that look for all jobs, and search through all jobs to see if their head matches the head listed, or it IS the head)
	 * ALSO - registered_account in _vending.dm for banks, and assigning new ones.
	 */

//////////////////////////////////////////////////////////////////////////////////////

// NOTE: Look up /steal in objective.dm for inspiration.
/// Steal hearts. You just really wanna have some hearts.
/datum/objective/bloodsucker/heartthief
	name = "heartthief"

// GENERATE!
/datum/objective/bloodsucker/heartthief/New()
	target_amount = rand(3,4)
	..()

// EXPLANATION
/datum/objective/bloodsucker/heartthief/update_explanation_text()
	. = ..()
	explanation_text = "Steal and keep [target_amount] organic heart\s."

// WIN CONDITIONS?
/datum/objective/bloodsucker/heartthief/check_completion()
	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.get_all_contents()
	var/heart_count = 0
	for(var/obj/item/organ/internal/heart/current_hearts in all_items)
		if(current_hearts.organ_flags & ORGAN_SYNTHETIC) // No robo-hearts allowed
			continue
		heart_count++

	if(heart_count >= target_amount)
		return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////////////////

///Eat blood from a lot of people
/datum/objective/bloodsucker/gourmand
	name = "gourmand"

// GENERATE!
/datum/objective/bloodsucker/gourmand/New()
	target_amount = rand(1250,2000)
	..()

// EXPLANATION
/datum/objective/bloodsucker/gourmand/update_explanation_text()
	. = ..()
	explanation_text = "Using your Feed ability, drink [target_amount] units of Blood."

// WIN CONDITIONS?
/datum/objective/bloodsucker/gourmand/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum)
		return FALSE
	var/stolen_blood = bloodsuckerdatum.total_blood_drank
	if(stolen_blood >= target_amount)
		return TRUE
	return FALSE

// HOW: Track each feed (if human). Count victory.

//////////////////////////////
// MONSTERHUNTER OBJECTIVES //
//////////////////////////////

/datum/objective/bloodsucker/monsterhunter
	name = "destroymonsters"

// EXPLANATION
/datum/objective/bloodsucker/monsterhunter/update_explanation_text()
	. = ..()
	explanation_text = "Destroy all monsters on [station_name()]."

// WIN CONDITIONS?
/datum/objective/bloodsucker/monsterhunter/check_completion()
	var/list/datum/mind/monsters = list()
	for(var/mob/living/players in GLOB.alive_mob_list)
		if(IS_HERETIC(players) || IS_BLOODSUCKER(players) || IS_CULTIST(players) || IS_WIZARD(players))
			monsters += players
		if(players?.mind?.has_antag_datum(/datum/antagonist/changeling))
			monsters += players
		if(players?.mind?.has_antag_datum(/datum/antagonist/wizard/apprentice))
			monsters += players
	for(var/datum/mind/monster_minds in monsters)
		if(monster_minds && monster_minds != owner && monster_minds.current.stat != DEAD)
			return FALSE
	return TRUE



//////////////////////////////
//     VASSAL OBJECTIVES    //
//////////////////////////////

/datum/objective/bloodsucker/vassal

// EXPLANATION
/datum/objective/bloodsucker/vassal/update_explanation_text()
	. = ..()
	explanation_text = "Guarantee the success of your Master's mission!"

// WIN CONDITIONS?
/datum/objective/bloodsucker/vassal/check_completion()
	var/datum/antagonist/vassal/antag_datum = owner.has_antag_datum(/datum/antagonist/vassal)
	return antag_datum.master?.owner?.current?.stat != DEAD



//////////////////////////////
//    REMOVED OBJECTIVES    //
//////////////////////////////

/// Defile a facility with blood
/datum/objective/bloodsucker/desecrate

	// Space_Station_13_areas.dm  <--- all the areas

//////////////////////////////////////////////////////////////////////////////////////

/// Destroy the Solar Arrays
/datum/objective/bloodsucker/solars
/* // TG Updates broke this, it needs maintaining.
// Space_Station_13_areas.dm  <--- all the areas
/datum/objective/bloodsucker/solars/update_explanation_text()
	. = ..()
	explanation_text = "Prevent all solar arrays on the station from functioning."
/datum/objective/bloodsucker/solars/check_completion()
	// Sort through all /obj/machinery/power/solar_control in the station ONLY, and check that they are functioning.
	// Make sure that lastgen is 0 or connected_panels.len is 0. Doesnt matter if it's tracking.
	for (var/obj/machinery/power/solar_control/solar_control_consoles in SSsun.solars)
		// Check On Station:
		var/turf/solar_turfs = get_turf(solar_control_consoles)
		if(!solar_turfs || !is_station_level(solar_turfs.z)) // <------ Taken from NukeOp
			//message_admins("DEBUG A: [solar_control_consoles] not on station!")
			continue // Not on station! We don't care about this.
		if(solar_control_consoles && solar_control_consoles.lastgen > 0 && solar_control_consoles.connected_panels.len > 0 && solar_control_consoles.connected_tracker)
			return FALSE
	return TRUE
*/

// NOTE: Look up /assassinate in objective.dm for inspiration.
/// Vassalize a target.
/datum/objective/bloodsucker/vassalhim
	name = "vassalhim"
	var/target_department_type = FALSE

/datum/objective/bloodsucker/vassalhim/New()
	var/list/possible_targets = return_possible_targets()
	find_target(possible_targets)
	..()

// EXPLANATION
/datum/objective/bloodsucker/vassalhim/update_explanation_text()
	. = ..()
	if(target?.current)
		explanation_text = "Ensure [target.name], the [!target_department_type ? target.assigned_role : target.special_role], is Vassalized via the Persuasion Rack."
	else
		explanation_text = "Free Objective"

/datum/objective/bloodsucker/vassalhim/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

// WIN CONDITIONS?
/datum/objective/bloodsucker/vassalhim/check_completion()
	if(!target || target.has_antag_datum(/datum/antagonist/vassal))
		return TRUE
	return FALSE

/// Enter Frenzy repeatedly
/datum/objective/bloodsucker/frenzy
	name = "frenzy"

/datum/objective/bloodsucker/frenzy/New()
	target_amount = rand(3,4)
	..()

/datum/objective/bloodsucker/frenzy/update_explanation_text()
	. = ..()
	explanation_text = "Enter Frenzy [target_amount] of times without succumbing to Final Death."

/datum/objective/bloodsucker/frenzy/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum)
		return FALSE
	if(bloodsuckerdatum.frenzies >= target_amount)
		return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////////////////

/// Mutilate a certain amount of Vassals
/*
/datum/objective/bloodsucker/vassal_mutilation
	name = "steal kindred"
/datum/objective/bloodsucker/vassal_mutilation/New()
	target_amount = rand(2,3)
	..()
// EXPLANATION
/datum/objective/bloodsucker/vassal_mutilation/update_explanation_text()
	. = ..()
	explanation_text = "Mutate [target_amount] of Vassals into vile sevant creatures."
// WIN CONDITIONS?
/datum/objective/bloodsucker/vassal_mutilation/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.vassals_mutated >= target_amount)
		return TRUE
	return FALSE
*/
