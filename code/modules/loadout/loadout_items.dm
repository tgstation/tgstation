/// Global list of ALL loadout datums instantiated.
/// Loadout datums are created by loadout categories.
GLOBAL_LIST_EMPTY(all_loadout_datums)

/// Global list of all loadout categories
/// Doesn't really NEED to be a global but we need to init this early for preferences,
/// as the categories instantiate all the loadout datums
GLOBAL_LIST_INIT(all_loadout_categories, init_loadout_categories())

/// Inits the global list of loadout category singletons
/// Also inits loadout item singletons
/proc/init_loadout_categories()
	var/list/loadout_categories = list()
	for(var/category_type in subtypesof(/datum/loadout_category))
		loadout_categories += new category_type()

	sortTim(loadout_categories, /proc/cmp_loadout_categories)
	return loadout_categories

/proc/cmp_loadout_categories(datum/loadout_category/A, datum/loadout_category/B)
	var/a_order = A::tab_order
	var/b_order = B::tab_order
	if(a_order == b_order)
		return cmp_text_asc(A::category_name, B::category_name)
	return cmp_numeric_asc(a_order, b_order)

/**
 * # Loadout item datum
 *
 * Singleton that holds all the information about each loadout items, and how to equip them.
 */
/datum/loadout_item
	/// The abstract parent of this loadout item, to determine which items to not instantiate
	abstract_type = /datum/loadout_item
	/// The category of the loadout item. Set automatically in New
	VAR_FINAL/datum/loadout_category/category
	/// Displayed name of the loadout item.
	/// Defaults to the item's name if unset.
	var/name
	/// Title of a group that this item will be bundled under
	/// Defaults to parent category's title if unset
	var/group = null
	/// Loadout flags, see LOADOUT_FLAG_* defines
	var/loadout_flags = NONE
	/// The actual item path of the loadout item.
	var/obj/item/item_path
	/// Icon file (DMI) for the UI to use for preview icons.
	/// Set automatically if null
	var/ui_icon
	/// Icon state for the UI to use for preview icons.
	/// Set automatically if null
	var/ui_icon_state
	/// Base typepath to what reskin datum this item can use to reskin into
	/// Doesn't verify that the item_path actually has these reskins
	var/reskin_datum
	/// A list of greyscale colors that are used for items that have greyscale support, but don't allow full customization.
	/// This is an assoc list of /datum/job_department -> colors, or /datum/job -> colors, allowing for preset colors based on player chosen job.
	/// Jobs are prioritized over departments.
	/// Note: You don't need to set a color for every job or department!
	var/list/job_greyscale_palettes

/datum/loadout_item/New(category)
	src.category = category

	if(!(loadout_flags & LOADOUT_FLAG_BLOCK_GREYSCALING) && is_greyscale_item())
		loadout_flags |= LOADOUT_FLAG_GREYSCALING_ALLOWED

	if(loadout_flags & LOADOUT_FLAG_JOB_GREYSCALING)
		var/default_colors = SSgreyscale.ParseColorString(item_path::greyscale_colors)
		var/list/final_palette = LAZYLISTDUPLICATE(job_greyscale_palettes)
		switch(length(default_colors))
			if(1)
				LAZYOR(final_palette, default_one_color_job_palette())
			if(2 to INFINITY)
				stack_trace("[length(default_colors)] color job palettes are not implemented yet, please do so.")
		job_greyscale_palettes = final_palette

	if(isnull(name))
		name = item_path::name

	if(isnull(ui_icon) && isnull(ui_icon_state))
		ui_icon = item_path::icon_preview || item_path::icon
		ui_icon_state = item_path::icon_state_preview || item_path::icon_state

/datum/loadout_item/Destroy(force, ...)
	if(!force)
		stack_trace("QDEL called on loadout item [type]. This shouldn't ever happen. (Use FORCE if necessary.)")
		return QDEL_HINT_LETMELIVE

	GLOB.all_loadout_datums -= item_path
	return ..()

/// Checks if the item is capable of being recolored / is a GAGS item.
/datum/loadout_item/proc/is_greyscale_item()
	if(!(item_path::flags_1 & IS_PLAYER_COLORABLE_1))
		return FALSE
	if(!item_path::greyscale_config || !item_path::greyscale_colors)
		return FALSE
	return TRUE

