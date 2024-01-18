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

	/// Whether the readable version of the log message is formatted internally instead of by rustg
	var/internal_formatting = TRUE

	/// List of log entries for this category
	var/list/entries = list()

	/// Total number of entries this round so far
	var/entry_count = 0

GENERAL_PROTECT_DATUM(/datum/log_category)

/// Backup log category to catch attempts to log to a category that doesn't exist
/datum/log_category/backup_category_not_found
	category = LOG_CATEGORY_NOT_FOUND

/// Add an entry to this category. It is very important that any data you provide doesn't hold references to anything!
/datum/log_category/proc/create_entry(message, list/data, list/semver_store)
	var/datum/log_entry/entry = new(
		// world state contains raw timestamp
		timestamp = logger.human_readable_timestamp(),
		category = category,
		message = message,
		data = data,
		semver_store = semver_store,
	)

	write_entry(entry)
	entry_count += 1
	if(entry_count <= CONFIG_MAX_CACHED_LOG_ENTRIES)
		entries += entry

/// Allows for category specific file splitting. Needs to accept a null entry for the default file.
/// If master_category it will always return the output of master_category.get_output_file(entry)
/datum/log_category/proc/get_output_file(list/entry, extension = "log.json")
	if(master_category)
		return master_category.get_output_file(entry, extension)
	if(secret)
		return "[GLOB.log_directory]/secret/[category].[extension]"
	return "[GLOB.log_directory]/[category].[extension]"

/// Writes an entry to the output file(s) for the category
/datum/log_category/proc/write_entry(datum/log_entry/entry)
	// config isn't loaded? assume we want human readable logs
	if(isnull(config) || CONFIG_GET(flag/log_as_human_readable))
		entry.write_readable_entry_to_file(get_output_file(entry, "log"), format_internally = internal_formatting)

	entry.write_entry_to_file(get_output_file(entry))
