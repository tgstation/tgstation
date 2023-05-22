GLOBAL_DATUM_INIT(logger, /datum/log_holder, new)
GLOBAL_PROTECT(logger)

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

	var/initialized = FALSE
	var/shutdown = FALSE

/// Assembles basic information for logging, creating the log category datums and checking for config flags as required
/datum/log_holder/proc/init_logging()
	if(initialized)
		CRASH("Attempted to call init_logging twice!")

	round_id = GLOB.round_id
	logging_start_timestamp = unix_timestamp_string()
	log_categories = list()
	disabled_categories = list()

	human_readable_enabled = CONFIG_GET(flag/log_as_human_readable)

	category_group_tree = assemble_log_category_tree()
	var/config_flag
	for(var/datum/log_category/master_category as anything in category_group_tree)
		var/list/sub_categories = category_group_tree[master_category]
		sub_categories = sub_categories.Copy()
		for(var/datum/log_category/sub_category as anything in sub_categories)
			config_flag = initial(sub_category.config_flag)
			if(config_flag && !config.Get(config_flag))
				disabled_categories[initial(sub_category.category)] = TRUE
				sub_categories -= sub_category
				continue

		config_flag = initial(master_category.config_flag)
		if(config_flag && !config.Get(config_flag))
			disabled_categories[initial(master_category.category)] = TRUE
			if(!length(sub_categories))
				continue
		// enabled, or any of the sub categories are enabled
		init_log_category(master_category, sub_categories)

	initialized = TRUE

	// process any waiting log calls and then cut the list
	for(var/list/arg_list as anything in waiting_log_calls)
		Log(arglist(arg_list))
	waiting_log_calls?.Cut()

	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	world._initialize_log_files()

/// Tells the log_holder to not allow any more logging to be done, and dumps all categories to their json file
/datum/log_holder/proc/shutdown_logging()
	if(shutdown)
		CRASH("Attempted to call shutdown_logging twice!")
	shutdown = TRUE

/// This is Log because log is a byond internal proc
/datum/log_holder/proc/Log(category, message, list/data)
	// This is Log because log is a byond internal proc
	if(shutdown)
		stack_trace("Performing logging after shutdown! This might not be functional in the future!")
	// but for right now it's fine

	// do not include the message because these go into the runtime log and we might be secret!
	if(!istext(message))
		message = "[message]"
		stack_trace("Logging with a non-text message")

	if(!category)
		category = LOG_CATEGORY_NOT_FOUND
		stack_trace("Logging with a null or empty category")

	if(data && !islist(data))
		data = list("data" = data)
		stack_trace("Logging with data this is not a list, it will be converted to a list with a single key 'data'")

	if(!initialized) // we are initialized during /world/proc/SetupLogging which is called in /world/New
		waiting_log_calls += list(list(category, message, data))
		return

	if(disabled_categories[category])
		return

	var/datum/log_category/log_category = log_categories[category]
	if(!log_category)
		Log(LOG_CATEGORY_NOT_FOUND, message, data)
		CRASH("Attempted to log to a category that doesn't exist! [category]")

	var/list/semver_store = null
	if(length(data))
		semver_store = list()
		data = recursive_jsonify(data, semver_store)
	log_category.create_entry(message, data, semver_store)

/// Recursively converts an associative list of datums into their jsonified(list) form
/datum/log_holder/proc/recursive_jsonify(list/data_list, list/semvers)
	if(isnull(data_list))
		return null

	var/list/jsonified_list = list()
	for(var/key in data_list)
		var/datum/data = data_list[key]

		if(isnull(data))
			// do nothing - nulls are allowed

		else if(islist(data))
			data = recursive_jsonify(data, semvers)

		else if(isdatum(data))
			var/list/options_list = list(
				SCHEMA_VERSION = LOG_CATEGORY_SCHEMA_VERSION_NOT_SET,
			)

			var/list/serialization_data = data.serialize_list(options_list, semvers)
			var/current_semver = semvers[data.type]
			if(!semver_to_list(current_semver))
				stack_trace("serialization of data had an invalid semver")
				semvers[data.type] = LOG_CATEGORY_SCHEMA_VERSION_NOT_SET

			if(!length(serialization_data)) // serialize_list wasn't implemented, and errored
				stack_trace("serialization data was empty")
				continue

			data = recursive_jsonify(serialization_data, semvers)

		if(islist(data) && !length(data))
			stack_trace("recursive_jsonify got an empty list after serialization")
			continue

		jsonified_list[key] = data

	return jsonified_list
