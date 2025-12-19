#define STAGE_CAMERAS 0
#define STAGE_CHUNKS 1

/// Manages camera visibility
SUBSYSTEM_DEF(cameras)
	name = "Cameras"
	flags = SS_BACKGROUND
	priority = FIRE_PRIORITY_CAMERAS
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping, // plane offsets
		/datum/controller/subsystem/atoms, // opacity
	)

	/// The stage of the current subsystem run.
	var/stage = STAGE_CAMERAS

	/// All cameras on the map.
	var/list/cameras = list()
	/// All camera chunks on the map. (alist[chunk_coords] = chunk)
	var/alist/chunks = alist()

	/// All cameras that must be updated. (alist[camera] = null)
	var/alist/camera_queue = alist()
	/// All camera chunks that must be updated. (alist[chunk] = null)
	var/alist/chunk_queue = alist()

	/// All base static images, indexed by plane offset. (list[offset + 1] = image)
	var/list/base_static_images = list()

	/// All viewer eye atoms to viewer clients.
	var/alist/eyes_to_clients = alist()

/datum/controller/subsystem/cameras/Initialize()
	update_static_images()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(update_static_images))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/cameras/fire(resumed = FALSE)
	if (stage == STAGE_CAMERAS)
		run_cameras()
		if (state != SS_RUNNING)
			return
		stage = STAGE_CHUNKS

	if (stage == STAGE_CHUNKS)
		run_chunks()
		if (state != SS_RUNNING)
			return
		stage = STAGE_CAMERAS

#undef STAGE_CAMERAS
#undef STAGE_CHUNKS

/// Updates the static images list to include all plane offsets.
/datum/controller/subsystem/cameras/proc/update_static_images()
	SIGNAL_HANDLER

	var/old_max_index = length(base_static_images) + 1
	base_static_images.len = SSmapping.max_plane_offset + 1

	for(var/index in old_max_index to length(base_static_images))
		var/image/static_image = new('icons/effects/cameravis.dmi')
		SET_PLANE_W_SCALAR(static_image, CAMERA_STATIC_PLANE, index - 1)
		static_image.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR | KEEP_APART
		static_image.override = TRUE
		base_static_images[index] = static_image