/**
 * Takes in an action from a loadout manager and applies it
 *
 * Useful for subtypes of loadout items with unique actions
 *
 * Return TRUE to force an update to the UI / character preview
 */
/datum/loadout_item/proc/handle_loadout_action(datum/preference_middleware/loadout/manager, mob/user, action, params)
	SHOULD_CALL_PARENT(TRUE)

	switch(action)
		if("select_color")
			if((loadout_flags & LOADOUT_FLAG_GREYSCALING_ALLOWED) && !(loadout_flags & LOADOUT_FLAG_JOB_GREYSCALING))
				return set_item_color(manager, user)

		if("set_name")
			if(loadout_flags & LOADOUT_FLAG_ALLOW_NAMING)
				return set_name(manager, user)

		if("set_skin")
			if(reskin_datum)
				return set_skin(manager, user, params)

	return TRUE

/// Opens up the GAGS editing menu.
/datum/loadout_item/proc/set_item_color(datum/preference_middleware/loadout/manager, mob/user)
	if(manager.menu)
		return FALSE

	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
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

/// Callback for GAGS menu to set this item's color.
/datum/loadout_item/proc/set_slot_greyscale(datum/preference_middleware/loadout/manager, datum/greyscale_modify_menu/open_menu)
	if(!istype(open_menu))
		CRASH("set_slot_greyscale called without a greyscale menu!")

	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	if(!loadout?[item_path])
		return FALSE

	var/list/colors = open_menu.split_colors
	if(!colors)
		return FALSE

	loadout[item_path][INFO_GREYSCALE] = colors.Join("")
	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return TRUE // update UI

/// Sets the name of the item.
/datum/loadout_item/proc/set_name(datum/preference_middleware/loadout/manager, mob/user)
	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	var/input_name = tgui_input_text(
		user = user,
		message = "What name do you want to give the [name]? Leave blank to clear.",
		title = "[name] name",
		default = loadout?[item_path]?[INFO_NAMED], // plop in existing name (if any)
		max_length = MAX_NAME_LEN,
	)
	if(QDELETED(src) || QDELETED(user) || QDELETED(manager) || QDELETED(manager.preferences))
		return FALSE

	loadout = manager.preferences.read_preference(/datum/preference/loadout) // Make sure no shenanigans happened
	if(!loadout?[item_path])
		return FALSE

	if(input_name)
		loadout[item_path][INFO_NAMED] = input_name
	else if(input_name == "")
		loadout[item_path] -= INFO_NAMED

	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return FALSE // no update needed

/// Used for reskinning an item to an alt skin.
/datum/loadout_item/proc/set_skin(datum/preference_middleware/loadout/manager, mob/user, params)
	var/reskin_to = params["skin"] // sanity checking isn't necessary because it's all checked when equipped anyways
	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	if(!loadout?[item_path])
		return FALSE

	loadout[item_path][INFO_RESKIN] = reskin_to
	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return TRUE // always update UI

/// When passed an outfit, attempts to select a job-appropriate color from job_greyscale_palettes
/datum/loadout_item/proc/get_job_color(datum/outfit/base_outfit)
	if(!istype(base_outfit, /datum/outfit/job))
		return job_greyscale_palettes[/datum/job] // default color

	var/datum/outfit/job/job_outfit = base_outfit
	var/jobtype = job_outfit.jobtype
	if(job_greyscale_palettes[jobtype])
		return job_greyscale_palettes[jobtype]

	var/datum/job/job = SSjob.get_job_type(jobtype)
	if(job.department_for_prefs && job_greyscale_palettes[job.department_for_prefs])
		return job_greyscale_palettes[job.department_for_prefs]

	for(var/job_dept in job.departments_list)
		if(job_greyscale_palettes[job_dept])
			return job_greyscale_palettes[job_dept]

	return job_greyscale_palettes[/datum/job] // default color

/**
 * Place our [item_path] into the passed [outfit].
 *
 * By default, just adds the item into the outfit's backpack contents, if non-visual.
 *
 * Arguments:
 * * outfit - The outfit we're equipping our items into.
 * * equipper - If we're equipping out outfit onto a mob at the time, this is the mob it is equipped on. Can be null.
 * * visual - If TRUE, then our outfit is only for visual use (for example, a preview).
 */
