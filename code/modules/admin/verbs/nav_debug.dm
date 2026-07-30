/obj/effect/temp_visual/nav_marker
	name = "nav path marker"
	icon = 'icons/effects/effects.dmi'
	icon_state = "sniper_zoom"
	randomdir = FALSE
	duration = 5 SECONDS
	color = COLOR_CYAN
	layer = ABOVE_MOB_LAYER
/client/var/turf/nav_debug_goal
/// Builds a passability profile for navmesh debugging.
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

ADMIN_VERB(navmesh_set_goal, R_DEBUG, "Navmesh: Set Goal", "Marks your current turf as the navmesh path goal.", ADMIN_CATEGORY_DEBUG)
	var/turf/goal = get_turf(user.mob)
	if(!goal)
		return
	user.nav_debug_goal = goal
	to_chat(user, span_notice("Navmesh goal set at [AREACOORD(goal)]."))

ADMIN_VERB(navmesh_run_path, R_DEBUG, "Navmesh: Run Path", "Paths from your turf to the set goal over the navmesh.", ADMIN_CATEGORY_DEBUG)
	var/turf/start = get_turf(user.mob)
	var/turf/goal = user.nav_debug_goal
	if(!start || !goal)
		to_chat(user, span_warning("Set a goal first (Navmesh: Set Goal)."))
		return
	if(start.z != goal.z)
		to_chat(user, span_warning("Start and goal are on different z-levels; navmesh is single-z."))
		return

	var/profile = tgui_input_list(user, "Mover profile", "Navmesh", list("baseline", "table+grille", "all-access", "flying"))
	if(!profile)
		return
	var/max_range = tgui_input_number(user, "Maximum path range in tiles (0 = unlimited).", "Navmesh", default = 200, min_value = 0, round_value = TRUE)
	if(isnull(max_range))
		return
	var/datum/can_pass_info/info = nav_debug_profile(profile, user.mob)
	var/list/rustg_nav_path
	var/rustg_nav_ms
	var/rustg_nav_available = TRUE
	var/rustg_nav_start = TICK_USAGE_REAL
	try
		rustg_nav_path = rustg_turfmap_pathfinder(start, goal, info, NAV_IS_FLYING(info), max_range, 0, TRUE, null, DIAGONAL_REMOVE_CLUNKY, TRUE)
	catch
		rustg_nav_available = FALSE
		rustg_nav_path = list()
	rustg_nav_ms = TICK_USAGE_TO_MS(rustg_nav_start)
	var/list/access = info.access || list()
	var/list/hand_around = list()
	var/datum/pathfind/jps/legacy_path = new()
	legacy_path.setup(user.mob, access, max_range, TRUE, null, \
		list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around)), goal, 0, TRUE, DIAGONAL_REMOVE_CLUNKY)
	var/list/jps_path
	var/jps_ms
	if(legacy_path.start())
		SSpathfinder.active_pathing += legacy_path
		UNTIL(length(hand_around))
		jps_path = islist(hand_around[1]) ? hand_around[1] : list()
		jps_ms = TICK_DELTA_TO_MS(legacy_path.compute_time)
	else
		qdel(legacy_path)
		jps_path = list()
		jps_ms = 0

	for(var/turf/step as anything in rustg_nav_path)
		new /obj/effect/temp_visual/nav_marker(step)

	to_chat(user, span_boldnotice("JPS (OLD): [length(jps_path) ? "[length(jps_path)] steps" : "NO PATH"] in [jps_ms]ms. \
		Rust A*: [rustg_nav_available ? "[length(rustg_nav_path) ? "[length(rustg_nav_path)] steps" : "NO PATH"] in [rustg_nav_ms]ms" : "unavailable (rust-g missing turfmap_pathfinder)"]"))

