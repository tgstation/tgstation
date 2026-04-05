// Handles indexing for the tasking strategy used for the manipulator's point iteraction
/datum/tasking_strategy
	var/current_index = 1

/// Get the next available point for this tasking strategy
/datum/tasking_strategy/proc/get_next_available(list/points, atom/movable/target, transfer_type, availability_check)
	return null

// Prefers the first point avaliable
/datum/tasking_strategy/prefer_first

/datum/tasking_strategy/prefer_first/get_next_available(list/points, atom/movable/target, transfer_type, datum/callback/availability_check)
	if(!length(points))
		return null

	for(var/datum/interaction_point/point in points)
		if(availability_check.Invoke(point, target, transfer_type))
			return point

	return null

/datum/tasking_strategy/round_robin

/datum/tasking_strategy/round_robin/get_next_available(list/points, atom/movable/target, transfer_type, datum/callback/availability_check)
	if(!length(points))
		return null

	if(current_index < 1 || current_index > length(points))
		current_index = 1

	var/starting_index = current_index

	while(TRUE)
		var/datum/interaction_point/point = points[current_index]

		if(point && availability_check.Invoke(point, target, transfer_type))
			advance_index(length(points))
			return point

		advance_index(length(points))

		if(current_index == starting_index)
			break

	return null

/// Advances the index of the last point the manipulator interacted with to properly iterate in the correct order
/datum/tasking_strategy/round_robin/proc/advance_index(list_length)
	current_index++
	if(current_index > list_length)
		current_index = 1

/datum/tasking_strategy/strict_robin

/datum/tasking_strategy/strict_robin/get_next_available(list/points, atom/movable/target, transfer_type, datum/callback/availability_check)
	if(!length(points))
		return null

	if(current_index < 1 || current_index > length(points))
		current_index = 1

	var/datum/interaction_point/point = points[current_index]

	if(point && availability_check.Invoke(point, target, transfer_type))
		current_index++
		if(current_index > length(points))
			current_index = 1
		return point

	return null

/// Picks a next candidate to run the checks for
/datum/tasking_strategy/proc/get_next_candidate(list/candidates)
	if(!length(candidates))
		return null
	return candidates[1]

/datum/tasking_strategy/prefer_first/get_next_candidate(list/candidates)
	if(!length(candidates))
		return null
	return candidates[1]

/datum/tasking_strategy/round_robin/get_next_candidate(list/candidates)
	if(!length(candidates))
		return null

	if(current_index < 1 || current_index > length(candidates))
		current_index = 1

	var/candidate = candidates[current_index]
	current_index++
	if(current_index > length(candidates))
		current_index = 1

	return candidate

/datum/tasking_strategy/strict_robin/get_next_candidate(list/candidates)
	if(!length(candidates))
		return null

	if(current_index < 1 || current_index > length(candidates))
		current_index = 1

	var/candidate = candidates[current_index]
	current_index++
	if(current_index > length(candidates))
		current_index = 1

	return candidate
