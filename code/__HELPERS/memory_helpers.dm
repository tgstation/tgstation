/**
 * Adds a memory to all carbon mobs in a certain range of a certain atom.
 *
 * The third argument should be a typepath of a /datum/memory.
 *
 * Two things of note when using this:
 * * If the source atom is a mob, it will be added to that mob if possible.
 * * The protagonist of the memory is set to the memorizer by default. If sourced from a mob, you need to set the protagonist manually.
 *
 * Beyond that, can be supplied with named arguments pertaining to your memory type.
 * Common arguments include:
 * * protagonist: The main subject of the memory
 * * deuteragonist: The side subject of the memory. Doesn't necessarily have to be a mob!
 * * antagonist: The main villain of the memory. Also doesn't necessarily have to be a mob!
 */
#define add_memory_in_range(source, range, arguments...) _add_memory_in_range(source, range, list(##arguments))

/// Unless you need to use this for an explicit reason, use the add_memory_in_range macro wrapper.
/proc/_add_memory_in_range(atom/source, range = 7, list/memory_args)
	for(var/mob/living/carbon/memorizer in hearers(range, source))
		memorizer.mind?._add_memory(memory_args.Copy()) // One copy for each memory, since it mutates the list

/**
 * Adds a memory to the target mob.
 *
 * The first argument should be a typepath of a /datum/memory.
 *
 * If the mob already has a memory of that type, it will be deleted.
 *
 * Beyond that, can be supplied with named arguments pertaining to your memory type.
 * Common arguments include:
 * * protagonist: The main subject of the memory
 * * deuteragonist: The side subject of the memory. Doesn't necessarily have to be a mob!
 * * antagonist: The main villain of the memory. Also doesn't necessarily have to be a mob!
 *
 * Returns the datum memory created, or null otherwise.
 */
#define add_mob_memory(arguments...) mind?._add_memory(list(##arguments))

// Wrapper for _add_memory so we can used named arguments.
/**
 * Adds a memory to the target mind.
 *
 * The first argument should be a typepath of a /datum/memory.
 *
 * If the mob already has a memory of that type, it will be deleted.
 *
 * Beyond that, can be supplied with named arguments pertaining to your memory type.
 * Common arguments include:
 * * protagonist: The main subject of the memory
 * * deuteragonist: The side subject of the memory. Doesn't necessarily have to be a mob!
 * * antagonist: The main villain of the memory. Also doesn't necessarily have to be a mob!
 *
 * Returns the datum memory created, or null otherwise.
 */
#define add_memory(arguments...) _add_memory(list(##arguments))

/// Unless you need to use this for an explicit reason, use the add_memory, add_mob_memory, or add_memory_in_range macro wrappers.
/datum/mind/proc/_add_memory(list/memory_args)
	RETURN_TYPE(/datum/memory)
	var/datum/memory/memory_type = memory_args[1]
	if(!ispath(memory_type))
		CRASH("add_memory called with an invalid memory type. (Got: [memory_type || "null"])")

	if(current)
		var/new_memory_flags = initial(memory_type.memory_flags)
		if(!(new_memory_flags & MEMORY_SKIP_UNCONSCIOUS) && current.stat >= UNCONSCIOUS)
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

/**
 * Simple / sane proc for giving a mob the option to select one of their memories
 * that do not have the flags [MEMORY_FLAG_ALREADY_USED] or [MEMORY_NO_STORY].
 *
 * Arguments
 * * verbage: This is used in the tgui selection menu, explains what they're selecting a memory to do.
 *
 * Returns the memory selected, or null otherwise.
 */
/datum/mind/proc/select_memory(verbage = "use")
	RETURN_TYPE(/datum/memory)
	var/list/choice_list = list()

	for(var/key in memories)
		var/datum/memory/memory_iter = memories[key]
		if(memory_iter.memory_flags & (MEMORY_FLAG_ALREADY_USED|MEMORY_NO_STORY)) //Can't use memories multiple times
			continue
		choice_list[memory_iter.name] = memory_iter

	var/choice = tgui_input_list(usr, "Select a memory to [verbage]", "Memory Selection?", choice_list)
	if(isnull(choice))
		return FALSE
	if(isnull(choice_list[choice]))
		return FALSE
	var/datum/memory/memory_choice = choice_list[choice]

	return memory_choice

/// Small helper to clean out memories.
/datum/mind/proc/wipe_memory()
	QDEL_LIST_ASSOC_VAL(memories)

/// Helder to wipe the passed memory type ONLY from our list of memories
/datum/mind/proc/wipe_memory_type(memory_type)
	qdel(memories[memory_type])
	memories -= memory_type

/// Helper to create quick copies of all of our memories
/// Quick copies aren't full copies - just basic copies containing necessities.
/// They cannot be used in stories.
/datum/mind/proc/quick_copy_all_memories(datum/mind/new_memorizer)
	for(var/memory_path in memories)
		var/datum/memory/prime_memory = memories[memory_path]
		new_memorizer.memories[memory_path] = prime_memory.quick_copy_memory(new_memorizer)
