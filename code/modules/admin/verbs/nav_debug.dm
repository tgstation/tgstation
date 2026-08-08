
/client/var/turf/nav_debug_goal
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

/// Returns a before/after timer that remains valid when a measured call crosses a tick boundary.
/proc/nav_debug_timer_start()
	return list(world.time, TICK_USAGE_REAL)

/proc/nav_debug_timer_ms(list/timer)
	var/ticks_elapsed = round((world.time - timer[1]) / world.tick_lag)
	return TICK_DELTA_TO_MS((ticks_elapsed * 100) + TICK_USAGE_REAL - timer[2])

ADMIN_VERB(navmap_set_goal, R_DEBUG, "Navmap: Set Goal", "Marks your current turf as the navmap path goal.", ADMIN_CATEGORY_DEBUG)
	var/turf/goal = get_turf(user.mob)
	if(!goal)
		return
	user.nav_debug_goal = goal
	to_chat(user, span_notice("Navmap goal set at [AREACOORD(goal)]."))

ADMIN_VERB(navmap_run_path, R_DEBUG, "Navmap: Run Path", "Paths from your turf to the set goal over the navmap.", ADMIN_CATEGORY_DEBUG)
	var/turf/start = get_turf(user.mob)
	var/turf/goal = user.nav_debug_goal
	if(!start || !goal)
		to_chat(user, span_warning("Set a goal first (Navmap: Set Goal)."))
		return
	if(start.z != goal.z)
		to_chat(user, span_warning("Start and goal are on different z-levels; navmap is single-z."))
		return

	var/profile = tgui_input_list(user, "Mover profile", "Navmap", list("baseline", "table+grille", "all-access", "flying"))
	if(!profile)
		return
	var/max_range = tgui_input_number(user, "Maximum path range in tiles (0 = unlimited).", "Navmap", default = 200, min_value = 0, round_value = TRUE)
	if(isnull(max_range))
		return
	var/datum/can_pass_info/info = nav_debug_profile(profile, user.mob)
	var/list/dll_path
	var/dll_ms
	var/dll_available = navmap_pathfinder_available()
	if(dll_available)
		var/list/dll_timer = nav_debug_timer_start()
		try
			dll_path = navmap_pathfinder(start, goal, info, NAV_IS_FLYING(info), max_range, 0, TRUE, null, DIAGONAL_REMOVE_CLUNKY, TRUE)
		catch
			navmap_pathfinder_mark_unavailable()
			dll_available = FALSE
		dll_ms = nav_debug_timer_ms(dll_timer)

	var/dm_start = nav_debug_timer_start()
	var/list/dm_path = navmap_pathfinder_blocking(user.mob, start, goal, info, max_range, 0, TRUE, null, DIAGONAL_REMOVE_CLUNKY, skip_first = TRUE, use_dm_implementation = TRUE, allow_tick_yield = FALSE)
	var/dm_ms = nav_debug_timer_ms(dm_start)

	var/list/access = info.access || list()
	var/list/hand_around = list()
	var/list/jps_timer = nav_debug_timer_start()
	var/datum/pathfind/jps/legacy_path = new()
	legacy_path.setup(user.mob, access, max_range, TRUE, null, \
		list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around)), goal, 0, TRUE, DIAGONAL_REMOVE_CLUNKY)
	// setup() normally builds the profile from the requester. Reuse the selected
	// navmap profile so flying and pass-flag comparisons measure the same mover.
	legacy_path.pass_info = info
	var/list/jps_path
	if(legacy_path.start())
		// Drive the legacy search directly so the timer excludes subsystem queueing and tick waits.
		while(!legacy_path.path && !legacy_path.open.is_empty())
			if(!legacy_path.search_step())
				legacy_path.early_exit()
				break
		if(!QDELETED(legacy_path))
			legacy_path.finished()
		jps_path = islist(hand_around[1]) ? hand_around[1] : list()
	else
		qdel(legacy_path)
		jps_path = list()
	var/jps_ms = nav_debug_timer_ms(jps_timer)

	to_chat(user, span_boldnotice("JPS (OLD): [length(jps_path) ? "[length(jps_path)] steps" : "NO PATH"] in [jps_ms]ms. \
		Navmap A* DLL: [dll_available ? "[length(dll_path) ? "[length(dll_path)] steps" : "NO PATH"] in [dll_ms]ms" : "unavailable"]. \
		DM implementation: [length(dm_path) ? "[length(dm_path)] steps" : "NO PATH"] in [dm_ms]ms"))

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
