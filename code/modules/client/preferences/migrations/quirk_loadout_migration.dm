/**
 * Move quirk items into loadout items
 *
 * If this is accompanied with removal of a quirk,
 * you don't need to worry about handling that here -
 * quirk sanitization happens AFTER migration
 */
/datum/preferences/proc/migrate_quirks_to_loadout(list/save_data)
	var/list/old_quirks = save_data?["all_quirks"]
	if("Pride Pin" in old_quirks)
		// Changes pride pin quirk -> pride pin loadout item for people who have it
		// This does all the sanitization and validation for us down the line -
		// So we don't need to worry about people carrying over old, invalid icon states or whatever
		add_loadout_item(
			typepath = /obj/item/clothing/accessory/pride,
			data = list(INFO_RESKIN = save_data?["pride_pin"]),
		)

/datum/preferences/proc/add_loadout_item(typepath, list/data = list())
	PRIVATE_PROC(TRUE) // I don't really want this used outside of preferences

	var/list/loadout_list = read_preference(/datum/preference/loadout) || list()
	loadout_list[typepath] = data
	write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)

/datum/preferences/proc/remove_loadout_item(typepath)
	PRIVATE_PROC(TRUE) // See above

	var/list/loadout_list = read_preference(/datum/preference/loadout)
	if(loadout_list?.Remove(typepath))
		write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)
