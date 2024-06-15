/datum/experiment/scanning/reagent
	name = "Reagent Scan"
	description = "We need to a sample of a reagent with high purity."
	exp_tag = "Reagent Scan"
	allowed_experimentors = list(/obj/item/experi_scanner, /obj/item/scanner_wand)
	required_atoms = list(/obj/item/reagent_containers = 1)
	var/target_reagent = /datum/reagent/water
	var/min_purity = 0.95

/datum/experiment/scanning/reagent/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE
	if(!is_reagent_container(target))
		return FALSE
	return is_valid_scan_target(target)

/datum/experiment/scanning/reagent/proc/is_valid_scan_target(obj/item/reagent_containers/container)
	SHOULD_CALL_PARENT(TRUE)
	if (container.reagents.total_volume == 0)
		container.balloon_alert(usr, "container empty!")
		return FALSE
	var/datum/reagent/master_reagent = container.reagents.get_master_reagent()
	if (master_reagent.type != target_reagent)
		container.balloon_alert(usr, "reagent not found!")
		return FALSE
	if (master_reagent.purity < min_purity)
		container.balloon_alert(usr, "purity too low!")
		return FALSE
	return TRUE

/datum/experiment/scanning/reagent/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan a reagent container with [initial(target_reagent).name] of at least [min_purity] purity.", \
		seen_instances.len, required_atoms[target])


