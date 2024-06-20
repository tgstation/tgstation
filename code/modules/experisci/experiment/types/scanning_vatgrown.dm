/datum/experiment/scanning/random/cytology
	name = "Cytology Scanning Experiment"
	description = "Base experiment for scanning atoms that were vatgrown"
	exp_tag = "Cytology Scan"
	total_requirement = 1
	possible_types = list(/mob/living/basic/slime)
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE

/datum/experiment/scanning/random/cytology/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	return ..() && HAS_TRAIT(target, TRAIT_VATGROWN)

/datum/experiment/scanning/random/cytology/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan samples of \a vat-grown [initial(target.name)]", \
		traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target])
