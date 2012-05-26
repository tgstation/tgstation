#define MINIMAP_UPDATE_DELAY 1200

/datum/camerachunk
	var/list/turfs = list()

	var/list/obscuredTurfs = list()
	var/list/visibleTurfs = list()
	var/list/dimTurfs = list()

	var/list/obscured = list()
	var/list/dim = list()

	var/list/cameras = list()
	var/list/seenby = list()

	var/changed = 1
	var/updating = 0
	var/minimap_updating = 0

	var/x
	var/y
	var/z


	var/icon/minimap_icon = new('minimap.dmi', "chunk_base")
	var/obj/minimap_obj/minimap_obj = new()



/datum/camerachunk/New(loc, x, y, z)
	//Round X and Y down to a multiple of 16, if nessecary
	src.x = x & ~0xF
	src.y = y & ~0xF
	src.z = z

	rebuild_chunk()



//  Completely re-calculate the whole chunk.

/datum/camerachunk/proc/rebuild_chunk()
	for(var/mob/aiEye/eye in seenby)
		if(!eye.ai)
			seenby -= eye
			continue

		if(eye.ai.client)
			eye.ai.client.images -= obscured
			eye.ai.client.images -= dim

	var/start = locate(x, y, z)
	var/end = locate(min(x + 15, world.maxx), min(y + 15, world.maxy), z)

	turfs = block(start, end)
	dimTurfs = list()
	visibleTurfs = list()
	obscured = list()
	dim = list()
	cameras = list()

	for(var/obj/machinery/camera/c in range(16, locate(x + 8, y + 8, z)))
		if(c.status)
			cameras += c

	for(var/obj/machinery/camera/c in cameras)
		var/lum = c.luminosity
		c.luminosity = 7

		dimTurfs |= turfs & view(7, c)
		visibleTurfs |= turfs & view(6, c)

		c.luminosity = lum

	obscuredTurfs = turfs - dimTurfs
	dimTurfs -= visibleTurfs

	for(var/turf/t in obscuredTurfs)
		if(!t.obscured)
			t.obscured = image('cameravis.dmi', t, "black", 15)

		obscured += t.obscured

	for(var/turf/t in dimTurfs)
		if(!t.dim)
			t.dim = image('cameravis.dmi', t, "dim", TURF_LAYER)
			t.dim.mouse_opacity = 0

		dim += t.dim

	cameranet.minimap |= minimap_obj

	for(var/mob/aiEye/eye in seenby)
		if(eye.ai.client)
			eye.ai.client.images |= obscured
			eye.ai.client.images |= dim



/datum/camerachunk/proc/add(mob/aiEye/eye)
	eye.visibleCameraChunks |= src

	if(eye.ai.client)
		eye.ai.client.images |= obscured
		eye.ai.client.images |= dim

	seenby |= eye

	if(changed && !updating)
		update()
		changed = 0



/datum/camerachunk/proc/remove(mob/aiEye/eye)
	eye.visibleCameraChunks -= src

	if(eye.ai.client)
		eye.ai.client.images -= obscured
		eye.ai.client.images -= dim

	seenby -= eye

/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!(loc in visibleTurfs))
		return

	hasChanged()

/datum/camerachunk/proc/hasChanged()
	if(length(seenby) > 0)
		if(!updating)
			updating = 1

			spawn(10)//Batch large changes, such as many doors opening or closing at once
				update()
				updating = 0

	else
		changed = 1

	if(!minimap_updating)
		minimap_updating = 1

		spawn(MINIMAP_UPDATE_DELAY)
			if(changed && !updating)
				update()
				changed = 0

			update_minimap()
			minimap_updating = 0

/datum/camerachunk/proc/update()

	var/list/newDimTurfs = list()
	var/list/newVisibleTurfs = list()

	for(var/obj/machinery/camera/c in cameras)
		var/lum = c.luminosity
		c.luminosity = 7

		newDimTurfs |= turfs & view(7, c)
		newVisibleTurfs |= turfs & view(6, c)

		c.luminosity = lum

	var/list/dimAdded = newDimTurfs - dimTurfs
	var/list/dimRemoved = dimTurfs - newDimTurfs
	var/list/visAdded = newVisibleTurfs - visibleTurfs
	var/list/visRemoved = visibleTurfs - newVisibleTurfs

	visibleTurfs = newVisibleTurfs
	dimTurfs = newDimTurfs
	obscuredTurfs = turfs - dimTurfs
	dimTurfs -= visibleTurfs

	var/list/images_added = list()
	var/list/images_removed = list()

	for(var/turf/t in dimRemoved)
		if(t.dim)
			dim -= t.dim
			images_removed += t.dim

		if(!(t in visibleTurfs))
			if(!t.obscured)
				t.obscured = image('cameravis.dmi', t, "black", 15)

			obscured += t.obscured
			images_added += t.obscured

	for(var/turf/t in dimAdded)
		if(!(t in visibleTurfs))
			if(!t.dim)
				t.dim = image('cameravis.dmi', t, "dim", 15)
				t.mouse_opacity = 0

			dim += t.dim
			images_added += t.dim

			if(t.obscured)
				obscured -= t.obscured
				images_removed += t.obscured

	for(var/turf/t in visAdded)
		if(t.obscured)
			obscured -= t.obscured
			images_removed += t.obscured

	for(var/turf/t in visRemoved)
		if(t in obscuredTurfs)
			if(!t.obscured)
				t.obscured = image('cameravis.dmi', t, "black", 15)

			obscured += t.obscured
			images_added += t.obscured

	for(var/mob/aiEye/eye in seenby)
		if(eye.ai.client)
			eye.ai.client.images -= images_removed
			eye.ai.client.images |= images_added
