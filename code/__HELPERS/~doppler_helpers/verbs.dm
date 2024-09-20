/** Get all hearers in range, ignores walls and such. Code stolen from `/proc/get_hearers_in_view()`
 * Much faster and less expensive than range()
*/
/proc/get_hearers_in_looc_range(atom/source, range_radius = LOOC_RANGE)
	var/turf/center_turf = get_turf(source)
	if(!center_turf)
		return

	. = list()
	var/old_luminosity = center_turf.luminosity
	if(range_radius <= 0) //special case for if only source cares
		for(var/atom/movable/target as anything in center_turf)
			var/list/recursive_contents = target.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]
			if(recursive_contents)
				. += recursive_contents
		return .

	var/list/hearables_from_grid = SSspatial_grid.orthogonal_range_search(source, RECURSIVE_CONTENTS_HEARING_SENSITIVE, range_radius)

	if(!length(hearables_from_grid))//we know that something is returned by the grid, but we dont know if we need to actually filter down the output
		return .

	var/list/assigned_oranges_ears = SSspatial_grid.assign_oranges_ears(hearables_from_grid)

	for(var/mob/oranges_ear/ear in range(range_radius, center_turf))
		. += ear.references

	for(var/mob/oranges_ear/remaining_ear as anything in assigned_oranges_ears) //we need to clean up our mess
		remaining_ear.unassign()

	center_turf.luminosity = old_luminosity
	return .