/datum/controller/subsystem/cameras/proc/run_cameras()
	var/world_max_chunk_x = ceil(WORLD_TO_CHUNK(world.maxx))
	var/world_max_chunk_y = ceil(WORLD_TO_CHUNK(world.maxy))

	for (var/obj/machinery/camera/camera as anything in camera_queue)
		if (MC_TICK_CHECK)
			return

		camera_queue -= camera

		// Cache last camera vars for speed and readability
		var/last_can_use = camera.last_can_use
		var/last_view_size = camera.last_view_size
		var/last_view_x = camera.last_view_x
		var/last_view_y = camera.last_view_y
		var/last_view_z = camera.last_view_z

		// Cache shared lists
		var/list/view_chunks = camera.last_view_chunks
		var/list/view_turfs = camera.last_view_turfs

		// If the camera was used in the last camera update, then remove it from turfs that its viewing
		if (last_can_use)
			adjust_viewing_camera_counts(camera, last_view_x, last_view_y, last_view_size, view_chunks, view_turfs, adjust_amount = -1)

		// If the camera can't be used, clear up any stale data and continue
		if (!camera.can_use())
			if (!last_can_use)
				continue // No stale data to remove, just continue
			camera.last_can_use = FALSE
			camera.last_view_size = 0
			camera.last_view_x = 0
			camera.last_view_y = 0
			camera.last_view_z = 0
			for (var/datum/camerachunk/chunk as anything in view_chunks)
				chunk.cameras -= camera
			view_chunks.Cut()
			view_turfs.Cut()
			continue

		var/turf/source = get_turf(camera)

		var/view_size = (camera.view_range * 2 + 1)
		var/view_x = source.x - camera.view_range
		var/view_y = source.y - camera.view_range
		var/view_z = source.z

		view_turfs.Cut()
		view_turfs.len = view_size ** 2

		// Set the source turf luminosity to max to make view() ignore darkness
		var/luminosity = source.luminosity
		source.luminosity = 6

		// Create a dense visibility mask indexed by view bound coordinates
		// view(), turf.x, turf.y and view_turfs[] are the most expensive operations here
		for (var/turf/turf in view(camera.view_range, source))
			view_turfs[GET_VIEW_COORDS(turf.x, turf.y, view_x, view_y, view_size)] = TRUE

		// Restore the previous luminosity
		source.luminosity = luminosity

		// If the camera view size or position has changed, then recompute viewed chunks
		if (view_x != last_view_x || view_y != last_view_y || view_size != last_view_size)
			// Reset viewed chunks
			for (var/datum/camerachunk/chunk as anything in view_chunks)
				chunk.cameras -= camera
			view_chunks.Cut()

			// Transform the view bounds into chunk coordinate space
			var/min_chunk_x = max(0, floor(WORLD_TO_CHUNK(view_x)))
			var/min_chunk_y = max(0, floor(WORLD_TO_CHUNK(view_y)))
			var/max_chunk_x = min(world_max_chunk_x, min_chunk_x + ceil(view_size / CHUNK_SIZE) - 1) // -1 because the bounds are inclusive
			var/max_chunk_y = min(world_max_chunk_y, min_chunk_y + ceil(view_size / CHUNK_SIZE) - 1) // ditto

			// Add chunks within view bounds
			for (var/chunk_x = min_chunk_x to max_chunk_x)
				for (var/chunk_y = min_chunk_y to max_chunk_y)
					var/datum/camerachunk/chunk = chunks[GET_CHUNK_COORDS(chunk_x, chunk_y, view_z)] || new(chunk_x, chunk_y, view_z)
					chunk.cameras += camera
					view_chunks += chunk

			adjust_viewing_camera_counts(camera, view_x, view_y, view_size, view_chunks, view_turfs, adjust_amount = 1)

		camera.last_can_use = TRUE
		camera.last_view_size = view_size
		camera.last_view_x = view_x
		camera.last_view_y = view_y
		camera.last_view_z = view_z

/datum/controller/subsystem/cameras/proc/run_chunks()
	for (var/datum/camerachunk/chunk as anything in chunk_queue)
		if (MC_TICK_CHECK)
			return
		if (!length(chunk.cameras))
			qdel(chunk)
			continue

		chunk_queue -= chunk

		var/list/turfs = chunk.turfs
		var/list/visibility = chunk.visibility
		var/list/obscured = chunk.obscured
		var/list/static_images = chunk.static_images
		var/list/viewers = chunk.viewers

		var/base_static_image = base_static_images[GET_Z_PLANE_OFFSET(chunk.z) + 1]

		for (var/i in 1 to length(visibility))
			var/is_visible = visibility[i]
			var/is_obscured = obscured[i]

			if (!is_visible && !is_obscured)
				var/image/static_image = new(base_static_image, turfs[i])
				static_images += static_image
				obscured[i] = static_image
				for (var/client/viewer as anything in viewers)
					viewer.images += static_image
			else if (is_visible && is_obscured)
				static_images -= obscured[i]
				QDEL_NULL(obscured[i])

