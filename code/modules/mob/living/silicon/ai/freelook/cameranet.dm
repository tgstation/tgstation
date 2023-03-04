// CAMERA NET
//
// The datum containing all the chunks.

#define CHUNK_SIZE 16 // Only chunk sizes that are to the power of 2. E.g: 2, 4, 8, 16, etc..
/// Takes a position, transforms it into a chunk bounded position. Indexes at 1 so it'll land on actual turfs always
#define GET_CHUNK_COORD(v) (max((FLOOR(v, CHUNK_SIZE)), 1))
GLOBAL_DATUM_INIT(cameranet, /datum/cameranet, new)

/datum/cameranet
	/// Name to show for VV and stat()
	var/name = "Camera Net"

	/// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Del().
	var/list/obj/machinery/camera/cameras = list()
	/// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = 0

	/// List of images cloned by all chunk static images put onto turfs cameras cant see
	/// Indexed by the plane offset to use
	var/list/image/obscured_images

/datum/cameranet/New()
	obscured_images = list()
	update_offsets(SSmapping.max_plane_offset)
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_offset_growth))

/datum/cameranet/proc/update_offsets(new_offset)
	for(var/i in length(obscured_images) to new_offset)
		var/image/obscured = new('icons/effects/cameravis.dmi')
		SET_PLANE_W_SCALAR(obscured, CAMERA_STATIC_PLANE, i)
		obscured.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR | KEEP_APART
		obscured.override = TRUE
		obscured_images += obscured

/datum/cameranet/proc/on_offset_growth(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	update_offsets(new_offset)

/// Checks if a chunk has been Generated in x, y, z.
/datum/cameranet/proc/chunkGenerated(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	if(GET_LOWEST_STACK_OFFSET(z) != 0)
		var/turf/lowest = get_lowest_turf(locate(x, y, z))
		return chunks["[x],[y],[lowest.z]"]

	return chunks["[x],[y],[z]"]

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/cameranet/proc/getCameraChunk(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	var/turf/lowest = get_lowest_turf(locate(x, y, z))
	var/key = "[x],[y],[lowest.z]"
	. = chunks[key]
	if(!.)
		chunks[key] = . = new /datum/camerachunk(x, y, lowest.z)

/// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.
/datum/cameranet/proc/visibility(list/moved_eyes, client/C, list/other_eyes, use_static = TRUE)
	if(!islist(moved_eyes))
		moved_eyes = moved_eyes ? list(moved_eyes) : list()
	if(islist(other_eyes))
		other_eyes = (other_eyes - moved_eyes)
	else
		other_eyes = list()

	for(var/mob/camera/ai_eye/eye as anything in moved_eyes)
		var/list/visibleChunks = list()
		//Get the eye's turf in case it's located in an object like a mecha
		var/turf/eye_turf = get_turf(eye)
		if(eye.loc)
			var/static_range = eye.static_visibility_range
			var/x1 = max(1, eye_turf.x - static_range)
			var/y1 = max(1, eye_turf.y - static_range)
			var/x2 = min(world.maxx, eye_turf.x + static_range)
			var/y2 = min(world.maxy, eye_turf.y + static_range)

			for(var/x = x1; x <= x2; x += CHUNK_SIZE)
				for(var/y = y1; y <= y2; y += CHUNK_SIZE)
					visibleChunks |= getCameraChunk(x, y, eye_turf.z)

		var/list/remove = eye.visibleCameraChunks - visibleChunks
		var/list/add = visibleChunks - eye.visibleCameraChunks

		for(var/datum/camerachunk/chunk as anything in remove)
			chunk.remove(eye, FALSE)

		for(var/datum/camerachunk/chunk as anything in add)
			chunk.add(eye)

/// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or when doors open.
/datum/cameranet/proc/updateVisibility(atom/A, opacity_check = 1)
	if(!SSticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)

/datum/cameranet/proc/updateChunk(x, y, z)
	var/datum/camerachunk/chunk = chunkGenerated(x, y, z)
	if (!chunk)
		return
	chunk.hasChanged()

/// Removes a camera from a chunk.
/datum/cameranet/proc/removeCamera(obj/machinery/camera/c)
	majorChunkChange(c, 0)

/// Add a camera to a chunk.
/datum/cameranet/proc/addCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)

/**
 * Used for Cyborg/mecha cameras. Since portable cameras can be in ANY chunk.
 * update_delay_buffer is passed all the way to hasChanged() from their camera updates on movement
 * to change the time between static updates.
*/
/datum/cameranet/proc/updatePortableCamera(obj/machinery/camera/updating_camera, update_delay_buffer)
	if(updating_camera.can_use())
		majorChunkChange(updating_camera, 1, update_delay_buffer)

/**
 * Never access this proc directly!!!!
 * This will update the chunk and all the surrounding chunks.
 * It will also add the atom to the cameras list if you set the choice to 1.
 * Setting the choice to 0 will remove the camera from the chunks.
 * If you want to update the chunks around an object, without adding/removing a camera, use choice 2.
 * update_delay_buffer is passed all the way to hasChanged() from portable camera updates on movement
 * to change the time between static updates.
 */
/datum/cameranet/proc/majorChunkChange(atom/c, choice, update_delay_buffer)
	if(QDELETED(c) && choice == 1)
		CRASH("Tried to add a qdeleting camera to the net")

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(1, T.x - (CHUNK_SIZE / 2))
		var/y1 = max(1, T.y - (CHUNK_SIZE / 2))
		var/x2 = min(world.maxx, T.x + (CHUNK_SIZE / 2))
		var/y2 = min(world.maxy, T.y + (CHUNK_SIZE / 2))
		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				var/datum/camerachunk/chunk = chunkGenerated(x, y, T.z)
				if(chunk)
					if(choice == 0)
						// Remove the camera.
						chunk.cameras["[T.z]"] -= c
					else if(choice == 1)
						// You can't have the same camera in the list twice.
						chunk.cameras["[T.z]"] |= c
					chunk.hasChanged(update_delay_buffer = update_delay_buffer)

/// A faster, turf only version of [/datum/cameranet/proc/majorChunkChange]
/// For use in sensitive code, be careful with it
/datum/cameranet/proc/bareMajorChunkChange(turf/changed)
	var/x1 = max(1, changed.x - (CHUNK_SIZE / 2))
	var/y1 = max(1, changed.y - (CHUNK_SIZE / 2))
	var/x2 = min(world.maxx, changed.x + (CHUNK_SIZE / 2))
	var/y2 = min(world.maxy, changed.y + (CHUNK_SIZE / 2))
	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = chunkGenerated(x, y, changed.z)
			chunk?.hasChanged()

/// Will check if a mob is on a viewable turf. Returns 1 if it is, otherwise returns 0.
/datum/cameranet/proc/checkCameraVis(mob/living/target)
	var/turf/position = get_turf(target)
	return checkTurfVis(position)


/datum/cameranet/proc/checkTurfVis(turf/position)
	var/datum/camerachunk/chunk = getCameraChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(chunk.visibleTurfs[position])
			return TRUE
	return FALSE

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
