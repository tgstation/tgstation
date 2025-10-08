/**
 * Replace a quirk with a personality
 *
 * If this is accompanied with removal of a quirk,
 * you don't need to worry about handling that here -
 * quirk sanitization happens AFTER migration
 */
/datum/preferences/proc/migrate_quirk_to_personality(quirk_to_migrate, datum/personality/new_typepath)
	ASSERT(istext(quirk_to_migrate) && ispath(new_typepath, /datum/personality))
	if(!(quirk_to_migrate in all_quirks))
		return
	var/list/personalities = read_preference(/datum/preference/personality)
	if(LAZYLEN(personalities) >= CONFIG_GET(number/max_personalities))
		return
	LAZYADD(personalities, initial(new_typepath.savefile_key))
	write_preference(GLOB.preference_entries[/datum/preference/personality], personalities)
