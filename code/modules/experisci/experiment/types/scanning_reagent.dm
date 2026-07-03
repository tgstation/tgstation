/// An experiment where you scan a container with a specified reagent of certain purity
/datum/experiment/scanning/reagent
	exp_tag = "Сканирование реагента"
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
		experiment_handler.announce_message("Контейнер пуст!")
		return FALSE
	var/datum/reagent/master_reagent = container.reagents.get_master_reagent()
	if (master_reagent.type != required_reagent)
		experiment_handler.announce_message("Реагент не обнаружен!")
		return FALSE
	if (master_reagent.purity < min_purity)
		experiment_handler.announce_message("Слишком низкая чистота!")
		return FALSE
	return TRUE

/datum/experiment/scanning/reagent/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Просканируйте контейнер с реагентом [required_reagent::name] с чистотой не менее [PERCENT(min_purity)]%.", \
		seen_instances.len, required_atoms[target])
