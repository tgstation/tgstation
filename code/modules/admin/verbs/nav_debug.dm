/*
 * Debug tooling for the experimental navmesh: admin verbs to test paths, inspect a turf's baked
 * data, and pre-bake a z-level, plus a simple pawn that walks a nav path and repaths on obstruction.
 */

/// Transient marker dropped along a computed nav path.
/obj/effect/temp_visual/nav_marker
	name = "nav path marker"
	icon = 'icons/effects/effects.dmi'
	icon_state = "sniper_zoom"
	randomdir = FALSE
	duration = 5 SECONDS
	color = COLOR_CYAN
	layer = ABOVE_MOB_LAYER

/// Client-stored goal turf for the path-test verb.
/client/var/turf/nav_debug_goal

/// Build a can_pass_info for the named debug profile.
/proc/nav_debug_profile(profile)
	var/datum/can_pass_info/info = new /datum/can_pass_info(null, null, no_id = TRUE)
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
	var/datum/can_pass_info/info = nav_debug_profile(profile)

	// Rust-side A* over the live navmesh (rust-g's turf_pathfinder feature). Synchronous, so a single
	// before/after TICK_USAGE_REAL snapshot is valid. Wrapped in try/catch because this needs a rust-g
	// build with turf_pathfinder enabled; falls back to reporting "unavailable" against a stock rust-g
	// DLL instead of crashing the verb.
	var/list/rustg_nav_path
	var/rustg_nav_ms
	var/rustg_nav_available = TRUE
	var/rustg_nav_start = TICK_USAGE_REAL
	try
		rustg_nav_path = rustg_nav_astar(start, goal, info, NAV_IS_FLYING(info), 200)
	catch
		rustg_nav_available = FALSE
		rustg_nav_path = list()
	rustg_nav_ms = TICK_USAGE_TO_MS(rustg_nav_start)

	// A/B comparison against the existing JPS pathfinder (read-only use of the old system). Unlike the
	// synchronous rust call above, get_path_to yields on SSpathfinder's async queue via UNTIL(),
	// potentially across several ticks, so TICK_USAGE_REAL/TO_MS can't be taken as a single
	// before/after snapshot here. We build the pathfind datum ourselves (rather than going through
	// get_path_to) so we can read back its accumulated compute_time - the sum of its own search_step()
	// tick usage, which SSpathfinder.fire() tracks regardless of how many ticks the search spans.
	var/list/access = info.access || list()
	var/list/hand_around = list()
	var/datum/pathfind/jps/legacy_path = new()
	legacy_path.setup(user.mob, access, /*max_distance*/ 0, /*simulated_only*/ TRUE, /*avoid*/ null, \
		list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around)), goal, /*mintargetdist*/ 0, /*skip_first*/ TRUE, DIAGONAL_REMOVE_CLUNKY)
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
		Rust A*: [rustg_nav_available ? "[length(rustg_nav_path) ? "[length(rustg_nav_path)] steps" : "NO PATH"] in [rustg_nav_ms]ms" : "unavailable (rust-g missing turf_pathfinder)"]"))

ADMIN_VERB(navmesh_inspect_turf, R_DEBUG, "Navmesh: Inspect Turf", "Prints the baked navmesh data for your current turf.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	if(!here)
		return
	if(isnull(here.nav_pass))
		here.nav_bake()
	var/list/lines = list("Navmesh at [AREACOORD(here)] (nav_pass = [here.nav_pass]):")
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

/*
 * A minimal pawn that walks a nav path to a target and repaths when it gets stuck (something moved
 * into the way, a door refused it). Demonstrates that mobs and access are resolved at execution time,
 * not baked into the mesh. Driven entirely by /datum/move_loop/has_target/navmesh_astar (see
 * code/controllers/subsystem/movement/movement_types_navmesh.dm) rather than any ad-hoc loop of its
 * own - SSmovement handles the ticking, repathing, and obstruction recovery.
 */
/mob/living/basic/nav_tester
	name = "navmesh tester"
	desc = "A test pawn that walks navmesh paths."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "mouse_gray"
	maxHealth = 100
	health = 100

/mob/living/basic/nav_tester/proc/set_nav_target(atom/target)
	GLOB.move_manager.navmesh_astar_move(
		src,
		target,
		delay = 2,
		repath_delay = 1 SECONDS,
		max_path_length = 0,
		access = list(),
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
