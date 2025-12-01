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
