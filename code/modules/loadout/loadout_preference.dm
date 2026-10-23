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
/datum/preference/loadout/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return

// Sanitize on load to ensure no invalid paths from older saves get in
/datum/preference/loadout/deserialize(input, datum/preferences/preferences)
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
 * Returns a list, or null if empty
 */
/datum/preference/loadout/proc/sanitize_loadout_list(list/passed_list, mob/optional_loadout_owner) as /list
	var/list/legacy_loadout_items = list(
		/obj/item/clothing/head/soft/black = list(/obj/item/clothing/head/soft, "Black"),
		/obj/item/clothing/head/soft/blue = list(/obj/item/clothing/head/soft, "Blue"),
		/obj/item/clothing/head/soft/green = list(/obj/item/clothing/head/soft, "Green"),
		/obj/item/clothing/head/soft/grey = list(/obj/item/clothing/head/soft, "Grey"),
		/obj/item/clothing/head/soft/orange = list(/obj/item/clothing/head/soft, "Orange"),
		/obj/item/clothing/head/soft/purple = list(/obj/item/clothing/head/soft, "Purple"),
		/obj/item/clothing/head/soft/rainbow = list(/obj/item/clothing/head/soft, "Rainbow"),
		/obj/item/clothing/head/soft/red = list(/obj/item/clothing/head/soft, "Red"),
		/obj/item/clothing/head/soft/mime = list(/obj/item/clothing/head/soft, "White"),
		/obj/item/clothing/head/soft/yellow = list(/obj/item/clothing/head/soft, "Yellow"),
		/obj/item/clothing/head/fedora/beige = list(/obj/item/clothing/head/fedora, "Beige"),
		/obj/item/clothing/head/fedora/white = list(/obj/item/clothing/head/fedora, "White"),
		/obj/item/clothing/shoes/cowboy/black/laced = list(/obj/item/clothing/shoes/cowboy/laced, "Black"),
		/obj/item/clothing/shoes/cowboy/white/laced = list(/obj/item/clothing/shoes/cowboy/laced, "White"),
	)
	var/list/normalized_list
	// Keep already-selected consolidated items in preference to migrated duplicates.
	for(var/path in passed_list)
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		if(legacy_loadout_items[real_path])
			continue
		LAZYSET(normalized_list, real_path || path, passed_list[path])

	for(var/path in passed_list)
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		var/list/migration = legacy_loadout_items[real_path]
		if(!migration || !isnull(normalized_list[migration[1]]))
			continue

		var/list/legacy_data = passed_list[path]
		var/list/data = LAZYLISTDUPLICATE(legacy_data) || list()
		data[INFO_RESKIN] = migration[2]
		LAZYSET(normalized_list, migration[1], data)

	var/list/sanitized_list
	for(var/path in normalized_list)
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

		var/datum/loadout_item/loadout_item = GLOB.all_loadout_datums[real_path]
		if(loadout_item.is_disabled())
			continue // this just falls off silently

		// Set into sanitize list using converted path key
		var/list/data = normalized_list[path]
		data = LAZYLISTDUPLICATE(data)
		// GAGS can't render malformed colors, so fall back to the item's defaults
		var/saved_colors = data?[INFO_GREYSCALE]
		if(saved_colors && (!istext(saved_colors) || !findtext(saved_colors, GLOB.is_greyscale_colors)))
			data -= INFO_GREYSCALE
			if(optional_loadout_owner)
				to_chat(optional_loadout_owner, span_boldnotice("The saved colors for [loadout_item.name] \
					in your character loadout were invalid and have been reset."))
		LAZYSET(sanitized_list, real_path, data)

	return sanitized_list