/datum/controller/subsystem/cameras/proc/adjust_viewing_camera_counts(obj/machinery/camera/camera, view_x, view_y, view_size, list/view_chunks, list/view_turfs, adjust_amount)
	for (var/datum/camerachunk/chunk in view_chunks)
		// The chunk's visibility is being changed, so queue it up
		chunk_queue += chunk

		// Cache the visibility list for speed
		var/list/visibility = chunk.visibility

		// Get the world space chunk bounds
		var/chunk_min_x = chunk.world_x
		var/chunk_min_y = chunk.world_y
		var/chunk_max_x = chunk_min_x + CHUNK_SIZE - 1 // -1 because the bounds are inclusive
		var/chunk_max_y = chunk_min_y + CHUNK_SIZE - 1 // ditto

		// Intersect the world space view bounds with the world space chunk bounds
		var/int_min_x = max(view_x, chunk_min_x)
		var/int_min_y = max(view_y, chunk_min_y)
		var/int_max_x = min(view_x + view_size - 1, chunk_max_x) // -1 because the bounds are inclusive
		var/int_max_y = min(view_y + view_size - 1, chunk_max_y) // ditto

		// Transform the world space intersection back into local chunk space
		var/start_x = int_min_x - chunk_min_x // 1-based -> 0-based
		var/start_y = int_min_y - chunk_min_y // ditto
		var/end_x = int_max_x - chunk_min_x // ditto
		var/end_y = int_max_y - chunk_min_y // ditto

		// Iterate over the intersection and remove the camera from visibility array camera counts
		for (var/vis_y in start_y to end_y)
			var/vis_x_start = vis_y * CHUNK_SIZE
			var/world_y = chunk_min_y + vis_y
			for (var/vis_x in start_x to end_x)
				if (view_turfs[GET_VIEW_COORDS(chunk_min_x + vis_x, world_y, view_x, view_y, view_size)])
					visibility[vis_x_start + vis_x + 1] += adjust_amount // +1 because bounds are 0-based while visibility is 1-

/// Checks if the atom is visible by any cameras on the map. Strictly returns TRUE or FALSE.
/datum/controller/subsystem/cameras/proc/is_on_cameras(atom/atom_to_check)
	var/turf/turf_to_check = get_turf(atom_to_check)
	if (!turf_to_check)
		return FALSE

	var/datum/camerachunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf_to_check)]
	return !isnull(chunk) && chunk.visibility[GET_CHUNK_TURF_COORDS(turf_to_check, chunk)] > 0

/// Returns the first camera found on which atom the is visible, if any.
/datum/controller/subsystem/cameras/proc/get_first_viewing_camera(atom/atom_to_check)
	var/turf/turf_to_check = get_turf(atom_to_check)
	if (!turf_to_check)
		return

	var/datum/camerachunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf_to_check)]
	if (!chunk?.visibility[GET_CHUNK_TURF_COORDS(turf_to_check, chunk)])
		return

	var/x = turf_to_check.x
	var/y = turf_to_check.y

	for (var/obj/machinery/camera/camera as anything in chunk.cameras)
		if (camera.last_view_turfs[GET_VIEW_COORDS(x, y, camera.last_view_x, camera.last_view_y, camera.last_view_size)])
			return camera

/// Returns a list of all of the cameras on which the atom is visible.
/datum/controller/subsystem/cameras/proc/get_all_viewing_cameras(atom/atom_to_check)
	. = list()
	var/turf/turf_to_check = get_turf(atom_to_check)
	if (!turf_to_check)
		return

	var/datum/camerachunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf_to_check)]
	if (!chunk?.visibility[GET_CHUNK_TURF_COORDS(turf_to_check, chunk)])
		return

	var/x = turf_to_check.x
	var/y = turf_to_check.y

	for (var/obj/machinery/camera/camera as anything in chunk.cameras)
		if (camera.last_view_turfs[GET_VIEW_COORDS(x, y, camera.last_view_x, camera.last_view_y, camera.last_view_size)])
			. += camera

/// Updates all of the cameras that might see this atom.
/datum/controller/subsystem/cameras/proc/update_visibility(atom/source)
	var/turf/turf = get_turf(source)
	if (!turf)
		return

	var/datum/camerachunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf)]
	if (!chunk)
		return

	// Update every camera where the checked atom was within the bounds of the camera's last view
	for (var/obj/machinery/camera/camera in chunk.cameras)
		if (camera.last_view_x <= turf.x && camera.last_view_y <= turf.y && camera.last_view_x + camera.last_view_size > turf.x && camera.last_view_y + camera.last_view_size > turf.y)
			camera_queue += camera

/datum/controller/subsystem/cameras/proc/add_viewer_mob(mob/viewer)
	if (viewer.client)
		add_viewer_client(viewer)
	RegisterSignal(viewer, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(add_viewer_client))
	RegisterSignal(viewer, COMSIG_MOB_LOGOUT, PROC_REF(remove_viewer_client))
	RegisterSignal(viewer, COMSIG_VIEWDATA_UPDATE, PROC_REF(on_viewdata_update))

