/datum/experiment/scanning/points
	name = "Point Scanning Experiment"
	description = "Base experiment for scanning experiments tracked by points"
	/// The current points gained on this experiment
	VAR_FINAL/points = 0
	/// The total required points for this experiment
	var/required_points = -1

/datum/experiment/scanning/points/is_complete()
	return points >= required_points

/datum/experiment/scanning/points/check_progress()
	. = EXPERIMENT_PROG_INT("Scan samples of the following objects to accumulate enough points to complete this experiment.", points, required_points)
	. += possible_progress_as_list(required_atoms)

/// Takes an asociated list of types or ids to values and returns a list of "prog details" to append to check progress.
/datum/experiment/scanning/points/proc/possible_progress_as_list(list/progress_list)
	. = list()
	var/complete = is_complete()
	var/point_val_cache = list()
	for (var/prog_type in progress_list)
		var/prog_key = "[progress_list[prog_type]]"
		if (!point_val_cache[prog_key])
			point_val_cache[prog_key] = list()

		point_val_cache[prog_key] += format_item_as_name(prog_type)

	for (var/point_amt in point_val_cache)
		var/list/types = point_val_cache[point_amt]
		var/types_joined = types.Join(", ")
		. += EXPERIMENT_PROG_DETAIL("[text2num(point_amt)] point\s: [types_joined]", complete)

/// Used to format the "progress item" into name form, usually it's a typepath
/datum/experiment/scanning/points/proc/format_item_as_name(atom/prog_type)
	return initial(prog_type.name)

/datum/experiment/scanning/points/get_contributing_index(atom/target)
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
		if (selected && final_contributing_index_checks(target, selected))
			return selected

/datum/experiment/scanning/points/do_after_experiment(atom/target, typepath)
	. = ..()
	points = min(required_points, points + required_atoms[typepath])
