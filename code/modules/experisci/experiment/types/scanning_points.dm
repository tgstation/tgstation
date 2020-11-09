/datum/experiment/scanning/points
	name = "Point Scanning Experiment"
	description = "Base experiment for scanning experiments tracked by points"
	/// The current points gained on this experiment
	var/points = 0
	/// The total required points for this experiment
	var/required_points

/datum/experiment/scanning/points/is_complete()
	return points >= required_points

/datum/experiment/scanning/points/check_progress()
	. = EXP_PROG_INT("Scan samples of the following objects to accumulate enough points to complete this experiment.", points, required_points)
	var/complete = is_complete()
	var/point_val_cache = list()
	for (var/a_type in required_atoms)
		var/atom/a = a_type
		if (!point_val_cache["[required_atoms[a_type]]"])
			point_val_cache["[required_atoms[a_type]]"] = list()
		point_val_cache["[required_atoms[a_type]]"] += initial(a.name)

	for (var/point_amt in point_val_cache)
		var/list/types = point_val_cache[point_amt]
		var/types_joined = types.Join(", ")
		. += EXP_PROG_DETAIL("[text2num(point_amt)] point\s: [types_joined]", complete)

/datum/experiment/scanning/points/get_contributing_index(atom/target)
	var/destructive = traits & EXP_TRAIT_DESTRUCTIVE
	for (var/a in required_atoms)
		if (!istype(target, a))
			continue

		// Try to select a required atom that this scanned atom would contribute towards
		var/selected
		if (destructive && (a in scanned))
			selected = a
		else if (!destructive && !(target in scanned[a]))
			selected = a

		// Run any additonal checks if necessary
		if (selected && final_contributing_index_checks(target, selected))
			return selected

/datum/experiment/scanning/points/do_after_experiment(atom/target, typepath)
	. = ..()
	points = min(required_points, points + required_atoms[typepath])
