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

/// This is Log because log is a byond internal proc
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
