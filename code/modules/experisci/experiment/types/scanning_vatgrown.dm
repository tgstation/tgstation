/datum/experiment/scanning/random/cytology
	name = "Cytology Scanning Experiment"
	description = "Base experiment for scanning atoms that were vatgrown"
	exp_tag = "Cytology Scan"
	total_requirement = 1
	possible_types = list(/mob/living/simple_animal/hostile/cockroach)

/datum/experiment/scanning/random/cytology/final_contributing_index_checks(atom/target, typepath)
	return ..() && HAS_TRAIT(target, TRAIT_VATGROWN)

/datum/experiment/scanning/random/cytology/serialize_progress_stage(atom/target, list/seen_instances)
	return EXP_PROG_INT("Scan samples of \a vat-grown [initial(target.name)]", \
		traits & EXP_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target])
