/datum/experiment/scanning/random/cytology
	name = "Cytology Scanning Experiment"
	description = "Base experiment for scanning atoms that were vatgrown"
	exp_tag = "Cytology Scan"
	total_requirement = 1
	possible_types = list(/mob/living/simple_animal/hostile/cockroach)

/datum/experiment/scanning/random/cytology/get_contributing_index(atom/target)
	. = ..()
	if(.)
		if(!HAS_TRAIT(target, TRAIT_VATGROWN))
			return null

/datum/experiment/scanning/random/cytology/serialize_progress_stage(atom/target, list/seen_instances)
	return list(
		EXP_INT_STAGE,
		"Scan samples of \a vat-grown [initial(target.name)]",
		seen_instances ? seen_instances.len : 0,
		required_atoms[target]
	)
