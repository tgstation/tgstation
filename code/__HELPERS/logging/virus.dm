/// Logging for the creation and contraction of viruses
/proc/log_virus(text, list/data)
	logger.Log(LOG_CATEGORY_VIRUS, text, data)

/// Returns a string for admin logging uses, should describe the disease in detail
/datum/disease/proc/admin_details()
	return "[src.name] : [src.type]"
