GLOBAL_DATUM_INIT(pathfind_dude, /obj/pathfind_guy, new())

/obj/pathfind_guy

/// Enables testing/visualization of pathfinding work
/datum/pathfind_debug
	var/datum/admins/owner
	var/datum/action/innate/path_debug/jps/jps_debug
	var/datum/action/innate/path_debug/sssp/sssp_debug

/datum/pathfind_debug/New(datum/admins/owner)
	src.owner = owner
	hook_client()

/datum/pathfind_debug/Destroy(force)
	QDEL_NULL(jps_debug)
	QDEL_NULL(sssp_debug)
	return ..()

/datum/pathfind_debug/proc/hook_client()
	if(!owner.owner)
		return
	QDEL_NULL(jps_debug)
	QDEL_NULL(sssp_debug)
	jps_debug = new
	jps_debug.Grant(owner.owner.mob)
	sssp_debug = new()
	sssp_debug.Grant(owner.owner.mob)
	RegisterSignal(owner.owner.mob, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))

/datum/pathfind_debug/proc/on_logout(mob/logging_out)
	SIGNAL_HANDLER
	UnregisterSignal(logging_out, COMSIG_MOB_LOGOUT)
	var/mob/new_mob = owner.owner?.mob
	if(!new_mob)
		RegisterSignal(logging_out, COMSIG_MOB_LOGIN, PROC_REF(on_login))
		return
	hook_client()

/datum/pathfind_debug/proc/on_login(mob/logging_in)
	SIGNAL_HANDLER
	UnregisterSignal(logging_in, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_LOGIN))
	hook_client()

/datum/action/innate/path_debug
	var/list/image/display_images = list()

/datum/action/innate/path_debug/Activate()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(clicked_somethin))
	active = TRUE

/datum/action/innate/path_debug/Deactivate()
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)
	clear_visuals()
	active = FALSE
	return ..()

/datum/action/innate/path_debug/proc/clicked_somethin(datum/source, atom/clicked, list/modifiers)
	SIGNAL_HANDLER
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		return NONE

	var/turf/clunked = get_turf(clicked)
	if(!clunked)
		return NONE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		right_clicked(clunked)
	else
		left_clicked(clunked)

	update_visuals()
	if(path_ready())
		pathfind()

/datum/action/innate/path_debug/proc/left_clicked(turf/clicked_on)
	return

/datum/action/innate/path_debug/proc/right_clicked(turf/clicked_on)
	return

/datum/action/innate/path_debug/proc/update_visuals()
	clear_visuals()
	build_visuals()
	owner.client?.images += display_images

/datum/action/innate/path_debug/proc/clear_visuals()
	owner.client?.images -= display_images
	display_images = list()

/datum/action/innate/path_debug/proc/build_visuals()
	return

/datum/action/innate/path_debug/proc/path_ready()
	return FALSE

/datum/action/innate/path_debug/proc/pathfind()
	INVOKE_ASYNC(src, PROC_REF(run_the_path), GLOB.pathfind_dude)
	GLOB.pathfind_dude.moveToNullspace()

/datum/action/innate/path_debug/proc/run_the_path(atom/movable/middle_man)
	return

/datum/action/innate/path_debug/proc/render_path(list/turf/draw_list)
	if(!length(draw_list))
		return list()

	var/list/image/turf_images = list()
	// Render everything but the first and last
	for(var/i in 1 to (length(draw_list) - 1))
		var/turf/problem_child = draw_list[i]
		var/turf/next = draw_list[i + 1]
		turf_images += render_turf(problem_child, get_dir(problem_child, next))

	return turf_images

/datum/action/innate/path_debug/proc/render_turf(turf/draw, direction)
	var/image/arrow = image('icons/turf/debug.dmi', draw, "arrow", PATH_ARROW_DEBUG_LAYER, direction)
	SET_PLANE_EXPLICIT(arrow, BALLOON_CHAT_PLANE, draw)
	return arrow

/datum/action/innate/path_debug/jps
	name = "JPS Test"
	button_icon = 'icons/turf/debug.dmi'
	button_icon_state = "jps"

	// Mirror vars for jps calls
	var/turf/source_turf
	var/turf/target_turf
	var/max_distance
	var/min_distance
	var/allowed_on_space
	var/turf/blacklisted_turf
	var/diagonal_handling
	/// List of turfs we are showing to our owner currently
	var/list/turf/display_turfs

/datum/action/innate/path_debug/jps/Activate()
	. = ..()
	max_distance = tgui_input_number(owner, "How far should we be allowed to try and path", "Max Distance", min_value = 1, default = 30)
	min_distance = tgui_input_number(owner, "How close should we try and get to the target before stopping", "Min Distance", min_value = 0, default = 0)
	allowed_on_space = tgui_alert(owner, "Are we allowed to path over space?", "Space Pathing", buttons = list("Yes", "No")) == "Yes"
	var/text_blacklist = tgui_input_text(owner, "Enter any turf path you want to blacklist (You get one)", "Turf Blacklist")
	if(text_blacklist)
		blacklisted_turf = pick_closest_path(text_blacklist)
	else
		blacklisted_turf = null
	diagonal_handling = DIAGONAL_DO_NOTHING
	switch(tgui_input_list(owner, "Pick how you want to handle diagonal moves", "Diagonal Moves", list("Leave Them Be", "Drop All", "Drop Odd Ones")))
		if("Leave Them Be")
			diagonal_handling = DIAGONAL_DO_NOTHING
		if("Drop All")
			diagonal_handling = DIAGONAL_REMOVE_ALL
		if("Drop Odd Ones")
			diagonal_handling = DIAGONAL_REMOVE_CLUNKY

