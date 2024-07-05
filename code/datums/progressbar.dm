#define PROGRESSBAR_HEIGHT 6
#define PROGRESSBAR_ANIMATION_TIME 5

/datum/progressbar
	///The progress bar visual element.
	var/image/bar
	///The target where this progress bar is applied and where it is shown.
	var/atom/bar_loc
	///The mob whose client sees the progress bar.
	var/mob/user
	///The client seeing the progress bar.
	var/client/user_client
	///Effectively the number of steps the progress bar will need to do before reaching completion.
	var/goal = 1
	///Control check to see if the progress was interrupted before reaching its goal.
	var/last_progress = 0
	///Variable to ensure smooth visual stacking on multiple progress bars.
	var/listindex = 0
	///border image
	var/image/border
	///shown image
	var/image/shown_image
	///accessroy overlay that goes over the bar
	var/image/border_look_accessory
	///the color shown when its active
	var/active_color
	///the color shown when it fails
	var/fail_color
	///the color shown when it succeeds
	var/finish_color
	///do we use the old format of progress bars or the new version
	var/old_format = FALSE
	///the icon_state of the bar
	var/bar_look


/datum/progressbar/New(mob/User, goal_number, atom/target, border_look = "border", border_look_accessory, bar_look = "prog_bar", old_format = FALSE, active_color = "#6699FF", finish_color = "#FFEE8C", fail_color = "#FF0033" , mutable_appearance/additional_image)
	. = ..()
	if (!istype(target))
		stack_trace("Invalid target [target] passed in")
		qdel(src)
		return
	if(QDELETED(User) || !istype(User))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] user")
		qdel(src)
		return
	if(!isnum(goal_number))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] goal_number")
		qdel(src)
		return
	goal = goal_number
	src.old_format = old_format
	src.active_color = active_color
	src.fail_color = fail_color
	src.finish_color = finish_color

	src.bar_look = bar_look
	if(additional_image)
		shown_image = image(additional_image.icon, target, additional_image.icon_state, 1.1)
		SET_PLANE_EXPLICIT(shown_image, ABOVE_HUD_PLANE, User)
		shown_image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	border = image('monkestation/icons/effects/progessbar.dmi', target, border_look, 1)
	border.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	bar = image('monkestation/icons/effects/progessbar.dmi', target, bar_look, 1.1)

	SET_PLANE_EXPLICIT(bar, ABOVE_HUD_PLANE, User)
	SET_PLANE_EXPLICIT(border, ABOVE_HUD_PLANE, User)
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	bar.color = active_color

	if(border_look_accessory)
		src.border_look_accessory = shown_image = image('monkestation/icons/effects/progessbar.dmi', target, border_look_accessory, 1.2)
		SET_PLANE_EXPLICIT(src.border_look_accessory, ABOVE_HUD_PLANE, User)
		src.border_look_accessory.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	user = User

	LAZYADDASSOCLIST(user.progressbars, bar_loc, src)
	var/list/bars = user.progressbars[bar_loc]
	listindex = bars.len

	if(user.client)
		user_client = user.client
		add_prog_bar_image_to_client()

	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_user_delete))
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(clean_user_client))
	RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(on_user_login))


