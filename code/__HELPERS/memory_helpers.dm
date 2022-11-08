
#define add_memory_in_range(source, range, arguments...) _add_memory_in_range(source, range, list(##arguments))

/proc/_add_memory_in_range(atom/source, range = 7, list/memory_args)
	var/list/witnessing = hearers(range, source) - source
	for(var/mob/living/carbon/memorizer in witnessing)
		memorizer.mind?._add_memory(memory_args)

#define add_mob_memory(arguments...) mind?._add_memory(list(##arguments))
#define add_memory(arguments...) _add_memory(list(##arguments))

/**
 * add_memory
 *
 * Adds a memory to a mob's mind if conditions are met, called wherever the memory takes place (memory for catching on fire in mob's fire code, for example)
 * Argument:
 * * memory_type: defined string in memory_defines.dm, shows the memories.json file which story parts to use (and generally what type it is)
 * * extra_info: the contents of the story. You're gonna want at least the protagonist for who is the main character in the story (Any non basic type will be converted to a string on insertion)
 * * story_value: the quality of the memory, make easy or roundstart memories have a low value so they don't flood persistence
 * * memory_flags: special specifications for skipping parts of the memory like moods for stories where showing moods doesn't make sense
 * Returns the datum memory created, null otherwise.
 */
/datum/mind/proc/_add_memory(list/memory_args)
	var/datum/memory/memory_type = memory_args[1]

	if(current)
		var/new_memory_flags = initial(memory_type.memory_flags)
		if(new_memory_flags & MEMORY_CHECK_UNCONSCIOUS && current.stat >= UNCONSCIOUS)
			return
		if(new_memory_flags & MEMORY_CHECK_BLINDNESS && current.is_blind())
			return
		if(new_memory_flags & MEMORY_CHECK_DEAFNESS && HAS_TRAIT(current, TRAIT_DEAF))
			return

	var/datum/memory/replaced_memory = memories[memory_type]
	if(replaced_memory)
		qdel(replaced_memory)

	memory_args[1] = src
	var/datum/memory/created_memory = new memory_type(arglist(memory_args))

	memories[memory_type] = created_memory
	return created_memory

///sane proc for giving a mob with a mind the option to select one of their memories, returns the memory selected (null otherwise)
/datum/mind/proc/select_memory(verbage)

	var/list/choice_list = list()

	for(var/key in memories)
		var/datum/memory/memory_iter = memories[key]
		if(memory_iter.memory_flags & MEMORY_FLAG_ALREADY_USED) //Can't use memories multiple times
			continue
		choice_list[memory_iter.name] = memory_iter

	var/choice = tgui_input_list(usr, "Select a memory to [verbage]", "Memory Selection?", choice_list)
	if(isnull(choice))
		return FALSE
	if(isnull(choice_list[choice]))
		return FALSE
	var/datum/memory/memory_choice = choice_list[choice]

	return memory_choice

///small helper to clean out memories
/datum/mind/proc/wipe_memory()
	QDEL_LIST_ASSOC_VAL(memories)
