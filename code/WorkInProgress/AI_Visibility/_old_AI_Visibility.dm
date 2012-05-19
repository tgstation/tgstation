//All credit for this goes to Uristqwerty.

//And some to me! -Mini



//This file is partly designed around being able to uninclude it to go back to the old ai viewing system completely.
//(And therefore also be portable to another similar codebase simply by transferring the file and including it after the other AI code files.)
//There are probably a few parts that don't do that at the moment, but I'll fix them at some point.


#define MINIMAP_UPDATE_DELAY 1200

/turf
	var/image/obscured
	var/image/dim

/turf/proc/visibilityChanged()
	cameranet.updateVisibility(src)

/turf/New()
	..()
	cameranet.updateVisibility(src)
/*
/turf/Del()
	..()
	cameranet.updateVisibility(src)
*/
/datum/camerachunk
	var/list/obscuredTurfs = list()
	var/list/visibleTurfs = list()
	var/list/dimTurfs = list()
	var/list/obscured = list()
	var/list/dim = list()
	var/list/cameras = list()
	var/list/turfs = list()
	var/list/seenby = list()
	var/visible = 0
	var/changed = 1
	var/updating = 0

	var/x
	var/y
	var/z

	var/minimap_updating = 0

	var/icon/minimap_icon = new('minimap.dmi', "chunk_base")
	var/obj/minimap_obj/minimap_obj = new()

/obj/minimap_obj/Click(location, control, params)
	if(!istype(usr, /mob/dead) && !istype(usr, /mob/living/silicon/ai) && !(usr.client && usr.client.holder && usr.client.holder.level >= 4))
		return

	var/list/par = params2list(params)
	var/screen_loc = par["screen-loc"]

	if(findtext(screen_loc, "minimap:") != 1)
		return

	screen_loc = copytext(screen_loc, length("minimap:") + 1)

	var/x_text = copytext(screen_loc, 1, findtext(screen_loc, ","))
	var/y_text = copytext(screen_loc, findtext(screen_loc, ",") + 1)

	var/x = (text2num(copytext(x_text, 1, findtext(x_text, ":"))) - 1) * 16
	x += round((text2num(copytext(x_text, findtext(x_text, ":") + 1)) + 1) / 2)

	var/y = (text2num(copytext(y_text, 1, findtext(y_text, ":"))) - 1) * 16
	y += round((text2num(copytext(y_text, findtext(y_text, ":") + 1)) + 1) / 2)

	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = usr
		ai.freelook()
		ai.eyeobj.loc = locate(max(1, x - 1), max(1, y - 1), ai.eyeobj.z)
		cameranet.visibility(ai.eyeobj)

	else
		usr.loc = locate(max(1, x - 1), max(1, y - 1), usr.z)

/mob/dead/verb/Open_Minimap()
	set category = "Ghost"
	winshow(src, "minimapwindow", 1)
	client.screen |= cameranet.minimap

	if(cameranet.generating_minimap)
		cameranet.minimap_viewers += src

/mob/living/silicon/ai/verb/Open_Minimap()
	set category = "AI Commands"
	winshow(src, "minimapwindow", 1)
	client.screen |= cameranet.minimap

	if(cameranet.generating_minimap)
		cameranet.minimap_viewers += src

/client/proc/Open_Minimap()
	set category = "Admin"
	winshow(src, "minimapwindow", 1)
	screen |= cameranet.minimap

	if(cameranet.generating_minimap)
		cameranet.minimap_viewers += src.mob

/datum/camerachunk/proc/update_minimap()
	if(changed && !updating)
		update()

	minimap_icon.Blend(rgb(255, 0, 0), ICON_MULTIPLY)

	var/list/turfs = visibleTurfs | dimTurfs

	for(var/turf/turf in turfs)
		var/x = (turf.x & 0xf) * 2
		var/y = (turf.y & 0xf) * 2

		if(turf.density)
			minimap_icon.DrawBox(rgb(100, 100, 100), x + 1, y + 1, x + 2, y + 2)
			continue

		else if(istype(turf, /turf/space))
			minimap_icon.DrawBox(rgb(0, 0, 0), x + 1, y + 1, x + 2, y + 2)

		else
			minimap_icon.DrawBox(rgb(200, 200, 200), x + 1, y + 1, x + 2, y + 2)

		for(var/obj/structure/o in turf)
			if(o.density)
				if(istype(o, /obj/structure/window) && (o.dir == NORTH || o.dir == SOUTH || o.dir == EAST || o.dir == WEST))
					if(o.dir == NORTH)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 1, y + 2, x + 2, y + 2)
					else if(o.dir == SOUTH)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 1, y + 1, x + 2, y + 1)
					else if(o.dir == EAST)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 3, y + 1, x + 2, y + 2)
					else if(o.dir == WEST)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 1, y + 1, x + 1, y + 2)

				else
					minimap_icon.DrawBox(rgb(150, 150, 150), x + 1, y + 1, x + 2, y + 2)
					break

		for(var/obj/machinery/door/o in turf)
			if(istype(o, /obj/machinery/door/window))
				if(o.dir == NORTH)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 2, x + 2, y + 2)
				else if(o.dir == SOUTH)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 1, x + 2, y + 1)
				else if(o.dir == EAST)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 2, y + 1, x + 2, y + 2)
				else if(o.dir == WEST)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 1, x + 1, y + 2)

			else
				minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 1, x + 2, y + 2)
				break

	minimap_obj.screen_loc = "minimap:[src.x / 16],[src.y / 16]"
	minimap_obj.icon = minimap_icon

