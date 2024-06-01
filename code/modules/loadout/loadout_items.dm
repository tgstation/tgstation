/// Global list of ALL loadout datums instantiated.
/// Loadout datums are created by loadout categories.
GLOBAL_LIST_EMPTY(all_loadout_datums)

/**
 * # Loadout item datum
 *
 * Singleton that holds all the information about each loadout items, and how to equip them.
 */
/datum/loadout_item
	/// Displayed name of the loadout item.
	/// Defaults to the item's name if unset.
	var/name
	/// Whether this item has greyscale support.
	/// Only works if the item is compatible with the GAGS system of coloring.
	/// Set automatically to TRUE for all items that have the flag [IS_PLAYER_COLORABLE_1].
	/// If you really want it to not be colorable set this to [DONT_GREYSCALE]
	var/can_be_greyscale = FALSE
	/// Whether this item can be renamed.
	/// I recommend you apply this sparingly becuase it certainly can go wrong (or get reset / overridden easily)
	var/can_be_named = FALSE
	/// Whether this item can be reskinned.
	/// Only works if the item has a "unique reskin" list set.
	var/can_be_reskinned = FALSE
	/// The abstract parent of this loadout item, to determine which items to not instantiate
	var/abstract_type = /datum/loadout_item
	/// The actual item path of the loadout item.
	var/obj/item/item_path
	/// Lazylist of additional "tooltips" to display about this item.
	var/list/additional_tooltip_contents
	/// Icon file (DMI) for the UI to use for preview icons.
	/// Set automatically if null
	var/ui_icon
	/// Icon state for the UI to use for preview icons.
	/// Set automatically if null
	var/ui_icon_state
	/// The category of the loadout item. Set automatically in New
	VAR_FINAL/datum/loadout_category/category

/datum/loadout_item/New(category)

	src.category = category

	if(can_be_greyscale == DONT_GREYSCALE)
		// Explicitly be false if we don't want this to greyscale
		can_be_greyscale = FALSE
	else if(item_path::flags_1 & IS_PLAYER_COLORABLE_1)
		// Otherwise set this automatically to true if it is actually colorable
		can_be_greyscale = TRUE
		// This means that one can add a greyscale item that does not have player colorable set
		// but is still modifyable as a greyscale item in the loadout menu by setting it to true manually
		// Why? I HAVE NO IDEA why you would do that but you sure can

	if(isnull(name))
		name = item_path::name

	if(GLOB.all_loadout_datums[item_path])
		stack_trace("Loadout datum collision detected! [item_path] is shared between multiple loadout datums.")
	GLOB.all_loadout_datums[item_path] = src

	if(isnull(ui_icon) && isnull(ui_icon_state))
		ui_icon = item_path::icon_preview || item_path::icon
		ui_icon_state = item_path::icon_state_preview || item_path::icon_state

/datum/loadout_item/Destroy(force, ...)
	if(force)
		stack_trace("QDEL called on loadout item [type]. This shouldn't ever happen. (Use FORCE if necessary.)")
		return QDEL_HINT_LETMELIVE

	GLOB.all_loadout_datums -= item_path
	return ..()

/**
 * Takes in an action from a loadout manager and applies it
 *
 * Useful for subtypes of loadout items with unique actions
 *
 * Return TRUE to force an update to the UI / character preview
 */
/datum/loadout_item/proc/handle_loadout_action(datum/preference_middleware/loadout/manager, mob/user, action)
	SHOULD_CALL_PARENT(TRUE)

	switch(action)
		if("select_color")
			if(can_be_greyscale)
				return set_item_color(manager, user)

		if("set_name")
			if(can_be_named)
				return set_name(manager, user)

		if("set_skin")
			return set_skin(manager, user)

	return FALSE

