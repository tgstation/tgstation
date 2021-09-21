/datum/experiment/scanning/machinery
	name = "Machinery Scanning Experiment"
	description = "Base experiment for scanning machinery with upgraded parts"
	exp_tag = "Scan"
	///What tier of parts is required for the experiment
	var/required_tier = 1

/datum/experiment/scanning/machinery/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan a [initial(target.name)] built with tier [required_tier] parts.", \
		traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target])

/datum/experiment/scanning/machinery/final_contributing_index_checks(atom/target, typepath)
	.=..()
	if(!.)
		return

	var/obj/machinery/machine = target
	for(var/obj/item/stock_parts/stock_part in machine.component_parts)
		if((stock_part.rating == required_tier))
			return ..() && TRUE
