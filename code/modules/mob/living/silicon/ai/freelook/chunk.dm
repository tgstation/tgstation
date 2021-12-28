#define UPDATE_BUFFER_TIME (2.5 SECONDS)

// CAMERA CHUNK
//
// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
// Allows the AI Eye to stream these chunks and know what it can and cannot see.

/datum/camerachunk
	///turfs our cameras cant see but are inside our grid. associative list of the form: list(obscured turf = static image on that turf)
	var/list/obscuredTurfs = list()
	///turfs our cameras can see inside our grid
	var/list/visibleTurfs = list()
	///cameras that can see into our grid
	var/list/cameras = list()
	///list of all turfs
	var/list/turfs = list()
	///camera mobs that can see turfs in our grid
	var/list/seenby = list()
	///images created to represent obscured turfs
	var/list/inactive_static_images = list()
	///images currently in use on obscured turfs.
	var/list/active_static_images = list()

	var/changed = FALSE
	var/x = 0
	var/y = 0
	var/z = 0

/// Add an AI eye to the chunk, then update if changed.
/datum/camerachunk/proc/add(mob/camera/ai_eye/eye)
	eye.visibleCameraChunks += src
	seenby += eye
	if(changed)
		update()

	var/client/client = eye.GetViewerClient()
	if(client && eye.use_static)
		client.images += active_static_images

/// Remove an AI eye from the chunk
/datum/camerachunk/proc/remove(mob/camera/ai_eye/eye, remove_static_with_last_chunk = TRUE)
	eye.visibleCameraChunks -= src
	seenby -= eye

	var/client/client = eye.GetViewerClient()
	if(client && eye.use_static)
		client.images -= active_static_images

/// Called when a chunk has changed. I.E: A wall was deleted.
/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!visibleTurfs[loc])
		return
	hasChanged()

/**
 * Updates the chunk, makes sure that it doesn't update too much. If the chunk isn't being watched it will
 * instead be flagged to update the next time an AI Eye moves near it.
 */
/datum/camerachunk/proc/hasChanged(update_now = 0)
	if(seenby.len || update_now)
		addtimer(CALLBACK(src, .proc/update), UPDATE_BUFFER_TIME, TIMER_UNIQUE)
	else
		changed = TRUE

/// The actual updating. It gathers the visible turfs from cameras and puts them into the appropiate lists.
/datum/camerachunk/proc/update()
	var/list/updated_visible_turfs = list()

	for(var/obj/machinery/camera/current_camera as anything in cameras)
		if(!current_camera || !current_camera.can_use())
			continue

		var/turf/point = locate(src.x + (CHUNK_SIZE / 2), src.y + (CHUNK_SIZE / 2), src.z)
		if(get_dist(point, current_camera) > CHUNK_SIZE + (CHUNK_SIZE / 2))
			continue

		for(var/turf/vis_turf in current_camera.can_see())
			if(turfs[vis_turf])
				updated_visible_turfs[vis_turf] = vis_turf

	///new turfs that we couldnt see last update but can now
	var/list/newly_visible_turfs = updated_visible_turfs - visibleTurfs
	///turfs that we could see last update but cant see now
	var/list/newly_obscured_turfs = visibleTurfs - updated_visible_turfs

	for(var/turf/visible_turf as anything in newly_visible_turfs)
		var/image/static_image_to_deallocate = obscuredTurfs[visible_turf]
		if(!static_image_to_deallocate)
			continue

		static_image_to_deallocate.loc = null
		active_static_images -= static_image_to_deallocate
		inactive_static_images += static_image_to_deallocate

		obscuredTurfs -= visible_turf

	for(var/turf/obscured_turf as anything in newly_obscured_turfs)
		if(!obscuredTurfs[obscured_turf] || istype(obscured_turf, /turf/open/ai_visible))
			continue

		var/image/static_image_to_allocate = inactive_static_images[length(inactive_static_images)]
		if(!static_image_to_allocate)
			stack_trace("somehow a camera chunk ran out of static images!")
			break

		obscuredTurfs[obscured_turf] = static_image_to_allocate
		static_image_to_allocate.loc = obscured_turf

		inactive_static_images -= static_image_to_allocate
		active_static_images += static_image_to_allocate

	visibleTurfs = updated_visible_turfs

	changed = FALSE

/// Create a new camera chunk, since the chunks are made as they are needed.
/datum/camerachunk/New(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)

	src.x = x
	src.y = y
	src.z = z

	for(var/turf_num in 1 to 16 * 16)
		inactive_static_images += new/image(GLOB.cameranet.obscured)

	for(var/obj/machinery/camera/camera in urange(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z)))
		if(camera.can_use())
			cameras += camera

	for(var/mob/living/silicon/sillycone in urange(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z)))
		if(sillycone.builtInCamera?.can_use())
			cameras += sillycone.builtInCamera

	for(var/turf/t as anything in block(locate(max(x, 1), max(y, 1), z), locate(min(x + CHUNK_SIZE - 1, world.maxx), min(y + CHUNK_SIZE - 1, world.maxy), z)))
		turfs[t] = t

	for(var/obj/machinery/camera/camera as anything in cameras)
		if(!camera)
			continue

		if(!camera.can_use())
			continue

		for(var/turf/vis_turf in camera.can_see())
			if(turfs[vis_turf])
				visibleTurfs[vis_turf] = vis_turf

	for(var/turf/obscured_turf as anything in turfs - visibleTurfs)
		var/image/new_static = inactive_static_images[inactive_static_images.len]
		new_static.loc = obscured_turf
		active_static_images += new_static
		inactive_static_images -= new_static
		obscuredTurfs[obscured_turf] = new_static

#undef UPDATE_BUFFER_TIME
#undef CHUNK_SIZE
