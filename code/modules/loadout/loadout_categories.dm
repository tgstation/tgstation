/**
 * # Loadout categories
 *
 * Loadout categories are singletons used to group loadout items together in the loadout screen.
 */
/datum/loadout_category
	/// The name of the category, shown in the tabs
	var/category_name
	/// FontAwesome icon for the category
	var/category_ui_icon
	/// String to display on the top-right of a category tab
	var/category_info
	/// Order which they appear in the tabs, ties go alphabetically
	var/tab_order = -1
	/// What type of loadout items should be generated for this category?
	var/type_to_generate
	/// List of all loadout items in this category
	VAR_FINAL/list/datum/loadout_item/associated_items

/datum/loadout_category/New()
	. = ..()
	associated_items = get_items()
	for(var/datum/loadout_item/item as anything in associated_items)
		if(GLOB.all_loadout_datums[item.item_path])
			stack_trace("Loadout datum collision - [item.item_path] is shared between multiple loadout datums.")
		GLOB.all_loadout_datums[item.item_path] = item

/datum/loadout_category/Destroy(force, ...)
	if(!force)
		stack_trace("QDEL called on loadout category [type]. This shouldn't ever happen. (Use FORCE if necessary.)")
		return QDEL_HINT_LETMELIVE

	associated_items.Cut()
	return ..()

/// Return a list of all /datum/loadout_items in this category.
/datum/loadout_category/proc/get_items() as /list
	var/list/all_items = list()
	for(var/datum/loadout_item/found_type as anything in typesof(type_to_generate))
		if(found_type == initial(found_type.abstract_type))
			continue

		if(!ispath(initial(found_type.item_path), /obj/item))
			stack_trace("Loadout get_items(): Attempted to instantiate a loadout item ([found_type]) with an invalid or null typepath! (got path: [initial(found_type.item_path)])")
			continue

		var/datum/loadout_item/spawned_type = new found_type(src)
		all_items += spawned_type

	return all_items

/// Returns a list of all /datum/loadout_items in this category, formatted for UI use. Only ran once.
/datum/loadout_category/proc/items_to_ui_data() as /list
	if(!length(associated_items))
		return list()

	var/list/formatted_list = list()

	for(var/datum/loadout_item/item as anything in associated_items)
		var/list/item_data = item.to_ui_data()
		UNTYPED_LIST_ADD(formatted_list, item_data)

	sortTim(formatted_list, /proc/cmp_assoc_list_name) // Alphabetizing
	return formatted_list

/**
 * Handles what happens when two items of this category are selected at once
 *
 * Return TRUE if it's okay to continue with adding the incoming item,
 * or return FALSE to stop the new item from being added
 */
/datum/loadout_category/proc/handle_duplicate_entires(
	datum/preference_middleware/loadout/manager,
	datum/loadout_item/conflicting_item,
	datum/loadout_item/added_item,
	list/datum/loadout_item/all_loadout_items,
)
	manager.deselect_item(conflicting_item)
	return TRUE
