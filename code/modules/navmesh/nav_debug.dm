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

	var/nav_start = TICK_USAGE_REAL
	var/list/nav_path = nav_find_path(start, goal, info, max_distance = 0)
	var/nav_ms = TICK_USAGE_TO_MS(nav_start)

	// A/B comparison against the existing JPS pathfinder (read-only use of the old system).
	var/list/access = info.access || list()
	var/jps_start = TICK_USAGE_REAL
	var/list/jps_path = get_path_to(user.mob, goal, max_distance = 100, access = access)
	var/jps_ms = TICK_USAGE_TO_MS(jps_start)

	for(var/turf/step as anything in nav_path)
		new /obj/effect/temp_visual/nav_marker(step)

	to_chat(user, span_boldnotice("Navmesh path: [length(nav_path) ? "[length(nav_path)] steps" : "NO PATH"] in [nav_ms]ms. \
		JPS: [length(jps_path) ? "[length(jps_path)] steps" : "NO PATH"] in [jps_ms]ms. \
		(baked so far: [SSnavmesh.bakes], cond evals: [SSnavmesh.cond_evaluations])"))

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
 * not baked into the mesh.
 */
/mob/living/basic/nav_tester
	name = "navmesh tester"
	desc = "A test pawn that walks navmesh paths."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "mouse_gray"
	maxHealth = 100
	health = 100
	//basic_mob_flags = FLICKS_ON_HIT temp disabled; flag isnt real?

	/// Where we're trying to go.
	var/atom/nav_target
	/// The remaining path (list of turfs).
	var/list/current_path
	/// Consecutive failed steps before we give up on the cached path and recompute.
	var/failed_steps = 0

/mob/living/basic/nav_tester/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/mob/living/basic/nav_tester/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	nav_target = null
	current_path = null
	return ..()

/mob/living/basic/nav_tester/proc/set_nav_target(atom/target)
	nav_target = target
	current_path = null
	failed_steps = 0

/mob/living/basic/nav_tester/process(seconds_per_tick)
	if(!nav_target)
		return
	var/turf/our_turf = get_turf(src)
	var/turf/goal = get_turf(nav_target)
	if(!our_turf || !goal || our_turf == goal)
		return

	if(!length(current_path))
		current_path = get_nav_path_to(src, nav_target, max_distance = 0)
		if(!length(current_path))
			return

	var/turf/next_step = current_path[1]
	var/old_turf = our_turf
	step_towards(src, next_step)

	if(get_turf(src) == next_step)
		current_path.Cut(1, 2)
		failed_steps = 0
	else if(get_turf(src) != old_turf)
		// We moved but not where we planned (bumped along); trust the mesh, recompute.
		current_path = null
	else
		failed_steps++
		if(failed_steps >= 2)
			current_path = null // stuck: mob or door in the way, get a fresh path
			failed_steps = 0

ADMIN_VERB(navmesh_spawn_tester, R_DEBUG, "Navmesh: Spawn Tester", "Spawns a pawn that walks a navmesh path to the set goal.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	var/turf/goal = user.nav_debug_goal
	if(!here || !goal)
		to_chat(user, span_warning("Set a goal first (Navmesh: Set Goal)."))
		return
	var/mob/living/basic/nav_tester/pawn = new(here)
	pawn.set_nav_target(goal)
	to_chat(user, span_notice("Spawned a navmesh tester heading for [AREACOORD(goal)]."))
