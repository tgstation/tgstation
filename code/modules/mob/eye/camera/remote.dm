/**
 * A camera controlled by a machine-operating user, like advanced cameras.
 * Handles assigning/unassigning it's users, as well as applying sight effects.
 */
/mob/eye/camera/remote
	/// Weakref to the current user of this eye. Must be a [living mob][/mob/living].
	var/datum/weakref/user_ref
	/// Weakref to the creator of this eye. Must be a [machine][/obj/machinery].
	var/datum/weakref/origin_ref

	/// TRUE if this camera should show itself to the user.
	var/visible_to_user = FALSE
	/// If visible_to_user is TRUE, it will show this in the center of the screen.
	VAR_PROTECTED/image/user_image

	/* The below code could be shared by AI eyes... */

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
	/// The maximum sprint that this eye can reach.
	VAR_PROTECTED/max_sprint = 50


/mob/eye/camera/remote/Initialize(mapload, obj/machinery/creator)
	if(!creator)
		return INITIALIZE_HINT_QDEL

	. = ..()

	origin_ref = WEAKREF(creator)
	if(visible_to_user)
		set_user_icon(icon, icon_state)

/mob/eye/camera/remote/Destroy()
	var/mob/living/user = user_ref?.resolve()
	var/obj/machinery/origin = origin_ref?.resolve()
	if(origin && user)
		origin.remove_eye_control(user,src)

	assign_user(null)
	origin_ref = null
	return ..()

/mob/eye/camera/remote/proc/assign_user(mob/living/new_user)
	var/mob/living/old_user = user_ref?.resolve()
	SEND_SIGNAL(src, COMSIG_REMOTE_CAMERA_ASSIGN_USER, new_user, old_user)
	if(old_user)
		old_user.remote_control = null
		old_user.reset_perspective(null)
		name = initial(src.name)

		var/client/old_user_client = GetViewerClient()
		if(user_image && old_user_client)
			old_user_client.images -= user_image
		clear_camera_chunks()

	user_ref = WEAKREF(new_user) //The user_ref can still be null!

	if(new_user)
		new_user.remote_control = src
		new_user.reset_perspective(src)
		name = "Camera Eye ([new_user.name])"

		var/client/new_user_client = GetViewerClient()
		if(user_image && new_user_client)
			new_user_client.images += user_image
		if(use_visibility)
			update_visibility()

/**
 * Sets the camera's user image to this icon and state.
 * If chosen_icon is null, the user image will be removed.
 */
/mob/eye/camera/remote/proc/set_user_icon(icon/chosen_icon, icon_state)
	SHOULD_CALL_PARENT(TRUE)

	var/client/user_client = GetViewerClient()

	if(!isnull(chosen_icon))
		set_user_icon(null) //remove whatever the last icon was
		if(!isicon(chosen_icon) || !(!isnull(icon_state) && istext(icon_state)))
			CRASH("Tried to set [src]'s user_image with bad parameters")

		user_image = image(chosen_icon, src, icon_state, FLY_LAYER)
		if(user_client)
			user_client.images += user_image
	else
		if(user_client)
			user_client.images -= user_image
		QDEL_NULL(user_image)

/mob/eye/camera/remote/update_remote_sight(mob/living/user)
	user.set_invis_see(SEE_INVISIBLE_LIVING) //can't see ghosts through cameras
	user.set_sight(SEE_TURFS)
	return TRUE

/mob/eye/camera/remote/GetViewerClient()
	var/mob/living/user = user_ref?.resolve()

	if(user)
		return user.client
	return null

/mob/eye/camera/remote/setLoc(turf/destination, force_update = FALSE)
	. = ..()

	var/client/user_client = GetViewerClient()
	if(user_image && user_client)
		SET_PLANE(user_image, ABOVE_GAME_PLANE, destination) //incase we move a z-level

/mob/eye/camera/remote/relaymove(mob/living/user, direction)
	var/initial = initial(src.sprint)

	if(last_moved < world.timeofday) // It's been too long since we last moved, reset sprint
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/step = get_turf(get_step_multiz(src, direction))
		if(step)
			if(!(ISINRANGE_EX(step.x, TRANSITIONEDGE, world.maxx - TRANSITIONEDGE) && ISINRANGE_EX(step.y, TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)))
				transition_step(step, direction)
			else
				setLoc(step)

	last_moved = world.timeofday + wait_time
	if(acceleration)
		sprint = min(sprint + momentum, max_sprint)
	else
		sprint = initial

/mob/eye/camera/remote/proc/transition_step(turf/destination, direction)
	var/datum/space_level/from = SSmapping.get_level(destination.z)
	var/datum/space_level/into = from.neigbours["[direction]"]
	if(into && allow_z_transition(from, into))
		var/dest_x = destination.x
		var/dest_y = destination.y
		switch(direction)
			if(NORTH)
				dest_y = 1+TRANSITIONEDGE
			if(SOUTH)
				dest_y = world.maxy-TRANSITIONEDGE
			if(EAST)
				dest_x = 1+TRANSITIONEDGE
			if(WEST)
				dest_x = world.maxx-TRANSITIONEDGE
		var/turf/new_destination = locate(dest_x, dest_y, into.z_value)
		setLoc(new_destination || destination)
	else
		setLoc(destination)

/mob/eye/camera/remote/proc/allow_z_transition(datum/space_level/from, datum/space_level/into)
	return from == into
