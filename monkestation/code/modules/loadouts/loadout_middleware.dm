/datum/preference_middleware/loadout
	var/datum/greyscale_modify_menu/menu

	action_delegations = list(
		"select_item" = PROC_REF(select_item),
		"set_name" = PROC_REF(set_name),
		"display_restrictions" = PROC_REF(display_restrictions),
		"clear_all_items" = PROC_REF(clear_all_items),
		"donator_explain" = PROC_REF(donator_explain),
		"ckey_explain" = PROC_REF(ckey_explain),
		"select_color" = PROC_REF(select_color),
	)

/datum/preference_middleware/loadout/get_ui_static_data()
	// [name] is the name of the tab that contains all the corresponding contents.
	// [title] is the name at the top of the list of corresponding contents.
	// [contents] is a formatted list of all the possible items for that slot.
	//  - [contents.path] is the path the singleton datum holds
	//  - [contents.name] is the name of the singleton datum
	//  - [contents.is_renamable], whether the item can be renamed in the UI
	//  - [contents.is_greyscale], whether the item can be greyscaled in the UI
	//  - [contents.tooltip_text], any additional tooltip text that hovers over the item's select button

	var/list/loadout_tabs = list()
	loadout_tabs += list(list("name" = "Belt", "title" = "Belt Slot Items", "contents" = list_to_data(GLOB.loadout_belts)))
	loadout_tabs += list(list("name" = "Ears", "title" = "Ear Slot Items", "contents" = list_to_data(GLOB.loadout_ears)))
	loadout_tabs += list(list("name" = "Glasses", "title" = "Glasses Slot Items", "contents" = list_to_data(GLOB.loadout_glasses)))
	loadout_tabs += list(list("name" = "Gloves", "title" = "Glove Slot Items", "contents" = list_to_data(GLOB.loadout_gloves)))
	loadout_tabs += list(list("name" = "Head", "title" = "Head Slot Items", "contents" = list_to_data(GLOB.loadout_helmets)))
	loadout_tabs += list(list("name" = "Mask", "title" = "Mask Slot Items", "contents" = list_to_data(GLOB.loadout_masks)))
	loadout_tabs += list(list("name" = "Neck", "title" = "Neck Slot Items", "contents" = list_to_data(GLOB.loadout_necks)))
	loadout_tabs += list(list("name" = "Shoes", "title" = "Shoe Slot Items", "contents" = list_to_data(GLOB.loadout_shoes)))
	loadout_tabs += list(list("name" = "Suit", "title" = "Suit Slot Items", "contents" = list_to_data(GLOB.loadout_exosuits)))
	loadout_tabs += list(list("name" = "Jumpsuit", "title" = "Uniform Slot Items", "contents" = list_to_data(GLOB.loadout_jumpsuits)))
	loadout_tabs += list(list("name" = "Formal", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.loadout_undersuits)))
	loadout_tabs += list(list("name" = "Misc. Under", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.loadout_miscunders)))
	loadout_tabs += list(list("name" = "Accessory", "title" = "Uniform Accessory Slot Items", "contents" = list_to_data(GLOB.loadout_accessory)))
	loadout_tabs += list(list("name" = "Inhand", "title" = "In-hand Items", "contents" = list_to_data(GLOB.loadout_inhand_items)))
	loadout_tabs += list(list("name" = "Toys", "title" = "Toys! ([MAX_ALLOWED_MISC_ITEMS] max)", "contents" = list_to_data(GLOB.loadout_toys)))
	loadout_tabs += list(list("name" = "Other", "title" = "Backpack Items ([MAX_ALLOWED_MISC_ITEMS] max)", "contents" = list_to_data(GLOB.loadout_pocket_items)))
	loadout_tabs += list(list("name" = "Effects", "title" = "Unique Effects", "contents" = list_to_data(GLOB.loadout_effects)))
	loadout_tabs += list(list("name" = "Unusuals", "title" = "Unusual Hats", "contents" = convert_stored_unusuals_to_data()))

	return list("loadout_tabs" = loadout_tabs)

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	. = ..()
	var/list/data = list()

	var/list/all_selected_paths = list()
	for(var/path in preferences.loadout_list)
		all_selected_paths += path

	var/list/all_selected_unusuals = list()
	if(length(preferences.special_loadout_list["unusual"]))
		all_selected_unusuals = preferences.special_loadout_list["unusual"]

	data["selected_loadout"] = all_selected_paths
	data["selected_unusuals"] = all_selected_unusuals
	data["user_is_donator"] = !!(preferences.parent.patreon?.is_donator() || preferences.parent.twitch?.is_donator() || is_admin(preferences.parent))
	data["mob_name"] = preferences.read_preference(/datum/preference/name/real_name)
	data["ismoth"] = istype(preferences.parent.prefs.read_preference(/datum/preference/choiced/species), /datum/species/moth) // Moth's humanflaticcon isn't the same dimensions for some reason
	data["total_coins"] = preferences.metacoins

	return data

