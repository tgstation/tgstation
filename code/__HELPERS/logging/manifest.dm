/// Logging for player manifest (ckey, name, job, special role, roundstart/latejoin)
/proc/log_manifest(ckey, datum/mind/mind, mob/body, latejoin = FALSE)
	var/roles = english_list(mind.get_special_roles(), nothing_text = "NONE")
	var/message = "[ckey] \\ [body.real_name] \\ [mind.assigned_role.title] \\ [roles] \\ [latejoin ? "LATEJOIN" : "ROUNDSTART"]"
	logger.Log(LOG_CATEGORY_MANIFEST, message, list(
		"mind" = mind, "body" = body, "latejoin" = latejoin
	))
	// Roundstart happens with SSblackbox.ReportRoundstartManifest
	if(latejoin)
		SSblackbox.ReportManifest(ckey, body.real_name, mind.assigned_role.title, roles, latejoin)
