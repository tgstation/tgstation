/// Logging for player manifest (ckey, name, job, special role, roundstart/latejoin)
/proc/log_manifest(ckey, datum/mind/mind, mob/body, latejoin = FALSE)
	var/message = {"([body.real_name])\[[ckey]\] added to manifest
					as a(n) [latejoin ? "LATEJOIN " : ""][mind.assigned_role.title][mind.special_role ? mind.special_role : ""]
					with a location of [loc_name(body.loc)]"}
	logger.Log(LOG_CATEGORY_MANIFEST, message, list(
		"mind" = mind, "body" = body, "latejoin" = latejoin
	))
