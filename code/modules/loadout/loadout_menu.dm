/datum/preference_middleware/loadout
	action_delegations = list(
		"clear_all_items" = PROC_REF(action_clear_all),
		"pass_to_loadout_item" = PROC_REF(action_pass_to_loadout_item),
		"rotate_dummy" = PROC_REF(action_rotate_model_dir),
		"select_item" = PROC_REF(action_select_item),
		"toggle_job_clothes" = PROC_REF(action_toggle_job_outfit),
		"close_greyscale_menu" = PROC_REF(force_close_greyscale_menu),
	)
	/// Our currently open greyscaling menu.
	VAR_FINAL/datum/greyscale_modify_menu/menu

/datum/preference_middleware/loadout/Destroy(force, ...)
	QDEL_NULL(menu)
	return ..()

/datum/preference_middleware/loadout/on_new_character(mob/user)
	preferences.character_preview_view?.update_body()

/datum/preference_middleware/loadout/proc/action_select_item(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	var/path_to_use = text2path(params["path"])
	var/datum/loadout_item/interacted_item = GLOB.all_loadout_datums[path_to_use]
	if(!istype(interacted_item))
		stack_trace("Failed to locate desired loadout item (path: [params["path"]]) in the global list of loadout datums!")
		return TRUE // update

	if(params["deselect"])
		deselect_item(interacted_item)
	else
		select_item(interacted_item)
	return TRUE

/datum/preference_middleware/loadout/proc/action_clear_all(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], null)
	return TRUE

/datum/preference_middleware/loadout/proc/action_toggle_job_outfit(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	preferences.character_preview_view.show_job_clothes = !preferences.character_preview_view.show_job_clothes
	preferences.character_preview_view.update_body()
	return TRUE

/datum/preference_middleware/loadout/proc/action_rotate_model_dir(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	switch(params["dir"])
		if("left")
			preferences.character_preview_view.setDir(turn(preferences.character_preview_view.dir, -90))
		if("right")
			preferences.character_preview_view.setDir(turn(preferences.character_preview_view.dir, 90))

/datum/preference_middleware/loadout/proc/action_pass_to_loadout_item(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	var/path_to_use = text2path(params["path"])
	var/datum/loadout_item/interacted_item = GLOB.all_loadout_datums[path_to_use]
	if(!istype(interacted_item)) // no you cannot href exploit to spawn with a pulse rifle
		stack_trace("Failed to locate desired loadout item (path: [params["path"]]) in the global list of loadout datums!")
		return TRUE // update

	if(interacted_item.handle_loadout_action(src, user, params["subaction"], params))
		preferences.character_preview_view.update_body()
		return TRUE

	return FALSE

/// Select [path] item to [category_slot] slot.
/datum/preference_middleware/loadout/proc/select_item(datum/loadout_item/selected_item)
	var/list/loadout = preferences.read_preference(/datum/preference/loadout)
	var/list/datum/loadout_item/loadout_datums = loadout_list_to_datums(loadout)
	for(var/datum/loadout_item/item as anything in loadout_datums)
		if(item.category != selected_item.category)
			continue
		if(!item.category.handle_duplicate_entires(src, item, selected_item, loadout_datums))
			return

	LAZYSET(loadout, selected_item.item_path, list())
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)

/// Deselect [deselected_item].
/datum/preference_middleware/loadout/proc/deselect_item(datum/loadout_item/deselected_item)
	var/list/loadout = preferences.read_preference(/datum/preference/loadout)
	LAZYREMOVE(loadout, deselected_item.item_path)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)

/datum/preference_middleware/loadout/proc/register_greyscale_menu(datum/greyscale_modify_menu/open_menu)
	src.menu = open_menu
	RegisterSignal(menu, COMSIG_QDELETING, PROC_REF(cleanup_greyscale_menu))

/datum/preference_middleware/loadout/proc/cleanup_greyscale_menu()
	SIGNAL_HANDLER
	menu = null

/datum/preference_middleware/loadout/proc/force_close_greyscale_menu()
	menu?.ui_close()

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	var/list/data = list()
	data["job_clothes"] = preferences.character_preview_view.show_job_clothes
	return data

/datum/preference_middleware/loadout/get_ui_static_data(mob/user)
	var/list/data = list()
	data["loadout_preview_view"] = preferences.character_preview_view.assigned_map
	return data

/datum/preference_middleware/loadout/get_constant_data()
	var/list/data = list()
	var/list/loadout_tabs = list()
	for(var/datum/loadout_category/category as anything in GLOB.all_loadout_categories)
		var/list/cat_data = list(
			"name" = category.category_name,
			"category_icon" = category.category_ui_icon,
			"category_info" = category.category_info,
			"contents" = category.items_to_ui_data(),
		)
		UNTYPED_LIST_ADD(loadout_tabs, cat_data)

	data["loadout_tabs"] = loadout_tabs
	return data
