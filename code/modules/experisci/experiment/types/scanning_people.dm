/// An experiment where you scan your fellow humans
/datum/experiment/scanning/people
	allowed_experimentors = list(/obj/item/experi_scanner, /obj/item/scanner_wand)
	/// Number of people you need to scan
	var/required_count = 2
	/// Does the scanned target need to have a mind?
	var/mind_required = FALSE
	/// How do we describe the people you need to scan?
	var/required_traits_desc = ""

/datum/experiment/scanning/people/New()
	required_atoms = list(/mob/living/carbon/human = required_count)
	return ..()

/datum/experiment/scanning/people/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return FALSE
	return is_valid_scan_target(target, experiment_handler)

/// Checks that the passed mob is valid human to scan
/datum/experiment/scanning/people/proc/is_valid_scan_target(mob/living/carbon/human/check, datum/component/experiment_handler/experiment_handler)
	SHOULD_CALL_PARENT(TRUE)
	if(!mind_required || !isnull(check.mind))
		return TRUE
	if(isliving(usr))
		experiment_handler.announce_message("Subject is mindless!")
	return FALSE

/datum/experiment/scanning/people/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan unique individuals with [required_traits_desc].", \
		seen_instances.len, required_atoms[target])