/datum/loadout_item/proc/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(!visuals_only)
		LAZYADD(outfit.backpack_contents, item_path)

/**
 * Called When the item is equipped on [equipper].
 *
 * At this point the item is in the mob's contents
 *
 * Arguments:
 * * preference_source - the datum/preferences our loadout item originated from - cannot be null
 * * item_details - the details of the item in the loadout preferences, such as greyscale, name, reskin, etc
 * * equipper - the mob we're equipping this item onto
 * * outfit - the rest of the outfit being equipped, may be null
 * * visuals_only - whether or not this is only concerned with visual things (not backpack, not renaming, etc)
 *
 * Return a bitflag of slot flags to update
 */
/datum/loadout_item/proc/on_equip_item(obj/item/equipped_item, list/item_details, mob/living/carbon/human/equipper, datum/outfit/outfit, visuals_only = FALSE)
	if(isnull(equipped_item))
		return NONE

	if(!visuals_only)
		ADD_TRAIT(equipped_item, TRAIT_ITEM_OBJECTIVE_BLOCKED, "Loadout")

	var/update_flag = NONE

	if((loadout_flags & LOADOUT_FLAG_GREYSCALING_ALLOWED) && ((loadout_flags & LOADOUT_FLAG_JOB_GREYSCALING) || item_details?[INFO_GREYSCALE]))
		var/item_color = (loadout_flags & LOADOUT_FLAG_JOB_GREYSCALING) ? get_job_color(outfit) : item_details?[INFO_GREYSCALE]
		equipped_item.set_greyscale(item_color)
		update_flag |= equipped_item.slot_flags

	if((loadout_flags & LOADOUT_FLAG_ALLOW_NAMING) && item_details?[INFO_NAMED] && !visuals_only)
		equipped_item.name = trim(item_details[INFO_NAMED], PREVENT_CHARACTER_TRIM_LOSS(MAX_NAME_LEN))
		ADD_TRAIT(equipped_item, TRAIT_WAS_RENAMED, "Loadout")

	if(reskin_datum && item_details?[INFO_RESKIN])
		var/skin_chosen = item_details[INFO_RESKIN]
		for(var/datum/atom_skin/skin_path as anything in valid_subtypesof(reskin_datum))
			if(skin_path::preview_name != skin_chosen)
				continue
			var/datum/atom_skin/skin_instance = GLOB.atom_skins[skin_path]
			skin_instance.apply(equipped_item)
			if(istype(equipped_item, /obj/item/clothing/accessory))
				// Snowflake handing for accessories, because we need to update the thing it's attached to instead
				if(isclothing(equipped_item.loc))
					var/obj/item/clothing/under/attached_to = equipped_item.loc
					attached_to.update_accessory_overlay()
					update_flag |= (ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)
			else
				update_flag |= equipped_item.slot_flags
			break

	return update_flag

/**
 * Returns a formatted list of data for this loadout item.
 */
/datum/loadout_item/proc/to_ui_data() as /list
	SHOULD_CALL_PARENT(TRUE)

	var/list/formatted_item = list()
	var/list/information = list()
	var/list/fetched_info = get_item_information()
	for (var/icon_name in fetched_info)
		information += list(list(
			"icon" = icon_name,
			"tooltip" = fetched_info[icon_name]
		))

	formatted_item["name"] = name
	formatted_item["group"] = group || category.category_name
	formatted_item["path"] = item_path
	formatted_item["information"] = information
	formatted_item["buttons"] = get_ui_buttons()
	formatted_item["reskins"] = get_reskin_options()
	formatted_item["icon"] = ui_icon
	formatted_item["icon_state"] = ui_icon_state
	return formatted_item

/**
 * Returns a list of information to display about this item in the loadout UI.
 * Icon -> tooltip displayed when its hovered over
 */
/datum/loadout_item/proc/get_item_information() as /list
	SHOULD_CALL_PARENT(TRUE)

	// Mothblocks is hellbent on recolorable and reskinnable being only tooltips for items for visual clarity, so ask her before changing these
	var/list/displayed_text = list()
	if((loadout_flags & LOADOUT_FLAG_GREYSCALING_ALLOWED) && !(loadout_flags & LOADOUT_FLAG_JOB_GREYSCALING))
		displayed_text[FA_ICON_PALETTE] = "Recolorable"

	if(reskin_datum)
		displayed_text[FA_ICON_SWATCHBOOK] = "Reskinnable"

	return displayed_text

