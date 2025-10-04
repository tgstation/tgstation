PROCESSING_SUBSYSTEM_DEF(personalities)
	name = "Personalities"
	runlevels = RUNLEVEL_GAME
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	wait = 3 SECONDS

	/// All personality singletons indexed by their type
	VAR_FINAL/list/datum/personality/personalities_by_type
	/// All personality singletons indexed by their savefile key
	VAR_FINAL/list/datum/personality/personalities_by_key
	/// Assoc list of personality group to list of personality typepaths in that group
	VAR_FINAL/list/incompatibilities_by_group
	/// For personalities which process, this tracks all mobs we need to process for
	VAR_FINAL/list/processing_personalities

/datum/controller/subsystem/processing/personalities/Initialize()
	init_personalities()
	return SS_INIT_SUCCESS

/// Initialized personality singletons
/datum/controller/subsystem/processing/personalities/proc/init_personalities()
	if(length(personalities_by_type))
		return // Already initialized

	personalities_by_type = list()
	personalities_by_key = list()
	incompatibilities_by_group = list()
	processing_personalities = list()
	for(var/datum/personality/personality_type as anything in subtypesof(/datum/personality))
		var/personality_key = personality_type::savefile_key
		if(isnull(personality_key))
			// Abstract personality, ignore
			continue
		if(personalities_by_key[personality_key])
			stack_trace("Personality save key collision! \
				key: [personality_key] - \
				new: [personality_type::name] - \
				old: [personalities_by_key[personality_key].name]")
			continue

		var/datum/personality/personality = new personality_type()
		personalities_by_type[personality_type] = personality
		personalities_by_key[personality.savefile_key] = personality
		for(var/group in personality.groups)
			incompatibilities_by_group[group] ||= list()
			incompatibilities_by_group[group] += personality_type

/// Helper to check if the new personality type is incompatible with the passed list of personality types
/datum/controller/subsystem/processing/personalities/proc/is_incompatible(list/personality_types, new_personality_type)
	if(!length(incompatibilities_by_group))
		stack_trace("Checking personality incompatibilities before the incompatibility list was initialized?")
		return FALSE
	if(length(personality_types))
		// No incompatibilities possible with no personalities
		return FALSE
	var/datum/personality/new_personality = personalities_by_type[new_personality_type]
	if(!length(new_personality.groups))
		// No groups, so no incompatibilities
		return FALSE

	// Filters all incompatibily groups against the new personality's groups
	for(var/group, incompatibility_list in incompatibilities_by_group & new_personality.groups)
		// Then checks if any personality type in the list is also in the group
		if(length(incompatibility_list & personality_types))
			return TRUE
	return FALSE

/// Helper to select a random list of personalities, respecting incompatibilities. REturns a list of typepaths
/datum/controller/subsystem/processing/personalities/proc/select_random_personalities(lower_end = 1, upper_end = CONFIG_GET(number/max_personalities))
	var/list/personality_pool = personalities_by_type.Copy()
	var/list/selected_personalities = list()
	var/num = rand(lower_end, upper_end)
	var/i = 1
	while(i <= num)
		if(!length(personality_pool))
			break
		var/picked_type = pick(personality_pool)
		if(is_incompatible(selected_personalities, picked_type))
			continue
		selected_personalities += picked_type
		personality_pool -= picked_type
		i += 1
	return selected_personalities
