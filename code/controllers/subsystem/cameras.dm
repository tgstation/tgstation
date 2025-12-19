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

//GLOBAL_LIST_EMPTY(camera_cost)
//GLOBAL_LIST_EMPTY(camera_count)

/datum/controller/subsystem/cameras/fire(resumed = FALSE)
	//INIT_COST(GLOB.camera_cost, GLOB.camera_count)
	//EXPORT_STATS_TO_CSV_LATER("camera-cost.txt", GLOB.camera_cost, GLOB.camera_count)
	if (stage == STAGE_CAMERAS)
		run_cameras()
		//SET_COST("Run cameras")
		if (state != SS_RUNNING)
			return
		stage = STAGE_CHUNKS

	if (stage == STAGE_CHUNKS)
		run_chunks()
		//SET_COST("Run chunks")
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
					visibility[vis_x_start + vis_x + 1] += adjust_amount // +1 because bounds are 0-based while visibility is 1-based

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

/// Adds the mob to camera static viewers, causing it to see camera static over areas where cameras on the map can't see.
/// The source variable is such that multiple sources can add the ability to view static without conflicting.
/datum/controller/subsystem/cameras/proc/add_viewer_mob(mob/viewer_mob, source)
	if (!source)
		CRASH("Attempted to add the ability to view camera static to a mob without a source for it.")
	if (QDELETED(viewer_mob))
		return

	var/was_a_viewer = HAS_TRAIT(viewer_mob, TRAIT_SEES_CAMERA_STATIC)

	ADD_TRAIT(viewer_mob, TRAIT_SEES_CAMERA_STATIC, source)

	if (was_a_viewer)
		return

	if (viewer_mob.client)
		add_viewer_client(viewer_mob.client, REF(viewer_mob))

	RegisterSignals(viewer_mob, list(COMSIG_QDELETING, SIGNAL_REMOVETRAIT(TRAIT_SEES_CAMERA_STATIC)), PROC_REF(remove_viewer_mob_internal))
	RegisterSignal(viewer_mob, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(on_viewer_mob_login))
	RegisterSignal(viewer_mob, COMSIG_MOB_LOGOUT, PROC_REF(on_viewer_mob_logout))
	RegisterSignal(viewer_mob, COMSIG_VIEWDATA_UPDATE, PROC_REF(on_viewer_mob_viewdata_update))

/// Removes the mob from camera static viewers, causing camera static that it sees to disappear. (if there are no more sources, that is)
/datum/controller/subsystem/cameras/proc/remove_viewer_mob(mob/viewer_mob, source)
	if (!source)
		CRASH("Attempted to remove the ability to view camera static from a mob without a source for it.")

	REMOVE_TRAIT(viewer_mob, TRAIT_SEES_CAMERA_STATIC, source)

/// Internal part of [proc/remove_viewer_source()]
/datum/controller/subsystem/cameras/proc/remove_viewer_mob_internal(mob/viewer_mob)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	if (viewer_mob.client)
		remove_viewer_client(viewer_mob.client, REF(viewer_mob))

	UnregisterSignal(viewer_mob, list(COMSIG_QDELETING, SIGNAL_REMOVETRAIT(TRAIT_SEES_CAMERA_STATIC), COMSIG_MOB_CLIENT_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_VIEWDATA_UPDATE))

/datum/controller/subsystem/cameras/proc/on_viewer_mob_login(mob/viewer_mob, client/viewer_client)
	SIGNAL_HANDLER
	add_viewer_client(viewer_client, REF(viewer_mob))

/datum/controller/subsystem/cameras/proc/on_viewer_mob_logout(mob/viewer_mob)
	SIGNAL_HANDLER
	remove_viewer_client(viewer_mob.canon_client, REF(viewer_mob))

