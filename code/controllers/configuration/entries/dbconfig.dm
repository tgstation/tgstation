/datum/config_entry/flag/sql_enabled // for sql switching
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/address
	default = "localhost"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/number/port
	default = 3306
	min_val = 0
	max_val = 65535
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_database
	default = "test"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_login
	default = "root"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_password
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_tableprefix
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/number/query_debug_log_timeout
	default = 70
	min_val = 1
	protection = CONFIG_ENTRY_LOCKED
	deprecated_by = /datum/config_entry/number/blocking_query_timeout

/datum/config_entry/number/query_debug_log_timeout/DeprecationUpdate(value)
	return value

/datum/config_entry/number/async_query_timeout
	default = 10
	min_val = 0
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/number/blocking_query_timeout
	default = 5
	min_val = 0
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/number/bsql_thread_limit
	default = 50
	min_val = 1
	deprecated_by = /datum/config_entry/number/pooling_max_sql_connections

/datum/config_entry/number/bsql_thread_limit/DeprecationUpdate(value)
	return value

/datum/config_entry/number/pooling_min_sql_connections
	default = 1
	min_val = 1

/datum/config_entry/number/pooling_max_sql_connections
	default = 25
	min_val = 1

/datum/config_entry/number/max_concurrent_queries
	default = 25
	min_val = 1

/datum/config_entry/number/max_concurrent_queries/ValidateAndSet(str_val)
	. = ..()
	if (.)
		SSdbcore.max_concurrent_queries = config_entry_value

/// The exe for mariadbd.exe.
/// Shouldn't really be set on production servers, primarily for EZDB.
/datum/config_entry/string/db_daemon
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
