
/datum/camerachunk
	var/list/turfs = list()

	var/list/obscuredTurfs = list()
	var/list/visibleTurfs = list()
	var/list/dimTurfs = list()

	var/list/obscured = list()
	var/list/dim = list()

	var/list/cameras = list()
	var/list/seenby = list()

	var/visible = 0
	var/changed = 1
	var/updating = 0
	var/minimap_updating = 0

	var/x
	var/y
	var/z


	var/icon/minimap_icon = new('minimap.dmi', "chunk_base")
	var/obj/minimap_obj/minimap_obj = new()

/datum/camerachunk/proc/add(mob/aiEye/ai)
	ai.visibleCameraChunks += src
	if(ai.ai.client)
		ai.ai.client.images += obscured
		ai.ai.client.images += dim
	visible++
	seenby += ai
	if(changed && !updating)
		update()
		changed = 0

/datum/camerachunk/proc/remove(mob/aiEye/ai)
	ai.visibleCameraChunks -= src
	if(ai.ai.client)
		ai.ai.client.images -= obscured
		ai.ai.client.images -= dim
	seenby -= ai
	if(visible > 0)
		visible--

/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!(loc in visibleTurfs))
		return

	hasChanged()

/datum/camerachunk/proc/hasChanged()
	if(visible)
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

	for(var/turf/t in dimRemoved)
		if(t.dim)
			dim -= t.dim
			for(var/mob/aiEye/m in seenby)
				if(m.ai.client)
					m.ai.client.images -= t.dim

		if(!(t in visibleTurfs))
			if(!t.obscured)
				t.obscured = image('cameravis.dmi', t, "black", 15)

			obscured += t.obscured
			for(var/mob/aiEye/m in seenby)
				if(m.ai.client)
					m.ai.client.images += t.obscured

	for(var/turf/t in dimAdded)
		if(!(t in visibleTurfs))
			if(!t.dim)
				t.dim = image('cameravis.dmi', t, "dim", 15)
				t.mouse_opacity = 0

			dim += t.dim
			for(var/mob/aiEye/m in seenby)
				if(m.ai.client)
					m.ai.client.images += t.dim

			if(t.obscured)
				obscured -= t.obscured
				for(var/mob/aiEye/m in seenby)
					if(m.ai.client)
						m.ai.client.images -= t.obscured

	for(var/turf/t in visAdded)
		if(t.obscured)
			obscured -= t.obscured
			for(var/mob/aiEye/m in seenby)
				if(m.ai.client)
					m.ai.client.images -= t.obscured

	for(var/turf/t in visRemoved)
		if(t in obscuredTurfs)
			if(!t.obscured)
				t.obscured = image('cameravis.dmi', t, "black", 15)

			obscured += t.obscured
			for(var/mob/aiEye/m in seenby)
				if(m.ai.client)
					m.ai.client.images += t.obscured


/datum/camerachunk/New(loc, x, y, z)
	x &= ~0xf
	y &= ~0xf

	src.x = x
	src.y = y
	src.z = z

	for(var/obj/machinery/camera/c in range(16, locate(x + 8, y + 8, z)))
		if(c.status)
			cameras += c

	turfs = block(locate(x, y, z), locate(min(world.maxx, x + 15), min(world.maxy, y + 15), z))

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
		if(!(t in visibleTurfs))
			if(!t.dim)
				t.dim = image('cameravis.dmi', t, "dim", TURF_LAYER)
				t.dim.mouse_opacity = 0

			dim += t.dim

	cameranet.minimap += minimap_obj