/datum/controller/subsystem/cameras/proc/remove_viewer_mob(mob/viewer)
	if (viewer.client)
		remove_viewer_client(viewer, viewer.client)
	UnregisterSignal(viewer, list(COMSIG_MOB_CLIENT_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_VIEWDATA_UPDATE))

/datum/controller/subsystem/cameras/proc/on_viewdata_update(mob/viewer, view_size)
	if (viewer.client?.eye)
		update_viewer_static(viewer.client, viewer.client.eye, view_size[1], view_size[2])

/datum/controller/subsystem/cameras/proc/add_viewer_client(mob/viewer)
	PRIVATE_PROC(TRUE)
	viewer.client.view_chunks = list()
	if (viewer.client.eye)
		set_viewer_client_eye(viewer, null, viewer.client.eye)
	RegisterSignal(viewer.client, COMSIG_CLIENT_SET_EYE, PROC_REF(set_viewer_client_eye))

/datum/controller/subsystem/cameras/proc/remove_viewer_client(mob/viewer)
	PRIVATE_PROC(TRUE)
	if (viewer.canon_client.eye)
		set_viewer_client_eye(viewer, viewer.canon_client.eye, null)
	viewer.client.view_chunks = null
	UnregisterSignal(viewer.client, COMSIG_CLIENT_SET_EYE)

/datum/controller/subsystem/cameras/proc/set_viewer_client_eye(client/viewer, atom/old_eye, atom/new_eye)
	PRIVATE_PROC(TRUE)
	if (old_eye)
		UnregisterSignal(old_eye, COMSIG_MOVABLE_MOVED)
		eyes_to_clients -= old_eye
	if (new_eye)
		update_viewer_client(viewer, new_eye)
		RegisterSignal(new_eye, COMSIG_MOVABLE_MOVED, PROC_REF(update_viewer_eye))
		eyes_to_clients[new_eye] = viewer

/datum/controller/subsystem/cameras/proc/update_viewer_eye(atom/eye)
	PRIVATE_PROC(TRUE)
	update_viewer_client(eyes_to_clients[eye], eye)

/datum/controller/subsystem/cameras/proc/update_viewer_client(client/viewer, atom/eye)
	PRIVATE_PROC(TRUE)
	var/list/view_size = viewer.view_size?.getView() || getviewsize(viewer.view)
	update_viewer_static(viewer, eye, view_size[1], view_size[2])

/datum/controller/subsystem/cameras/proc/update_viewer_static(client/viewer, atom/eye, view_size_x, view_size_y)
	PRIVATE_PROC(TRUE)

	var/list/last_view_chunks = viewer.view_chunks

	// Remove the viewer from last view chunks
	for (var/datum/camerachunk/chunk as anything in last_view_chunks)
		chunk.viewers -= viewer

	var/turf/turf = get_turf(eye)

	if (!turf)
		last_view_chunks.Cut()
		return

	// Cache vars for speed and readability
	var/view_x = turf.x
	var/view_y = turf.y
	var/view_z = turf.z

	// Calculate the view bounds
	var/min_view_x = view_x - floor((view_size_x - 1) / 2)
	var/min_view_y = view_y - floor((view_size_y - 1) / 2)
	var/max_view_x = min_view_x + view_size_x - 1
	var/max_view_y = min_view_y + view_size_y - 1

	// Calculate the chunk bounds
	var/min_chunk_x = floor(WORLD_TO_CHUNK(min_view_x))
	var/min_chunk_y = floor(WORLD_TO_CHUNK(min_view_y))
	var/max_chunk_x = ceil(WORLD_TO_CHUNK(max_view_x))
	var/max_chunk_y = ceil(WORLD_TO_CHUNK(max_view_y))

	var/list/view_chunks = list()

	// Add the viewer to new view chunks
	for (var/chunk_x in min_chunk_x to max_chunk_x)
		for (var/chunk_y in min_chunk_y to max_chunk_y)
			var/datum/camerachunk/chunk = SScameras.chunks[GET_CHUNK_COORDS(chunk_x, chunk_y, view_z)]
			if (!chunk)
				continue

			chunk.viewers += viewer
			view_chunks += chunk

	viewer.view_chunks = view_chunks

	// Remove static images for chunks that are no longer in view
	for (var/datum/camerachunk/chunk as anything in (last_view_chunks - view_chunks))
		viewer.images -= chunk.static_images

	// Add static images for chunks that are newly in view
	for (var/datum/camerachunk/chunk as anything in (view_chunks - last_view_chunks))
		viewer.images += chunk.static_images

