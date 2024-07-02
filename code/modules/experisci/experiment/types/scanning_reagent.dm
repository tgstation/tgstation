/// An experiment where you scan a container with a specified reagent of certain purity
/datum/experiment/scanning/reagent
	exp_tag = "Reagent Scan"
	allowed_experimentors = list(/obj/item/experi_scanner, /obj/item/scanner_wand)
	required_atoms = list(/obj/item/reagent_containers = 1)
	/// The reagent required to present in the scanned container
	var/datum/reagent/required_reagent = /datum/reagent/water
	/// The minimum required purity of required_reagent
	var/min_purity = 0

/datum/experiment/scanning/reagent/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE
	if(!is_reagent_container(target))
		return FALSE
	return is_valid_scan_target(experiment_handler, target)

/datum/experiment/scanning/reagent/proc/is_valid_scan_target(datum/component/experiment_handler/experiment_handler, obj/item/reagent_containers/container)
	SHOULD_CALL_PARENT(TRUE)
	if (container.reagents.total_volume == 0)
		experiment_handler.announce_message("Container empty!")
		return FALSE
	var/datum/reagent/master_reagent = container.reagents.get_master_reagent()
	if (master_reagent.type != required_reagent)
		experiment_handler.announce_message("Reagent not found!")
		return FALSE
	if (master_reagent.purity < min_purity)
		experiment_handler.announce_message("Purity too low!")
		return FALSE
	return TRUE

/datum/experiment/scanning/reagent/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan a reagent container with [required_reagent::name] of at least [PERCENT(min_purity)]% purity.", \
		seen_instances.len, required_atoms[target])
