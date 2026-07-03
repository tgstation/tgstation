/datum/experiment/scanning/points
	name = "Эксперимент по скану очков"
	description = "Базовый эксперимент для скана экспериментов, отслеживаемых по очкам."
	/// The current points gained on this experiment
	var/points = 0
	/// The total required points for this experiment
	var/required_points

/datum/experiment/scanning/points/is_complete()
	return points >= required_points

/datum/experiment/scanning/points/check_progress()
	. = EXPERIMENT_PROG_INT("Сканируйте образцы следующих объектов для набора достаточного кол-ва очков и завершения эксперимента.", points, required_points)
	var/complete = is_complete()
	var/point_val_cache = list()
	for (var/a_type in required_atoms)
		var/atom/req_atom = a_type
		if (!point_val_cache["[required_atoms[a_type]]"])
			point_val_cache["[required_atoms[a_type]]"] = list()
		point_val_cache["[required_atoms[a_type]]"] += initial(req_atom.name)

	for (var/point_amt in point_val_cache)
		var/list/types = point_val_cache[point_amt]
		var/types_joined = types.Join(", ")
		. += EXPERIMENT_PROG_DETAIL("[text2num(point_amt)] очк[declension_ru(text2num(point_amt), "о", "а", "ов")]: [types_joined]", complete)

/datum/experiment/scanning/points/experiment_requirements(datum/component/experiment_handler/experiment_handler, atom/target)
	var/destructive = traits & EXPERIMENT_TRAIT_DESTRUCTIVE
	for (var/req_atom in required_atoms)
		if (!istype(target, req_atom))
			continue

		// Try to select a required atom that this scanned atom would contribute towards
		var/selected
		if (destructive && (req_atom in scanned))
			selected = req_atom
		else if (!destructive && !(WEAKREF(target) in scanned[req_atom]))
			selected = req_atom

		// Run any additonal checks if necessary
		if (selected && final_contributing_index_checks(experiment_handler, target, selected))
			return selected

/datum/experiment/scanning/points/do_after_experiment(atom/target, typepath)
	. = ..()
	points = min(required_points, points + required_atoms[typepath])
