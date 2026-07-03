/// The main datum that contains all log entries for a category
/datum/log_category
	/// The category name
	var/category

	/// The schema version of this log category.
	/// Expected format of "Major.Minor.Patch"
	var/schema_version = LOG_CATEGORY_SCHEMA_VERSION_NOT_SET

	/// The master category that contains this category
	var/datum/log_category/master_category

	/// Flags to apply to our /datum/log_entry's
	/// See code/__DEFINES/logging/dm
	var/entry_flags = NONE

	/// If set this config flag is checked to enable this log category
	var/config_flag

	/// Whether or not this log should not be publically visible
	var/secret = FALSE

	/// The list of header information for this category. Used for log file re-initialization
	var/list/category_header

	/// Whether the readable version of the log message is formatted internally instead of by rustg
	/// IF YOU CHANGE THIS VERIFY LOGS ARE STILL PARSED CORRECTLY
	var/internal_formatting = FALSE

	/// List of log entries for this category
	var/list/entries = list()

	/// Total number of entries this round so far
	var/entry_count = 0

GENERAL_PROTECT_DATUM(/datum/log_category)

/// Add an entry to this category. It is very important that any data you provide doesn't hold references to anything!
/datum/log_category/proc/create_entry(message, list/data, list/semver_store)
	var/datum/log_entry/entry = new(
		// world state contains raw timestamp
		timestamp = logger.human_readable_timestamp(),
		category = category,
		message = message,
		flags = entry_flags,
		data = data,
		semver_store = semver_store,
	)

	write_entry(entry)
	entry_count += 1
	if(entry_count <= CONFIG_MAX_CACHED_LOG_ENTRIES)
		entries += entry

/// Allows for category specific file splitting. Needs to accept a null entry for the default file.
/// If master_category it will always return the output of master_category.get_output_file(entry)
/datum/log_category/proc/get_output_file(list/entry, extension = "log.json", logis_log = FALSE) // BANDASTATION EDIT - Logis
	if(master_category)
		return master_category.get_output_file(entry, extension, logis_log) // BANDASTATION EDIT - Logis

	// BANDASTATION EDIT START - Logis
	if(secret)
		if(logis_log)
			return "[GLOB.logis_logs_directory ]/secret/[LOG_CATEGORY_GAME].[extension]"
		else
			return "[GLOB.log_directory]/secret/[category].[extension]"

	if(logis_log)
		return "[GLOB.logis_logs_directory ]/[LOG_CATEGORY_GAME].[extension]"
	else
		return "[GLOB.log_directory]/[category].[extension]"
	// BANDASTATION EDIT END - Logis

/// Writes an entry to the output file(s) for the category
/datum/log_category/proc/write_entry(datum/log_entry/entry)
	// config isn't loaded? assume we want human readable logs
	if(isnull(config) || CONFIG_GET(flag/log_as_human_readable))
		entry.write_readable_entry_to_file(get_output_file(entry, "log", logis_log = TRUE), format_internally = internal_formatting) // BANDASTATION EDIT - Logis: added `logis_log = TRUE`

	entry.write_entry_to_file(get_output_file(entry))
