/// Logging for player manifest (ckey, name, job, special role, roundstart/latejoin)
/proc/log_manifest(ckey, datum/mind/mind, mob/body, latejoin = FALSE)
	Logger.Log(LOG_CATEGORY_MANIFEST, list(
		"mind" = mind, "body" = body, "latejoin" = latejoin
	))
