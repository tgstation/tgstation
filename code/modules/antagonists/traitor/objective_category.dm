/// The traitor category handler. This is where the probability of all objectives are managed.
/datum/traitor_category_handler
	var/list/datum/traitor_objective_category/all_categories = list()

/datum/traitor_category_handler/New()
	. = ..()
	for(var/type in subtypesof(/datum/traitor_objective_category))
		var/datum/traitor_objective_category/category = new type()
		if(length(category.objectives))
			all_categories += category
		else
			// Category should just get autoGC'd here if they don't have any length, this may not be necessary
			qdel(category)

/datum/traitor_category_handler/proc/objective_valid(datum/traitor_objective/objective_path, progression_points)
	if(initial(objective_path.abstract_type) == objective_path)
		return FALSE
	if(progression_points < initial(objective_path.progression_minimum))
		return FALSE
	if(progression_points > initial(objective_path.progression_maximum))
		return FALSE
	return TRUE

/datum/traitor_category_handler/proc/get_possible_objectives(progression_points)
	var/list/valid_objectives = list()
	for(var/datum/traitor_objective_category/category as anything in all_categories)
		var/list/category_list = list()
		for(var/value in category.objectives)
			if(islist(value))
				var/list/objective_category = filter_invalid_objective_list(value, progression_points)
				if(!length(objective_category))
					continue
				category_list[objective_category] = category.objectives[value]
			else
				if(!objective_valid(value, progression_points))
					continue
				category_list[value] = category.objectives[value]
		if(!length(category_list))
			continue
		valid_objectives[category_list] = category.weight

	return valid_objectives

/datum/traitor_category_handler/proc/filter_invalid_objective_list(list/objectives, progression_points)
	var/list/filtered_objectives = list()
	for(var/value in objectives)
		if(islist(value))
			var/list/result = filter_invalid_objective_list(value, progression_points)
			if(!length(result))
				continue
			filtered_objectives[value] = objectives[value]
		else
			if(!objective_valid(value, progression_points))
				continue
			filtered_objectives[value] = objectives[value]
	return filtered_objectives

/// The objective category.
/// Used to group up entire objectives into 1 weight objects to prevent having a
/// higher chance of getting an objective due to an increased number of different objective subtypes.
/// These are nothing but informational holders and will have no other purpose.
/datum/traitor_objective_category
	/// Name of the category, unused but may help in the future
	var/name = "generic category"
	/// Assoc list of objectives by type mapped to their weight. Can also contain lists of objectives mapped to weight
	var/list/objectives = list()
	/// The weight of the category. How likely this category is to be chosen.
	var/weight = OBJECTIVE_WEIGHT_DEFAULT
