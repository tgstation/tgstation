///This experiment type will turn up TRUE if at least one of the stock parts in the scanned machine is of the required_tier.
///Pretend to upgrade security's techfab but in reality apply only one better matter bin!

/datum/experiment/scanning/machinery_tiered_scan
	name = "Upgraded Machinery Scanning Experiment"
	description = "Base experiment for scanning machinery with upgraded parts"
	exp_tag = "Scan"
	///What tier of parts is required for the experiment
	var/required_tier = 1

/datum/experiment/scanning/machinery_tiered_scan/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan a [initial(target.name)] built with tier [required_tier] parts.", \
		traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target])

/datum/experiment/scanning/machinery_tiered_scan/final_contributing_index_checks(atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE

	var/obj/machinery/machine = target
	for(var/obj/item/stock_parts/stock_part in machine.component_parts)
		if(stock_part.rating == required_tier)
			return TRUE
	return FALSE

//This experiment type will turn up TRUE if there is a specific part in the scanned machine
/datum/experiment/scanning/machinery_pinpoint_scan
	name = "Machinery Pinpoint Stock Parts Scanning Experiment"
	description = "Base experiment for scanning machinery with specific parts"
	exp_tag = "Scan"
	///Which stock part are we looking for in the machine
	var/required_stock_part = /obj/item/stock_parts

/datum/experiment/scanning/machinery_pinpoint_scan/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan \a [initial(target.name)] built with \a [required_stock_part].", \
		traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target]) //make this show the actual name of the part goddamnit

/datum/experiment/scanning/machinery_pinpoint_scan/final_contributing_index_checks(atom/target, typepath)
	.=..()
	if(!.)
		return FALSE

	var/obj/machinery/machine = target
	for(var/obj/stock_part in machine.component_parts)
		if(istype(stock_part, required_stock_part))
			return TRUE
	return FALSE
