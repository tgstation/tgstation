GLOBAL_REAL(logger, /datum/log_holder)
/**
 * Main datum to manage logging actions
 */
/datum/log_holder
	/// Round ID, if set, that logging is initialized for
	var/round_id
	/// When the log_holder first initialized
	var/logging_start_timestamp

	/// Associative: category -> datum
	var/list/datum/log_category/log_categories
	/// typecache list for categories that exist but are disabled
	var/list/disabled_categories

	/// Cached ui_data
	var/list/data_cache = list()

	/// Last time the ui_data was updated
	var/last_data_update = 0

	var/initialized = FALSE
	var/shutdown = FALSE

GENERAL_PROTECT_DATUM(/datum/log_holder)

/client/proc/log_viewer_new()
	set name = "View Round Logs"
	set category = "Admin"
	logger.ui_interact(mob)

/datum/log_holder/ui_interact(mob/user, datum/tgui/ui)
	if(!check_rights_for(user.client, R_ADMIN))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new(user, src, "LogViewer")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/log_holder/ui_state(mob/user)
	return GLOB.admin_state

/datum/log_holder/ui_static_data(mob/user)
	var/list/data = list(
		"round_id" = GLOB.round_id,
		"logging_start_timestamp" = logging_start_timestamp,
	)

	var/list/tree = list()
	data["tree"] = tree
	var/list/enabled_categories = list()
	for(var/enabled in log_categories)
		enabled_categories += enabled
	tree["enabled"] = enabled_categories

	var/list/disabled_categories = list()
	for(var/disabled in src.disabled_categories)
		disabled_categories += disabled
	tree["disabled"] = disabled_categories

	return data

/datum/log_holder/ui_data(mob/user)
	if(!last_data_update || (world.time - last_data_update) > LOG_UPDATE_TIMEOUT)
		cache_ui_data()
	return data_cache

/datum/log_holder/proc/cache_ui_data()
	var/list/category_map = list()
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

	data_cache.Cut()
	last_data_update = world.time

	data_cache["categories"] = category_map
	data_cache["last_data_update"] = last_data_update

/datum/log_holder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("re-render")
			cache_ui_data()
			SStgui.update_uis(src)
			return TRUE

		else
			stack_trace("unknown ui_act action [action] for [type]")

/// Assembles basic information for logging, creating the log category datums and checking for config flags as required
/datum/log_holder/proc/init_logging()
	if(initialized)
		CRASH("Attempted to call init_logging twice!")
	initialized = TRUE

	round_id = GLOB.round_id
	logging_start_timestamp = rustg_unix_timestamp()
	log_categories = list()
	disabled_categories = list()
	for(var/datum/log_category/category_type as anything in subtypesof(/datum/log_category))
		var/category = initial(category_type.category)
		if(!category)
			continue

		if(category in log_categories)
			stack_trace("Found two identical log category type definitions! [category_type]")
			continue

		var/config_flag = initial(category_type.config_flag)
		if(config_flag && !config.Get(config_flag))
			disabled_categories[category] = TRUE
			continue
		category_type = log_categories[category] = new category_type
		var/list/log_start_entry = list(
			LOG_HEADER_CATEGORY = category,
			LOG_HEADER_INIT_TIMESTAMP = big_number_to_text(logging_start_timestamp),
			LOG_HEADER_ROUND_ID = big_number_to_text(GLOB.round_id),
		)
		rustg_file_write("[json_encode(log_start_entry)]\n", category_type.get_output_file(null))

/// Tells the log_holder to not allow any more logging to be done, and dumps all categories to their json file
/datum/log_holder/proc/shutdown_logging()
	if(shutdown)
		CRASH("Attempted to call shutdown_logging twice!")
	shutdown = TRUE

