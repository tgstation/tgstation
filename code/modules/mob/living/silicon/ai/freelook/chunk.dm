#define UPDATE_BUFFER_TIME (2.5 SECONDS)

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
	var/list/cameras = list()
	///list of all turfs, associative with that turf's static image
	///turf -> /image
	var/list/turfs = list()
	///Camera mobs that can see turfs in our grid
	var/list/seenby = list()
	///images currently in use on obscured turfs.
	var/list/active_static_images = list()

	var/changed = FALSE
	var/x = 0
	var/y = 0
	var/lower_z
	var/upper_z

/// Add a camera eye to the chunk, then update if changed.
/datum/camerachunk/proc/add(mob/eye/camera/eye)
	eye.visibleCameraChunks += src
	seenby += eye
	if(changed)
		update()

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

/// Called when a chunk has changed. I.E: A wall was deleted.
/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!visibleTurfs[loc])
		return
	hasChanged()

/**
 * Updates the chunk, makes sure that it doesn't update too much. If the chunk isn't being watched it will
 * instead be flagged to update the next time an AI Eye moves near it.
 *
 * update_delay_buffer is used for cameras that are moving around, which are cyborg inbuilt cameras and
 * mecha onboard cameras. This buffer should be usually lower than UPDATE_BUFFER_TIME because
 * otherwise a moving camera can run out of its own view before updating static.
 */
/datum/camerachunk/proc/hasChanged(update_now = 0, update_delay_buffer = UPDATE_BUFFER_TIME)
	if(seenby.len || update_now)
		addtimer(CALLBACK(src, PROC_REF(update)), update_delay_buffer, TIMER_UNIQUE)
	else
		changed = TRUE

/// The actual updating. It gathers the visible turfs from cameras and puts them into the appropiate lists.
/// Accepts an optional partial_update argument, that blocks any calls out to chunks that could affect us, like above or below
/datum/camerachunk/proc/update(partial_update = FALSE)
	var/list/updated_visible_turfs = list()

	for(var/z_level in lower_z to upper_z)
		for(var/obj/machinery/camera/current_camera as anything in cameras["[z_level]"])
			if(!current_camera || !current_camera.can_use())
				continue

			var/turf/point = locate(src.x + (CHUNK_SIZE / 2), src.y + (CHUNK_SIZE / 2), z_level)
			if(get_dist(point, current_camera) > CHUNK_SIZE + (CHUNK_SIZE / 2))
				continue

			for(var/turf/vis_turf in current_camera.can_see())
				if(turfs[vis_turf])
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

	changed = FALSE

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

		cameras["[z_level]"] = local_cameras

		var/image/mirror_from = GLOB.cameranet.obscured_images[GET_Z_PLANE_OFFSET(z_level) + 1]
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

			for(var/turf/vis_turf in camera.can_see())
				if(turfs[vis_turf])
					visibleTurfs[vis_turf] = vis_turf

	for(var/turf/obscured_turf as anything in turfs - visibleTurfs)
		var/image/new_static = turfs[obscured_turf]
		active_static_images += new_static
		obscuredTurfs[obscured_turf] = new_static

#undef UPDATE_BUFFER_TIME
