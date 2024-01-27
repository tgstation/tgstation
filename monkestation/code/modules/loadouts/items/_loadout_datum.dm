// -- The loadout item datum and related procs. --

/// Global list of ALL loadout datums instantiated.
GLOBAL_LIST_EMPTY(all_loadout_datums)

/*
 * Generate a list of singleton loadout_item datums from all subtypes of [type_to_generate]
 *
 * returns a list of singleton datums.
 */
/proc/generate_loadout_items(type_to_generate)
	RETURN_TYPE(/list)

	. = list()
	if(!ispath(type_to_generate))
		CRASH("generate_loadout_items(): called with an invalid or null path as an argument!")

	for(var/datum/loadout_item/found_type as anything in subtypesof(type_to_generate))
		/// Any item without a name is "abstract"
		if(isnull(initial(found_type.name)))
			continue

		if(!ispath(initial(found_type.item_path)))
			stack_trace("generate_loadout_items(): Attempted to instantiate a loadout item ([initial(found_type.name)]) with an invalid or null typepath! (got path: [initial(found_type.item_path)])")
			continue

		var/datum/loadout_item/spawned_type = new found_type()
		// Let's sanitize in case somebody inserted the player's byond name instead of ckey in canonical form
		if(spawned_type.ckeywhitelist)
			for (var/i = 1, i <= length(spawned_type.ckeywhitelist), i++)
				spawned_type.ckeywhitelist[i] = ckey(spawned_type.ckeywhitelist[i])
		GLOB.all_loadout_datums[spawned_type.item_path] = spawned_type
		. |= spawned_type

/// Loadout item datum.
/// Holds all the information about each loadout items.
/// A list of singleton loadout items are generated on initialize.
/datum/loadout_item
	/// Displayed name of the loadout item.
	var/name
	/// Whether this item can be renamed.
	var/can_be_named = FALSE
	/// The category of the loadout item.
	var/category
	/// The actual item path of the loadout item.
	var/atom/item_path
	/// List of additional text for the tooltip displayed on this item.
	var/list/additional_tooltip_contents
	/// If set, it's a list containing ckeys which only can get the item
	var/list/ckeywhitelist
	/// If set, is a list of job names of which can get the loadout item
	var/list/restricted_roles
	/// Whether the item is restricted to supporters
	var/donator_only
	/// Whether the item requires a specific season in order to be available
	var/required_season = null
	///does this item require being bought to show up?
	var/requires_purchase = TRUE
	///can only admins use this?
	var/admin_only = FALSE

/*
 * Place our [var/item_path] into [outfit].
 *
 * By default, just adds the item into the outfit's backpack contents, if non-visual.
 *
 * equipper - If we're equipping our outfit onto a mob at the time, this is the mob it is equipped on. Can be null.
 * outfit - The outfit we're equipping our items into.
 * visual - If TRUE, then our outfit is only for visual use (for example, a preview).
 */
/datum/loadout_item/proc/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(!visuals_only)
		LAZYADD(outfit.backpack_contents, item_path)

/*
 * To be called before insert_path_into_outfit()
 *
 * Checks if an important_for_life item exists and puts the loadout item into the backpack if they would take up the same slot as it.
 *
 * equipper - If we're equipping our outfit onto a mob at the time, this is the mob it is equipped on. Can be null.
 * outfit - The outfit we're equipping our items into.
 * outfit_important_for_life - The outfit whose slots we want to make sure we don't equip an item into.
 * visual - If TRUE, then our outfit is only for visual use (for example, a preview).
 *
 * Returns TRUE if there is an important_for_life item in the slot that the loadout item would normally occupy, FALSE otherwise
 */
/datum/loadout_item/proc/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(!visuals_only)
		LAZYADD(outfit.backpack_contents, item_path)

/*
 * Called When the item is equipped on [equipper].
 */
/datum/loadout_item/proc/on_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(!preference_source)
		return

	var/list/our_loadout = preference_source.loadout_list
	var/atom/loadout_atom = item_path
	var/can_be_greyscale = !!(initial(loadout_atom.greyscale_config) && initial(loadout_atom.greyscale_colors) && (initial(loadout_atom.flags_1) & IS_PLAYER_COLORABLE_1))
	if(can_be_greyscale && (INFO_GREYSCALE in our_loadout[item_path]))
		if(ispath(item_path, /obj/item/clothing))
			// When an outfit is equipped in preview, get_equipped_items() does not work, so we have to use get_all_contents()
			var/obj/item/clothing/equipped_item = locate(item_path) in (visuals_only ? equipper.get_all_contents() : equipper.get_all_gear()) // needs held items for briefcasers
			if(equipped_item)
				equipped_item.set_greyscale(our_loadout[item_path][INFO_GREYSCALE])
			else
				stack_trace("[type] on_equip_item(): Could not locate clothing item (path: [item_path]) in [equipper]'s [visuals_only ? "visible":"all"] contents to set greyscaling!")

		else if(!visuals_only)
			var/obj/item/other_item = locate(item_path) in equipper.get_all_gear()
			if(other_item)
				other_item.set_greyscale(our_loadout[item_path][INFO_GREYSCALE])
			else
				stack_trace("[type] on_equip_item(): Could not locate backpack item (path: [item_path]) in [equipper]'s contents to set greyscaling!")

	if(can_be_named && !visuals_only && (INFO_NAMED in our_loadout[item_path]))
		var/obj/item/equipped_item = locate(item_path) in equipper.get_all_gear()
		if(equipped_item)
			equipped_item.name = our_loadout[item_path][INFO_NAMED]
		else
			stack_trace("[type] on_equip_item(): Could not locate item (path: [item_path]) in [equipper]'s contents to set name!")

/*
 * Called after the item is equipped on [equipper], at the end of character setup.
 */
/datum/loadout_item/proc/post_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper)
	return FALSE
