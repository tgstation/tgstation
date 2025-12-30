/**
 * A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed. \
 * Allows Camera Eyes to stream these chunks and know what it can and cannot see.
 */

/datum/camerachunk
	///turfs our cameras cant see but are inside our grid. associative list of the form: list(obscured turf = static image on that turf)
	var/list/obscuredTurfs = list()
	///turfs our cameras can see inside our grid
	var/list/visibleTurfs = list()
	///cameras that can see into our grid
	///indexed by the z level of the camera
	var/alist/cameras = alist()
	///list of all turfs, associative with that turf's static image
	///turf -> /image
	var/list/turfs = list()
	///Camera mobs that can see turfs in our grid
	var/list/seenby = list()
	///images currently in use on obscured turfs.
	var/list/active_static_images = list()

	var/x = 0
	var/y = 0
	var/lower_z
	var/upper_z

	/// List of atoms that caused the chunk to update - assoc atom ref() to opacity on queue
	var/list/update_sources = list()

/// Add a camera eye to the chunk, updating the chunk if necessary.
/datum/camerachunk/proc/add(mob/eye/camera/eye)
	eye.visibleCameraChunks += src
	seenby += eye
	force_update()

	var/client/client = eye.GetViewerClient()
	if(client && eye.use_visibility)
		client.images += active_static_images

/// Remove a camera eye from the chunk
/datum/camerachunk/proc/remove(mob/eye/camera/ai/eye)
	eye.visibleCameraChunks -= src
	seenby -= eye

	var/client/client = eye.GetViewerClient()
	if(client && eye.use_visibility && seenby.len == 0)
		client.images -= active_static_images

/**
 * Queues the chuck to be updated after a delay.
 *
 * * update_source - the atom that caused the update
 * * update_delay_buffer - the delay before the update is performed. Defaults to 0 (instant).
 */
/datum/camerachunk/proc/queue_update(atom/update_source, update_delay_buffer = 0)
	// This chunk is being actively observed, skip queuing
	if(length(seenby))
		addtimer(CALLBACK(src, PROC_REF(update)), update_delay_buffer || 1, TIMER_UNIQUE)
		return

	// Only start queue if this is the first thing to queue an update
	var/start_queue = !length(update_sources)

	var/update_key = REF(update_source)
	// Camera updates will never be second guessed.
	// Track the number of times the camera has queued an update instead of opacity (just for fun)
	if(istype(update_source, /obj/machinery/camera))
		update_sources[update_source] += 1

	// Otherwise track this atom's opacity at time of queue
	else if(isnull(update_sources[update_key]))
		update_sources[update_key] = update_source.opacity

	// If the tracked opacity does not match current opacity,
	// that implies that the atom changed opacity twice in the time before the update happened
	// So we can safely remove this atom as a "source of update"
	else if(update_sources[update_key] != update_source.opacity)
		update_sources -= update_key
		return

	if(!start_queue)
		return

	if(update_delay_buffer <= 0)
		_queue_update()
	else
		addtimer(CALLBACK(src, PROC_REF(_queue_update)), update_delay_buffer, TIMER_UNIQUE)

/datum/camerachunk/proc/_queue_update()
	PRIVATE_PROC(TRUE)
	// Something forced an update during the delay
	if(!length(update_sources))
		return
	SScameras.chunks_to_update[src] += 1

/**
 * Forces the chunk to update immediately
 *
 * * only_if_necessary - if TRUE, will not update the chunk unless it's been marked to update.
 */
/datum/camerachunk/proc/force_update(only_if_necessary = TRUE)
	if(only_if_necessary && !length(update_sources))
		return
	update()

/// The actual updating. It gathers the visible turfs from cameras and puts them into the appropiate lists.
/datum/camerachunk/proc/update()
	if(SScameras.disable_camera_updates)
		return

	update_sources.Cut()

	var/list/updated_visible_turfs = list()

	for(var/z_level in lower_z to upper_z)
		for(var/obj/machinery/camera/current_camera as anything in cameras[z_level])
			if(!current_camera || !current_camera.can_use())
				continue

			var/turf/point = locate(src.x + (CHUNK_SIZE / 2), src.y + (CHUNK_SIZE / 2), z_level)
			if(get_dist(point, current_camera) > CHUNK_SIZE + (CHUNK_SIZE / 2))
				continue

			for(var/turf/vis_turf as anything in turfs & current_camera.can_see())
				updated_visible_turfs[vis_turf] = vis_turf

	///new turfs that we couldnt see last update but can now
	var/list/newly_visible_turfs = updated_visible_turfs - visibleTurfs
	///turfs that we could see last update but cant see now
	var/list/newly_obscured_turfs = visibleTurfs - updated_visible_turfs

	for(var/mob/eye/camera/client_eye as anything in seenby)
		var/client/client = client_eye.GetViewerClient()
		if(!client)
			continue

		client.images -= active_static_images

	for(var/turf/visible_turf as anything in newly_visible_turfs)
		var/image/static_image = obscuredTurfs[visible_turf]
		if(!static_image)
			continue

		active_static_images -= static_image
		obscuredTurfs -= visible_turf

	for(var/turf/obscured_turf as anything in newly_obscured_turfs)
		if(obscuredTurfs[obscured_turf] || istype(obscured_turf, /turf/open/ai_visible))
			continue

		var/image/static_image = turfs[obscured_turf]
		if(!static_image)
			stack_trace("somehow a camera chunk used a turf it didn't contain!!")
			break

		obscuredTurfs[obscured_turf] = static_image
		active_static_images += static_image
	visibleTurfs = updated_visible_turfs

	for(var/mob/eye/camera/client_eye as anything in seenby)
		var/client/client = client_eye.GetViewerClient()
		if(!client)
			continue

		client.images += active_static_images


/// Create a new camera chunk, since the chunks are made as they are needed.
/datum/camerachunk/New(x, y, lower_z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)

	src.x = x
	src.y = y
	src.lower_z = lower_z
	var/turf/upper_turf = get_highest_turf(locate(x, y, lower_z))
	src.upper_z = upper_turf.z

	for(var/z_level in lower_z to upper_z)
		var/list/local_cameras = list()
		for(var/obj/machinery/camera/camera in urange(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z_level)))
			if(camera.can_use())
				local_cameras += camera

		for(var/mob/living/silicon/sillycone in urange(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z_level)))
			if(sillycone.builtInCamera?.can_use())
				local_cameras += sillycone.builtInCamera

		for(var/obj/vehicle/sealed/mecha/mech in urange(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z_level)))
			if(mech.chassis_camera?.can_use())
				local_cameras += mech.chassis_camera

		cameras[z_level] = local_cameras

		var/image/mirror_from = SScameras.obscured_images[GET_Z_PLANE_OFFSET(z_level) + 1]
		var/turf/chunk_corner = locate(x, y, z_level)
		for(var/turf/lad as anything in CORNER_BLOCK(chunk_corner, CHUNK_SIZE, CHUNK_SIZE)) //we use CHUNK_SIZE for width and height here as it handles subtracting 1 from those two parameters by itself
			var/image/our_image = new /image(mirror_from)
			our_image.loc = lad
			turfs[lad] = our_image

		for(var/obj/machinery/camera/camera as anything in local_cameras)
			if(!camera)
				continue

			if(!camera.can_use())
				continue

			for(var/turf/vis_turf as anything in turfs & camera.can_see())
				visibleTurfs[vis_turf] = vis_turf

	for(var/turf/obscured_turf as anything in turfs - visibleTurfs)
		var/image/new_static = turfs[obscured_turf]
		active_static_images += new_static
		obscuredTurfs[obscured_turf] = new_static
