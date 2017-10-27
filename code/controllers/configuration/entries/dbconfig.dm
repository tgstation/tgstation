#define CURRENT_RESIDENT_FILE "dbconfig.txt"

CONFIG_DEF(flag/sql_enabled)	// for sql switching
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(string/address)
	value = "localhost"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
	
CONFIG_DEF(number/port)
	value = 3306
	min_val = 0
	max_val = 65535
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

CONFIG_DEF(string/feedback_database)
	value = "test"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

CONFIG_DEF(string/feedback_login)
	value = "root"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

CONFIG_DEF(string/feedback_password)
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

CONFIG_DEF(string/feedback_tableprefix)
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