/// Iterates over all log category types to assemble them into a tree of main category -> (sub category)[] while also checking for loops and sanity errors
/datum/log_holder/proc/assemble_log_category_tree()
	var/static/list/category_tree
	if(category_tree)
		return category_tree

	category_tree = list()
	var/list/all_types = subtypesof(/datum/log_category)
	var/list/known_categories = list()
	var/list/sub_categories = list()

	// Assemble the master categories
	for(var/datum/log_category/category_type as anything in all_types)
		var/category = initial(category_type.category)
		if(category in known_categories)
			stack_trace("log category type '[category_type]' has duplicate category '[category]', skipping")
			continue

		if(!initial(category_type.schema_version))
			stack_trace("log category type '[category_type]' does not have a valid schema version, skipping")
			continue

		var/master_category = initial(category_type.master_category)
		if(master_category)
			sub_categories[master_category] += list(category_type)
			continue
		category_tree[category_type] = list()

	// Sort the sub categories
	for(var/datum/log_category/master as anything in sub_categories)
		if(!(master in category_tree))
			stack_trace("log category [master] is an invalid master category as it's a sub category")
			continue
		for(var/datum/log_category/sub_category as anything in sub_categories[master])
			if(initial(sub_category.secret) != initial(master.secret))
				stack_trace("log category [sub_category] has a secret status that differs from its master category [master]")
			category_tree[master] += list(sub_category)

	return category_tree

/// Initializes the given log category and populates the list of contained categories based on the sub category list
/datum/log_holder/proc/init_log_category(datum/log_category/category_type, list/datum/log_category/sub_categories)
	var/datum/log_category/category_instance = new category_type

	var/list/contained_categories = list()
	for(var/datum/log_category/sub_category as anything in sub_categories)
		sub_category = new sub_category
		var/sub_category_actual = sub_category.category
		sub_category.master_category = category_instance
		log_categories[sub_category_actual] = sub_category

		if(!semver_to_list(sub_category.schema_version))
			stack_trace("log category [sub_category_actual] has an invalid schema version '[sub_category.schema_version]'")
			sub_category.schema_version = LOG_CATEGORY_SCHEMA_VERSION_NOT_SET

		contained_categories += sub_category_actual

	log_categories[category_instance.category] = category_instance

	if(!semver_to_list(category_instance.schema_version))
		stack_trace("log category [category_instance.category] has an invalid schema version '[category_instance.schema_version]'")
		category_instance.schema_version = LOG_CATEGORY_SCHEMA_VERSION_NOT_SET

	contained_categories += category_instance.category

	var/list/category_header = list(
		LOG_HEADER_INIT_TIMESTAMP = logging_start_timestamp,
		LOG_HEADER_ROUND_ID = GLOB.round_id,
		LOG_HEADER_SECRET = category_instance.secret,
		LOG_HEADER_CATEGORY_LIST = contained_categories,
		LOG_HEADER_CATEGORY = category_instance.category,
	)

	rustg_file_write("[json_encode(category_header)]\n", category_instance.get_output_file(null))
	if(human_readable_enabled)
		rustg_file_write("\[[human_readable_timestamp()]\] Starting up round ID [round_id].\n - -------------------------\n", category_instance.get_output_file(null, "log"))

/datum/log_holder/proc/unix_timestamp_string() // pending change to rust-g
	return RUSTG_CALL(RUST_G, "unix_timestamp")()

/datum/log_holder/proc/human_readable_timestamp(precision = 3)
	var/start = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")
	// now we grab the millis from the rustg timestamp
	var/list/timestamp = splittext(unix_timestamp_string(), ".")
	var/millis = timestamp[2]
	if(length(millis) > precision)
		millis = copytext(millis, 1, precision + 1)
	return "[start].[millis]"

/// Adds an entry to the given category, if the category is disabled it will not be logged.
/// If the category does not exist, we will CRASH and log to the error category.
/// the data list is optional and will be recursively json serialized.
/datum/log_holder/proc/Log(category, message, list/data)
	if(!initialized || shutdown)
		CRASH("Attempted to perform logging before initializion or after shutdown!")

	if(disabled_categories[category])
		return

	var/datum/log_category/log_category = log_categories[category]
	if(!log_category)
		Log(LOG_CATEGORY_NOT_FOUND, message, data)
		CRASH("Attempted to log to a category that doesn't exist! [category]")
	log_category.add_entry(message, data)
