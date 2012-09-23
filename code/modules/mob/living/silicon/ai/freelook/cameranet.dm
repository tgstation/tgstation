// CAMERA NET
//
// The datum containing all the chunks.

var/datum/cameranet/cameranet = new()

/datum/cameranet
	// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Del().
	var/list/cameras = list()
	// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = 0

// Checks if a chunk has been Generated in x, y, z.
/datum/cameranet/proc/chunkGenerated(x, y, z)
	x &= ~0xf
	y &= ~0xf
	var/key = "[x],[y],[z]"
	return key in chunks

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/cameranet/proc/getCameraChunk(x, y, z)
	x &= ~0xf
	y &= ~0xf
	var/key = "[x],[y],[z]"
	if(!(key in chunks))
		chunks[key] = new /datum/camerachunk(null, x, y, z)

	return chunks[key]

// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.

/datum/cameranet/proc/visibility(mob/aiEye/ai)
	// 0xf = 15
	var/x1 = max(0, ai.x - 16) & ~0xf
	var/y1 = max(0, ai.y - 16) & ~0xf
	var/x2 = min(world.maxx, ai.x + 16) & ~0xf
	var/y2 = min(world.maxy, ai.y + 16) & ~0xf

	var/list/visibleChunks = list()

	for(var/x = x1; x <= x2; x += 16)
		for(var/y = y1; y <= y2; y += 16)
			visibleChunks += getCameraChunk(x, y, ai.z)

	var/list/remove = ai.visibleCameraChunks - visibleChunks
	var/list/add = visibleChunks - ai.visibleCameraChunks

	for(var/chunk in remove)
		var/datum/camerachunk/c = chunk
		c.remove(ai)

	for(var/chunk in add)
		var/datum/camerachunk/c = chunk
		c.add(ai)

// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or	when doors open.

/datum/cameranet/proc/updateVisibility(atom/A, var/opacity_check = 1)

	if(!ticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)

/datum/cameranet/proc/updateChunk(x, y, z)
	// 0xf = 15
	if(!chunkGenerated(x, y, z))
		return
	var/datum/camerachunk/chunk = getCameraChunk(x, y, z)
	chunk.hasChanged()

// Removes a camera from a chunk.

/datum/cameranet/proc/removeCamera(obj/machinery/camera/c)
	majorChunkChange(c, 0)

// Add a camera to a chunk.

/datum/cameranet/proc/addCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)

// Used for Cyborg cameras. It is the same as "add" but named differently for easier readability
// and to allow the user know what it is for. Since portable cameras can be in ANY chunk, we have to
// all it to be added to all chunks. If the camera is disabled, it will instead remove.

/datum/cameranet/proc/updatePortableCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)
	else
		majorChunkChange(c, 0)

// Never access this proc directly!!!!
// This will update the chunk and all the surrounding chunks.
// It will also add the atom to the cameras list if you set the choice to 1.
// Setting the choice to 0 will remove the camera from the chunks.
// If you want to update the chunks around an object, without adding/removing a camera, use choice 2.

/datum/cameranet/proc/majorChunkChange(atom/c, var/choice)
	// 0xf = 15
	if(!c)
		return

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(0, T.x - 16) & ~0xf
		var/y1 = max(0, T.y - 16) & ~0xf
		var/x2 = min(world.maxx, T.x + 16) & ~0xf
		var/y2 = min(world.maxy, T.y + 16) & ~0xf

		for(var/x = x1; x <= x2; x += 16)
			for(var/y = y1; y <= y2; y += 16)
				if(chunkGenerated(x, y, T.z))
					var/datum/camerachunk/chunk = getCameraChunk(x, y, T.z)
					if(choice == 0)
						// Remove the camera.
						chunk.cameras -= c
					else if(choice == 1)
						// You can't have the same camera in the list twice.
						chunk.cameras |= c
					chunk.hasChanged()

// Will check if a mob is on a viewable turf. Returns 1 if it is, otherwise returns 0.

/datum/cameranet/proc/checkCameraVis(mob/living/target as mob)

	// 0xf = 15
	var/turf/position = get_turf(target)
	var/datum/camerachunk/chunk = getCameraChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(position in chunk.visibleTurfs)
			return 1
	return 0