/*

/datum/controller/subsystem/cameras/stat_entry(msg)
	msg = "Cams: [length(cameras)] | Chunks: [length(chunks)] | Updating: [length(chunks_to_update)]"
	return ..()

/// Updates the images for new plane offsets
/datum/controller/subsystem/cameras/proc/update_offsets(new_offset)
	for(var/i in length(obscured_images) to new_offset)
		var/image/obscured = new('icons/effects/cameravis.dmi')
		SET_PLANE_W_SCALAR(obscured, CAMERA_STATIC_PLANE, i)
		obscured.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR | KEEP_APART
		obscured.override = TRUE
		obscured_images += obscured

/datum/controller/subsystem/cameras/proc/on_offset_growth(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	update_offsets(new_offset)

/// Checks if a chunk has been generated in x, y, z.
/datum/controller/subsystem/cameras/proc/get_camera_chunk(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	if(GET_LOWEST_STACK_OFFSET(z) != 0)
		var/turf/lowest = get_lowest_turf(locate(x, y, z))
		return chunks["[x],[y],[lowest.z]"]

	return chunks["[x],[y],[z]"]

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/controller/subsystem/cameras/proc/generate_chunk(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	var/turf/lowest = get_lowest_turf(locate(x, y, z))
	var/key = "[x],[y],[lowest.z]"
	. = chunks[key]
	if(!.)
		. = new /datum/camerachunk(x, y, lowest.z)
		chunks[key] = .

/// Updates what the camera eye can see.
/// It is recommended you use this when a camera eye moves or its location is set.
/datum/controller/subsystem/cameras/proc/update_eye_chunk(mob/eye/camera/eye)
	var/list/visibleChunks = list()
	//Get the eye's turf in case its located in an object like a mecha
	var/turf/eye_turf = get_turf(eye)
	if(eye.loc)
		var/static_range = eye.static_visibility_range
		var/x1 = max(1, eye_turf.x - static_range)
		var/y1 = max(1, eye_turf.y - static_range)
		var/x2 = min(world.maxx, eye_turf.x + static_range)
		var/y2 = min(world.maxy, eye_turf.y + static_range)

		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				visibleChunks |= generate_chunk(x, y, eye_turf.z)

	var/list/remove = eye.visibleCameraChunks - visibleChunks
	var/list/add = visibleChunks - eye.visibleCameraChunks

	for(var/datum/camerachunk/chunk as anything in remove)
		chunk.remove(eye)

	for(var/datum/camerachunk/chunk as anything in add)
		chunk.add(eye)

/// Used in [/proc/major_chunk_change] - indicates the camera should be removed from the chunk list.
#define REMOVE_CAMERA 0
/// Used in [/proc/major_chunk_change] - indicates the camera should be added to the chunk list.
#define ADD_CAMERA 1
/// Used in [/proc/major_chunk_change] - indicates the chunk should be updated without adding/removing a camera.
#define IGNORE_CAMERA 2

/// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or when doors open.
/datum/controller/subsystem/cameras/proc/update_visibility(atom/relevant_atom)
	if(!SSticker)
		return
	major_chunk_change(relevant_atom, IGNORE_CAMERA)

/// Removes a camera from a chunk.
/datum/controller/subsystem/cameras/proc/remove_camera_from_chunk(obj/machinery/camera/old_cam)
	major_chunk_change(old_cam, REMOVE_CAMERA)

/// Add a camera to a chunk.
/datum/controller/subsystem/cameras/proc/add_camera_to_chunk(obj/machinery/camera/new_cam)
	if(new_cam.can_use())
		major_chunk_change(new_cam, ADD_CAMERA)

/**
 * Used for Cyborg/mecha cameras. Since portable cameras can be in ANY chunk.
 * update_delay_buffer is passed all the way to queue_update() from their camera updates on movement
 * to change the time between static updates.
*/
/datum/controller/subsystem/cameras/proc/update_portable_camera(obj/machinery/camera/updating_camera, update_delay_buffer)
	if(updating_camera.can_use())
		major_chunk_change(updating_camera, ADD_CAMERA, update_delay_buffer)