/**
 * Returns a list of buttons that are shown in the loadout UI for customizing this item.
 *
 * Buttons contain
 * - 'L'abel: The text displayed beside the button
 * - act_key: The key that is sent to the loadout manager when the button is clicked,
 * for use in handle_loadout_action
 * - button_icon: The FontAwesome icon to display on the button
 * - active_key: In the loadout UI, this key is checked  in the user's loadout list for this item
 * to determine if the button is 'active' (green) or not (blue).
 * - active_text: Optional, if provided, the button appears to be a checkbox and this text is shown when 'active'
 * - inactive_text: Optional, if provided, the button appears to be a checkbox and this text is shown when not 'active'
 */
/datum/loadout_item/proc/get_ui_buttons() as /list
	SHOULD_CALL_PARENT(TRUE)

	var/list/button_list = list()

	if((loadout_flags & LOADOUT_FLAG_GREYSCALING_ALLOWED) && !(loadout_flags & LOADOUT_FLAG_JOB_GREYSCALING))
		UNTYPED_LIST_ADD(button_list, list(
			"label" = "Recolor",
			"act_key" = "select_color",
			"button_icon" = FA_ICON_PALETTE,
			"active_key" = INFO_GREYSCALE,
		))

	if(loadout_flags & LOADOUT_FLAG_ALLOW_NAMING)
		UNTYPED_LIST_ADD(button_list, list(
			"label" = "Rename",
			"act_key" = "set_name",
			"button_icon" = FA_ICON_PEN,
			"active_key" = INFO_NAMED,
		))

	return button_list

/**
 * Returns a list of options this item can be reskinned into.
 */
/datum/loadout_item/proc/get_reskin_options() as /list
	if(!reskin_datum)
		return null

	var/list/reskins = list()

	for(var/datum/atom_skin/skin as anything in valid_subtypesof(reskin_datum))
		UNTYPED_LIST_ADD(reskins, list(
			"name" = skin::new_name || skin::preview_name,
			"tooltip" = skin::preview_name,
			"skin_icon" = skin::new_icon,
			"skin_icon_state" = skin::new_icon_state,
		))

	return reskins

/// Default job gags colors for one color gags items
/datum/loadout_item/proc/default_one_color_job_palette()
	return list(
		/datum/job/assistant = COLOR_JOB_ASSISTANT,
		/datum/job/bitrunner = COLOR_JOB_DEFAULT,
		/datum/job/botanist = COLOR_JOB_BOTANIST,
		/datum/job/chemist = COLOR_JOB_CHEMIST,
		/datum/job/chief_engineer = COLOR_JOB_CE,
		/datum/job/chief_medical_officer = COLOR_JOB_CMO,
		/datum/job/clown = COLOR_JOB_CLOWN,
		/datum/job/cook = COLOR_JOB_CHEF,
		/datum/job/coroner = COLOR_JOB_DEFAULT,
		/datum/job/curator = COLOR_DRIED_TAN,
		/datum/job/detective = COLOR_DRIED_TAN,
		/datum/job/geneticist = COLOR_BLUE_GRAY,
		/datum/job/janitor = COLOR_JOB_JANITOR,
		/datum/job/lawyer = COLOR_JOB_LAWYER,
		/datum/job/prisoner = COLOR_PRISONER_ORANGE,
		/datum/job/psychologist = COLOR_DRIED_TAN,
		/datum/job/roboticist = COLOR_JOB_DEFAULT,
		/datum/job/shaft_miner = COLOR_DARK_BROWN,
		/datum/job_department/command = COLOR_JOB_COMMAND_GENERIC,
		/datum/job_department/engineering = COLOR_JOB_ENGI_GENERIC,
		/datum/job_department/medical = COLOR_JOB_MED_GENERIC,
		/datum/job_department/security = COLOR_JOB_SEC_GENERIC,
		/datum/job_department/science = COLOR_JOB_SCI_GENERIC,
		/datum/job_department/cargo = COLOR_JOB_CARGO_GENERIC,
		/datum/job = COLOR_JOB_DEFAULT, // default for any job not listed above
	)
