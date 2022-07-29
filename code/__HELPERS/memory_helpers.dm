
///Adds a memory to people that can see this happening, only use this for impactful or rare events to reduce overhead.
/proc/add_memory_in_range(atom/source, range, memory_type, extra_info, story_value, memory_flags, protagonist_memory_flags)
	var/list/memorizers = hearers(range, source)
	if(!isnull(protagonist_memory_flags))
		var/mob/living/carbon/protagonist = extra_info[DETAIL_PROTAGONIST]
		if(istype(protagonist))
			memorizers -= protagonist
			protagonist.mind?.add_memory(memory_type, extra_info, story_value, protagonist_memory_flags)
	for(var/mob/living/carbon/memorizer in memorizers)
		memorizer.mind?.add_memory(memory_type, extra_info, story_value, memory_flags)

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
/datum/mind/proc/add_memory(memory_type, extra_info, story_value, memory_flags)
	if(current)
		if(!(memory_flags & MEMORY_SKIP_UNCONSCIOUS) && current.stat >= UNCONSCIOUS)
			return
		var/is_blind = FALSE
		if(memory_flags & MEMORY_CHECK_BLINDNESS && current.is_blind())
			if(!(memory_flags & MEMORY_CHECK_DEAFNESS)) // Only check for blindness
				return
			is_blind = TRUE // Otherwise check if the mob is both blind and deaf
		if(memory_flags & MEMORY_CHECK_DEAFNESS && HAS_TRAIT(current, TRAIT_DEAF) && (!(memory_flags & MEMORY_CHECK_BLINDNESS) || is_blind))
			return

	var/story_mood = MOODLESS_MEMORY
	var/victim_mood = MOODLESS_MEMORY

	extra_info[DETAIL_PROTAGONIST] = extra_info[DETAIL_PROTAGONIST] || current //If no victim is supplied, assume it happend to the memorizer.
	var/atom/victim = extra_info[DETAIL_PROTAGONIST]
	if(!(memory_flags & MEMORY_FLAG_NOLOCATION))
		extra_info[DETAIL_WHERE] = get_area(victim)

	if(!(memory_flags & MEMORY_FLAG_NOMOOD))
		var/datum/component/mood/victim_mood_component = current.GetComponent(/datum/component/mood)
		if(victim_mood_component)
			victim_mood = victim_mood_component.mood_level

		if(victim == current)
			story_mood = victim_mood
		else
			var/datum/component/mood/memorizer_mood_component = current.GetComponent(/datum/component/mood)
			if(memorizer_mood_component)
				story_mood = memorizer_mood_component.mood_level

	extra_info[DETAIL_PROTAGONIST_MOOD] = victim_mood

	var/datum/memory/replaced_memory = memories[memory_type]
	if(replaced_memory)
		qdel(replaced_memory)

	var/extra_info_parsed = list()

	for(var/key in extra_info)
		var/detail = extra_info[key]
		extra_info_parsed[key] = build_story_detail(detail)

	memories[memory_type] = new /datum/memory(src, build_story_mob(current), memory_type, extra_info_parsed, story_mood, story_value, memory_flags)
	return memories[memory_type]

///returns the story name of a mob
/datum/mind/proc/build_story_mob(mob/living/target)
	if(isanimal(target))
		return "\the [target]"
	if(target.mind?.assigned_role)
		return  "\the [lowertext(initial(target.mind?.assigned_role.title))]"
	return target

///returns the story name of anything
/datum/mind/proc/build_story_detail(detail)
	if(!isatom(detail))
		return detail //Its either text or deserves to runtime.
	var/atom/target = detail
	if(isliving(target))
		return build_story_mob(target)
	return lowertext(initial(target.name))

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