/**
 * Never access this proc directly!!!!
 * This will update the chunk and all the surrounding chunks.
 * It will also add the atom to the cameras list if you set the choice to 1.
 * Setting the choice to 0 will remove the camera from the chunks.
 * If you want to update the chunks around an object, without adding/removing a camera, use choice 2.
 * update_delay_buffer is passed all the way to queue_update() from portable camera updates on movement
 * to change the time between static updates.
 */
/datum/controller/subsystem/cameras/proc/major_chunk_change(atom/center_or_camera, choice = IGNORE_CAMERA, update_delay_buffer = 0)
	PROTECTED_PROC(TRUE)

	if(QDELETED(center_or_camera) && choice == ADD_CAMERA)
		CRASH("Tried to add a qdeleting camera to the net")

	var/turf/chunk_turf = get_turf(center_or_camera)
	if(isnull(chunk_turf))
		return

	var/x1 = max(1, chunk_turf.x - (CHUNK_SIZE / 2))
	var/y1 = max(1, chunk_turf.y - (CHUNK_SIZE / 2))
	var/x2 = min(world.maxx, chunk_turf.x + (CHUNK_SIZE / 2))
	var/y2 = min(world.maxy, chunk_turf.y + (CHUNK_SIZE / 2))
	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = get_camera_chunk(x, y, chunk_turf.z)
			if(isnull(chunk))
				continue
			if(choice == REMOVE_CAMERA)
				// Remove the camera.
				chunk.cameras[chunk_turf.z] -= center_or_camera
			if(choice == ADD_CAMERA)
				// You can't have the same camera in the list twice.
				chunk.cameras[chunk_turf.z] |= center_or_camera
			chunk.queue_update(center_or_camera, update_delay_buffer)

/// A faster, turf only version of [/datum/controller/subsystem/cameras/proc/major_chunk_change]
/// For use in sensitive code, be careful with it
/datum/controller/subsystem/cameras/proc/bare_major_chunk_change(turf/changed)
	var/x1 = max(1, changed.x - (CHUNK_SIZE / 2))
	var/y1 = max(1, changed.y - (CHUNK_SIZE / 2))
	var/x2 = min(world.maxx, changed.x + (CHUNK_SIZE / 2))
	var/y2 = min(world.maxy, changed.y + (CHUNK_SIZE / 2))
	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = get_camera_chunk(x, y, changed.z)
			chunk?.queue_update(changed, 0)

/// Will check if an atom is on a viewable turf.
/// Returns TRUE if the atom is visible by any camera, FALSE otherwise.
/datum/controller/subsystem/cameras/proc/is_on_cameras(atom/target)
	return turf_visible_by_cameras(get_turf(target))

/// Checks if the passed turf is visible by any camera.
/// Returns TRUE if the turf is visible by any camera, FALSE otherwise.
/datum/controller/subsystem/cameras/proc/turf_visible_by_cameras(turf/position)
	PRIVATE_PROC(TRUE)
	if(isnull(position))
		return FALSE
	var/datum/camerachunk/chunk = generate_chunk(position.x, position.y, position.z)
	if(isnull(chunk))
		return FALSE
	chunk.force_update(only_if_necessary = TRUE) // Update NOW if necessary
	if(chunk.visibleTurfs[position])
		return TRUE
	return FALSE

