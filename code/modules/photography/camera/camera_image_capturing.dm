/obj/effect/appearance_clone

/obj/effect/appearance_clone/New(loc, atom/A)			//Intentionally not Initialize().
	. = ..()
	appearance = A.appearance

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	var/list/atoms = list()
	var/list/atoms_replaced
	if(istype(clone_area) && total_x == clone_area.width && total_y == clone_area.height)
		var/list/newturfs = list()
		atoms_replaced = list()
		for(var/t in turfs)
			var/turf/T = t
			var/offset_x = T.x - center.x + size_x
			var/offset_y = T.y - center.y + size_y
			var/turf/newT = locate(clone_area.bottom_left_coords[1] + offset_x, clone_area.bottom_left_coords[2] + offset_y, clone_area.bottom_left_coords[3])
			newturfs[newT] = TRUE
			newT.appearance = T.appearance
			for(var/i in T)
				var/atom/A = i
				atoms_replaced += new /obj/effect/appearance_clone(newT, A)
		turfs = newturfs

	for(var/i in turfs)
		var/turf/T = i
		atoms[T] = TRUE
		for(var/atom/movable/A in T)
			if(A.invisibility)
				if(!(see_ghosts && isobserver(A)))
					continue
			atoms[A] = TRUE
		CHECK_TICK

	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(psize_x, psize_y)

	var/list/sorted = list()
	var/j
	for(var/i = 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.layer <= c.layer)
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/xcomp = FLOOR(psize_x / 2, 1) - 15
	var/ycomp = FLOOR(psize_y / 2, 1) - 15
	for(var/atom/A in sorted)
		var/xo = (A.x - center.x) * world.icon_size + A.pixel_x + xcomp
		var/yo = (A.y - center.y) * world.icon_size + A.pixel_y + ycomp
		if(ismovableatom(A))
			var/atom/movable/AM = A
			xo += AM.step_x
			yo += AM.step_y
		var/icon/img = getFlatIcon(A)
		res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
		CHECK_TICK

	if(istype(custom_sound))				//This is where the camera actually finishes its exposure.
		playsound(loc, custom_sound, 75, 1, -3)
	else
		playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	if(atoms_replaced)
		QDEL_LIST(atoms_replaced)

	return res

/proc/camera_photoclone()
