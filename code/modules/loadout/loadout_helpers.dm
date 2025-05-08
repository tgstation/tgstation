/**
 * Equips this mob with a given outfit and loadout items as per the passed preferences.
 *
 * Loadout items override the pre-existing item in the corresponding slot of the job outfit.
 * Some job items are preserved after being overridden - belt items, ear items, and glasses.
 * The rest of the slots, the items are overridden completely and deleted.
 *
 * Species with special outfits are snowflaked to have loadout items placed in their bags instead of overriding the outfit.
 *
 * * outfit - the job outfit we're equipping
 * * preference_source - the preferences to draw loadout items from.
 * * visuals_only - whether we call special equipped procs, or if we just look like we equipped it
 */
/mob/living/carbon/human/proc/equip_outfit_and_loadout(
	datum/outfit/outfit = /datum/outfit,
	datum/preferences/preference_source,
	visuals_only = FALSE,
)
	set waitfor = FALSE // DOPPLER ADDITION: the nuclear option: this should stop the linter fucking whining?
	if(isnull(preference_source))
		return equipOutfit(outfit, visuals_only)

	var/datum/outfit/equipped_outfit
	if(ispath(outfit, /datum/outfit))
		equipped_outfit = new outfit()
	else if(istype(outfit, /datum/outfit))
		equipped_outfit = outfit
	else
		CRASH("Invalid outfit passed to equip_outfit_and_loadout ([outfit])")

	var/override_preference = preference_source.read_preference(/datum/preference/choiced/loadout_override_preference) // DOPPLER ADDITION: loadout preferences

	var/list/preference_list = preference_source.read_preference(/datum/preference/loadout)
	var/list/loadout_datums = loadout_list_to_datums(preference_list)
	/* DOPPLER EDIT START - Original:
	// Slap our things into the outfit given
	for(var/datum/loadout_item/item as anything in loadout_datums)
		item.insert_path_into_outfit(equipped_outfit, src, visuals_only)
	// Equip the outfit loadout items included
	if(!equipped_outfit.equip(src, visuals_only))
		return FALSE
	*/
	var/obj/item/storage/briefcase/empty/briefcase
	var/list/new_contents
	if (!isnull(override_preference) && override_preference == LOADOUT_OVERRIDE_CASE && !visuals_only)
		briefcase = new(loc)
		for(var/datum/loadout_item/item as anything in loadout_datums)
			new item.item_path(briefcase)

		briefcase.name = "[preference_source.read_preference(/datum/preference/name/real_name)]'s travel suitcase"
		equipOutfit(equipped_outfit, visuals_only)
		put_in_hands(briefcase)
		new_contents = briefcase.get_all_contents()
	else
		// Slap our things into the outfit given
		for(var/datum/loadout_item/item as anything in loadout_datums)
			item.insert_path_into_outfit(equipped_outfit, src, visuals_only, override_preference)
		// Equip the outfit loadout items included
		if(!equipped_outfit.equip(src, visuals_only))
			return FALSE
		new_contents = get_all_gear()

	// Handle any snowflake on_equips
	// DOPPLER EDIT END
	var/update = NONE
	for(var/datum/loadout_item/item as anything in loadout_datums)
		update |= item.on_equip_item(
			equipped_item = locate(item.item_path) in new_contents,
			preference_source = preference_source,
			preference_list = preference_list,
			equipper = src,
			visuals_only = visuals_only,
		)
	if(update)
		update_clothing(update)

	return TRUE

/**
 * Takes a list of paths (such as a loadout list)
 * and returns a list of their singleton loadout item datums
 *
 * loadout_list - the list being checked
 *
 * Returns a list of singleton datums
 */
/proc/loadout_list_to_datums(list/loadout_list) as /list
	var/list/datums = list()

	if(!length(GLOB.all_loadout_datums))
		CRASH("No loadout datums in the global loadout list!")

	for(var/path in loadout_list)
		var/actual_datum = GLOB.all_loadout_datums[path]
		if(!istype(actual_datum, /datum/loadout_item))
			stack_trace("Could not find ([path]) loadout item in the global list of loadout datums!")
			continue

		datums += actual_datum

	return datums
