/**
 * ## People scanning experiments
 *
 * Scan members of the crew for research and profit.
 */
/datum/experiment/scanning/points/people
	name = "Crewmember Scanning Experiment"
	exp_tag = "Scan"
	// It'd be fun if the emagged Destructive Scanner could contribute to this but maybe later
	required_atoms = list(/mob/living/carbon/human = 1)

	/**
	 * Does this experiment require you scan someone with a mind?
	 *
	 * By default these explicity require you scan mobs with minds rather than scanning monkeys / hu-monkeys.
	 * This is intended so that scientists may go out and engage more with the crew,
	 * or so that medical doctors can do some scans for science while in downtime by scanning patients.
	 * Possibly also opens up some antag shenanigans ("Hey, wanna get your leg broken so I can scan you? It's for science!")
	 */
	var/mind_required = TRUE

/datum/experiment/scanning/points/people/check_progress()
	return EXPERIMENT_PROG_INT("Scan members of the crew. The same crewmember cannot be scanned twice.", points, required_points)

/datum/experiment/scanning/points/people/final_contributing_index_checks(atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return FALSE

	return is_valid_scan_target(target)

/// Checks that the passed mob is a valid human to scan
/datum/experiment/scanning/points/people/proc/is_valid_scan_target(mob/living/carbon/human/check)
	SHOULD_CALL_PARENT(TRUE)

	if(!mind_required || !isnull(check.mind))
		return TRUE

	if(isliving(usr))
		// cringe usr use I know, but this deserves an alert to let people know why this guy isn't cutting it
		check.balloon_alert(usr, "subject is mindless!")
	return FALSE

/// A people scanning experiment that require you scan certain species IDs
/datum/experiment/scanning/points/people/species
	name = "Crewmember Species Scanning Experiment"
	/// Assoc list of [species ids] to [points awarded for scanning them]
	var/list/required_species_ids = list()
	/// If FALSE, we can scan multiple of the same species (but not the same mob)
	var/dupes_banned = FALSE
	/// Easy tracking of all species ids alerady scanned
	var/list/scanned_species_ids

/datum/experiment/scanning/points/people/species/is_valid_scan_target(mob/living/carbon/human/check)
	. = ..()
	if(!.)
		return FALSE

	var/scanned_id = check.dna?.species?.id
	if(isnull(scanned_id))
		return FALSE
	if(dupes_banned && (scanned_id in scanned_species_ids))
		if(isliving(usr))
			check.balloon_alert(usr, "species already scanned!")
		return FALSE

	return !!required_species_ids[scanned_id]

/datum/experiment/scanning/points/people/species/format_item_as_name(prog_type)
	return capitalize(prog_type)

/datum/experiment/scanning/points/people/species/check_progress()
	. = EXPERIMENT_PROG_INT("Scan members of the crew of a [length(required_species_ids) > 1 ? "variety of " : ""]species. \
		The same crewmember[dupes_banned ? " or species " : ""]cannot be scanned twice.", points, required_points)
	. += possible_progress_as_list(required_species_ids)

/datum/experiment/scanning/points/people/species/do_after_experiment(mob/living/carbon/human/target, typepath)
	var/scanned_id = target.dna.species.id
	points = min(required_points, points + required_species_ids[scanned_id])
	LAZYADD(scanned_species_ids, scanned_id)

/// A people scanning experiment that require you scan people with wounds
/datum/experiment/scanning/points/people/wounds
	name = "Crewmember Wound Scanning Experiment"
	/**
	 * Assoc list of [wound typepaths] to [points awarded for the wound]
	 *
	 * 1 mob can have multiple wounds, which rewards multiple points
	 */
	var/list/required_wound_types = list()

/datum/experiment/scanning/points/people/wounds/is_valid_scan_target(mob/living/carbon/human/check)
	. = ..()
	if(!.)
		return FALSE
	for(var/datum/wound/wound as anything in check.all_wounds)
		if(required_wound_types[wound.type])
			return TRUE
	return FALSE

/datum/experiment/scanning/points/people/wounds/format_item_as_name(datum/wound/prog_type)
	return initial(prog_type.name)

/datum/experiment/scanning/points/people/wounds/do_after_experiment(mob/living/carbon/human/target, typepath)
	for(var/datum/wound/wound as anything in target.all_wounds)
		points += (required_wound_types[wound.type] || 0)

	points = min(points, required_points)

/datum/experiment/scanning/points/people/wounds/check_progress()
	. = EXPERIMENT_PROG_INT("Scan crewmembers sustaining wounds. Multiple wounds on one patient will \
		all count towards progress, but the same crewmember cannot be scanned twice.", points, required_points)
	. += possible_progress_as_list(required_wound_types)

/// A people scanning experiment that require you scan certain mutations in people
/datum/experiment/scanning/points/people/mutations
	name = "Crewmember Mutation Scanning Experiment"
	// Does not require crewmember scanning, as geneticists more often than not test on monkeys
	// and it'd be confusing as to why their prime test subject does not contribute to the experimetn
	mind_required = FALSE
	/**
	 * Assoc list of [mutation typepaths] to [points awarded for the mutation]
	 *
	 * 1 mob can have multiple mutations, which awards multiple points
	 */
	var/list/required_mutation_types = list()

/datum/experiment/scanning/points/people/mutations/is_valid_scan_target(mob/living/carbon/human/check)
	. = ..()
	if(!.)
		return FALSE
	for(var/datum/mutation/mutation as anything in check.dna?.mutations)
		if(required_mutation_types[mutation.type])
			return TRUE
	return FALSE

/datum/experiment/scanning/points/people/mutations/format_item_as_name(datum/mutation/human/prog_type)
	return initial(prog_type.name)

/datum/experiment/scanning/points/people/mutations/do_after_experiment(mob/living/carbon/human/target, typepath)
	for(var/datum/mutation/mutation as anything in target.dna.mutations)
		points += (required_mutation_types[mutation.type] || 0)

	points = min(points, required_points)

/datum/experiment/scanning/points/people/mutations/check_progress()
	. = EXPERIMENT_PROG_INT("Scan subjects with the following mutations. Multiple mutations in one subject will \
		all count towards progress, but the same subject cannot be scanned twice.", points, required_points)
	. += possible_progress_as_list(required_mutation_types)

/// A people scanning experiment that require you scan people for organs or bodyparts (or both)
/datum/experiment/scanning/points/people/organs_or_bodyparts
	name = "Crewmember Body Scanning Experiment"
	/**
	 * Assoc list of [organ OR bodypart typepaths] to [points awarded for having it]
	 *
	 * 1 mob can have multiple of them, which awards multiple points
	 */
	var/list/required_organ_or_bodypart_type = list()
	/// Autogenerated "what are we scanning" from our required organ / bodypart list
	VAR_FINAL/scan_what = ""

/datum/experiment/scanning/points/people/organs_or_bodyparts/New()
	. = ..()

	var/has_organs = TRUE
	var/has_limbs = TRUE
	for(var/typepath in required_organ_or_bodypart_type)
		if(ispath(typepath, /obj/item/organ))
			has_organs = TRUE
		if(ispath(typepath, /obj/item/bodypart))
			has_limbs = TRUE
		if(has_organs && has_limbs)
			break

	if(has_organs && has_limbs)
		scan_what = "organs or limbs"
	else if(has_organs)
		scan_what = "organs"
	else if(has_limbs)
		scan_what = "limbs"
	else
		scan_what = "??? (Report this please)"

/datum/experiment/scanning/points/people/organs_or_bodyparts/is_valid_scan_target(mob/living/carbon/human/check)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/bodypart/limb as anything in check.bodyparts)
		if(required_organ_or_bodypart_type[limb.type])
			return TRUE
	for(var/obj/item/organ/organ as anything in check.internal_organs)
		if(required_organ_or_bodypart_type[organ.type])
			return TRUE
	return FALSE