ADMIN_VERB(navmesh_run_cooperative_path, R_DEBUG, "Navmesh: Test Cooperative A*", "Runs the time-sliced rust-g turfmap pathfinder to the set goal.", ADMIN_CATEGORY_DEBUG)
	var/turf/start = get_turf(user.mob)
	var/turf/goal = user.nav_debug_goal
	if(!start || !goal)
		to_chat(user, span_warning("Set a goal first (Navmesh: Set Goal)."))
		return
	if(start.z != goal.z)
		to_chat(user, span_warning("Start and goal are on different z-levels; navmesh is single-z."))
		return
	var/profile = tgui_input_list(user, "Mover profile", "Navmesh", list("baseline", "table+grille", "all-access", "flying"))
	if(!profile)
		return
	var/max_range = tgui_input_number(user, "Maximum path range in tiles (0 = unlimited).", "Navmesh", default = 200, min_value = 0, round_value = TRUE)
	if(isnull(max_range))
		return
	var/datum/can_pass_info/info = nav_debug_profile(profile, user.mob)
	var/list/result
	try
		result = rustg_turfmap_pathfinder_start(start, goal, info, NAV_IS_FLYING(info), max_range, 0, TRUE, null, DIAGONAL_REMOVE_CLUNKY, TRUE)
	catch
		to_chat(user, span_warning("Cooperative turfmap A* is unavailable in the loaded rust-g."))
		return
	var/slices = 1
	while(islist(result) && result["status"] == RUSTG_TURFMAP_PATH_IN_PROGRESS)
		var/job_id = result["job_id"]
		if(!job_id)
			break
		sleep(world.tick_lag)
		slices++
		try
			result = rustg_turfmap_pathfinder_resume(job_id, info)
		catch
			to_chat(user, span_warning("Cooperative turfmap A* failed while resuming."))
			return
	if(!islist(result))
		to_chat(user, span_warning("Cooperative turfmap A* returned an invalid result."))
		return
	var/status = result["status"]
	var/list/path = result["path"]
	for(var/turf/step as anything in path)
		new /obj/effect/temp_visual/nav_marker(step)
	if(status == RUSTG_TURFMAP_PATH_COMPLETE)
		to_chat(user, span_boldnotice("Cooperative Rust A*: [length(path)] steps in [slices] slices."))
	else if(status == RUSTG_TURFMAP_PATH_NO_PATH)
		to_chat(user, span_warning("Cooperative Rust A*: no path after [slices] slices."))
	else
		var/error_message = result["error"] || "unexpected status ([status])"
		to_chat(user, span_warning("Cooperative Rust A*: [error_message]."))

ADMIN_VERB(navmesh_inspect_turf, R_DEBUG, "Navmesh: Inspect Turf", "Prints the baked navmesh data for your current turf.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	if(!here)
		return
	if(isnull(here.nav_pass))
		here.nav_bake()
	var/list/lines = list("Navmesh at [AREACOORD(here)] (nav_pass = [here.nav_pass], simulated = !!(here.nav_pass & NAV_SIMULATED)):")
	for(var/dir in GLOB.cardinals)
		var/ground = (here.nav_pass & NAV_GROUND(dir)) ? "G" : "-"
		var/flight = (here.nav_pass & NAV_FLIGHT(dir)) ? "F" : "-"
		var/cond = (here.nav_pass & NAV_COND(dir)) ? "C" : "-"
		var/entries = here.nav_blockers?["[dir]"]
		lines += "  [dir2text(dir)]: [ground][flight][cond][length(entries) ? " entries=[json_encode(entries)]" : ""]"
	to_chat(user, span_notice(jointext(lines, "\n")))

ADMIN_VERB(navmesh_prebake_z, R_DEBUG, "Navmesh: Prebake Z-Level", "Eagerly bakes every turf on your current z-level.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	if(!here)
		return
	var/start_time = REALTIMEOFDAY
	var/count = SSnavmesh.prebake_z(here.z)
	to_chat(user, span_boldnotice("Prebaked [count] turfs on z[here.z] in [(REALTIMEOFDAY - start_time) / 10]s."))

/mob/living/basic/nav_tester
	name = "navmesh tester"
	desc = "A test pawn that walks navmesh paths."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "mouse_gray"
	maxHealth = 100
	health = 100

/// Starts the tester moving toward a target over the navmesh.
/mob/living/basic/nav_tester/proc/set_nav_target(atom/target)
	GLOB.move_manager.navmesh_astar_move(
		src,
		target,
		delay = 2,
		repath_delay = 1 SECONDS,
		max_path_length = 0,
		access = list(),
		skip_first = TRUE,
	)

ADMIN_VERB(navmesh_spawn_tester, R_DEBUG, "Navmesh: Spawn Tester", "Spawns a pawn that walks a navmesh path to the set goal.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	var/turf/goal = user.nav_debug_goal
	if(!here || !goal)
		to_chat(user, span_warning("Set a goal first (Navmesh: Set Goal)."))
		return
	var/mob/living/basic/nav_tester/pawn = new(here)
	pawn.set_nav_target(goal)
	to_chat(user, span_notice("Spawned a navmesh tester heading for [AREACOORD(goal)]."))
