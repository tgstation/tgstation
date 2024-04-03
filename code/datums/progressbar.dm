#define PROGRESSBAR_HEIGHT 6
#define PROGRESSBAR_ANIMATION_TIME 5

/datum/progressbar
	/// The progress bar visual element.
	var/image/bar
	/// The target where this progress bar is applied and where it is shown.
	var/atom/bar_loc
	/// The mob whose client sees the progress bar.
	var/mob/user
	/// The client seeing the progress bar.
	var/client/user_client
	/// Effectively the number of steps the progress bar will need to do before reaching completion.
	var/goal = 1
	/// Control check to see if the progress was interrupted before reaching its goal.
	var/last_progress = 0
	/// Variable to ensure smooth visual stacking on multiple progress bars.
	var/listindex = 0
	/// The type of our last value for bar_loc, for debugging
	var/location_type
	/// Where to draw the progress bar above the icon
	var/offset_y
	/// The progress visible to other players
	var/obj/effect/overlay/vis/cog
	/// The blank image to hide the cog
	var/image/blank

/datum/progressbar/New(mob/user, goal_number, atom/target)
	. = ..()
	if (!istype(target))
		stack_trace("Invalid target [target] passed in")
		qdel(src)
		return
	if(QDELETED(user) || !istype(user))
		stack_trace("/datum/progressbar created with [isnull(user) ? "null" : "invalid"] user")
		qdel(src)
		return
	if(!isnum(goal_number))
		stack_trace("/datum/progressbar created with [isnull(user) ? "null" : "invalid"] goal_number")
		qdel(src)
		return

	goal = goal_number
	bar_loc = target
	location_type = bar_loc.type

	var/list/icon_offsets = target.get_oversized_icon_offsets()
	var/offset_x = icon_offsets["x"]
	offset_y = icon_offsets["y"]

	bar = image('icons/effects/progressbar.dmi', bar_loc, "prog_bar_0", pixel_x = offset_x)
	SET_PLANE_EXPLICIT(bar, ABOVE_HUD_PLANE, user)
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	src.user = user

	LAZYADDASSOCLIST(user.progressbars, bar_loc, src)
	var/list/bars = user.progressbars[bar_loc]
	listindex = bars.len

	user_client = user.client
	add_prog_bar_image_to_client()
	add_cog_to_user()
	
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_user_delete))
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(clean_user_client))
	RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(on_user_login))


/datum/progressbar/Destroy()
	SSvis_overlays.remove_vis_overlay(user, user.managed_vis_overlays)

	if(user)
		for(var/pb in user.progressbars[bar_loc])
			var/datum/progressbar/progress_bar = pb
			if(progress_bar == src || progress_bar.listindex <= listindex)
				continue
			progress_bar.listindex--

			progress_bar.bar.pixel_y = world.icon_size + offset_y + (PROGRESSBAR_HEIGHT * (progress_bar.listindex - 1))
			var/dist_to_travel = world.icon_size + offset_y + (PROGRESSBAR_HEIGHT * (progress_bar.listindex - 1)) - PROGRESSBAR_HEIGHT
			animate(progress_bar.bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

		LAZYREMOVEASSOC(user.progressbars, bar_loc, src)
		user = null

	if(user_client)		
		clean_user_client()

	bar_loc = null
	bar = null
	cog = null

	return ..()


/// Called right before the user's Destroy()
/datum/progressbar/proc/on_user_delete(datum/source)
	SIGNAL_HANDLER

	user.progressbars = null //We can simply nuke the list and stop worrying about updating other prog bars if the user itself is gone.
	user = null
	qdel(src)


/// Removes the progress bar image from the user_client and nulls the variable, if it exists.
/datum/progressbar/proc/clean_user_client(datum/source)
	SIGNAL_HANDLER

	if(isnull(user_client)) //Disconnected, already gone.
		return
	user_client.images.Remove(bar, blank)
	user_client = null


/// Called by user's Login(), it transfers the progress bar image to the new client.
/datum/progressbar/proc/on_user_login(datum/source)
	SIGNAL_HANDLER

	if(user_client)
		if(user_client == user.client) //If this was not client handling I'd condemn this sanity check. But clients are fickle things.
			return
		clean_user_client()
	if(!isnull(user.client)) //Clients can vanish at any time, the bastards.
		return
	user_client = user.client
	add_prog_bar_image_to_client()


/// Adds a smoothly-appearing progress bar image to the player's screen.
/datum/progressbar/proc/add_prog_bar_image_to_client()
	bar.pixel_y = 0
	bar.alpha = 0
	user_client.images.Add(bar)
	animate(bar, pixel_y = world.icon_size + offset_y + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/// Adds the cog to the user, visible by other players
/datum/progressbar/proc/add_cog_to_user()
	cog = SSvis_overlays.add_vis_overlay(user, 
		icon = 'icons/effects/progressbar.dmi',
		iconstate = "cog",
		plane = ABOVE_HUD_PLANE,
		add_appearance_flags = APPEARANCE_UI_IGNORE_ALPHA,
		unique = TRUE,
		alpha = 0,
	)
	cog.pixel_y = world.icon_size + offset_y
	animate(cog, alpha = 255, time = PROGRESSBAR_ANIMATION_TIME)

	if(isnull(user_client))
		return

	blank = image('icons/blanks/32x32.dmi', cog, "nothing")
	SET_PLANE_EXPLICIT(blank, ABOVE_HUD_PLANE, user)
	blank.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	blank.override = TRUE	

/// Updates the progress bar image visually.
/datum/progressbar/proc/update(progress)
	progress = clamp(progress, 0, goal)
	if(progress == last_progress)
		return
	last_progress = progress
	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"


/// Called on progress end, be it successful or a failure. Wraps up things to delete the datum and bar.
/datum/progressbar/proc/end_progress()
	if(last_progress != goal)
		bar.icon_state = "[bar.icon_state]_fail"

	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	animate(cog, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)

	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)

/// Progress bars are very generic, and what hangs a ref to them depends heavily on the context in which they're used
/// So let's make hunting harddels easier yeah?
/datum/progressbar/dump_harddel_info()
	if(harddel_deets_dumped)
		return
	harddel_deets_dumped = TRUE
	return "Owner's type: [location_type]"

#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT
