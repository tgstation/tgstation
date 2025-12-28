/// Manages camera visibility
SUBSYSTEM_DEF(cameras)
	name = "Cameras"
	flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_CAMERAS
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping, // plane offsets
		/datum/controller/subsystem/atoms, // opacity
	)

	/// All cameras on the map.
	var/list/cameras = list()
	/// All camera chunks on the map. (alist[chunk_coords] = chunk)
	var/alist/chunks = alist()

	/// All cameras that must be updated. (alist[camera] = null)
	var/alist/camera_queue = alist()
	/// All chunks that must be updated. (alist[chunk] = null)
	var/alist/chunk_queue = alist()

//GLOBAL_LIST_EMPTY(camera_cost)
//GLOBAL_LIST_EMPTY(camera_count)

/datum/controller/subsystem/cameras/fire(resumed = FALSE)
	//INIT_COST(GLOB.camera_cost, GLOB.camera_count)
	//EXPORT_STATS_TO_CSV_LATER("camera-cost.txt", GLOB.camera_cost, GLOB.camera_count)

	for (var/datum/component/camera/camera as anything in camera_queue)
		if (MC_TICK_CHECK)
			return

		camera_queue -= camera

		// Cache for speed and readability
		var/datum/camera_view_data/old_view = camera.view

		// We're gonna use this after old_view is deleted
		var/list/old_view_chunks = old_view.chunks

		// Remove the camera from turfs that it's viewing
		if (old_view)
			adjust_viewing_camera_counts(old_view, -1)
			QDEL_NULL(camera.view)

		// If the camera can't be used, clear up view data and continue
		if (QDELING(camera) || !camera.enabled || !get_turf(camera.parent))
			remove_camera_from_chunks(camera, old_view_chunks)
			continue

		view = new(camera)

		var/list/new_view_chunks = list()

		populate_view_chunks(new_view_chunks, view_bounds)

		add_camera_to_chunks(camera, new_view_chunks - old_view_chunks)

		remove_camera_from_chunks(camera, old_view_chunks - new_view_chunks)

		camera.view_chunks = new_view_chunks

		// Add the camera to turfs that it's viewing
		adjust_viewing_camera_counts(camera, 1)

	//SET_COST("Run cameras")

/datum/controller/subsystem/cameras/proc/populate_view_turfs(datum/camera_view_data/view)
	var/view_range = view.range
	var/view_size = view.size

	var/view_min_x = view.min_x
	var/view_min_y = view.min_y

	// Set the source turf luminosity to max to make view() ignore darkness
	var/luminosity = source.luminosity
	source.luminosity = 6

	// Create a dense visibility mask indexed by view bound coordinates
	// view(), turf.x, turf.y and view_turfs[] are the most expensive operations here
	for (var/turf/turf in view(view_range, source))
		view_turfs[1 + (turf.x - view_min_x) + (turf.y - view_min_y) * view_size] = TRUE

	// Restore the previous luminosity
	source.luminosity = luminosity

/datum/controller/subsystem/cameras/proc/populate_view_chunks(datum/camera_view_data/view)
	var/view_min_x = view.min_x
	var/view_min_y = view.min_y

	var/start_chunk_x = max(0, floor(WORLD_TO_CHUNK(view_min_x)))
	var/start_chunk_y = max(0, floor(WORLD_TO_CHUNK(view_min_y)))

	var/view_size = view.size

	var/end_chunk_x = start_chunk_x + ceil(view_size / CHUNK_SIZE) - 1 // -1 because the bounds are inclusive
	var/end_chunk_y = start_chunk_y + ceil(view_size / CHUNK_SIZE) - 1 // ditto

	var/view_z = view.z

	var/chunk_z_coord = GET_CHUNK_Z_COORD(view_z)

	// Add chunks within view bounds
	for (var/chunk_y = start_chunk_y to end_chunk_y)
		var/chunk_yz_coord = GET_CHUNK_Y_COORD(chunk_y) | chunk_z_coord
		for (var/chunk_x = start_chunk_x to end_chunk_x)
			var/datum/camera_chunk/chunk = chunks[chunk_x | chunk_yz_coord] || new /datum/camera_chunk(chunk_x, chunk_y, view_z)
			if (chunk)
				view_chunks += chunk

/datum/controller/subsystem/cameras/proc/add_camera_to_chunks(obj/machinery/camera/camera, list/chunks)
	for (var/datum/camera_chunk/chunk as anything in chunks)
		if (!length(chunk.cameras))
			chunk.init_cameras()

		chunk.cameras += camera

/datum/controller/subsystem/cameras/proc/remove_camera_from_chunks(obj/machinery/camera/camera, list/chunks)
	for (var/datum/camera_chunk/chunk as anything in chunks)
		chunk.cameras -= camera

		if (!length(chunk.cameras))
			chunk.deinit_cameras()

