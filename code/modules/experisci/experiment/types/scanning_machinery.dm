///This experiment type will turn up TRUE if at least one of the stock parts in the scanned machine is of the required_tier.
///Pretend to upgrade security's techfab but in reality apply only one better matter bin!
///Note that a stock part in a machine can either be an object, or a datum.
/datum/experiment/scanning/points/machinery_tiered_scan
	name = "Upgraded Machinery Scanning Experiment"
	description = "Base experiment for scanning machinery with upgraded parts"
	exp_tag = "Scan"
	///What tier of parts is required for the experiment
	var/required_tier = 1

/datum/experiment/scanning/points/machinery_tiered_scan/check_progress()
	. = ..()
	.[1] = EXPERIMENT_PROG_INT("Scan samples of the following machines built with parts of tier [required_tier] or better.", points, required_points)[1]

/datum/experiment/scanning/points/machinery_tiered_scan/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE

	var/obj/machinery/machine = target
	//check for the required tier in the machine's stock parts as items
	for(var/obj/item/stock_parts/stock_part in machine.component_parts)
		if(stock_part.rating >= required_tier) //>= for backwards research cases when you want the discount done after you did the node
			return TRUE
	//check for the required tier in the machine's stock parts as datums
	for(var/datum/stock_part/datum_stock_part in machine.component_parts)
		if(datum_stock_part.tier >= required_tier)
			return TRUE
	experiment_handler.announce_message("Scanned machine is missing high enough quality parts. Expecting tier [required_tier] parts or better.")
	return FALSE

//This experiment type will turn up TRUE if there is a specific part in the scanned machine
/datum/experiment/scanning/points/machinery_pinpoint_scan
	name = "Machinery Pinpoint Stock Parts Scanning Experiment"
	description = "Base experiment for scanning machinery with specific parts"
	exp_tag = "Scan"
	///Which stock part are we looking for in the machine.
	///We use obj instead of datum here, as some stock parts aren't datumised, and in datumised ones
	///we can just look for the physical_object_reference to match up the requirement.
	var/obj/item/stock_parts/required_stock_part = /obj/item/stock_parts

/datum/experiment/scanning/points/machinery_pinpoint_scan/check_progress()
	. = ..()
	.[1] = EXPERIMENT_PROG_INT("Scan samples of the following machines upgraded with \a [initial(required_stock_part.name)] to accumulate enough points to complete this experiment.", points, required_points)[1]

/datum/experiment/scanning/points/machinery_pinpoint_scan/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE

	var/obj/machinery/machine = target
	//check for the required stock part as an item in the machine
	for(var/obj/stock_part in machine.component_parts)
		if(istype(stock_part, required_stock_part))
			return TRUE
	//check for the required stock part as a datum in the machine
	for(var/datum/stock_part/datum_stock_part in machine.component_parts)
		if(istype(datum_stock_part.physical_object_reference, required_stock_part))
			return TRUE
	experiment_handler.announce_message("Scanned machine is missing an exact quality part. Expecting tier [required_stock_part.name] part.")
	return FALSE
