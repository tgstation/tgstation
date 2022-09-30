#define UPDATE_BUFFER_TIME (2.5 SECONDS)

// CAMERA CHUNK
//
// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
// Allows the AI Eye to stream these chunks and know what it can and cannot see.

/datum/camerachunk
	///turfs our cameras cant see but are inside our grid
	var/list/obscuredTurfs = list()
	///turfs our cameras can see inside our grid
	var/list/visibleTurfs = list()
	///cameras that can see into our grid
	var/list/cameras = list()
	///list of all turfs
	var/list/turfs = list()
	///camera mobs that can see turfs in our grid
	var/list/seenby = list()
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

/// Remove an AI eye from the chunk, then update if changed.
/datum/camerachunk/proc/remove(mob/camera/ai_eye/eye, remove_static_with_last_chunk = TRUE)
	eye.visibleCameraChunks -= src
	seenby -= eye

	if(remove_static_with_last_chunk && !eye.visibleCameraChunks.len)
		var/client/client = eye.GetViewerClient()
		if(client && eye.use_static)
			client.images -= GLOB.cameranet.obscured

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
	var/list/newVisibleTurfs = list()

	for(var/obj/machinery/camera/current_camera as anything in cameras)
		if(!current_camera || !current_camera.can_use())
			continue

		var/turf/point = locate(src.x + (CHUNK_SIZE / 2), src.y + (CHUNK_SIZE / 2), src.z)
		if(get_dist(point, current_camera) > CHUNK_SIZE + (CHUNK_SIZE / 2))
			continue

		for(var/turf/vis_turf in current_camera.can_see())
			if(turfs[vis_turf])
				newVisibleTurfs[vis_turf] = vis_turf

	//new turfs will be in visibleTurfs but werent last update
	var/list/visAdded = newVisibleTurfs - visibleTurfs
	//old turfs that will no longer be in visibleTurfs but were last update
	var/list/visRemoved = visibleTurfs - newVisibleTurfs

	visibleTurfs = newVisibleTurfs
	//turfs that are included in the chunks normal turfs list minus the turfs the cameras CAN see
	obscuredTurfs = turfs - newVisibleTurfs

	var/static/list/vis_contents_opaque = GLOB.cameranet.vis_contents_opaque //ba dum tsss
	for(var/turf/added_turf as anything in visAdded)
		added_turf.vis_contents -= vis_contents_opaque

	for(var/turf/removed_turf as anything in visRemoved)
		if(obscuredTurfs[removed_turf] && !istype(removed_turf, /turf/open/ai_visible))
			removed_turf.vis_contents += vis_contents_opaque

	changed = FALSE

/// Create a new camera chunk, since the chunks are made as they are needed.
/datum/camerachunk/New(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)

	src.x = x
	src.y = y
	src.z = z

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

	obscuredTurfs = turfs - visibleTurfs

	var/list/vis_contents_opaque = GLOB.cameranet.vis_contents_opaque
	for(var/turf/obscured_turf as anything in obscuredTurfs)
		obscured_turf.vis_contents += vis_contents_opaque

#undef UPDATE_BUFFER_TIME
#undef CHUNK_SIZE