/datum/preference_middleware/loadout/proc/return_item(list/params)
	var/datum/loadout_item/interacted_item
	if(params["path"])
		interacted_item = GLOB.all_loadout_datums[text2path(params["path"])]
		if(!interacted_item)
			stack_trace("Failed to locate desired loadout item (path: [params["path"]]) in the global list of loadout datums!")
			return null

	//Here we will perform basic checks to ensure there are no exploits happening
	if(interacted_item.donator_only && !preferences.parent.patreon?.is_donator() && !preferences.parent.twitch?.is_donator() && !is_admin(preferences.parent))
		message_admins("LOADOUT SYSTEM: Possible exploit detected, non-donator [preferences.parent.ckey] tried loading [interacted_item.item_path], but this is donator only.")
		return null

	if(interacted_item.ckeywhitelist && (!(preferences.parent.ckey in interacted_item.ckeywhitelist)) && !is_admin(preferences.parent))
		message_admins("LOADOUT SYSTEM: Possible exploit detected, non-donator [preferences.parent.ckey] tried loading [interacted_item.item_path], but this is ckey locked.")
		return null

	if(interacted_item.requires_purchase && !(interacted_item.item_path in preferences.inventory))
		message_admins("LOADOUT SYSTEM: Possible exploit detected, [preferences.parent.ckey] has tried loading [interacted_item.item_path], but does not own that item.")
		return null

	return interacted_item

/datum/preference_middleware/loadout/proc/select_item(list/params, mob/user)
	if(params["unusual_spawning_requirements"])
		unusual_selection(params, user)
		return

	var/datum/loadout_item/interacted_item = return_item(params)
	if(!interacted_item)
		return

	if(params["deselect"])
		deselect_item(interacted_item, user)
		return

	var/num_misc_items = 0
	var/datum/loadout_item/first_misc_found
	for(var/datum/loadout_item/item as anything in loadout_list_to_datums(preferences.loadout_list))
		if(item.category == interacted_item.category)
			if((item.category == LOADOUT_ITEM_MISC || item.category == LOADOUT_ITEM_TOYS) && ++num_misc_items < MAX_ALLOWED_MISC_ITEMS)
				if(!first_misc_found)
					first_misc_found = item
				continue

			deselect_item(first_misc_found || item, user)
			continue

	LAZYSET(preferences.loadout_list, interacted_item.item_path, list())
	var/datum/tgui/ui = SStgui.get_open_ui(user, preferences)
	ui.send_update()
	preferences.character_preview_view?.update_body()

/datum/preference_middleware/proc/unusual_selection(list/params, mob/user)
	if("[params["unusual_placement"]]" in preferences.special_loadout_list["unusual"])
		preferences.special_loadout_list["unusual"] -= params["unusual_placement"]
		preferences.save_preferences()
		var/datum/tgui/ui = SStgui.get_open_ui(user, preferences)
		ui.send_update()
		return

	if(!islist(preferences.special_loadout_list["unusual"]))
		preferences.special_loadout_list["unusual"] = list()

	preferences.special_loadout_list["unusual"] += "[params["unusual_placement"]]"
	var/datum/tgui/ui = SStgui.get_open_ui(user, preferences)
	ui.send_update()
	preferences.character_preview_view?.update_body()

