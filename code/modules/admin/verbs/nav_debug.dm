/// Builds a passability profile for navmap debugging.
/proc/nav_debug_profile(profile, mob/requester)
	var/list/access = requester?.get_access()
	var/datum/can_pass_info/info = new /datum/can_pass_info(requester, access)
	switch(profile)
		if("flying")
			info.movement_type = FLYING
		if("table+grille")
			info.movement_type = GROUND
			info.pass_flags = PASSTABLE | PASSGRILLE
		if("all-access")
			info.movement_type = GROUND
			info.no_id = FALSE
			info.access = SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL))
		else // "baseline"
			info.movement_type = GROUND
	return info

ADMIN_VERB(navmap_inspect_turf, R_DEBUG, "Navmap: Inspect Turf", "Prints the baked navmap data for your current turf.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	if(!here)
		return
	if(isnull(here.nav_pass))
		here.nav_bake()
	var/simulated = !!(here.nav_pass & NAV_SIMULATED)
	var/simulated_text = simulated ? "TRUE" : "FALSE"
	var/list/lines = list("Navmap at [AREACOORD(here)] (nav_pass = [here.nav_pass], simulated = [simulated_text]):")
	for(var/dir in GLOB.cardinals)
		var/ground = (here.nav_pass & NAV_GROUND(dir)) ? "Pass" : "Blocked"
		var/flight = (here.nav_pass & NAV_FLIGHT(dir)) ? "Pass" : "Blocked"
		var/conditional = (here.nav_pass & NAV_COND(dir)) ? "Yes" : "No"
		var/entries = here.nav_blockers?["[dir]"]
		lines += "  [dir2text(dir)]: Ground: [ground], Flying: [flight], Conditional: [conditional][length(entries) ? " (blockers: [json_encode(entries)])" : ""]"
	to_chat(user, span_notice(jointext(lines, "\n")))

ADMIN_VERB(navmap_prebake_z, R_DEBUG, "Navmap: Prebake Z-Level", "Eagerly bakes every turf on your current z-level.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	if(!here)
		return
	var/start_time = REALTIMEOFDAY
	var/count = SSnavmap.prebake_z(here.z)
	to_chat(user, span_boldnotice("Prebaked [count] turfs on z[here.z] in [(REALTIMEOFDAY - start_time) / 10]s."))
