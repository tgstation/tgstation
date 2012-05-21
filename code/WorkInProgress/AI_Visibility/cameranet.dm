//------------------------------------------------------------
//
//                      The Cameranet
//
//   The cameranet is a single global instance of a unique
//  datum, which contains logic for managing the individual
//  chunks.
//
//------------------------------------------------------------

/datum/cameranet
	var/list/cameras = list()
	var/list/chunks = list()
	var/network = "net1"
	var/ready = 0

	var/list/minimap = list()

	var/generating_minimap = TRUE

var/datum/cameranet/cameranet = new()



/datum/cameranet/New()
	..()

	spawn(100)
		init_minimap()


/datum/cameranet/proc/init_minimap()
	for(var/x = 0, x <= world.maxx, x += 16)
		for(var/y = 0, y <= world.maxy, y += 16)
			sleep(1)
			getCameraChunk(x, y, 5)
			getCameraChunk(x, y, 1)

	generating_minimap = FALSE


/datum/cameranet/proc/chunkGenerated(x, y, z)
	var/key = "[x],[y],[z]"
	return key in chunks


/datum/cameranet/proc/getCameraChunk(x, y, z)
	var/key = "[x],[y],[z]"

	if(!(key in chunks))
		chunks[key] = new /datum/camerachunk(null, x, y, z)

	return chunks[key]




//  This proc updates what chunks are considered seen
// by an aiEye. As part of the process, it will force
// any newly visible chunks with pending unscheduled
// updates to update, and show the correct obscuring
// and dimming image sets. If you do not call this
// after the eye has moved, it may result in the
// affected AI gaining (partial) xray, seeing through
// now-closed doors, not seeing through open doors,
// or other visibility oddities, depending on if/when
// they last visited any of the chunks in the nearby
// area.

//  It must be called manually, as there is no way to
// have a proc called automatically every time an
// object's loc changes.

/datum/cameranet/proc/visibility(mob/aiEye/ai)
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

	for(var/datum/camerachunk/c in remove)
		c.remove(ai)

	for(var/datum/camerachunk/c in add)
		c.add(ai)




//  This proc should be called if a turf, or the contents
// of a turf, changes opacity. This includes such things
// as changing the turf, opening or closing a door, or
// anything else that would alter line of sight in the
// general area.

/datum/cameranet/proc/updateVisibility(turf/loc)
	if(!chunkGenerated(loc.x & ~0xf, loc.y & ~0xf, loc.z))
		return

	var/datum/camerachunk/chunk = getCameraChunk(loc.x & ~0xf, loc.y & ~0xf, loc.z)
	chunk.visibilityChanged(loc)




//  This proc updates all relevant chunks when enabling or
// creating a camera, allowing freelook and the minimap to
// respond correctly.

/datum/cameranet/proc/addCamera(obj/machinery/camera/c)
	var/x1 = max(0, c.x - 16) & ~0xf
	var/y1 = max(0, c.y - 16) & ~0xf
	var/x2 = min(world.maxx, c.x + 16) & ~0xf
	var/y2 = min(world.maxy, c.y + 16) & ~0xf

	for(var/x = x1; x <= x2; x += 16)
		for(var/y = y1; y <= y2; y += 16)
			if(chunkGenerated(x, y, c.z))
				var/datum/camerachunk/chunk = getCameraChunk(x, y, c.z)

				if(!(c in chunk.cameras))
					chunk.cameras += c
					chunk.hasChanged()




//  This proc updates all relevant chunks when disabling or
// deleting a camera, allowing freelook and the minimap to
// respond correctly.

/datum/cameranet/proc/removeCamera(obj/machinery/camera/c)
	var/x1 = max(0, c.x - 16) & ~0xf
	var/y1 = max(0, c.y - 16) & ~0xf
	var/x2 = min(world.maxx, c.x + 16) & ~0xf
	var/y2 = min(world.maxy, c.y + 16) & ~0xf

	for(var/x = x1; x <= x2; x += 16)
		for(var/y = y1; y <= y2; y += 16)
			if(chunkGenerated(x, y, c.z))
				var/datum/camerachunk/chunk = getCameraChunk(x, y, c.z)

				if(!c)
					chunk.hasChanged()

				if(c in chunk.cameras)
					chunk.cameras -= c
					chunk.hasChanged()