/// Opens up the GAGS editing menu for a certain item
/datum/loadout_item/proc/set_item_color(datum/preference_middleware/loadout/manager, mob/user)
	if(manager.menu)
		tgui_alert(user, "You already have a color menu open!")
		return FALSE

	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	if(!loadout?[item_path])
		manager.select_item(src)

	var/list/allowed_configs = list()
	if(initial(item_path.greyscale_config))
		allowed_configs += "[initial(item_path.greyscale_config)]"
	if(initial(item_path.greyscale_config_worn))
		allowed_configs += "[initial(item_path.greyscale_config_worn)]"
	if(initial(item_path.greyscale_config_inhand_left))
		allowed_configs += "[initial(item_path.greyscale_config_inhand_left)]"
	if(initial(item_path.greyscale_config_inhand_right))
		allowed_configs += "[initial(item_path.greyscale_config_inhand_right)]"

	var/datum/greyscale_modify_menu/menu = new(
		manager,
		user,
		allowed_configs,
		CALLBACK(src, PROC_REF(set_slot_greyscale), manager),
		starting_icon_state = initial(item_path.icon_state),
		starting_config = initial(item_path.greyscale_config),
		starting_colors = loadout?[item_path]?[INFO_GREYSCALE] || initial(item_path.greyscale_colors),
	)

	manager.register_greyscale_menu(menu)
	menu.ui_interact(user)
	return TRUE

/// Sets [category_slot]'s greyscale colors to the colors in the currently opened [open_menu].
/datum/loadout_item/proc/set_slot_greyscale(datum/preference_middleware/loadout/manager, datum/greyscale_modify_menu/open_menu)
	if(!istype(open_menu))
		CRASH("set_slot_greyscale called without a greyscale menu!")

	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	if(!loadout?[item_path])
		manager.select_item(src)

	var/list/colors = open_menu.split_colors
	if(!colors)
		return FALSE

	loadout[item_path][INFO_GREYSCALE] = colors.Join("")
	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return TRUE // update UI

/// Sets the name of the item in the loadout
/datum/loadout_item/proc/set_name(datum/preference_middleware/loadout/manager, mob/user)
	. = FALSE
	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	var/input_name = tgui_input_text(
		user = user,
		message = "What name do you want to give [name]? Leave blank to clear.",
		title = "[name] name",
		default = loadout?[item_path]?[INFO_NAMED], // plop in existing name (if any)
		max_length = MAX_NAME_LEN,
	)
	if(QDELETED(src) || QDELETED(user) || QDELETED(manager) || QDELETED(manager.preferences))
		return .

	if(!islist(loadout?[item_path]))
		manager.select_item(src)
		. = TRUE // update UI

	if(input_name)
		loadout[item_path][INFO_NAMED] = input_name
	else
		loadout[item_path] -= INFO_NAMED

	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return .

/// Used for reskinning an item to an alt skin by default
/datum/loadout_item/proc/set_skin(datum/preference_middleware/loadout/manager, mob/user)
	if(!can_be_reskinned)
		return FALSE

	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	var/static/list/list/cached_reskins = list()
	if(!islist(cached_reskins[item_path]))
		var/obj/item/item_template = new item_path()
		cached_reskins[item_path] = item_template.unique_reskin.Copy()
		qdel(item_template)

	var/list/choices = cached_reskins[item_path].Copy()
	choices["Default"] = TRUE

	var/input_skin = tgui_input_list(
		user = user,
		message = "What skin do you want this to be?",
		title = "Reskin [name]",
		items = choices,
		default = loadout?[item_path]?[INFO_RESKIN],
	)
	if(QDELETED(src) || QDELETED(user) || QDELETED(manager) || QDELETED(manager.preferences))
		return FALSE

	if(!islist(loadout?[type]))
		manager.select_item(src)

	if(!input_skin || input_skin == "Default")
		loadout[item_path] -= INFO_RESKIN
	else
		loadout[item_path][INFO_RESKIN] = input_skin

	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return TRUE // always update UI

/**
 * Place our [var/item_path] into [outfit].
 *
 * By default, just adds the item into the outfit's backpack contents, if non-visual.
 *
 * outfit - The outfit we're equipping our items into.
 * equipper - If we're equipping out outfit onto a mob at the time, this is the mob it is equipped on. Can be null.
 * visual - If TRUE, then our outfit is only for visual use (for example, a preview).
 */
