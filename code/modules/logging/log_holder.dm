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
	/// category nesting tree for ui purposes
	var/list/category_group_tree

	/// list of Log args waiting for processing pending log initialization
	var/list/waiting_log_calls

	var/initialized = FALSE
	var/shutdown = FALSE

GENERAL_PROTECT_DATUM(/datum/log_holder)

/// Assembles basic information for logging, creating the log category datums and checking for config flags as required
/datum/log_holder/proc/init_logging()
	if(initialized)
		CRASH("Attempted to call init_logging twice!")

	round_id = GLOB.round_id
	logging_start_timestamp = rustg_unix_timestamp()
	log_categories = list()
	disabled_categories = list()

	category_group_tree = assemble_log_category_tree()
	var/config_flag
	for(var/datum/log_category/master_category as anything in category_group_tree)
		var/list/sub_categories = category_group_tree[master_category]
		for(var/datum/log_category/sub_category as anything in sub_categories)
			config_flag = initial(sub_category.config_flag)
			if(config_flag && !config.Get(config_flag))
				disabled_categories += initial(sub_category.category)
				sub_categories -= sub_category
				continue

		config_flag = initial(master_category.config_flag)
		if(config_flag && !config.Get(config_flag))
			disabled_categories += initial(master_category.category)
			if(!length(sub_categories))
				continue
		// enabled, or any of the sub categories are enabled
		init_log_category(master_category, sub_categories)

	initialized = TRUE

	// process any waiting log calls and then cut the list
	for(var/list/arg_list as anything in waiting_log_calls)
		Log(arglist(arg_list))
	waiting_log_calls?.Cut()

/// Tells the log_holder to not allow any more logging to be done, and dumps all categories to their json file
/datum/log_holder/proc/shutdown_logging()
	if(shutdown)
		CRASH("Attempted to call shutdown_logging twice!")
	shutdown = TRUE

/// Iterates over all log category types to assemble them into a tree of main category -> (sub category)[] while also checking for loops and sanity errors
/datum/log_holder/proc/assemble_log_category_tree()
	var/static/list/category_tree
	if(category_tree)
		return category_tree.Copy()

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
			stack_trace("log category [master] is an invalid master category as its a sub category")
			continue
		for(var/datum/log_category/sub_category as anything in sub_categories[master])
			if(initial(sub_category.secret) != initial(master.secret))
				stack_trace("log category [sub_category] has a secret status that differs from its master category [master]")
			category_tree[master] += list(sub_category)

	return category_tree.Copy()

/// Initializes the given log category and populates the list of contained categories based on the sub category list
/datum/log_holder/proc/init_log_category(datum/log_category/category_type, list/datum/log_category/sub_categories)
	var/datum/log_category/category_instance = new category_type

	var/list/contained_categories = list()
	for(var/datum/log_category/sub_category as anything in sub_categories)
		sub_category = new sub_category
		sub_category.master_category = category_instance
		log_categories[sub_category.category] = sub_category
		contained_categories[sub_category.category] = sub_category.schema_version

	log_categories[category_instance.category] = category_instance
	contained_categories[category_instance.category] = category_instance.schema_version

	var/list/category_header = list(
		LOG_HEADER_INIT_TIMESTAMP = big_number_to_text(logging_start_timestamp),
		LOG_HEADER_ROUND_ID = big_number_to_text(GLOB.round_id),
		LOG_HEADER_SECRET = category_instance.secret,
		LOG_HEADER_SCHEMA_LIST = contained_categories,
		LOG_HEADER_CATEGORY = category_instance.category,
	)
	rustg_file_write("[json_encode(category_header)]\n", category_instance.get_output_file(null))

/// This is Log because log is a byond internal proc
/datum/log_holder/proc/Log(category, message, list/data)
	if(shutdown)
		CRASH("Attempted to perform logging after shutdown!")

	if(!initialized)
		waiting_log_calls += list(args)
		return

	if(disabled_categories[category])
		return

	var/datum/log_category/log_category = log_categories[category]
	if(!log_category)
		Log(LOG_CATEGORY_NOT_FOUND, message, data)
		CRASH("Attempted to log to a category that doesn't exist! [category]")
	log_category.add_entry(message, data)