/// Deselect [deselected_item].
/datum/preference_middleware/proc/deselect_item(datum/loadout_item/deselected_item, mob/user)
	LAZYREMOVE(preferences.loadout_list, deselected_item.item_path)
	var/datum/tgui/ui = SStgui.get_open_ui(user, preferences)
	ui.send_update()
	preferences.character_preview_view?.update_body()

/datum/preference_middleware/proc/list_to_data(list_of_datums)
	if(!LAZYLEN(list_of_datums) || QDELETED(preferences)|| QDELETED(preferences.parent))
		return

	var/list/formatted_list = new(length(list_of_datums))

	var/array_index = 1
	for(var/datum/loadout_item/item as anything in list_of_datums)
		if(QDELETED(preferences) || QDELETED(preferences.parent))
			return
		if(!isnull(item.ckeywhitelist)) //These checks are also performed in the backend.
			if(!(preferences.parent.ckey in item.ckeywhitelist) && !is_admin(preferences.parent))
				formatted_list.len--
				continue
		if(item.donator_only) //These checks are also performed in the backend.
			if((!preferences.parent.patreon?.is_donator() && !preferences.parent.twitch?.is_donator()) && !is_admin(preferences.parent))
				formatted_list.len--
				continue

		if(item.admin_only) //These checks are also performed in the backend.
			if(!is_admin(preferences.parent))
				formatted_list.len--
				continue

		if(item.required_season && !check_holidays(item.required_season))
			formatted_list.len--
			continue

		if(item.requires_purchase && !(item.item_path in preferences.inventory))
			formatted_list.len--
			continue

		var/atom/loadout_atom = item.item_path

		var/list/formatted_item = list()
		formatted_item["name"] = item.name
		formatted_item["path"] = item.item_path
		formatted_item["is_greyscale"] = !!(initial(loadout_atom.greyscale_config) && initial(loadout_atom.greyscale_colors) && (initial(loadout_atom.flags_1) & IS_PLAYER_COLORABLE_1))
		formatted_item["is_renamable"] = item.can_be_named
		formatted_item["is_job_restricted"] = !isnull(item.restricted_roles)
		formatted_item["is_donator_only"] = !isnull(item.donator_only)
		formatted_item["is_ckey_whitelisted"] = !isnull(item.ckeywhitelist)
		if(LAZYLEN(item.additional_tooltip_contents))
			formatted_item["tooltip_text"] = item.additional_tooltip_contents.Join("\n")

		formatted_list[array_index++] = formatted_item

	return formatted_list

/datum/preference_middleware/proc/convert_stored_unusuals_to_data()
	var/list/data = preferences.extra_stat_inventory["unusual"]
	if(!length(data))
		return

	var/list/formatted_list = new(length(data))

	var/array_index = 1
	for(var/iter as anything in data)
		var/list/formatted_item = list()
		formatted_item["name"] = data[array_index]["name"]
		formatted_item["path"] = data[array_index]["unusual_type"]
		formatted_item["unusual_placement"] = "[array_index]"
		formatted_item["is_greyscale"] = FALSE
		formatted_item["is_renamable"] = FALSE
		formatted_item["is_job_restricted"] = FALSE
		formatted_item["is_donator_only"] = FALSE
		formatted_item["is_ckey_whitelisted"] = FALSE
		formatted_item["unusual_spawning_requirements"] = TRUE

		formatted_list[array_index++] = formatted_item

	return formatted_list

/datum/preference_middleware/loadout/proc/set_name(list/params, mob/user)
	var/datum/loadout_item/item = return_item(params)
	if(!item)
		return

	var/current_name = ""
	if(INFO_NAMED in preferences.loadout_list[item.item_path])
		current_name = preferences.loadout_list[item.item_path][INFO_NAMED]

	var/input_name = stripped_input(preferences.parent, "What name do you want to give [item.name]? Leave blank to clear.", "[item.name] name", current_name, MAX_NAME_LEN)
	if(QDELETED(src) || QDELETED(preferences.parent) || QDELETED(preferences))
		return

	if(!(item.item_path in preferences.loadout_list))
		to_chat(preferences.parent, span_warning("Select the item before attempting to name to it!"))
		return

	if(input_name)
		preferences.loadout_list[item.item_path][INFO_NAMED] = input_name
	else
		if(INFO_NAMED in preferences.loadout_list[item.item_path])
			preferences.loadout_list[item.item_path] -= INFO_NAMED