/datum/loadout_item/proc/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(!visuals_only)
		LAZYADD(outfit.backpack_contents, item_path)

/**
 * Called When the item is equipped on [equipper].
 *
 * At this point the item is in the mob's contents
 *
 * preference_source - the datum/preferences our loadout item originated from - cannot be null
 * equipper - the mob we're equipping this item onto - cannot be null
 * visuals_only - whether or not this is only concerned with visual things (not backpack, not renaming, etc)
 * preference_list - what the raw loadout list looks like in the preferences
 */
/datum/loadout_item/proc/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list = preference_source?.read_preference(/datum/preference/loadout),
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	ASSERT(!isnull(equipped_item))
	var/list/item_details = preference_list[item_path]

	if(can_be_greyscale && item_details?[INFO_GREYSCALE])
		equipped_item.set_greyscale(item_details[INFO_GREYSCALE])
		equipper.update_clothing(equipped_item.slot_flags)

	if(can_be_named && item_details?[INFO_NAMED] && !visuals_only)
		equipped_item.name = item_details[INFO_NAMED]
		ADD_TRAIT(equipped_item, TRAIT_WAS_RENAMED, "Loadout")

	if(can_be_reskinned && item_details?[INFO_RESKIN])
		var/skin_chosen = item_details[INFO_RESKIN]
		if(skin_chosen in equipped_item.unique_reskin)
			equipped_item.current_skin = skin_chosen
			equipped_item.icon_state = equipped_item.unique_reskin[skin_chosen]
			if(istype(equipped_item, /obj/item/clothing/accessory))
				// Snowflake handing for accessories, because we need to update the thing it's attached to instead
				if(isclothing(equipped_item.loc))
					var/obj/item/clothing/under/attached_to = equipped_item.loc
					attached_to.update_accessory_overlay()
					equipper.update_clothing(ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)
			else
				equipper.update_clothing(equipped_item.slot_flags)

		else
			// Not valid, update the preference
			item_details -= INFO_RESKIN
			preference_source.write_preference(GLOB.preference_entries[/datum/preference/loadout], preference_list)

	return equipped_item

/// Returns a formatted list of data for this loadout item, for use in UIs
/datum/loadout_item/proc/to_ui_data() as /list
	SHOULD_CALL_PARENT(TRUE)

	var/list/formatted_item = list()
	formatted_item["name"] = name
	formatted_item["path"] = item_path
	formatted_item["buttons"] = get_ui_buttons()
	formatted_item["icon"] = ui_icon
	formatted_item["icon_state"] = ui_icon_state
	return formatted_item

/**
 * Returns a list of UI buttons for this loadout item
 * These will automatically be turned into buttons in the UI, according to they icon you provide
 * act_key should match a key to handle in [handle_loadout_action] - this is how you react to the button being pressed
 */
/datum/loadout_item/proc/get_ui_buttons() as /list
	SHOULD_CALL_PARENT(TRUE)

	var/list/button_list = list()

	for(var/tooltip in additional_tooltip_contents)
		// Not real buttons - have no act - but just provides a "hey, this is special!" tip
		UNTYPED_LIST_ADD(button_list, list(
			"icon" = FA_ICON_INFO,
			"tooltip" = tooltip,
		))

	if(can_be_greyscale)
		UNTYPED_LIST_ADD(button_list, list(
			"icon" = FA_ICON_PALETTE,
			"act_key" = "select_color",
			"tooltip" = "Modify this item's color.",
		))

	if(can_be_named)
		UNTYPED_LIST_ADD(button_list, list(
			"icon" = FA_ICON_PEN,
			"act_key" = "set_name",
			"tooltip" = "Modify the name this item will have.",
		))

	if(can_be_reskinned)
		UNTYPED_LIST_ADD(button_list, list(
			"icon" = FA_ICON_THEATER_MASKS,
			"act_key" = "set_skin",
			"tooltip" = "Change the default skin of this item.",
		))

	return button_list
