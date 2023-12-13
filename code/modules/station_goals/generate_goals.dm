/// Creates the initial station goals.
/proc/generate_station_goals(goal_budget)
	var/list/possible = subtypesof(/datum/station_goal)
	// Remove all goals that require space if space is not present
	if(SSmapping.is_planetary())
		for(var/datum/station_goal/goal as anything in possible)
			if(initial(goal.requires_space))
				possible -= goal
	var/goal_weights = 0
	while(possible.len && goal_weights < goal_budget)
		var/datum/station_goal/picked = pick_n_take(possible)
		goal_weights += initial(picked.weight)
		GLOB.station_goals += new picked
