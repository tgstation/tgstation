/**
 * Move quirk items into loadout items
 *
 * If this is accompanied with removal of a quirk,
 * you don't need to worry about handling that here -
 * quirk sanitization happens AFTER migration
 */
/datum/preferences/proc/migrate_quirk_to_loadout(quirk_to_migrate, new_typepath, list/data_to_migrate)
	ASSERT(istext(quirk_to_migrate) && ispath(new_typepath, /obj/item))
	if(quirk_to_migrate in all_quirks)
		add_loadout_item(new_typepath, data_to_migrate)

/// Consolidate legacy loadout item paths into reskinnable items.
/datum/preferences/proc/migrate_legacy_loadout_items(list/save_data)
	var/datum/preference/loadout/loadout_preference = GLOB.preference_entries[/datum/preference/loadout]
	var/list/loadout_list = save_data[loadout_preference.savefile_key]
	if(!islist(loadout_list))
		return

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

	var/list/migrated_loadout = list()
	// Keep already-selected consolidated items in preference to migrated duplicates.
	for(var/path in loadout_list)
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		if(legacy_loadout_items[real_path])
			continue
		migrated_loadout[path] = loadout_list[path]

	for(var/path in loadout_list)
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		var/list/migration = legacy_loadout_items[real_path]
		if(!migration)
			continue

		var/target_path = "[migration[1]]"
		if(target_path in migrated_loadout)
			continue

		var/list/legacy_data = loadout_list[path]
		var/list/data_to_migrate = LAZYLISTDUPLICATE(legacy_data) || list()
		data_to_migrate[INFO_RESKIN] = migration[2]
		migrated_loadout[target_path] = data_to_migrate

	save_data[loadout_preference.savefile_key] = migrated_loadout
	if(!write_preference(loadout_preference, migrated_loadout))
		CRASH("Failed to migrate legacy loadout items for [parent]")

/// Helper for slotting in a new loadout item
/datum/preferences/proc/add_loadout_item(typepath, list/data = list())
	PRIVATE_PROC(TRUE)

	var/list/loadout_list = read_preference(/datum/preference/loadout) || list()
	loadout_list[typepath] = data
	write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)

/// Helper for removing a loadout item
/datum/preferences/proc/remove_loadout_item(typepath)
	PRIVATE_PROC(TRUE)

	var/list/loadout_list = read_preference(/datum/preference/loadout)
	if(loadout_list?.Remove(typepath))
		write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)
