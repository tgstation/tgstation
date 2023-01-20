GLOBAL_DATUM_INIT(log_holder, /datum/log_holder, new)
GLOBAL_PROTECT(log_holder)

/**
 * Main datum to manage logging actions
 */
/datum/log_holder
	var/round_id
	var/logging_start_timestamp

	/// Assosciative: category -> datum
	var/list/datum/log_category/log_categories
	var/list/disabled_categories

	var/init = FALSE
	var/shutdown = FALSE

/datum/log_holder/proc/init_logging()
	if(init)
		CRASH("Attempted to call init_logging twice!")
	init = TRUE

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

		log_categories[category] = new category_type

/datum/log_holder/proc/shutdown_logging()
	if(shutdown)
		CRASH("Attempted to call shutdown_logging twice!")
	shutdown = TRUE

	for(var/datum/log_category/category as anything in log_categories)
		category = log_categories[category]
		var/category_json = category.json_dump()
		rustg_file_write(category_json, "[GLOB.log_directory]/[lowertext(category.category)].json")

/datum/log_holder/proc/log(category, message, list/data)
	if(disabled_categories[category])
		return

	var/datum/log_category/log_category = log_categories[category]
	if(!log_category)
		log(LOG_CATEGORY_NOT_FOUND, message, data)
		CRASH("Attempted to log to a category that doesn't exist! [category]")
	log_category.add_entry(message, data)
