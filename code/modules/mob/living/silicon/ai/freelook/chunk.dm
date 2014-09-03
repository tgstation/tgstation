#define UPDATE_BUFFER 25 // 2.5 seconds

/**
 * CAMERA CHUNK
 *
 * A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
 * Allows the AI Eye to stream these chunks and know what it can and cannot see.
 */
/datum/camerachunk
	var/list/obscuredTurfs = new
	var/list/visibleTurfs = new
	var/list/obscured = new
	var/list/cameras = new
	var/list/turfs = new
	var/list/seenby = new
	var/visible = 0
	var/changed = 0
	var/updating = 0
	var/x = 0
	var/y = 0
	var/z = 0

/*
 * Add an AI eye to the chunk, then update if changed.
 */
/datum/camerachunk/proc/add(const/mob/camera/aiEye/ai)
	if(!ai.ai)
		return
	ai.visibleCameraChunks += src
	if(ai.ai.client)
		ai.ai.client.images += obscured
	visible++
	seenby += ai
	if(changed && !updating)
		update()

/*
 * Remove an AI eye from the chunk, then update if changed.
 */
/datum/camerachunk/proc/remove(const/mob/camera/aiEye/ai)
	if(!ai.ai)
		return
	ai.visibleCameraChunks -= src
	if(ai.ai.client)
		ai.ai.client.images -= obscured
	seenby -= ai
	if(visible > 0)
		visible--

/*
 * Called when a chunk has changed.
 * I.E: A wall was deleted.
 */
/datum/camerachunk/proc/visibilityChanged(const/turf/loc)
	if(!visibleTurfs[loc])
		return

	hasChanged()

/*
 * Updates the chunk, makes sure that it doesn't update too much.
 * If the chunk isn't being watched it will instead be flagged to update the next time an AI Eye moves near it.
 */
/datum/camerachunk/proc/hasChanged(var/update_now = 0)
	if(visible || update_now)
		if(!updating)
			updating = 1

			spawn(UPDATE_BUFFER) // Batch large changes, such as many doors opening or closing at once
				update()
				updating = 0
	else
		changed = 1

#undef UPDATE_BUFFER

/*
 * The actual updating.
 * It gathers the visible turfs from cameras and puts them into the appropiate lists.
 */
/datum/camerachunk/proc/update()

	//set background = 1

	var/list/newVisibleTurfs = list()

	var/turf/point = locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z)

	for(var/obj/machinery/camera/camera in cameras)
		if(!camera)
			continue

		if(!camera.can_use())
			continue

		if(get_dist(point, camera) > CHUNK_SIZE + (CHUNK_SIZE / 2))
			continue

		for(var/turf/turf in camera.can_see())
			// Possible optimization: if(turfs[t]) here, rather than &= turfs afterwards.
			// List associations use a tree or hashmap of some sort (alongside the list itself)
			// so are surprisingly fast. (significantly faster than var/thingy/x in list, in testing)
			newVisibleTurfs[turf] = turf

	// Removes turf that isn't in turfs.
	newVisibleTurfs &= turfs

	var/list/visAdded = newVisibleTurfs - visibleTurfs
	var/list/visRemoved = visibleTurfs - newVisibleTurfs

	visibleTurfs = newVisibleTurfs
	obscuredTurfs = turfs - newVisibleTurfs

	for(var/turf in visAdded)
		var/turf/t = turf
		if(t.obscured)
			obscured -= t.obscured
			for(var/eye in seenby)
				var/mob/camera/aiEye/m = eye
				if(!m || !m.ai)
					continue
				if(m.ai.client)
					m.ai.client.images -= t.obscured

	for(var/turf in visRemoved)
		var/turf/t = turf
		if(obscuredTurfs[t])
			if(!t.obscured)
				t.obscured = image('icons/effects/cameravis.dmi', t, "black", 15)

			obscured += t.obscured
			for(var/eye in seenby)
				var/mob/camera/aiEye/m = eye
				if(!m || !m.ai)
					continue
				if(m.ai.client)
					m.ai.client.images += t.obscured

	changed = 0

/*
 * Create a new camera chunk, since the chunks are made as they are needed.
 */
/datum/camerachunk/New(loc, x, y, z)
	. = ..()

	// 0xf = 15
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)

	src.x = x
	src.y = y
	src.z = z

	for(var/obj/machinery/camera/c in range(CHUNK_SIZE, locate(x + (CHUNK_SIZE / 2), y + (CHUNK_SIZE / 2), z)))
		if(c.can_use())
			cameras += c

	for(var/turf/t in block(locate(x, y, z), locate(min(x + CHUNK_SIZE - 1, world.maxx), min(y + CHUNK_SIZE - 1, world.maxy), z)))
		turfs[t] = t

	for(var/obj/machinery/camera/camera in cameras)
		if(!camera)
			continue

		if(!camera.can_use())
			continue

		for(var/turf/t in camera.can_see())
			// Possible optimization: if(turfs[t]) here, rather than &= turfs afterwards.
			// List associations use a tree or hashmap of some sort (alongside the list itself)
			//  so are surprisingly fast. (significantly faster than var/thingy/x in list, in testing)
			visibleTurfs[t] = t

	// Removes turf that isn't in turfs.
	visibleTurfs &= turfs

	obscuredTurfs = turfs - visibleTurfs

	for(var/turf in obscuredTurfs)
		var/turf/t = turf
		if(!t.obscured)
			t.obscured = image('icons/effects/cameravis.dmi', t, "black", 15)
		obscured += t.obscured