/mob/aiEye
	var/list/visibleCameraChunks = list()
	var/mob/ai = null
	density = 0

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

var/datum/cameranet/cameranet = new()

/datum/cameranet
	var/list/cameras = list()
	var/list/chunks = list()
	var/network = "net1"
	var/ready = 0

	var/list/minimap = list()

	var/generating_minimap = TRUE
	var/list/minimap_viewers = list()

/datum/cameranet/New()
	..()

	spawn(200)
		for(var/x = 0, x <= world.maxx, x += 16)
			for(var/y = 0, y <= world.maxy, y += 16)
				sleep(1)
				var/datum/camerachunk/c = getCameraChunk(x, y, 1)
				c.update_minimap()

				for(var/mob/m in minimap_viewers)
					m.client.screen |= c.minimap_obj

		generating_minimap = FALSE
		minimap_viewers = list()

/datum/cameranet/proc/chunkGenerated(x, y, z)
	var/key = "[x],[y],[z]"
	return key in chunks

/datum/cameranet/proc/getCameraChunk(x, y, z)
	var/key = "[x],[y],[z]"

	if(!(key in chunks))
		chunks[key] = new /datum/camerachunk(null, x, y, z)

	return chunks[key]

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

/datum/cameranet/proc/updateVisibility(turf/loc)
	if(!chunkGenerated(loc.x & ~0xf, loc.y & ~0xf, loc.z))
		return

	var/datum/camerachunk/chunk = getCameraChunk(loc.x & ~0xf, loc.y & ~0xf, loc.z)
	chunk.visibilityChanged(loc)

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

/mob/living/silicon/ai/var/mob/aiEye/eyeobj = new()

/mob/living/silicon/ai/New()
	..()
	eyeobj.ai = src
	spawn(20)
		freelook()

/mob/living/silicon/ai/death(gibbed)
	if(client && client.eye == eyeobj)
		for(var/datum/camerachunk/c in eyeobj.visibleCameraChunks)
			c.remove(eyeobj)
		client.eye = src
	return ..(gibbed)

/mob/living/silicon/ai/verb/freelook()
	set category = "AI Commands"
	set name = "freelook"
	current = null	//cancel camera view first, it causes problems
	cameraFollow = null
//	machine = null
	if(!eyeobj)	//if it got deleted somehow (like an admin trying to fix things <.<')
		eyeobj = new()
		eyeobj.ai = src
	client.eye = eyeobj
	eyeobj.loc = loc
	cameranet.visibility(eyeobj)
	cameraFollow = null

/mob/aiEye/Move()
	. = ..()
	if(.)
		cameranet.visibility(src)

/client/AIMove(n, direct, var/mob/living/silicon/ai/user)
	if(eye == user.eyeobj)
		user.eyeobj.loc = get_step(user.eyeobj, direct)
		cameranet.visibility(user.eyeobj)

	else
		return ..()

/*
/client/AIMoveZ(direct, var/mob/living/silicon/ai/user)
	if(eye == user.eyeobj)
		var/dif = 0
		if(direct == UP && user.eyeobj.z > 1)
			dif = -1
		else if(direct == DOWN && user.eyeobj.z < 4)
			dif = 1
		user.eyeobj.loc = locate(user.eyeobj.x, user.eyeobj.y, user.eyeobj.z + dif)
		cameranet.visibility(user.eyeobj)
	else
		return ..()
*/

/turf/move_camera_by_click()
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.client.eye == AI.eyeobj)
			return
	return ..()


/obj/machinery/door/update_nearby_tiles(need_rebuild)
	. = ..(need_rebuild)
	cameranet.updateVisibility(loc)

/obj/machinery/camera/New()
	..()
	cameranet.addCamera(src)

/obj/machinery/camera/Del()
	cameranet.removeCamera(src)
	..()

/obj/machinery/camera/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	. = ..(W, user)
	if(istype(W, /obj/item/weapon/wirecutters))
		if(status)
			cameranet.addCamera(src)
		else
			cameranet.removeCamera(src)

/proc/checkcameravis(atom/A)
	for(var/obj/machinery/camera/C in view(A,7))
		if(!C.status || C.stat == 2)
			continue
		return 1
	return 0

/mob/living/silicon/ai/attack_ai(var/mob/user as mob)
	if (user != src)
		return

	if (stat == 2)
		return

	var/list/L = list()
	for (var/obj/machinery/camera/C in world)
		L.Add(C)

	camera_sort(L)
	L = camera_network_sort(L)

	var/list/D = list()
	for (var/obj/machinery/camera/C in L)
		if ( C.network in src.networks )
			D[text("[]: [][]", C.network, C.c_tag, (C.status ? null : " (Deactivated)"))] = C
	D["Cancel"] = "Cancel"

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if (!t || t == "Cancel")
		return 0

	var/obj/machinery/camera/C = D[t]

	eyeobj.loc = C.loc
	cameranet.visibility(eyeobj)

	return

/mob/living/silicon/ai/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	machine = null

/mob/living/silicon/ai/reset_view(atom/A)
	if (client)
		if(!eyeobj)
			eyeobj = new()
			eyeobj.ai = src

		client.eye = eyeobj
		client.perspective = EYE_PERSPECTIVE

		if (istype(A, /atom/movable))
			eyeobj.loc = locate(A.x, A.y, A.z)

		else
			eyeobj.loc = locate(src.x, src.y, src.z)

		cameranet.visibility(eyeobj)