/datum/experiment/scanning/points/people/organs_or_bodyparts/do_after_experiment(mob/living/carbon/human/target, typepath)
	for(var/obj/item/bodypart/limb as anything in target.bodyparts)
		points += (required_organ_or_bodypart_type[limb.type] || 0)
	for(var/obj/item/organ/organ as anything in target.internal_organs)
		points += (required_organ_or_bodypart_type[organ.type] || 0)

	points = min(points, required_points)

/datum/experiment/scanning/points/people/organs_or_bodyparts/check_progress()
	. = EXPERIMENT_PROG_INT("Scan crewmembers with the following [scan_what]. Multiple [scan_what] in the same crewmember \
		all count towards progress, but the same crewmember cannot be scanned twice.", points, required_points)
	. += possible_progress_as_list(required_organ_or_bodypart_type)

/// A people scanning experiment that require you find certain brain traumas
/datum/experiment/scanning/points/people/brain_traumas
	name = "Crewmember Trauma Scanning Experiment"
	/**
	 * Assoc list of [trauma typepaths] to [points awarded for having it]
	 */
	var/list/required_trauma_type = list()
	/// Required severity of trauma needed
	var/required_severity = TRAUMA_RESILIENCE_BASIC

/datum/experiment/scanning/points/people/brain_traumas/is_valid_scan_target(mob/living/carbon/human/check)
	. = ..()
	if(!.)
		return FALSE

	for(var/datum/brain_trauma/trauma as anything in check.get_traumas())
		if(trauma.resilience >= required_severity && required_trauma_type[trauma.type])
			return TRUE
	return FALSE

/datum/experiment/scanning/points/people/brain_traumas/format_item_as_name(datum/brain_trauma/prog_type)
	return "[RESILIENCE_TO_ADJECTIVE[required_severity]][initial(prog_type.name)]"

/datum/experiment/scanning/points/people/brain_traumas/do_after_experiment(mob/living/carbon/human/target, typepath)
	for(var/datum/brain_trauma/trauma as anything in target.get_traumas())
		if(trauma.resilience < required_severity)
			continue
		var/reward = required_trauma_type[trauma.type] || 0
		if(!reward)
			continue
		points = min(points + reward, required_points)
		return

/datum/experiment/scanning/points/people/brain_traumas/check_progress()
	. = EXPERIMENT_PROG_INT("Scan crewmembers sustaining the following brain traumas. The same crewmember cannot be scanned twice.", points, required_points)
	. += possible_progress_as_list(required_trauma_type)
