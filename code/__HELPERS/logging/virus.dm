/// Logging for the creation and contraction of viruses
/proc/log_virus(text)
	if (CONFIG_GET(flag/log_virus))
		WRITE_LOG(GLOB.world_virus_log, "VIRUS: [text]")

/// Returns a string for admin logging uses, should describe the disease in detail
/datum/disease/proc/admin_details()
	return "[src.name] : [src.type]"