/// Gets the camera chunk the passed turf is in.
/// Returns the chunk if it exists and is visible, null otherwise.
/datum/controller/subsystem/cameras/proc/get_turf_camera_chunk(turf/position)
	RETURN_TYPE(/datum/camerachunk)
	var/datum/camerachunk/chunk = generate_chunk(position.x, position.y, position.z)
	if(!chunk)
		return null
	chunk.force_update(only_if_necessary = TRUE) // Update NOW if necessary
	if(chunk.visibleTurfs[position])
		return chunk
	return null

/// Returns list of available cameras, ready to use for UIs displaying list of them
/// The format is: list("name" = "camera.c_tag", ref = REF(camera))
/datum/controller/subsystem/cameras/proc/get_available_cameras_data(list/networks_available, list/z_levels_available)
	var/list/available_cameras_data = list()
	for(var/obj/machinery/camera/camera as anything in get_filtered_and_sorted_cameras(networks_available, z_levels_available))
		available_cameras_data += list(list(
			name = camera.c_tag,
			ref = REF(camera),
		))

	return available_cameras_data

/**
 * get_available_camera_by_tag_list
 *
 * Builds a list of all available cameras that can be seen to networks_available and in z_levels_available.
 * Entries are stored in `c_tag[camera.can_use() ? null : " (Deactivated)"]` => `camera` format
 * Args:
 *  networks_available - List of networks that we use to see which cameras are visible to it.
 *  z_levels_available - List of z levels to filter camera by. If empty, all z levels are considered valid.
 *  sort_by_ctag - If the resulting list should be sorted by `c_tag`.
 */
/datum/controller/subsystem/cameras/proc/get_available_camera_by_tag_list(list/networks_available, list/z_levels_available)
	var/list/available_cameras_by_tag = list()
	for(var/obj/machinery/camera/camera as anything in get_filtered_and_sorted_cameras(networks_available, z_levels_available))
		available_cameras_by_tag["[camera.c_tag][camera.can_use() ? null : " (Deactivated)"]"] = camera

	return available_cameras_by_tag

/// Returns list of all cameras that passed `is_camera_available` filter and sorted by `cmp_camera_ctag_asc`
/datum/controller/subsystem/cameras/proc/get_filtered_and_sorted_cameras(list/networks_available, list/z_levels_available)
	PRIVATE_PROC(TRUE)

	var/list/filtered_cameras = list()
	for(var/obj/machinery/camera/camera as anything in cameras)
		if(!is_camera_available(camera, networks_available, z_levels_available))
			continue

		filtered_cameras += camera

	return sortTim(filtered_cameras, GLOBAL_PROC_REF(cmp_camera_ctag_asc))

/// Checks if the `camera_to_check` meets the requirements of availability.
/datum/controller/subsystem/cameras/proc/is_camera_available(obj/machinery/camera/camera_to_check, list/networks_available, list/z_levels_available)
	PRIVATE_PROC(TRUE)

	if(!camera_to_check.c_tag)
		return FALSE

	if(length(z_levels_available) && !(camera_to_check.z in z_levels_available))
		return FALSE

	return length(camera_to_check.network & networks_available) > 0

#undef ADD_CAMERA
#undef REMOVE_CAMERA
#undef IGNORE_CAMERA

/obj/effect/overlay/camera_static
	name = "static"
	icon = null
	icon_state = null
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	appearance_flags = RESET_TRANSFORM | TILE_BOUND | LONG_GLIDE
	// this combination makes the static block clicks to everything below it,
	// without appearing in the right-click menu for non-AI clients
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_ABSTRACT

	plane = CAMERA_STATIC_PLANE

ADMIN_VERB(pause_camera_updates, R_ADMIN, "Toggle Camera Updates", "Stop security cameras from updating, meaning what they see now is what they will see forever.", ADMIN_CATEGORY_DEBUG)
	SScameras.disable_camera_updates = !SScameras.disable_camera_updates
	log_admin("[key_name_admin(user)] [SScameras.disable_camera_updates ? "disabled" : "enabled"] camera updates.")
	message_admins("Admin [key_name_admin(user)] has [SScameras.disable_camera_updates ? "disabled" : "enabled"] camera updates.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Camera Updates")

*/