/datum/progressbar/Destroy()
	if(user)
		for(var/pb in user.progressbars[bar_loc])
			var/datum/progressbar/progress_bar = pb
			if(progress_bar == src || progress_bar.listindex <= listindex)
				continue
			progress_bar.listindex--

			var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * (progress_bar.listindex - 1)) - PROGRESSBAR_HEIGHT
			animate(progress_bar.bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
			animate(progress_bar.border, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
			if(progress_bar.shown_image)
				animate(progress_bar.shown_image, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
			if(progress_bar.border_look_accessory)
				animate(progress_bar.border_look_accessory, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

		LAZYREMOVEASSOC(user.progressbars, bar_loc, src)
		user = null

	if(user_client)
		clean_user_client()

	bar_loc = null
	bar = null

	return ..()


///Called right before the user's Destroy()
/datum/progressbar/proc/on_user_delete(datum/source)
	SIGNAL_HANDLER

	user.progressbars = null //We can simply nuke the list and stop worrying about updating other prog bars if the user itself is gone.
	user = null
	qdel(src)


///Removes the progress bar image from the user_client and nulls the variable, if it exists.
/datum/progressbar/proc/clean_user_client(datum/source)
	SIGNAL_HANDLER

	if(!user_client) //Disconnected, already gone.
		return
	user_client.images -= bar
	user_client.images -= border
	if(shown_image)
		user_client.images -= shown_image
	if(border_look_accessory)
		user_client.images -= border_look_accessory
	user_client = null


///Called by user's Login(), it transfers the progress bar image to the new client.
/datum/progressbar/proc/on_user_login(datum/source)
	SIGNAL_HANDLER

	if(user_client)
		if(user_client == user.client) //If this was not client handling I'd condemn this sanity check. But clients are fickle things.
			return
		clean_user_client()
	if(!user.client) //Clients can vanish at any time, the bastards.
		return
	user_client = user.client
	add_prog_bar_image_to_client()


///Adds a smoothly-appearing progress bar image to the player's screen.
/datum/progressbar/proc/add_prog_bar_image_to_client()
	var/stored_index = listindex - 1
	bar.pixel_y = -32
	bar.alpha = 0
	user_client.images += bar
	animate(bar, pixel_y = 32 + (PROGRESSBAR_HEIGHT * stored_index), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	border.pixel_y = -32
	border.alpha = 0
	user_client.images += border
	animate(border, pixel_y = 32 + (PROGRESSBAR_HEIGHT * stored_index), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(shown_image)
		shown_image.pixel_y = -32
		shown_image.alpha = 0
		user_client.images += shown_image
		animate(shown_image, pixel_y = 32 + (PROGRESSBAR_HEIGHT * stored_index), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(border_look_accessory)
		src.border_look_accessory.pixel_y = -32
		src.border_look_accessory.alpha = 0
		user_client.images += border_look_accessory
		animate(src.border_look_accessory, pixel_y = 32 + (PROGRESSBAR_HEIGHT * stored_index), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

///Updates the progress bar image visually.
/datum/progressbar/proc/update(progress)
	progress = clamp(progress, 0, goal)
	if(progress == last_progress)
		return
	last_progress = progress
	var/complete = clamp(progress / goal, 0, 1)
	if(old_format)
		bar.icon_state = "[bar_look]_[round(((progress / goal) * 100), 5)]"
	else
		bar.transform = matrix(complete, 0, -10 * (1 - complete), 0, 1, 0)


///Called on progress end, be it successful or a failure. Wraps up things to delete the datum and bar.
/datum/progressbar/proc/end_progress()
	if(last_progress != goal)
		if(old_format)
			bar.icon_state = "[bar.icon_state]_fail"
		else
			bar.color = fail_color

	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	animate(border, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)

	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)
	QDEL_IN(border, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	if(shown_image)
		animate(shown_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(shown_image, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	if(border_look_accessory)
		animate(border_look_accessory, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(border_look_accessory, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety


/obj/effect/world_progressbar
	///The progress bar visual element.
	icon = 'monkestation/icons/effects/progessbar.dmi'
	icon_state = "border"
	plane = RUNECHAT_PLANE
	layer = FLY_LAYER
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	base_pixel_y = 20
	pixel_y = 20
	var/obj/effect/bar/bar
	var/obj/effect/additional_image/additional_image
	var/obj/effect/border_accessory/border_accessory
	///The target where this progress bar is applied and where it is shown.
	var/atom/movable/bar_loc
	///The atom who "created" the bar
	var/atom/owner
	///Effectively the number of steps the progress bar will need to do before reaching completion.
	var/goal = 1
	///Control check to see if the progress was interrupted before reaching its goal.
	var/last_progress = 0
	///Variable to ensure smooth visual stacking on multiple progress bars.
	var/listindex = 0
	///the look of the bar inside the progress bar
	var/bar_look
	///does this use the old format of icons(useful for totally unqiue progress bars)
	var/old_format = FALSE

	///the color of the bar for new style bars
	var/finish_color
	var/active_color
	var/fail_color

/obj/effect/world_progressbar/Initialize(mapload, atom/owner, goal, atom/target, border_look = "border", border_accessory, bar_look = "prog_bar", old_format = FALSE, active_color = "#6699FF", finish_color = "#FFEE8C", fail_color = "#FF0033" , mutable_appearance/additional_image, has_outline = TRUE, y_multiplier)
	. = ..()
	if(!owner || !target || !goal)
		return INITIALIZE_HINT_QDEL

	src.icon_state = border_look
	src.bar_look = bar_look
	src.old_format = old_format
	src.owner = owner
	src.goal = goal
	src.bar_loc = target
	src.base_pixel_y *= y_multiplier
	src.pixel_y *= y_multiplier
	if(additional_image)
		src.additional_image = new /obj/effect/additional_image
		src.additional_image.icon = additional_image.icon
		src.additional_image.icon_state = additional_image.icon_state
		src.additional_image.plane = src.plane
		src.additional_image.layer = src.layer - 0.1
		src.additional_image.pixel_y *= y_multiplier
		src.additional_image.base_pixel_y *= y_multiplier
		if(has_outline)
			src.additional_image.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FFFFFF"))
		src.bar_loc.vis_contents += src.additional_image

	src.bar_loc:vis_contents += src

	src.bar = new /obj/effect/bar
	src.bar.icon = icon
	src.bar.icon_state = bar_look
	src.bar.layer = src.layer + 0.1
	src.bar.plane = src.plane
	src.bar_loc.vis_contents += src.bar
	src.bar.alpha = 0
	src.bar.pixel_y *= y_multiplier
	src.bar.base_pixel_y *= y_multiplier

	if(border_accessory)
		src.border_accessory = new /obj/effect/border_accessory
		src.border_accessory.icon = icon
		src.border_accessory.icon_state = border_accessory
		src.border_accessory.layer = src.layer + 0.2
		src.border_accessory.plane = src.plane
		src.border_accessory.pixel_y *= y_multiplier
		src.border_accessory.base_pixel_y *= y_multiplier
		if(has_outline)
			src.border_accessory.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FFFFFF"))
		src.bar_loc.vis_contents += src.border_accessory

	src.finish_color = finish_color
	src.active_color = active_color
	src.fail_color = fail_color
	if(has_outline)
		src.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FFFFFF"))

	RegisterSignal(bar_loc, COMSIG_QDELETING, PROC_REF(bar_loc_delete), override = TRUE)
	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(owner_delete), override = TRUE)

/obj/effect/world_progressbar/Destroy()
	owner = null
	bar_loc = null
	bar_loc?:vis_contents -= src
	bar_loc?:vis_contents -= bar
	bar_loc?:vis_contents -= border_accessory
	bar_loc?:vis_contents -= additional_image
	qdel(bar)
	qdel(border_accessory)
	qdel(additional_image)
	cut_overlays()
	return ..()

/obj/effect/world_progressbar/proc/bar_loc_delete()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/world_progressbar/proc/owner_delete()
	SIGNAL_HANDLER
	qdel(src)

///Updates the progress bar image visually.
/obj/effect/world_progressbar/proc/update(progress)
	bar.alpha = 255
	bar.color = active_color
	var/complete = clamp(progress / goal, 0, 1)
	progress = clamp(progress, 0, goal)
	if(progress == last_progress)
		return
	last_progress = progress
	if(old_format)
		bar.icon_state = "[bar_look]_[round(((progress / goal) * 100), 5)]"
	else
		bar.transform = matrix(complete, 0, -10 * (1 - complete), 0, 1, 0)

/obj/effect/world_progressbar/proc/end_progress()
	if(last_progress != goal)
		bar.icon_state = "[bar_look]_fail"
		bar.color = fail_color
	bar.color = finish_color
	animate(src, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	animate(src.bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)


	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)
	QDEL_IN(src.bar, PROGRESSBAR_ANIMATION_TIME)

	if(additional_image)
		animate(src.additional_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(src.additional_image, PROGRESSBAR_ANIMATION_TIME)
	if(border_accessory)
		animate(src.border_accessory, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(src.border_accessory, PROGRESSBAR_ANIMATION_TIME)

#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT

/obj/effect/bar
	plane = RUNECHAT_PLANE
	base_pixel_y = 20
	pixel_y = 20
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/additional_image
	plane = RUNECHAT_PLANE
	base_pixel_y = 20
	pixel_y = 20
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/border_accessory
	plane = RUNECHAT_PLANE
	base_pixel_y = 20
	pixel_y = 20
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/proc/machine_do_after_visable(atom/source, delay, progress = TRUE, border_look = "border", border_look_accessory, bar_look = "prog_bar", active_color = "#6699FF", finish_color = "#FFEE8C", fail_color = "#FF0033", old_format = FALSE, image/add_image, has_outline = TRUE, y_multiplier = 1)
	var/atom/target_loc = source

	var/datum/progressbar/progbar
	if(progress)
		progbar = new /obj/effect/world_progressbar(null, source, delay, target_loc || source,  border_look, border_look_accessory, bar_look, old_format, active_color, finish_color, fail_color, add_image, has_outline, y_multiplier)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE

	while (world.time < endtime)
		stoplag(1)
		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)

	if(!QDELETED(progbar))
		progbar.end_progress()