/datum/controller/subsystem/cameras/proc/on_viewer_mob_viewdata_update(mob/viewer_mob, view_size)
	if (viewer_mob.client?.eye)
		update_viewer_static(viewer_mob.client, viewer_mob.client.eye, view_size[1], view_size[2])

/datum/controller/subsystem/cameras/proc/add_viewer_client(client/viewer_client, source)
	if (!source)
		CRASH("Attempted to add the ability to view camera static to a client without a source for it.")

	var/was_a_viewer = HAS_TRAIT(viewer_client, TRAIT_SEES_CAMERA_STATIC)

	ADD_TRAIT(viewer_client, TRAIT_SEES_CAMERA_STATIC, source)

	if (was_a_viewer)
		return

	viewer_client.view_chunks = list()

	if (viewer_client.eye)
		set_viewer_client_eye(viewer_client, old_eye = null, new_eye = viewer_client.eye)

	RegisterSignals(viewer_client, list(COMSIG_QDELETING, SIGNAL_REMOVETRAIT(TRAIT_SEES_CAMERA_STATIC)), PROC_REF(remove_viewer_client_internal))
	RegisterSignal(viewer_client, COMSIG_CLIENT_SET_EYE, PROC_REF(set_viewer_client_eye))

/datum/controller/subsystem/cameras/proc/remove_viewer_client(client/viewer_client, source)
	if (!source)
		CRASH("Attempted to remove the ability to view camera static from a client without a source for it.")

	REMOVE_TRAIT(viewer_client, TRAIT_SEES_CAMERA_STATIC, source)

/datum/controller/subsystem/cameras/proc/remove_viewer_client_internal(client/viewer_client)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	if (viewer_client.eye)
		set_viewer_client_eye(viewer_client, old_eye = viewer_client.eye, new_eye = null)

	UnregisterSignal(viewer_client, list(COMSIG_QDELETING, SIGNAL_REMOVETRAIT(TRAIT_SEES_CAMERA_STATIC)))

	viewer_client.view_chunks = null

/datum/controller/subsystem/cameras/proc/set_viewer_client_eye(client/viewer_client, atom/old_eye, atom/new_eye)
	PRIVATE_PROC(TRUE)

	if (old_eye)
		UnregisterSignal(old_eye, COMSIG_MOVABLE_MOVED)
		eyes_to_clients -= old_eye

	if (new_eye)
		eyes_to_clients[new_eye] = viewer_client
		update_viewer_client(viewer_client, new_eye)
		RegisterSignal(new_eye, COMSIG_MOVABLE_MOVED, PROC_REF(update_viewer_eye))

/datum/controller/subsystem/cameras/proc/update_viewer_eye(atom/eye)
	PRIVATE_PROC(TRUE)

	update_viewer_client(eyes_to_clients[eye], eye)

/datum/controller/subsystem/cameras/proc/update_viewer_client(client/viewer_client, atom/eye)
	PRIVATE_PROC(TRUE)

	var/list/view_size = viewer_client.view_size?.getView() || getviewsize(viewer_client.view)
	update_viewer_static(viewer_client, eye, view_size[1], view_size[2])

/datum/controller/subsystem/cameras/proc/update_viewer_static(client/viewer_client, atom/eye, view_size_x, view_size_y)
	PRIVATE_PROC(TRUE)

	var/list/last_view_chunks = viewer_client.view_chunks

	// Remove the viewer from last view chunks
	for (var/datum/camerachunk/chunk as anything in last_view_chunks)
		chunk.viewers -= viewer_client

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

			chunk.viewers += viewer_client
			view_chunks += chunk

	viewer_client.view_chunks = view_chunks

	// Remove static images for chunks that are no longer in view
	for (var/datum/camerachunk/chunk as anything in (last_view_chunks - view_chunks))
		viewer_client.images -= chunk.static_images

	// Add static images for chunks that are newly in view
	for (var/datum/camerachunk/chunk as anything in (view_chunks - last_view_chunks))
		viewer_client.images += chunk.static_images

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
