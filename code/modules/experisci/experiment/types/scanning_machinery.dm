///This experiment type will turn up TRUE if at least one of the stock parts in the scanned machine is of the required_tier.
///Pretend to upgrade security's techfab but in reality apply only one better matter bin!

/datum/experiment/scanning/points/machinery_tiered_scan
	name = "Upgraded Machinery Scanning Experiment"
	description = "Base experiment for scanning machinery with upgraded parts"
	exp_tag = "Scan"
	///What tier of parts is required for the experiment
	var/required_tier = 1

/datum/experiment/scanning/points/machinery_tiered_scan/check_progress()
	. = ..()
	.[1] = EXPERIMENT_PROG_INT("Scan samples of the following machines built with parts of tier [required_tier] or better.", points, required_points)[1]

/datum/experiment/scanning/points/machinery_tiered_scan/final_contributing_index_checks(atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE

	var/obj/machinery/machine = target
	for(var/obj/item/stock_parts/stock_part in machine.component_parts)
		if(stock_part.rating >= required_tier) //>= for backwards research cases when you want the discount done after you did the node
			return TRUE
	return FALSE

//This experiment type will turn up TRUE if there is a specific part in the scanned machine
/datum/experiment/scanning/points/machinery_pinpoint_scan
	name = "Machinery Pinpoint Stock Parts Scanning Experiment"
	description = "Base experiment for scanning machinery with specific parts"
	exp_tag = "Scan"
	///Which stock part are we looking for in the machine
	var/obj/item/stock_parts/required_stock_part = /obj/item/stock_parts

/datum/experiment/scanning/points/machinery_pinpoint_scan/check_progress()
	. = ..()
	.[1] = EXPERIMENT_PROG_INT("Scan samples of the following machines upgraded with \a [initial(required_stock_part.name)] to accumulate enough points to complete this experiment.", points, required_points)[1]

/datum/experiment/scanning/points/machinery_pinpoint_scan/final_contributing_index_checks(atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE

	var/obj/machinery/machine = target
	for(var/obj/stock_part in machine.component_parts)
		if(istype(stock_part, required_stock_part))
			return TRUE
	return FALSE
