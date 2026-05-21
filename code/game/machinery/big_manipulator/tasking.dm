/datum/tasking_strategy
	var/current_index = 1

/// Returns the next task to run, or null if nothing is available.
/datum/tasking_strategy/proc/get_next_task(list/tasks)
	return null

/// Picks a next candidate from a list of eligible atoms.
/datum/tasking_strategy/proc/get_next_candidate(list/candidates)
	if(!length(candidates))
		return null
	return candidates[1]

// Moves through the list, skipping tasks that can't run.
/datum/tasking_strategy/sequential

/datum/tasking_strategy/sequential/get_next_task(list/tasks, obj/machinery/big_manipulator/manipulator)
	if(!length(tasks))
		return null
	if(current_index < 1 || current_index > length(tasks))
		current_index = 1
	var/start = current_index
	while(TRUE)
		var/datum/manipulator_task/task = tasks[current_index]
		current_index++
		if(current_index > length(tasks))
			current_index = 1
		if(task.can_run(manipulator))
			return task
		if(current_index == start)
			return null

/datum/tasking_strategy/sequential/get_next_candidate(list/candidates)
	if(!length(candidates))
		return null
	if(current_index < 1 || current_index > length(candidates))
		current_index = 1
	var/candidate = candidates[current_index]
	current_index++
	if(current_index > length(candidates))
		current_index = 1
	return candidate

// Stays on the current task until it can run.
/datum/tasking_strategy/strict

/datum/tasking_strategy/strict/get_next_task(list/tasks, obj/machinery/big_manipulator/manipulator)
	if(!length(tasks))
		return null
	if(current_index < 1 || current_index > length(tasks))
		current_index = 1
	var/datum/manipulator_task/task = tasks[current_index]
	if(!task.can_run(manipulator))
		return null
	current_index++
	if(current_index > length(tasks))
		current_index = 1
	return task

/datum/tasking_strategy/strict/get_next_candidate(list/candidates)
	if(!length(candidates))
		return null
	if(current_index < 1 || current_index > length(candidates))
		current_index = 1
	var/candidate = candidates[current_index]
	current_index++
	if(current_index > length(candidates))
		current_index = 1
	return candidate
