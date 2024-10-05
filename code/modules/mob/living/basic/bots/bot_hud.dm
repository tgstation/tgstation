/mob/living/basic/bot/proc/diag_hud_set_bothealth()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/icon_image = icon(icon, icon_state, dir)
	holder.pixel_y = icon_image.Height() - ICON_SIZE_Y
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/basic/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/our_icon = icon(icon, icon_state, dir)
	holder.pixel_y = our_icon.Height() - ICON_SIZE_Y
	if(bot_mode_flags & BOT_MODE_ON)
		holder.icon_state = "hudstat"
		return
	if(stat != CONSCIOUS)
		holder.icon_state = "hudoffline"
		return
	holder.icon_state = "huddead2"

/mob/living/basic/bot/proc/diag_hud_set_botmode() //Shows a bot's current operation
	var/image/holder = hud_list[DIAG_BOT_HUD]
	var/icon/icon_image = icon(icon, icon_state, dir)
	holder.pixel_y = icon_image.Height() - ICON_SIZE_Y
	if(client) //If the bot is player controlled, it will not be following mode logic!
		holder.icon_state = "hudsentient"
		return

	switch(mode)
		if(BOT_SUMMON, BOT_RESPONDING) //Responding to PDA or AI summons
			holder.icon_state = "hudcalled"
		if(BOT_CLEANING, BOT_REPAIRING, BOT_HEALING) //Cleanbot cleaning, Floorbot fixing, or Medibot Healing
			holder.icon_state = "hudworking"
		if(BOT_PATROL, BOT_START_PATROL) //Patrol mode
			holder.icon_state = "hudpatrol"
		if(BOT_PREP_ARREST, BOT_ARREST, BOT_HUNT) //STOP RIGHT THERE, CRIMINAL SCUM!
			holder.icon_state = "hudalert"
		if(BOT_MOVING, BOT_DELIVER, BOT_GO_HOME, BOT_NAV) //Moving to target for normal bots, moving to deliver or go home for MULES.
			holder.icon_state = "hudmove"
		else
			holder.icon_state = ""

///proc that handles drawing and transforming the bot's path onto diagnostic huds
/mob/living/basic/bot/proc/generate_bot_path(datum/move_loop/has_target/jps/source)
	SIGNAL_HANDLER

	UnregisterSignal(src, COMSIG_MOVELOOP_JPS_FINISHED_PATHING)

	if(isnull(ai_controller))
		return

	//Removes path images and handles removing hud client images
	clear_path_hud()

	var/list/path_huds_watching_me = list(GLOB.huds[DATA_HUD_DIAGNOSTIC], GLOB.huds[DATA_HUD_BOT_PATH])

	var/list/path_images = active_hud_list[DIAG_PATH_HUD]
	LAZYCLEARLIST(path_images)


	var/atom/move_target = ai_controller.current_movement_target
	if(move_target != ai_controller.blackboard[BB_BEACON_TARGET])
		return

	var/list/our_path = source.movement_path
	if(!length(our_path))
		return

	for(var/index in 1 to our_path.len)
		if(index == 1 || index == our_path.len)
			continue
		var/turf/current_turf = our_path[index]
		var/turf/previous_turf = our_path[index - 1]

		var/turf/next_turf = our_path[index + 1]
		var/next_direction = get_dir(previous_turf, next_turf)
		var/previous_direction = get_dir(current_turf, previous_turf)

		var/image/path_display = image(icon = path_image_icon, loc = current_turf, icon_state = path_image_icon_state, layer = BOT_PATH_LAYER, dir = next_direction)

		SET_PLANE(path_display, GAME_PLANE, current_turf)

		if((ISDIAGONALDIR(next_direction) && (previous_direction & (NORTH|SOUTH))))
			var/turn_value = (next_direction == SOUTHWEST || next_direction == NORTHEAST) ? 90 : -90
			path_display.transform = path_display.transform.Turn(turn_value)
			path_display.transform = path_display.transform.Scale(1, -1)

		path_display.color = path_image_color
		path_images += path_display
		current_pathed_turfs[current_turf] = path_display

	for(var/datum/atom_hud/hud as anything in path_huds_watching_me)
		hud.add_atom_to_hud(src)

///proc that handles moving along the bot's drawn path
/mob/living/basic/bot/proc/handle_loop_movement(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	handle_hud_path()
	on_bot_movement(source, oldloc, dir, forced)

/mob/living/basic/bot/proc/handle_hud_path()
	if(client || !length(current_pathed_turfs) || isnull(ai_controller))
		return

	var/atom/move_target = ai_controller.current_movement_target

	if(move_target != ai_controller.blackboard[BB_BEACON_TARGET])
		clear_path_hud()

	var/turf/our_turf = get_turf(src)
	var/image/target_image = current_pathed_turfs[our_turf]
	if(target_image)
		animate(target_image, alpha = 0, time = 0.3 SECONDS)
	current_pathed_turfs -= our_turf

///proc that handles deleting the bot's drawn path when needed
/mob/living/basic/bot/proc/clear_path_hud()
	for(var/turf/index as anything in current_pathed_turfs)
		var/image/our_image = current_pathed_turfs[index]
		animate(our_image, alpha = 0, time = 0.3 SECONDS)
		current_pathed_turfs -= index

	// Call hud remove handlers to ensure viewing user client images are removed
	var/list/path_huds_watching_me = list(GLOB.huds[DATA_HUD_DIAGNOSTIC], GLOB.huds[DATA_HUD_BOT_PATH])
	for(var/datum/atom_hud/hud as anything in path_huds_watching_me)
		hud.remove_atom_from_hud(src)

