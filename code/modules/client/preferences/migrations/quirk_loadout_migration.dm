/**
 * Move quirk items into loadout items
 *
 * If this is accompanied with removal of a quirk,
 * you don't need to worry about handling that here -
 * quirk sanitization happens AFTER migration
 */
/datum/preferences/proc/migrate_quirks_to_loadout(list/old_quirks)
	if("Pride Pin" in old_quirks)
		// Changes pride pin quirk -> pride pin loadout item for people who have it
		// This does all the sanitization and validation for us down the line -
		// So we don't need to worry about people carrying over old, invalid icon states or whatever
		add_loadout_item(
			typepath = /obj/item/clothing/accessory/pride,
			data = list(INFO_RESKIN = read_preference(/datum/preference/choiced/pride_pin)),
		)
