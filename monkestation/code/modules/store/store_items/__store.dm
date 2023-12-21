/// Global list of ALL store datums instantiated.
GLOBAL_LIST_EMPTY(all_store_datums)

/// -- The loadout manager and UI --
/// Tracking when a client has an open loadout manager, to prevent funky stuff.
/client
	/// A ref to store_manager datum.
	var/datum/store_manager/open_store_ui = null

/// Datum holder for the loadout manager UI.
/datum/store_manager
	/// The client of the person using the UI
	var/client/owner
	/// The current selected loadout list.
	var/list/loadout_on_open
	/// The key of the dummy we use to generate sprites
	var/dummy_key
	/// The dir the dummy is facing.
	var/list/dummy_dir = list(SOUTH)
	/// A ref to the dummy outfit we're using
	var/datum/outfit/player_loadout/custom_loadout
	/// Whether we see our favorite job's clothes on the dummy
	var/view_job_clothes = TRUE
	/// Our currently open greyscaling menu.
	var/datum/greyscale_modify_menu/menu
	/// Whether we need to update our dummy sprite next ui_data or not.
	var/update_dummysprite = TRUE
	/// Our preview sprite.
	var/icon/dummysprite

/datum/store_manager/Destroy(force, ...)
	owner = null
	QDEL_NULL(menu)
	QDEL_NULL(custom_loadout)
	return ..()

/datum/store_manager/New(user)
	owner = CLIENT_FROM_VAR(user)
	owner.open_store_ui = src
	custom_loadout = new()

/datum/store_manager/ui_close(mob/user)
	owner?.prefs.save_character()
	if(menu)
		SStgui.close_uis(menu)
		menu = null
	owner?.open_store_ui = null
	qdel(custom_loadout)
	qdel(src)

/datum/store_manager/ui_state(mob/user)
	return GLOB.always_state

/datum/store_manager/ui_interact(mob/user, datum/tgui/ui)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StoreManager")
		ui.open()

/datum/store_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/store_item/interacted_item
	if(params["path"])
		interacted_item = GLOB.all_store_datums[text2path(params["path"])]
		if(!interacted_item)
			stack_trace("Failed to locate desired loadout item (path: [params["path"]]) in the global list of loadout datums!")
			return

	switch(action)
		// Closes the UI, reverting our loadout to before edits if params["revert"] is set
		if("close_ui")
			if(params["revert"])
				owner.prefs.loadout_list = loadout_on_open
			SStgui.close_uis(src)
			return

		if("select_item")
			select_item(interacted_item)
			owner?.prefs?.character_preview_view.update_body()
			owner?.prefs?.update_static_data(usr)

		// Rotates the dummy left or right depending on params["dir"]
		if("rotate_dummy")
			rotate_model_dir(params["dir"])

		// Toggles between showing all dirs of the dummy at once.
		if("show_all_dirs")
			toggle_model_dirs()

		if("update_preview")
			owner?.prefs?.character_preview_view.update_body()

	return TRUE

/// Select [path] item to [category_slot] slot.
/datum/store_manager/proc/select_item(datum/store_item/selected_item)
	if(selected_item.item_path in owner.prefs.inventory)
		return //safety
	selected_item.attempt_purchase(owner)

/// Rotate the dummy [DIR] direction, or reset it to SOUTH dir if we're showing all dirs at once.
/datum/store_manager/proc/rotate_model_dir(dir)
	if(dir == "left")
		owner?.prefs?.character_preview_view.dir = turn(owner?.prefs?.character_preview_view.dir, 90)
	else
		owner?.prefs?.character_preview_view.dir = turn(owner?.prefs?.character_preview_view.dir, -90)

/// Toggle between showing all the dirs and just the front dir of the dummy.
/datum/store_manager/proc/toggle_model_dirs()
	if(dummy_dir.len > 1)
		dummy_dir = list(SOUTH)
	else
		dummy_dir = GLOB.cardinals

/datum/store_manager/ui_data(mob/user)
	var/list/data = list()

	var/list/all_selected_paths = list()
	for(var/path in owner?.prefs?.loadout_list)
		all_selected_paths += path
	data["user_is_donator"] = !!(owner.patreon?.is_donator() || owner.twitch?.is_donator() || is_admin(owner))
	data["owned_items"] = user.client.prefs.inventory

	data["total_coins"] = user.client.prefs.metacoins

	return data

