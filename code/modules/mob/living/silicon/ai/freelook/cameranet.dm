// CAMERA NET
//
// The datum containing all the chunks.

#define CHUNK_SIZE 16 // Only chunk sizes that are to the power of 2. E.g: 2, 4, 8, 16, etc..

GLOBAL_DATUM_INIT(cameranet, /datum/cameranet, new)

/datum/cameranet
	var/name = "Camera Net" // Name to show for VV and stat()

	// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Del().
	var/list/cameras = list()
	// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = 0

	///this object is the static that ais see on obscured turfs, added to the turfs vis_contents
	var/obj/effect/overlay/camera_static/vis_contents_opaque

	///The image given to the effect in vis_contents on AI clients
	var/image/obscured

/datum/cameranet/New()
	vis_contents_opaque = new /obj/effect/overlay/camera_static()

	obscured = new('icons/effects/cameravis.dmi', vis_contents_opaque, null)
	obscured.plane = CAMERA_STATIC_PLANE

/// Checks if a chunk has been Generated in x, y, z.
/datum/cameranet/proc/chunkGenerated(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)
	return chunks["[x],[y],[z]"]

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/cameranet/proc/getCameraChunk(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	. = chunks[key]
	if(!.)
		chunks[key] = . = new /datum/camerachunk(x, y, z)

/// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.
/datum/cameranet/proc/visibility(list/moved_eyes, client/C, list/other_eyes, use_static = TRUE)
	if(!islist(moved_eyes))
		moved_eyes = moved_eyes ? list(moved_eyes) : list()
	if(islist(other_eyes))
		other_eyes = (other_eyes - moved_eyes)
	else
		other_eyes = list()

	if(C && use_static)
		C.images += obscured

	for(var/mob/camera/ai_eye/eye as anything in moved_eyes)
		var/list/visibleChunks = list()
		if(eye.loc)
			// 0xf = 15
			var/static_range = eye.static_visibility_range
			var/x1 = max(0, eye.x - static_range) & ~(CHUNK_SIZE - 1)
			var/y1 = max(0, eye.y - static_range) & ~(CHUNK_SIZE - 1)
			var/x2 = min(world.maxx, eye.x + static_range) & ~(CHUNK_SIZE - 1)
			var/y2 = min(world.maxy, eye.y + static_range) & ~(CHUNK_SIZE - 1)


			for(var/x = x1; x <= x2; x += CHUNK_SIZE)
				for(var/y = y1; y <= y2; y += CHUNK_SIZE)
					visibleChunks |= getCameraChunk(x, y, eye.z)

		var/list/remove = eye.visibleCameraChunks - visibleChunks
		var/list/add = visibleChunks - eye.visibleCameraChunks

		for(var/datum/camerachunk/chunk as anything in remove)
			chunk.remove(eye, FALSE)

		for(var/datum/camerachunk/chunk as anything in add)
			chunk.add(eye)

		if(!eye.visibleCameraChunks.len)
			var/client/client = eye.GetViewerClient()
			if(client && eye.use_static)
				client.images -= obscured

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

/// Used for Cyborg cameras. Since portable cameras can be in ANY chunk.
/datum/cameranet/proc/updatePortableCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)

/**
 * Never access this proc directly!!!!
 * This will update the chunk and all the surrounding chunks.
 * It will also add the atom to the cameras list if you set the choice to 1.
 * Setting the choice to 0 will remove the camera from the chunks.
 * If you want to update the chunks around an object, without adding/removing a camera, use choice 2.
 */
/datum/cameranet/proc/majorChunkChange(atom/c, choice)
	if(!c)
		return

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(0, T.x - (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/y1 = max(0, T.y - (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/x2 = min(world.maxx, T.x + (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/y2 = min(world.maxy, T.y + (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				var/datum/camerachunk/chunk = chunkGenerated(x, y, T.z)
				if(chunk)
					if(choice == 0)
						// Remove the camera.
						chunk.cameras -= c
					else if(choice == 1)
						// You can't have the same camera in the list twice.
						chunk.cameras |= c
					chunk.hasChanged()

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
	appearance_flags = RESET_TRANSFORM | TILE_BOUND
	// this combination makes the static block clicks to everything below it,
	// without appearing in the right-click menu for non-AI clients
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_ABSTRACT

	plane = CAMERA_STATIC_PLANE
