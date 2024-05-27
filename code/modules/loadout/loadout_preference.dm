/datum/preference/loadout
	savefile_key = "loadout_list"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

// Loadouts are applied with job equip code.
/datum/preference/loadout/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/loadout/deserialize(input, datum/preferences/preferences)
	// Sanitize on load to ensure no invalid paths from older saves get in
	return sanitize_loadout_list(input, preferences.parent?.mob)

// Default value is null - the loadout list is a lazylist
/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return null

/datum/preference/loadout/is_valid(value)
	return isnull(value) || islist(value)

/**
 * Removes all invalid paths from loadout lists.
 * This is a general sanitization for preference loading.
 *
 * returns a list, or null if empty
 */
/datum/preference/loadout/proc/sanitize_loadout_list(list/passed_list, mob/optional_loadout_owner)
	var/list/sanitized_list
	for(var/path in passed_list)
		// Loading from json has each path in the list as a string that we need to convert back to typepath
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		if(!ispath(real_path, /obj/item))
			if(optional_loadout_owner)
				to_chat(optional_loadout_owner, span_boldnotice("The following invalid item path was found \
					in your character loadout: [real_path || "null"]. \
					It has been removed, renamed, or is otherwise missing - \
					You may want to check your loadout settings."))
			continue

		else if(!istype(GLOB.all_loadout_datums[real_path], /datum/loadout_item))
			if(optional_loadout_owner)
				to_chat(optional_loadout_owner, span_boldnotice("The following invalid loadout item was found \
					in your character loadout: [real_path || "null"]. \
					It has been removed, renamed, or is otherwise missing - \
					You may want to check your loadout settings."))
			continue

		// Set into sanitize list using converted path key
		var/list/data = passed_list[path]
		LAZYSET(sanitized_list, real_path, LAZYLISTDUPLICATE(data))

	return sanitized_list
