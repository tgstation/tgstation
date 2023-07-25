/// Logging for player manifest (ckey, name, job, special role, roundstart/latejoin)
/proc/log_manifest(ckey, datum/mind/mind, mob/body, latejoin = FALSE)
	var/message = "[ckey] \\ [body.real_name] \\ [mind.assigned_role.title] \\ [mind.special_role || "NONE"] \\ [latejoin ? "LATEJOIN" : "ROUNDSTART"]"
	logger.Log(LOG_CATEGORY_MANIFEST, message, list(
		"mind" = mind, "body" = body, "latejoin" = latejoin
	))
