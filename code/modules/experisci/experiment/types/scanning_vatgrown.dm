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

/datum/experiment/scanning/random/cytology/check_progress()
	var/list/status = list()
	for (var/a_type in required_atoms)
		var/atom/a = a_type
		var/list/seen = scanned[a]
		var/remaining = required_atoms[a] - (seen ? seen.len : 0)
		if (remaining)
			status += " - Scan [remaining] more vat-grown [initial(a.name)][remaining > 1 ? "s" : ""]"
	return "The following things must be scanned:\n" + jointext(status, ", \n")
