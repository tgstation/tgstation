/image/photo
	var/_step_x = 0
	var/_step_y = 0

/image/photo/New(location, atom/A)			//Intentionally not Initialize(), to make sure the clone assumes the intended appearance in time for the camera getFlatIcon.
	if(istype(A))
		loc = location
		appearance = A.appearance
		dir = A.dir
		if(ismovableatom(A))
			var/atom/movable/AM = A
			_step_x = AM.step_x
			_step_y = AM.step_y
	. = ..()

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	var/list/images = list()
	var/skip_normal = FALSE
	var/wipe_images = FALSE

	if(istype(clone_area) && total_x == clone_area.width && total_y == clone_area.height && size_x >= 0 && size_y > 0)
		var/cloned_center_x = round(clone_area.bottom_left_coords[1] + ((total_x - 1) / 2))
		var/cloned_center_y = round(clone_area.bottom_left_coords[2] + ((total_y - 1) / 2))
		for(var/t in turfs)
			var/turf/T = t
			var/offset_x = T.x - center.x
			var/offset_y = T.y - center.y
			var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, clone_area.bottom_left_coords[3])
			if(!(newT in clone_area.reserved_turfs))		//sanity check so we don't overwrite other areas somehow
				continue
			images += new /image/photo(newT, T)
			if(T.loc.icon_state)
				images += new /image/photo(newT, T.loc)
			for(var/i in T.contents)
				var/atom/A = i
				if(!A.invisibility || (see_ghosts && isobserver(A)))
					images += new /image/photo(newT, A)
		skip_normal = TRUE
		wipe_images = TRUE
		center = locate(cloned_center_x, cloned_center_y, clone_area.bottom_left_coords[3])

	if(!skip_normal)
		for(var/i in turfs)
			var/turf/T = i
			images += new /image/photo(T.loc, T)
			for(var/atom/movable/A in T)
				if(A.invisibility)
					if(!(see_ghosts && isobserver(A)))
						continue
				images += new /image/photo(A.loc, A)
			CHECK_TICK

	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(psize_x, psize_y)

	var/list/sorted = list()
	var/j
	for(var/i in 1 to images.len)
		var/image/c = images[i]
		for(j = sorted.len, j > 0, --j)
			var/image/c2 = sorted[j]
			if(c2.layer <= c.layer)
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/xcomp = FLOOR(psize_x / 2, 1) - 15
	var/ycomp = FLOOR(psize_y / 2, 1) - 15


	for(var/Adummy in sorted)
		var/image/photo/A = Adummy
		var/xo = (A.x - center.x) * world.icon_size + A.pixel_x + xcomp + A._step_x
		var/yo = (A.y - center.y) * world.icon_size + A.pixel_y + ycomp + A._step_y
		var/icon/img = getFlatIcon(A)
		if(img)
			res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
		CHECK_TICK

	if(!silent)
		if(istype(custom_sound))				//This is where the camera actually finishes its exposure.
			playsound(loc, custom_sound, 75, 1, -3)
		else
			playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	if(wipe_images)
		QDEL_LIST(images)

	return res
