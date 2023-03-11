/// The main datum that contains all log entries for a category
/datum/log_category
	/// The category name
	var/category

	/// The schema version of this log category.
	/// Expected format of "Major.Minor.Patch"
	var/schema_version = LOG_CATEGORY_SCHEMA_VERSION_NOT_SET

	/// The master category that contains this category
	var/datum/log_category/master_category

	/// If set this config flag is checked to enable this log category
	var/config_flag

	/// Whether or not this log should not be publically visible
	var/secret = FALSE

	/// List of all entries, in chronological order of when they were added
	var/list/entries = list()

GENERAL_PROTECT_DATUM(/datum/log_category)

/// Backup log category to catch attempts to log to a category that doesn't exist
/datum/log_category/backup_category_not_found
	category = LOG_CATEGORY_NOT_FOUND

/// Add an entry to this category. It is very important that any data you provide doesn't hold references to anything!
/datum/log_category/proc/add_entry(message, list/data)
	// Entries that are added first will be at the front of the log entry
	var/list/entry = list(
		LOG_ENTRY_TIMESTAMP = logger.human_readable_timestamp(),
		LOG_ENTRY_CATEGORY = category,
		LOG_ENTRY_MESSAGE = message,
		LOG_ENTRY_SCHEMA_VERSION = schema_version,
	)
	if(data)
		entry[LOG_ENTRY_DATA] = data
	entry[LOG_ENTRY_WORLD_DATA] = world.get_world_state_for_logging()

	entries += list(entry)
	write_entry(entry)

/// Allows for category specific file splitting. Needs to accept a null entry for the default file.
/// If master_category it will always return the output of master_category.get_output_file(entry)
/datum/log_category/proc/get_output_file(list/entry)
	if(master_category)
		return master_category.get_output_file(entry)
	if(secret)
		return "[GLOB.log_directory]/secret/[category].json"
	return "[GLOB.log_directory]/[category].json"

/// Writes an entry to the output file for the category
/datum/log_category/proc/write_entry(list/entry)
	rustg_file_append("[json_encode(entry)]\n", get_output_file(entry))
