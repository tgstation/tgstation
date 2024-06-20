/datum/log_holder
	/// Cached ui_data for debuggers
	var/list/debug_data_cache = list()

/datum/log_holder/ui_interact(mob/user, datum/tgui/ui)
	if(!check_rights_for(user.client, R_ADMIN | R_DEBUG))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new(user, src, "LogViewer")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/log_holder/ui_status(mob/user, datum/ui_state/state)
	return check_rights_for(user.client, R_ADMIN | R_DEBUG) ? UI_INTERACTIVE : UI_CLOSE

/datum/log_holder/ui_static_data(mob/user)
	var/list/data = list(
		"round_id" = GLOB.round_id,
		"logging_start_timestamp" = logging_start_timestamp,
	)
	var/debug_user = is_user_debug_only(user)

	var/list/tree = list()
	data["tree"] = tree
	var/list/enabled_categories = list()
	for(var/enabled in log_categories)
		if(debug_user && !is_category_debug_visible(log_categories[enabled]))
			continue
		enabled_categories += enabled
	tree["enabled"] = enabled_categories

	var/list/disabled_categories = list()
	for(var/disabled in src.disabled_categories)
		if(debug_user && !is_category_debug_visible(disabled))
			continue
		disabled_categories += disabled
	tree["disabled"] = disabled_categories

	return data

/datum/log_holder/ui_data(mob/user)
	if(!last_data_update || (world.time - last_data_update) > LOG_UPDATE_TIMEOUT)
		cache_ui_data()
	return is_user_debug_only(user) ? debug_data_cache : data_cache

/datum/log_holder/cache_ui_data()
	var/list/category_map = list()
	var/list/debug_category_map = list()
	for(var/datum/log_category/category as anything in log_categories)
		category = log_categories[category]
		var/list/category_data = list()

		var/list/entries = list()
		for(var/datum/log_entry/entry as anything in category.entries)
			entries += list(list(
				"id" = entry.id,
				"message" = entry.message,
				"timestamp" = entry.timestamp,
				"data" = entry.data,
				"semver" = entry.semver_store,
			))
		category_data["entries"] = entries
		category_data["entry_count"] = category.entry_count

		category_map[category.category] = category_data
		if(is_category_debug_visible(category))
			debug_category_map[category.category] = category_data

	data_cache.Cut()
	debug_data_cache.Cut()
	last_data_update = world.time

	data_cache["categories"] = category_map
	data_cache["last_data_update"] = last_data_update

	debug_data_cache["categories"] = debug_category_map
	debug_data_cache["last_data_update"] = last_data_update

/// Checks to see if a user has +DEBUG without +ADMIN permissions.
/// Used to give +DEBUG holders "limited" versions of some admin commands for debugging purposes.
/proc/is_user_debug_only(mob/user)
	var/client/client = user.client
	return client.holder && check_rights_for(client, R_DEBUG) && !check_rights_for(client, R_ADMIN)
