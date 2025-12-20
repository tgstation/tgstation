#define STAGE_CAMERAS 0

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

	/// All cameras on the map.
	var/list/cameras = list()
	/// All camera chunks on the map. (alist[chunk_coords] = chunk)
	var/alist/chunks = alist()

	/// All cameras that must be updated. (alist[camera] = null)
	var/alist/camera_queue = alist()

	/// All base static images, indexed by plane offset. (list[offset + 1] = image)
	var/list/base_static_images = list()

/datum/controller/subsystem/cameras/Initialize()
	update_static_images()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(update_static_images))
	return SS_INIT_SUCCESS

//GLOBAL_LIST_EMPTY(camera_cost)
//GLOBAL_LIST_EMPTY(camera_count)

/datum/controller/subsystem/cameras/fire(resumed = FALSE)
	//INIT_COST(GLOB.camera_cost, GLOB.camera_count)
	//EXPORT_STATS_TO_CSV_LATER("camera-cost.txt", GLOB.camera_cost, GLOB.camera_count)

	var/world_max_chunk_x = ceil(WORLD_TO_CHUNK(world.maxx))
	var/world_max_chunk_y = ceil(WORLD_TO_CHUNK(world.maxy))

	for (var/obj/machinery/camera/camera as anything in camera_queue)
		if (MC_TICK_CHECK)
			return

		camera_queue -= camera

		// Cache for speed and readability
		var/datum/bounds/view_bounds = camera.view_bounds
		var/list/view_chunks = camera.view_chunks
		var/list/view_turfs = camera.view_turfs

		// Rremove the camera from turfs and chunks that it's viewing
		if (view_bounds)
			adjust_viewing_camera_counts(camera, -1)
			view_turfs.Cut()

			for (var/datum/camerachunk/chunk as anything in view_chunks)
				chunk.cameras -= camera
			view_chunks.Cut()

		// If the camera can't be used, clear up view bounds and continue
		if (QDELING(camera) || !camera.can_use())
			camera.view_bounds = null
			continue

		var/turf/source = get_turf(camera)

		var/view_range = camera.view_range
		var/view_size = view_range * 2 + 1

		if (!view_bounds)
			view_bounds = BOUNDS_CENTER_AND_SIZE(vector(source.x, source.y, source.z), vector(view_size, view_size, 1))
			camera.view_bounds = view_bounds
		else
			view_bounds.set_center(vector(source.x, source.y, source.z))
			view_bounds.set_size(vector(view_size, view_size, 1))

		var/view_min_x = view_bounds.min.x
		var/view_min_y = view_bounds.min.y
		var/view_z = source.z

		view_turfs.len = view_size ** 2

		// Set the source turf luminosity to max to make view() ignore darkness
		var/luminosity = source.luminosity
		source.luminosity = 6

		// Create a dense visibility mask indexed by view bound coordinates
		// view(), turf.x, turf.y and view_turfs[] are the most expensive operations here
		for (var/turf/turf in view(view_range, source))
			view_turfs[1 + (turf.x - view_min_x) + (turf.y - view_min_y) * view_size] = TRUE

		// Restore the previous luminosity
		source.luminosity = luminosity

		// Add chunks within view bounds
		populate_view_chunks(view_chunks, view_bounds, create_new_if_null = TRUE)

		for (var/datum/camerachunk/chunk as anything in view_chunks)
			chunk.cameras += camera

		// Add the camera to turfs that it's viewing
		adjust_viewing_camera_counts(camera, 1)

	//SET_COST("Run cameras")

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

/datum/controller/subsystem/cameras/proc/populate_view_chunks(list/view_chunks, datum/bounds/view_bounds, create_new_if_null)
	var/vector/view_min = view_bounds.min

	var/start_chunk_x = max(0, floor(WORLD_TO_CHUNK(view_min.x)))
	var/start_chunk_y = max(0, floor(WORLD_TO_CHUNK(view_min.y)))

	var/vector/view_size = view_bounds.get_size()

	var/end_chunk_x = start_chunk_x + ceil(view_size.x / CHUNK_SIZE) - 1 // -1 because the bounds are inclusive
	var/end_chunk_y = start_chunk_y + ceil(view_size.y / CHUNK_SIZE) - 1 // ditto

	var/view_z = view_min.z

	var/chunk_z_coord = GET_CHUNK_Z_COORD(view_z)

	// Add chunks within view bounds
	for (var/chunk_y = start_chunk_y to end_chunk_y)
		var/chunk_yz_coord = GET_CHUNK_Y_COORD(chunk_y) | chunk_z_coord
		for (var/chunk_x = start_chunk_x to end_chunk_x)
			var/datum/camerachunk/chunk = chunks[chunk_x | chunk_yz_coord] || (create_new_if_null && new /datum/camerachunk(chunk_x, chunk_y, view_z))
			if (chunk)
				view_chunks += chunk

/datum/controller/subsystem/cameras/proc/adjust_viewing_camera_counts(obj/machinery/camera/camera, amount)
	var/list/view_turfs = camera.view_turfs

	var/datum/bounds/view_bounds = camera.view_bounds.get_copy_2D()

	var/view_min_x = view_bounds.min.x
	var/view_min_y = view_bounds.min.y

	var/view_size_y = view_bounds.get_size().y

	// Pre-allocate intersection bounds for speed
	var/datum/bounds/intersection = new(vector(0, 0), vector(0, 0))

	for (var/datum/camerachunk/chunk in camera.view_chunks)
		var/list/visibility = chunk.visibility

		var/datum/bounds/chunk_bounds = chunk.world_bounds

		var/chunk_min_x = chunk_bounds.min.x
		var/chunk_min_y = chunk_bounds.min.y

		// Re-use the same intersection bounds, making them act like chunk bounds
		intersection.set_copy_2D(chunk_bounds)

		// Intersect the world space view bounds with the world space chunk bounds
		intersection.intersect_unclamped(view_bounds)

		var/start_x = intersection.min.x
		var/end_x = intersection.max.x - 1 // inclusive

		var/start_y = intersection.min.y
		var/end_y = intersection.max.y - 1 // inclusive

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
		var/datum/bounds/view_bounds = camera.view_bounds
		if (camera.view_turfs[1 + (x - view_bounds.min.x) + (y - view_bounds.min.y) * view_bounds.get_size().y])
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
		var/datum/bounds/view_bounds = camera.view_bounds
		if (camera.view_turfs[1 + (x - view_bounds.min.x) + (y - view_bounds.min.y) * view_bounds.get_size().y])
			. += camera

/// Updates all of the cameras that might see this atom.
/datum/controller/subsystem/cameras/proc/update_visibility(atom/source)
	var/turf/turf = get_turf(source)
	if (!turf)
		return

	var/datum/camerachunk/chunk = chunks[GET_TURF_CHUNK_COORDS(turf)]
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
