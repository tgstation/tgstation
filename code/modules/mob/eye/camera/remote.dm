/**
 * A camera controlled by a machine-operating user, like advanced cameras.
 *
 */
/mob/eye/camera/remote
	/// The current user of this eye.
	var/mob/living/user
	/// The machine that created this eye.
	var/obj/machinery/origin

	/// If TRUE, the camera will show it's icon to the user.
	var/visible_to_user = TRUE
	/// If visible_to_user is TRUE, it will show this in the center of the screen.
	var/image/user_image

	/// If TRUE, the eye will have acceleration when moving.
	var/acceleration = TRUE
	/// Used internally for calculating wait time. (world.timeofday + wait_time)
	VAR_FINAL/last_moved = 0
	/// The amount of time that must pass before var/sprint is reset.
	VAR_PROTECTED/wait_time = 5 DECISECONDS
	/// The speed of the camera. Scales from initial(sprint) to var/max_sprint
	VAR_PROTECTED/sprint = 10
	/// Amount of speed that is added to var/sprint.
	VAR_PROTECTED/momentum = 0.5
	/// The maximum sprint that this eye can reach
	VAR_PROTECTED/max_sprint = 50


/mob/eye/camera/remote/Initialize(mapload, obj/machinery/creator)
	. = ..()
	if(visible_to_user)
		set_user_icon(icon, icon_state)

/mob/eye/camera/remote/Destroy()
	if(origin && user)
		origin.remove_eye_control(user,src)
	origin = null
	. = ..()
	user = null

/**
 * Sets the camera's user image to this icon and state.
 * If chosen_icon is null, the user image will be removed.
 */
/mob/eye/camera/remote/proc/set_user_icon(icon/chosen_icon, icon_state)
	SHOULD_CALL_PARENT(TRUE)

	if(!isnull(chosen_icon))
		set_user_icon(null)
		if(!isicon(chosen_icon) || !(!isnull(icon_state) && istext(icon_state)))
			CRASH("Tried to set [src]'s user_image with bad parameters")

		user_image = image(chosen_icon, src, icon_state, FLY_LAYER)
		if(user?.client)
			user.client.images += user_image
	else
		if(user?.client)
			user.client.images -= user_image
		QDEL_NULL(user_image)

/mob/eye/camera/remote/update_remote_sight(mob/living/user)
	user.set_invis_see(SEE_INVISIBLE_LIVING) //can't see ghosts through cameras
	user.set_sight(SEE_TURFS)
	return TRUE

/mob/eye/camera/remote/GetViewerClient()
	if(user)
		return user.client
	return null

/mob/eye/camera/remote/setLoc(turf/destination, force_update = FALSE)
	if(!user)
		return

	. = ..()

	if(user_image && user.client)
		user.client.images -= user_image
		SET_PLANE(user_image, ABOVE_GAME_PLANE, destination) //incase we move a z-level 
		user.client.images += user_image

/mob/eye/camera/remote/relaymove(mob/living/user, direction)
	var/initial = initial(sprint)

	if(last_moved < world.timeofday) // It's been too long since we last moved, reset sprint
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(src, direction))
		if(step)
			setLoc(step)

	last_moved = world.timeofday + wait_time
	if(acceleration)
		sprint = min(sprint + momentum, max_sprint)
	else
		sprint = initial