/datum/preference_middleware/loadout/proc/display_restrictions(list/params, mob/user)
	var/datum/loadout_item/item = return_item(params)
	if(!item)
		return

	var/composed_message = span_boldnotice("The [initial(item.item_path.name)] is restricted to the following roles: <br>")
	for(var/job_type in item.restricted_roles)
		composed_message += span_green("[job_type] <br>")

	to_chat(preferences.parent, examine_block(composed_message))

/// Select [path] item to [category_slot] slot, and open up the greyscale UI to customize [path] in [category] slot.
/datum/preference_middleware/loadout/proc/select_color(list/params, mob/user)
	var/datum/loadout_item/item = return_item(params)
	if(!item)
		return

	if(menu)
		to_chat(preferences.parent, span_warning("You already have a greyscaling window open!"))
		return

	var/obj/item/colored_item = item.item_path

	var/list/allowed_configs = list()
	if(initial(colored_item.greyscale_config))
		allowed_configs += "[initial(colored_item.greyscale_config)]"
	if(initial(colored_item.greyscale_config_worn))
		allowed_configs += "[initial(colored_item.greyscale_config_worn)]"
	if(initial(colored_item.greyscale_config_inhand_left))
		allowed_configs += "[initial(colored_item.greyscale_config_inhand_left)]"
	if(initial(colored_item.greyscale_config_inhand_right))
		allowed_configs += "[initial(colored_item.greyscale_config_inhand_right)]"

	var/slot_starting_colors = initial(colored_item.greyscale_colors)
	if(INFO_GREYSCALE in preferences.loadout_list[colored_item])
		slot_starting_colors = preferences.loadout_list[colored_item][INFO_GREYSCALE]

	menu = new(
		src,
		usr,
		allowed_configs,
		CALLBACK(src, PROC_REF(set_slot_greyscale), colored_item),
		starting_icon_state = initial(colored_item.icon_state),
		starting_config = initial(colored_item.greyscale_config),
		starting_colors = slot_starting_colors,
	)
	RegisterSignal(menu, COMSIG_PREQDELETED, TYPE_PROC_REF(/datum/preference_middleware/loadout, cleanup_greyscale_menu))
	menu.ui_interact(usr)

/// A proc to make sure our menu gets null'd properly when it's deleted.
/// If we delete the greyscale menu from the greyscale datum, we don't null it correctly here, it harddels.
/datum/preference_middleware/loadout/proc/cleanup_greyscale_menu(datum/source)
	SIGNAL_HANDLER

	menu = null

/// Sets [category_slot]'s greyscale colors to the colors in the currently opened [open_menu].
/datum/preference_middleware/loadout/proc/set_slot_greyscale(path, datum/greyscale_modify_menu/open_menu)
	if(!open_menu)
		CRASH("set_slot_greyscale called without a greyscale menu!")

	if(!(path in preferences.loadout_list))
		to_chat(preferences.parent, span_warning("Select the item before attempting to apply greyscale to it!"))
		return

	var/list/colors = open_menu.split_colors
	if(colors)
		preferences.loadout_list[path][INFO_GREYSCALE] = colors.Join("")

/datum/preference_middleware/loadout/proc/clear_all_items()
	LAZYNULL(preferences.loadout_list)
	preferences.special_loadout_list["unusual"] = list()
	preferences.character_preview_view.update_body()

/datum/preference_middleware/loadout/proc/ckey_explain(list/params, mob/user)
	to_chat(preferences.parent, examine_block(span_green("This item is restricted to your ckey only. Thank you!")))

/datum/preference_middleware/loadout/proc/donator_explain(list/params, mob/user)
	if(preferences.parent.patreon?.is_donator() || preferences.parent.twitch?.is_donator())
		to_chat(preferences.parent, examine_block("<b><font color='#f566d6'>Thank you for donating, this item is for you <3!</font></b>"))
	else
		to_chat(preferences.parent, examine_block(span_boldnotice("This item is restricted to donators only, for more information, please check the discord(#server-info) for more information!")))