/datum/store_manager/ui_static_data()
	var/list/data = list()

	// [name] is the name of the tab that contains all the corresponding contents.
	// [title] is the name at the top of the list of corresponding contents.
	// [contents] is a formatted list of all the possible items for that slot.
	//  - [contents.path] is the path the singleton datum holds
	//  - [contents.name] is the name of the singleton datum
	//  - [contents.item_cost], the total cost of this item

	var/list/loadout_tabs = list()
	loadout_tabs += list(list("name" = "Belt", "title" = "Belt Slot Items", "contents" = list_to_data(GLOB.store_belts)))
	loadout_tabs += list(list("name" = "Ears", "title" = "Ear Slot Items", "contents" = list_to_data(GLOB.store_ears)))
	loadout_tabs += list(list("name" = "Glasses", "title" = "Glasses Slot Items", "contents" = list_to_data(GLOB.store_glasses)))
	loadout_tabs += list(list("name" = "Gloves", "title" = "Glove Slot Items", "contents" = list_to_data(GLOB.store_gloves)))
	loadout_tabs += list(list("name" = "Head", "title" = "Head Slot Items", "contents" = list_to_data(GLOB.store_head)))
	loadout_tabs += list(list("name" = "Mask", "title" = "Mask Slot Items", "contents" = list_to_data(GLOB.store_masks)))
	loadout_tabs += list(list("name" = "Neck", "title" = "Neck Slot Items", "contents" = list_to_data(GLOB.store_neck)))
	loadout_tabs += list(list("name" = "Shoes", "title" = "Shoe Slot Items", "contents" = list_to_data(GLOB.store_shoes)))
	loadout_tabs += list(list("name" = "Suit", "title" = "Suit Slot Items", "contents" = list_to_data(GLOB.store_suits)))
	loadout_tabs += list(list("name" = "Jumpsuit", "title" = "Uniform Slot Items", "contents" = list_to_data(GLOB.store_jumpsuits)))
	loadout_tabs += list(list("name" = "Formal", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.store_undersuits)))
	loadout_tabs += list(list("name" = "Misc. Under", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.store_miscunders)))
	loadout_tabs += list(list("name" = "Accessory", "title" = "Uniform Accessory Slot Items", "contents" = list_to_data(GLOB.store_accessory)))
	loadout_tabs += list(list("name" = "Inhand", "title" = "In-hand Items", "contents" = list_to_data(GLOB.store_inhand_items)))
	loadout_tabs += list(list("name" = "Toys", "title" = "Toys!)", "contents" = list_to_data(GLOB.store_toys)))
	loadout_tabs += list(list("name" = "Other", "title" = "Backpack Items)", "contents" = list_to_data(GLOB.store_pockets)))

	data["loadout_tabs"] = loadout_tabs

	return data

/*
 * Takes an assoc list of [typepath]s to [singleton datum]
 * And formats it into an object for TGUI.
 *
 * - list[name] is the name of the datum.
 * - list[path] is the typepath of the item.
 */
/datum/store_manager/proc/list_to_data(list_of_datums)
	if(!LAZYLEN(list_of_datums))
		return

	var/list/formatted_list = new(length(list_of_datums))
	var/array_index = 1
	for(var/datum/store_item/item as anything in list_of_datums)
		if(item.hidden)
			formatted_list.len--
			continue
		var/atom/new_item = new item.item_path
		var/list/formatted_item = list()
		formatted_item["name"] = item.name
		formatted_item["path"] = item.item_path
		formatted_item["cost"] = item.item_cost
		formatted_item["desc"] = new_item.desc
		formatted_item["item_path"] = new_item.type
		formatted_item["job_restricted"] = null

		var/datum/loadout_item/selected = GLOB.all_loadout_datums[new_item.type]
		if(selected)
			if(length(selected.restricted_roles))
				formatted_item["job_restricted"] = selected.restricted_roles.Join(", ")


		var/icon/icon = getFlatIcon(new_item)
		var/md5 = md5(fcopy_rsc(icon))
		if(!SSassets.cache["photo_[md5]_[item.name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[item.name]_icon.png", icon)
		SSassets.transport.send_assets(usr, list("photo_[md5]_[item.name]_icon.png" = icon))

		formatted_item["icon"] = SSassets.transport.get_asset_url("photo_[md5]_[item.name]_icon.png")
		formatted_list[array_index++] = formatted_item
		qdel(new_item)

	return formatted_list



/*
 * Generate a list of singleton store_item datums from all subtypes of [type_to_generate]
 *
 * returns a list of singleton datums.
 */
/proc/generate_store_items(type_to_generate)
	RETURN_TYPE(/list)

	. = list()
	if(!ispath(type_to_generate))
		CRASH("generate_store_items(): called with an invalid or null path as an argument!")

	for(var/datum/store_item/found_type as anything in subtypesof(type_to_generate))
		/// Any item without a name is "abstract"
		if(isnull(initial(found_type.name)))
			continue

		if(!ispath(initial(found_type.item_path)))
			stack_trace("generate_loadout_items(): Attempted to instantiate a loadout item ([initial(found_type.name)]) with an invalid or null typepath! (got path: [initial(found_type.item_path)])")
			continue

		var/datum/store_item/spawned_type = new found_type()
		GLOB.all_store_datums[spawned_type.item_path] = spawned_type
		. |= spawned_type
