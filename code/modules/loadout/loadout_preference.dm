/datum/preference/loadout
	savefile_key = "loadout_list"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_LOADOUT
	can_randomize = FALSE
	// Loadout preference is an assoc list [item_path] = [loadout item information list]
	//
	// it may look something like
	// - list(/obj/item/glasses = list())
	// or
	// - list(/obj/item/plush/lizard = list("name" = "Tests-The-Loadout", "color" = "#FF0000"))

// Loadouts are applied with job equip code.
/datum/preference/loadout/apply_to_human(mob/living/carbon/human/target, value)
	return

// Sanitize on load to ensure no invalid paths from older saves get in
/datum/preference/loadout/deserialize(input, datum/preferences/preferences)
	return sanitize_loadout_list(input, preferences) /// BANDASTATION EDIT - Loadout

// Default value is null - the loadout list is a lazylist
/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return null

/datum/preference/loadout/is_valid(value)
	return isnull(value) || islist(value)

/**
 * Removes all invalid paths from loadout lists.
 * This is a general sanitization for preference loading.
 *
 * Returns a list, or null if empty
 */
/datum/preference/loadout/proc/sanitize_loadout_list(list/passed_list, datum/preferences/preferences) as /list
	var/list/sanitized_list
	/// BANDASTATION ADDITION START - Loadout
	var/total_points_spent = 0
	var/points_cap = preferences.get_loadout_max_points()
	var/donator_level = preferences.parent.get_donator_level()
	/// BANDASTATION ADDITION END - Loadout
	for(var/path in passed_list)
		// Loading from json has each path in the list as a string that we need to convert back to typepath
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		if(!ispath(real_path, /obj/item))
			to_chat(preferences.parent, span_boldnotice("The following invalid item path was found \
				in your character loadout: [real_path || "null"]. \
				It has been removed, renamed, or is otherwise missing - \
				You may want to check your loadout settings."))
			continue


		var/datum/loadout_item/loadout_item = GLOB.all_loadout_datums[real_path] /// BANDASTATION ADDITION - Loadout
		if(loadout_item.is_disabled())
			continue
		if(!istype(loadout_item, /datum/loadout_item))
			to_chat(preferences.parent, span_boldnotice("The following invalid loadout item was found \
				in your character loadout: [real_path || "null"]. \
				It has been removed, renamed, or is otherwise missing - \
				You may want to check your loadout settings."))
			continue

		/// BANDASTATION ADDITION START - Loadout
		if(loadout_item.donator_level > donator_level)
			to_chat(
				preferences.parent,
				span_boldnotice(\
					"Ваш уровень подписки ([donator_level]) недостаточен для [loadout_item.name] \
						с уровнем [loadout_item.donator_level]. Предмет убран из снаряжения." \
				)
			)
			continue

		if(loadout_item.cost + total_points_spent > points_cap)
			to_chat(
				preferences.parent,
				span_boldnotice(\
					"У вас недостаточно очков ([points_cap - total_points_spent]) \
						для [loadout_item.name] за [loadout_item.cost] очков. Предмет убран из снаряжения." \
				)
			)
			continue

		total_points_spent += loadout_item.cost
		/// BANDASTATION ADDITION END - Loadout

		// Set into sanitize list using converted path key
		var/list/data = passed_list[path]
		LAZYSET(sanitized_list, real_path, LAZYLISTDUPLICATE(data))

	preferences.loadout_points_spent = total_points_spent /// BANDASTATION ADDITION - Loadout

	return sanitized_list
