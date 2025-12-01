/obj/effect/appearance_clone

/obj/effect/appearance_clone/New(loc, atom/our_atom) //Intentionally not Initialize(), to make sure the clone assumes the intended appearance in time for the camera getFlatIcon.
	if(!istype(our_atom))
		return ..()
	if(!isopenspaceturf(our_atom))
		appearance = our_atom.appearance
	dir = our_atom.dir
	if(ismovable(our_atom))
		var/atom/movable/our_movable = our_atom
		step_x = our_movable.step_x
		step_y = our_movable.step_y
	return ..()

#define PHYSICAL_POSITION(atom) ((atom.y * ICON_SIZE_Y) + (atom.pixel_y))

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	var/list/atoms = list()
	var/list/lighting = list()
	var/skip_normal = FALSE
	var/wipe_atoms = FALSE

	var/mutable_appearance/backdrop = mutable_appearance('icons/hud/screen_gen.dmi', "flash")
	backdrop.blend_mode = BLEND_OVERLAY
	backdrop.color = "#292319"

	if(istype(clone_area) && total_x == clone_area.width && total_y == clone_area.height && size_x >= 0 && size_y > 0)
		var/turf/bottom_left = clone_area.bottom_left_turfs[1]
		var/cloned_center_x = round(bottom_left.x + ((total_x - 1) / 2))
		var/cloned_center_y = round(bottom_left.y + ((total_y - 1) / 2))
		for(var/t in turfs)
			var/turf/T = t
			var/offset_x = T.x - center.x
			var/offset_y = T.y - center.y
			var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, bottom_left.z)
			if(!(newT in clone_area.reserved_turfs)) //sanity check so we don't overwrite other areas somehow
				continue
			atoms += new /obj/effect/appearance_clone(newT, T)
			if(T.loc.icon_state)
				atoms += new /obj/effect/appearance_clone(newT, T.loc)
			if(T.lighting_object)
				var/obj/effect/appearance_clone/lighting_overlay = new(newT)
				lighting_overlay.appearance = T.lighting_object.current_underlay
				lighting_overlay.underlays += backdrop
				lighting_overlay.blend_mode = BLEND_MULTIPLY
				lighting += lighting_overlay
			for(var/atom/found_atom as anything in T.contents)
				if(HAS_TRAIT(found_atom, TRAIT_INVISIBLE_TO_CAMERA))
					if(see_ghosts)
						atoms += new /obj/effect/appearance_clone(newT, found_atom)
				else if(!found_atom.invisibility || (see_ghosts && isobserver(found_atom)))
					atoms += new /obj/effect/appearance_clone(newT, found_atom)
		skip_normal = TRUE
		wipe_atoms = TRUE
		center = locate(cloned_center_x, cloned_center_y, bottom_left.z)

	if(!skip_normal)
		for(var/i in turfs)
			var/turf/T = i
			atoms += T
			if(T.lighting_object)
				var/obj/effect/appearance_clone/lighting_overlay = new(T)
				lighting_overlay.appearance = T.lighting_object.current_underlay
				lighting_overlay.underlays += backdrop
				lighting_overlay.blend_mode = BLEND_MULTIPLY
				lighting += lighting_overlay
			for(var/atom/movable/A in T)
				if(A.invisibility)
					if(!(see_ghosts && (isobserver(A) || HAS_TRAIT(A, TRAIT_INVISIBLE_TO_CAMERA))))
						continue
				atoms += A
			CHECK_TICK

	var/icon/res = icon('icons/blanks/96x96.dmi', "nothing")
	res.Scale(psize_x, psize_y)
	atoms += lighting

	var/list/sorted = list()
	var/j
	for(var/i in 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.plane > c.plane)
				continue
			if(c2.plane < c.plane)
				break
			var/c_position = PHYSICAL_POSITION(c)
			var/c2_position = PHYSICAL_POSITION(c2)
			// If you are above me, I layer above you
			if(c2_position - 32 >= c_position)
				break
			// If I am above you you will always layer above me
			if(c2_position <= c_position - 32)
				continue
			if(c2.layer < c.layer)
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/xcomp = FLOOR(psize_x / 2, 1) - 15
	var/ycomp = FLOOR(psize_y / 2, 1) - 15

	if(!skip_normal) //these are not clones
		for(var/atom/A in sorted)
			var/xo = (A.x - center.x) * ICON_SIZE_X + A.pixel_x + xcomp
			var/yo = (A.y - center.y) * ICON_SIZE_Y + A.pixel_y + ycomp
			if(ismovable(A))
				var/atom/movable/AM = A
				xo += AM.step_x
				yo += AM.step_y
			var/icon/img = getFlatIcon(A, no_anim = TRUE)
			res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
			CHECK_TICK
	else
		for(var/X in sorted) //these are clones
			var/obj/effect/appearance_clone/clone = X
			var/icon/img = getFlatIcon(clone, no_anim = TRUE)
			if(!img)
				CHECK_TICK
				continue
			// Center of the image in X
			var/xo = (clone.x - center.x) * ICON_SIZE_X + clone.pixel_x + xcomp + clone.step_x
			// Center of the image in Y
			var/yo = (clone.y - center.y) * ICON_SIZE_Y + clone.pixel_y + ycomp + clone.step_y

			if(clone.transform) // getFlatIcon doesn't give a snot about transforms.
				var/datum/decompose_matrix/decompose = clone.transform.decompose()
				// Scale in X, Y
				if(decompose.scale_x != 1 || decompose.scale_y != 1)
					var/base_w = img.Width()
					var/base_h = img.Height()
					// scale_x can be negative
					img.Scale(base_w * abs(decompose.scale_x), base_h * decompose.scale_y)
					if(decompose.scale_x < 0)
						img.Flip(EAST)
					xo -= base_w * (decompose.scale_x - SIGN(decompose.scale_x)) / 2 * SIGN(decompose.scale_x)
					yo -= base_h * (decompose.scale_y - 1) / 2
				// Rotation
				if(decompose.rotation != 0)
					img.Turn(decompose.rotation)
				// Shift
				xo += decompose.shift_x
				yo += decompose.shift_y

			res.Blend(img, blendMode2iconMode(clone.blend_mode), xo, yo)
			CHECK_TICK

	if(wipe_atoms)
		QDEL_LIST(atoms)
	else
		QDEL_LIST(lighting)

	return res

#undef PHYSICAL_POSITION
