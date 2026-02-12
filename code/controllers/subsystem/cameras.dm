/// Manages the security cameras and camera chunks
SUBSYSTEM_DEF(cameras)
	name = "Cameras"
	flags = SS_BACKGROUND
	priority = FIRE_PRIORITY_CAMERAS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 MINUTES
	dependencies = list(
		// Required to get plane offset for static images
		/datum/controller/subsystem/mapping,
	)

	/// The cameras on the map, no matter if they work or not.
	/// Updated in obj/machinery/camera.dm in Initialize() and Destroy().
	var/list/obj/machinery/camera/cameras = list()
	/// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	/// Chunks that must be updated
	var/list/chunks_to_update  = list()
	/// List of images cloned by all chunk static images put onto turfs cameras cant see
	/// Indexed by the plane offset to use
	var/list/image/obscured_images = list()
	/// Primarily for debugging, outright prevents all camera chunk updates
	var/disable_camera_updates = FALSE
	/// Tracks current subsystem run
	var/list/current_run = list()

/datum/controller/subsystem/cameras/Initialize()
	update_offsets(SSmapping.max_plane_offset)
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_offset_growth))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/cameras/fire(resumed = FALSE)
	if(!resumed)
		src.current_run = chunks_to_update.Copy()
		chunks_to_update = list()

	var/list/current_run = src.current_run
	while(current_run.len)
		var/datum/camerachunk/chunk = current_run[current_run.len]
		chunk.force_update(only_if_necessary = TRUE) // Forces an update if necessary
		current_run.len--
		if(MC_TICK_CHECK)
			break

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
/datum/controller/subsystem/cameras/proc/is_visible_by_cameras(atom/target)
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
