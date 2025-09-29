PROCESSING_SUBSYSTEM_DEF(personalities)
	name = "Personalities"
	runlevels = RUNLEVEL_GAME
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	wait = 3 SECONDS

	/// All personality singletons indexed by their type
	VAR_FINAL/list/datum/personality/personalities_by_type
	/// All personality singletons indexed by their savefile key
	VAR_FINAL/list/datum/personality/personalities_by_key
	/// List of lists of incompatible personality types.
	VAR_FINAL/list/incompatibilities

	/// For personalities which process, this tracks all mobs we need to process for
	var/list/processing_personalities = list()

/datum/controller/subsystem/processing/personalities/Initialize()
	init_personalities()
	init_incompatibilities()
	return SS_INIT_SUCCESS

/// Initialized personality singletons
/datum/controller/subsystem/processing/personalities/proc/init_personalities()
	personalities_by_type = list()
	personalities_by_key = list()
	for(var/datum/personality/personality_type as anything in typesof(/datum/personality))
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

/// Initializes the incompatibility list
/datum/controller/subsystem/processing/personalities/proc/init_incompatibilities()
	incompatibilities = list(
		list(
			/datum/personality/callous,
			/datum/personality/compassionate,
		),
		list(
			/datum/personality/department/analytical,
			/datum/personality/department/impulsive,
		),
		list(
			/datum/personality/introvert,
			/datum/personality/extrovert,
		),
		list(
			/datum/personality/teetotal,
			/datum/personality/bibulous,
		),
		list(
			/datum/personality/gourmand,
			/datum/personality/ascetic,
		),
		list(
			/datum/personality/nt/loyalist,
			/datum/personality/nt/disillusioned,
		),
		list(
			/datum/personality/hopeful,
			/datum/personality/pessimistic,
		),
		list(
			/datum/personality/compassionate,
			/datum/personality/misanthropic,
		),
		list(
			/datum/personality/misanthropic,
			/datum/personality/extrovert,
			/datum/personality/empathetic,
		),
		list(
			/datum/personality/brave,
			/datum/personality/cowardly,
		),
		list(
			/datum/personality/brave,
			/datum/personality/paranoid,
		),
		list(
			/datum/personality/slacking/lazy,
			/datum/personality/slacking/diligent,
		),
		list(
			/datum/personality/slacking/lazy,
			/datum/personality/athletic,
		),
		list(
			/datum/personality/brooding,
			/datum/personality/resilient,
		),
		list(
			/datum/personality/slacking/lazy,
			/datum/personality/industrious,
		),
		list(
			/datum/personality/creative,
			/datum/personality/unimaginative,
		),
		list(
			/datum/personality/hopeful,
			/datum/personality/pessimistic,
		),
		list(
			/datum/personality/erudite,
			/datum/personality/uneducated,
		),
		list(
			/datum/personality/apathetic,
			/datum/personality/sensitive,
		),
		list(
			/datum/personality/animal_friend,
			/datum/personality/animal_disliker,
			/datum/personality/cat_fan,
			/datum/personality/dog_fan,
		),
	)

/// Helper to check if the new personality type is incompatible with the passed list of personality types
/datum/controller/subsystem/processing/personalities/proc/is_incompatible(list/personality_types, new_personality_type)
	if(!length(incompatibilities))
		stack_trace("Checking personality incompatibilities before the incompatibility list was initialized?")
		return FALSE
	if(length(personality_types) <= 1)
		return FALSE
	for(var/incompatibility in incompatibilities)
		if(!(new_personality_type in incompatibility))
			continue
		for(var/contrasting_type in personality_types)
			if(contrasting_type == new_personality_type) // You're not incompatible with yourself
				continue
			if(contrasting_type in incompatibility)
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
