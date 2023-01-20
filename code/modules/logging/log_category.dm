/datum/log_category
	var/category
	/// If set this config flag is checked to enable this log category
	var/config_flag
	var/list/entries

/// Backup log category to catch attempts to log to a category that doesn't exist
/datum/log_category/backup_category_not_found
	category = LOG_CATEGORY_NOT_FOUND

/datum/log_category/New()
	entries = list()
	return ..()

/// Add an entry to this category. It is very important that any data you provide doesn't hold references to anything!
/datum/log_category/proc/add_entry(message, list/data)
	var/list/entry = list(
		LOG_ENTRY_MESSAGE = message,
		LOG_ENTRY_TIMESTAMP = rustg_unix_timestamp(),
	)
	if(data)
		entry["data"] = data
	entries[++entries.len] = entry

/// Converts this category into a json dump
/datum/log_category/proc/json_dump()
	var/datum/json_savefile/json_tree = new
	json_tree.set_entry(LOG_JSON_CATEGORY, category)
	json_tree.set_entry(LOG_JSON_LOGGING_START, GLOB.log_holder.logging_start_timestamp)
	json_tree.set_entry(LOG_JSON_ENTRIES, entries)
	return json_tree.serialize_json()