/datum/action/innate/path_debug/jps/Deactivate()
	source_turf = null
	target_turf = null
	display_turfs = list()
	return ..()

/datum/action/innate/path_debug/jps/left_clicked(turf/clicked_on)
	source_turf = clicked_on
	display_turfs = list()

/datum/action/innate/path_debug/jps/right_clicked(turf/clicked_on)
	target_turf = clicked_on
	display_turfs = list()

/datum/action/innate/path_debug/jps/build_visuals()
	. = ..()
	if(source_turf)
		var/image/start = image('icons/turf/debug.dmi', source_turf, "start", PATH_DEBUG_LAYER)
		SET_PLANE_EXPLICIT(start, BALLOON_CHAT_PLANE, source_turf)
		display_images += start
	if(target_turf)
		var/image/end = image('icons/turf/debug.dmi', target_turf, "end", PATH_DEBUG_LAYER)
		SET_PLANE_EXPLICIT(end, BALLOON_CHAT_PLANE, target_turf)
		display_images += end

	display_images += render_path(display_turfs)

/datum/action/innate/path_debug/jps/path_ready()
	return (source_turf && target_turf)

/datum/action/innate/path_debug/jps/run_the_path(atom/movable/middle_man)
	middle_man.forceMove(source_turf)
	display_turfs = get_path_to(middle_man, target_turf, max_distance, min_distance, list(), allowed_on_space, blacklisted_turf, skip_first = FALSE, diagonal_handling = diagonal_handling)
	update_visuals()

/datum/action/innate/path_debug/sssp
	name = "Pathmap Test"
	button_icon = 'icons/turf/debug.dmi'
	button_icon_state = "sssp"

	// Mirror vars for sssp calls
	var/turf/source_turf
	var/max_distance
	var/allowed_on_space
	var/turf/blacklisted_turf
	// Turf to display the path to (optional)
	var/turf/target_turf
	/// List of turfs we are showing to our owner currently
	var/datum/path_map/shown_map

/datum/action/innate/path_debug/sssp/Activate()
	. = ..()
	max_distance = tgui_input_number(owner, "How far should we be allowed to try and path", "Max Distance", min_value = 1, default = 30)
	allowed_on_space = tgui_alert(owner, "Are we allowed to path over space?", "Space Pathing", buttons = list("Yes", "No")) == "Yes"
	var/text_blacklist = tgui_input_text(owner, "Enter any turf path you want to blacklist (You get one)", "Turf Blacklist")
	if(text_blacklist)
		blacklisted_turf = pick_closest_path(text_blacklist)
	else
		blacklisted_turf = null

/datum/action/innate/path_debug/sssp/Deactivate()
	source_turf = null
	target_turf = null
	shown_map = null
	return ..()

/datum/action/innate/path_debug/sssp/left_clicked(turf/clicked_on)
	source_turf = clicked_on
	shown_map = null

/datum/action/innate/path_debug/sssp/right_clicked(turf/clicked_on)
	if(clicked_on == target_turf)
		target_turf = null
		return
	target_turf = clicked_on

/datum/action/innate/path_debug/sssp/build_visuals()
	. = ..()
	if(source_turf)
		var/image/start = image('icons/turf/debug.dmi', source_turf, "start", PATH_DEBUG_LAYER)
		SET_PLANE_EXPLICIT(start, BALLOON_CHAT_PLANE, source_turf)
		display_images += start

	if(target_turf)
		var/image/end = image('icons/turf/debug.dmi', target_turf, "end", PATH_DEBUG_LAYER)
		SET_PLANE_EXPLICIT(end, BALLOON_CHAT_PLANE, target_turf)
		display_images += end
		if(shown_map)
			display_images += render_path(shown_map.get_path_to(target_turf))
	else
		if(!shown_map)
			return
		var/list/turf/next_closest = shown_map.next_closest
		var/turf/start = shown_map?.start
		for(var/turf/next_dude as anything in next_closest)
			if(next_dude == start)
				continue
			display_images += render_turf(next_dude, get_dir(next_dude, next_closest[next_dude]))

/datum/action/innate/path_debug/sssp/path_ready()
	return (source_turf && source_turf != shown_map?.start)

/datum/action/innate/path_debug/sssp/run_the_path(atom/movable/middle_man)
	middle_man.forceMove(source_turf)
	shown_map = get_sssp(middle_man, max_distance, list(), allowed_on_space, blacklisted_turf)
	update_visuals()
