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
	///indexed by the string z level of the camera
	///this could one day be an alist but vv doesn't work with it yet
	var/list/list/cameras = list()
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
	/// Are we currently being updated by the cameras subsystem?
	var/currently_updating = FALSE
	/// List of cameras that need to be processed. For use in yielding when being lazyupdated by the cameras subsystem
	var/list/list/processing_cameras = list()
	/// List of newly visible turfs that are currently being generated. For use in lazyupdating.
	var/list/processing_visible_turfs = list()

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

	reset_update()
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
		_dequeue_update()
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
	SScameras.chunks_to_update[src] = TRUE

/datum/camerachunk/proc/_dequeue_update()
	PRIVATE_PROC(TRUE)
	// Whelp
	if(length(update_sources))
		return
	SScameras.chunks_to_update -= src
	SScameras.current_run -= src

/**
 * Forces the chunk to update immediately
 *
 * * only_if_necessary - if TRUE, will not update the chunk unless it's been marked to update.
 */
/datum/camerachunk/proc/force_update(only_if_necessary = TRUE)
	if(only_if_necessary && !length(update_sources))
		return
	update()

/// Reset any in progress update
/datum/camerachunk/proc/reset_update()
	if(!currently_updating)
		return

	processing_visible_turfs = list()
	processing_cameras = list()
	currently_updating = FALSE
	// Not allowed to stick around in the list forever, that'd be dumb
	SScameras.current_run -= src
	_queue_update()

/// Updates our chunk in a lazy fashion, so large amounts of cameras don't lead to overtime spikes
/// Returns FALSE if the update is unfinished, TRUE if it's complete
/datum/camerachunk/proc/yield_update()
	if(SScameras.disable_camera_updates)
		return TRUE

	if(!currently_updating)
		currently_updating = TRUE
		processing_cameras = list()
		for(var/z_level in lower_z to upper_z)
			processing_cameras["[z_level]"] = cameras["[z_level]"].Copy()

	var/list/updated_visible_turfs = src.processing_visible_turfs
	for(var/z_level in lower_z to upper_z)
		var/list/processing = processing_cameras["[z_level]"]
		while(length(processing))
			var/obj/machinery/camera/current_camera = processing[length(processing)]
			processing.len--
			if(!current_camera?.can_use())
				if(TICK_CHECK)
					return FALSE
				continue

			var/turf/point = locate(src.x + (CHUNK_SIZE / 2), src.y + (CHUNK_SIZE / 2), z_level)
			if(get_dist(point, current_camera) > MAX_CAMERA_RANGE + (CHUNK_SIZE / 2))
				continue

			for(var/turf/vis_turf as anything in current_camera.can_see() & turfs)
				updated_visible_turfs[vis_turf] = vis_turf

			if(TICK_CHECK)
				return FALSE

	update_with_turfs(updated_visible_turfs)
	update_sources.Cut()
	reset_update()
	return TRUE

/// Perfroms a full update of the chunk
/datum/camerachunk/proc/update()
	if(SScameras.disable_camera_updates)
		return

	update_sources.Cut()
	_dequeue_update()
	reset_update()

	var/list/updated_visible_turfs = list()

	for(var/z_level in lower_z to upper_z)
		for(var/obj/machinery/camera/current_camera as anything in cameras["[z_level]"])
			if(!current_camera?.can_use())
				continue

			var/turf/point = locate(src.x + (CHUNK_SIZE / 2), src.y + (CHUNK_SIZE / 2), z_level)
			if(get_dist(point, current_camera) > MAX_CAMERA_RANGE + (CHUNK_SIZE / 2))
				continue

			// The return value of can_see being the left-hand operand here is a load-bearing performance pillar
			for(var/turf/vis_turf as anything in current_camera.can_see() & turfs)
				updated_visible_turfs[vis_turf] = vis_turf

	update_with_turfs(updated_visible_turfs)

/// Takes a list of newly visible turfs, updates our static images to match
/datum/camerachunk/proc/update_with_turfs(list/updated_visible_turfs)
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

	var/list/cameras = src.cameras
	var/list/turfs = src.turfs
	var/list/visibleTurfs = src.visibleTurfs
	var/list/obscuredTurfs = src.obscuredTurfs
	var/list/active_static_images = src.active_static_images
	var/lower_x = x
	var/lower_y = y
	var/upper_x = min(lower_x + CHUNK_SIZE - 1, world.maxx)
	var/upper_y = min(lower_y + CHUNK_SIZE - 1, world.maxy)
	var/list/stack = SSmapping.get_connected_levels(lower_z)
	for(var/z_level in lower_z to upper_z)
		cameras["[z_level]"] = list()
		var/image/mirror_from = SScameras.obscured_images[GET_Z_PLANE_OFFSET(z_level) + 1]
		var/turf/chunk_corner = locate(x, y, z_level)
		for(var/turf/lad as anything in CORNER_BLOCK(chunk_corner, CHUNK_SIZE, CHUNK_SIZE)) //we use CHUNK_SIZE for width and height here as it handles subtracting 1 from those two parameters by itself
			var/image/our_image = new /image(mirror_from)
			our_image.loc = lad
			turfs[lad] = our_image

	for(var/obj/machinery/camera/camera as anything in SScameras.cameras)
		var/turf/camera_loc = get_turf(camera)
		// AABB
		if(camera_loc.x + MAX_CAMERA_RANGE < lower_x || camera_loc.x - MAX_CAMERA_RANGE > upper_x)
			continue
		if(camera_loc.y + MAX_CAMERA_RANGE < lower_y || camera_loc.y - MAX_CAMERA_RANGE > upper_y)
			continue
		if(stack != SSmapping.get_connected_levels(camera_loc.z))
			continue
		if(!camera.can_use())
			continue

		cameras["[camera_loc.z]"] += camera
		for(var/turf/vis_turf as anything in camera.can_see() & turfs)
			visibleTurfs[vis_turf] = vis_turf

	for(var/turf/obscured_turf as anything in turfs - visibleTurfs)
		var/image/new_static = turfs[obscured_turf]
		active_static_images += new_static
		obscuredTurfs[obscured_turf] = new_static