/datum/controller/subsystem/cameras/proc/adjust_viewing_camera_counts(datum/camera_view/view, amount)
	var/list/view_turfs = camera.view_turfs

	var/view_size = view.size
	var/view_range = view.range

	var/view_min_x = view.min_x
	var/view_min_y = view.min.y

	var/view_max_x = view_min_x + view.range
	var/view_max_y = view_max_y + view.range

	for (var/datum/camera_chunk/chunk in camera.view_chunks)
		var/list/visibility = chunk.visibility

		var/chunk_min_x = chunk.world_x
		var/chunk_min_y = chunk.world_y

		// Get the intersection of the chunk and view bounds
		var/int_min_x = max(chunk_min_x, view_min_x)
		var/int_min_y = max(chunk_min_y, view_min_y)

		var/start_x = intersection.min.x
		var/start_y = intersection.min.y

		var/end_x = intersection.max.x - 1 // inclusive
		var/end_y = intersection.max.y - 1 // ditto

		// Iterate over the intersection and remove the camera from visibility array camera counts
		for (var/world_y in start_y to end_y)
			var/view_row = (world_y - view_min_y) * view_size_y
			var/chunk_row = (world_y - chunk_min_y) * CHUNK_SIZE

			for (var/world_x in start_x to end_x)
				if (view_turfs[1 + (world_x - view_min_x) + view_row])
					visibility[1 + (world_x - chunk_min_x) + chunk_row] += amount

/// Checks if the atom is visible by any cameras on the map. Strictly returns TRUE or FALSE.
/datum/controller/subsystem/cameras/proc/is_on_cameras(atom/atom_to_check)
	var/turf/turf_to_check = get_turf(atom_to_check)
	if (!turf_to_check)
		return FALSE

	var/datum/camera_chunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf_to_check)]
	return !isnull(chunk) && chunk.visibility[GET_CHUNK_TURF_COORDS(turf_to_check, chunk)] > 0

/// Returns the first camera found on which atom the is visible, if any.
/datum/controller/subsystem/cameras/proc/get_first_viewing_camera(atom/atom_to_check)
	var/turf/turf_to_check = get_turf(atom_to_check)
	if (!turf_to_check)
		return

	var/datum/camera_chunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf_to_check)]
	if (!chunk?.visibility[GET_CHUNK_TURF_COORDS(turf_to_check, chunk)])
		return

	var/x = turf_to_check.x
	var/y = turf_to_check.y

	for (var/obj/machinery/camera/camera as anything in chunk.cameras)
		var/datum/bounds/view_bounds = camera.view_bounds
		if (camera.view_turfs[1 + (x - view_bounds.min.x) + (y - view_bounds.min.y) * view_bounds.get_size().y])
			return camera

/// Returns a list of all of the cameras on which the atom is visible.
/datum/controller/subsystem/cameras/proc/get_all_viewing_cameras(atom/atom_to_check)
	. = list()
	var/turf/turf_to_check = get_turf(atom_to_check)
	if (!turf_to_check)
		return

	var/datum/camera_chunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf_to_check)]
	if (!chunk?.visibility[GET_CHUNK_TURF_COORDS(turf_to_check, chunk)])
		return

	var/x = turf_to_check.x
	var/y = turf_to_check.y

	for (var/obj/machinery/camera/camera as anything in chunk.cameras)
		var/datum/bounds/view_bounds = camera.view_bounds
		if (camera.view_turfs[1 + (x - view_bounds.min.x) + (y - view_bounds.min.y) * view_bounds.get_size().y])
			. += camera

/// Updates all of the cameras that might see this atom.
/datum/controller/subsystem/cameras/proc/update_visibility(atom/source)
	var/turf/turf = get_turf(source)
	if (!turf)
		return

	var/datum/camera_chunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf)]
	if (!chunk)
		return

	var/vector/point = vector(turf.x, turf.y, turf.z)

	for (var/obj/machinery/camera/camera in chunk.cameras)
		if (camera.view_bounds.contains(point))
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

	UnregisterSignal(viewer_mob, list(COMSIG_QDELETING, SIGNAL_REMOVETRAIT(TRAIT_SEES_CAMERA_STATIC), COMSIG_MOB_CLIENT_LOGIN, COMSIG_MOB_LOGOUT))

/datum/controller/subsystem/cameras/proc/on_viewer_mob_login(mob/viewer_mob, client/viewer_client)
	SIGNAL_HANDLER
	add_viewer_client(viewer_client, REF(viewer_mob))

/datum/controller/subsystem/cameras/proc/on_viewer_mob_logout(mob/viewer_mob)
	SIGNAL_HANDLER
	remove_viewer_client(viewer_mob.canon_client, REF(viewer_mob))

/datum/controller/subsystem/cameras/proc/add_viewer_client(client/viewer_client, source)
	if (!source)
		CRASH("Attempted to add the ability to view camera static to a client without a source for it.")

	var/was_a_viewer = HAS_TRAIT(viewer_client, TRAIT_SEES_CAMERA_STATIC)

	ADD_TRAIT(viewer_client, TRAIT_SEES_CAMERA_STATIC, source)

	if (was_a_viewer)
		return

	viewer_client.AddComponent(/datum/component/camera_viewer)

	RegisterSignal(viewer_client, SIGNAL_REMOVETRAIT(TRAIT_SEES_CAMERA_STATIC), PROC_REF(remove_viewer_client_internal))

/datum/controller/subsystem/cameras/proc/remove_viewer_client(client/viewer_client, source)
	if (!source)
		CRASH("Attempted to remove the ability to view camera static from a client without a source for it.")

	REMOVE_TRAIT(viewer_client, TRAIT_SEES_CAMERA_STATIC, source)

/datum/controller/subsystem/cameras/proc/remove_viewer_client_internal(client/viewer_client)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	var/datum/component/camera_viewer = viewer_client.GetComponent(/datum/component/camera_viewer)

	if (!QDELETED(camera_viewer))
		qdel(camera_viewer)

	UnregisterSignal(viewer_client, SIGNAL_REMOVETRAIT(TRAIT_SEES_CAMERA_STATIC))

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
