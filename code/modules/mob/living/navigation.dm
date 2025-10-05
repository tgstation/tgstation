#define MAX_NAVIGATE_RANGE 125

/mob/living
	/// Cooldown of the navigate() verb.
	COOLDOWN_DECLARE(navigate_cooldown)

/client
	/// Images of the path created by navigate().
	var/list/navigation_images = list()

/mob/living/verb/navigate()
	set name = "Navigate"
	set category = "IC"

	if(incapacitated)
		return
	if(length(client.navigation_images))
		addtimer(CALLBACK(src, PROC_REF(cut_navigation)), world.tick_lag)
		balloon_alert(src, "navigation path removed")
		return
	if(!COOLDOWN_FINISHED(src, navigate_cooldown))
		balloon_alert(src, "navigation on cooldown!")
		return
	addtimer(CALLBACK(src, PROC_REF(create_navigation)), world.tick_lag)

/mob/living/proc/create_navigation()
	var/list/destination_list = list()
	for(var/atom/destination as anything in GLOB.navigate_destinations)
		if(get_dist(destination, src) > MAX_NAVIGATE_RANGE)
			continue
		var/destination_name = GLOB.navigate_destinations[destination]
		if(destination.z != z && is_multi_z_level(z)) // up or down is just a good indicator "we're on the station", we don't need to check specifics
			destination_name += ((get_dir_multiz(src, destination) & UP) ? " (Above)" : " (Below)")

		destination_list[destination_name] = destination

	var/can_go_down = SSmapping.level_trait(z, ZTRAIT_DOWN)
	var/can_go_up = SSmapping.level_trait(z, ZTRAIT_UP)
	if(can_go_down)
		destination_list["Nearest Way Down"] = DOWN
	if(can_go_up)
		destination_list["Nearest Way Up"] = UP

	if(!length(destination_list))
		balloon_alert(src, "no navigation signals!")
		return

	var/platform_code = tgui_input_list(src, "Select a location", "Navigate", sort_list(destination_list))
	var/atom/navigate_target = destination_list[platform_code]

	if(isnull(navigate_target) || incapacitated)
		return


	var/finding_zchange = FALSE
	COOLDOWN_START(src, navigate_cooldown, 15 SECONDS)
	if(navigate_target == UP || navigate_target == DOWN || (isatom(navigate_target) && navigate_target.z != z))
		// lowering the cooldown to 5 seconds if we're navigating to a ladder or staircase instead of a proper destination
		// (so we can decide to move to another destination right off the bat, rather than needing to wait)
		COOLDOWN_START(src, navigate_cooldown, 5 SECONDS)
		var/direction_name = isatom(navigate_target) ? "there" : (navigate_target == UP ? "up" : "down")
		var/nav_dir = isatom(navigate_target) ? (get_dir_multiz(src, navigate_target) & (UP|DOWN)) : navigate_target
		var/atom/new_target = find_nearest_stair_or_ladder(nav_dir)

		if(!new_target)
			balloon_alert(src, "can't find ladder or staircase going [direction_name]!")
			return

		navigate_target = new_target
		finding_zchange = TRUE

	if(!isatom(navigate_target))
		stack_trace("Navigate target ([navigate_target]) is not an atom, somehow.")
		return

	var/list/path = get_path_to(src, navigate_target, MAX_NAVIGATE_RANGE, mintargetdist = 1, access = get_access(), skip_first = FALSE)
	if(!length(path))
		balloon_alert(src, "no valid path with current access!")
		return
	path |= get_turf(navigate_target)
	for(var/i in 1 to length(path))
		var/turf/current_turf = path[i]
		var/image/path_image = image(icon = 'icons/effects/navigation.dmi', layer = HIGH_PIPE_LAYER, loc = current_turf)
		SET_PLANE(path_image, GAME_PLANE, current_turf)
		path_image.color = COLOR_CYAN
		path_image.alpha = 0
		var/dir_1 = 0
		var/dir_2 = 0
		if(i == 1)
			dir_2 = REVERSE_DIR(angle2dir(get_angle(path[i+1], current_turf)))
		else if(i == length(path))
			dir_2 = REVERSE_DIR(angle2dir(get_angle(path[i-1], current_turf)))
		else
			dir_1 = REVERSE_DIR(angle2dir(get_angle(path[i+1], current_turf)))
			dir_2 = REVERSE_DIR(angle2dir(get_angle(path[i-1], current_turf)))
			if(dir_1 > dir_2)
				dir_1 = dir_2
				dir_2 = REVERSE_DIR(angle2dir(get_angle(path[i+1], current_turf)))
		path_image.icon_state = "[dir_1]-[dir_2]"
		client.images += path_image
		client.navigation_images += path_image
		animate(path_image, 0.5 SECONDS, alpha = 150)
	addtimer(CALLBACK(src, PROC_REF(shine_navigation)), 0.5 SECONDS)
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(cut_navigation))
	if(finding_zchange)
		RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(cut_navigation))
	balloon_alert(src, "navigation path created")

/mob/living/proc/shine_navigation()
	for(var/i in 1 to length(client.navigation_images))
		if(!length(client.navigation_images))
			return
		animate(client.navigation_images[i], time = 1 SECONDS, loop = -1, alpha = 200, color = "#bbffff", easing = BACK_EASING | EASE_OUT)
		animate(time = 2 SECONDS, loop = -1, alpha = 150, color = "#00ffff", easing = CUBIC_EASING | EASE_OUT)
		stoplag(0.1 SECONDS)

/mob/living/proc/cut_navigation()
	SIGNAL_HANDLER
	for(var/image/navigation_path in client.navigation_images)
		client.images -= navigation_path
	client.navigation_images.Cut()
	UnregisterSignal(src, list(COMSIG_LIVING_DEATH, COMSIG_MOVABLE_Z_CHANGED))

/**
 * Finds nearest ladder or staircase either up or down.
 *
 * Arguments:
 * * direction - UP or DOWN.
 */
/mob/living/proc/find_nearest_stair_or_ladder(direction)
	if(!direction)
		return
	if(direction != UP && direction != DOWN)
		return

	var/target
	for(var/obj/structure/ladder/lad in GLOB.ladders)
		if(lad.z != z)
			continue
		if(direction == UP && !lad.up)
			continue
		if(direction == DOWN && !lad.down)
			continue
		if(!target)
			target = lad
			continue
		if(get_dist_euclidean(lad, src) > get_dist_euclidean(target, src))
			continue
		target = lad

	for(var/obj/structure/stairs/stairs_bro in GLOB.stairs)
		if(direction == UP && stairs_bro.z != z) //if we're going up, we need to find stairs on our z level
			continue
		if(direction == DOWN && stairs_bro.z != z - 1) //if we're going down, we need to find stairs on the z level beneath us
			continue
		if(!target)
			target = stairs_bro.z == z ? stairs_bro : get_step_multiz(stairs_bro, UP) //if the stairs aren't on our z level, get the turf above them (on our zlevel) to path to instead
			continue
		if(get_dist_euclidean(stairs_bro, src) > get_dist_euclidean(target, src))
			continue
		target = stairs_bro.z == z ? stairs_bro : get_step_multiz(stairs_bro, UP)

	return target

#undef MAX_NAVIGATE_RANGE
