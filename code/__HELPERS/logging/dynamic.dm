/// Log to dynamic and message admins
/datum/game_mode/dynamic/proc/log_dynamic_and_announce(text)
	message_admins("DYNAMIC: [text]")
	log_dynamic("[text]")

/// Logging for dynamic procs
/proc/log_dynamic(text)
	Logger.Log(LOG_CATEGORY_DYNAMIC, text)
