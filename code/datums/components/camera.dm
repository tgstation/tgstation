/datum/component/camera

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

/datum/component/camera/proc/camera_get_icon(list/turfs, turf/center, datum/turf_reservation/clone_area, see_ghosts, print_monochrome = FALSE)
	var/list/atoms = list()
	var/list/lighting = list()
	var/skip_normal = FALSE
	var/wipe_atoms = FALSE

	var/mutable_appearance/backdrop = mutable_appearance('icons/hud/screen_gen.dmi', "flash")
	backdrop.blend_mode = BLEND_OVERLAY
	backdrop.color = "#292319"

	var/turf/bottom_left = clone_area.bottom_left_turfs[1]
	var/cloned_center_x = round(bottom_left.x + ((clone_area.width - 1) / 2))
	var/cloned_center_y = round(bottom_left.y + ((clone_area.height - 1) / 2))
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
			lighting_overlay.appearance = T.lighting_object.appearance
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
				lighting_overlay.appearance = T.lighting_object.appearance
				lighting_overlay.underlays += backdrop
				lighting_overlay.blend_mode = BLEND_MULTIPLY
				lighting += lighting_overlay
			for(var/atom/movable/A in T)
				if(A.invisibility)
					if(!(see_ghosts && (isobserver(A) || HAS_TRAIT(A, TRAIT_INVISIBLE_TO_CAMERA))))
						continue
				atoms += A
			CHECK_TICK

	var/psize_x = clone_area.width * ICON_SIZE_X
	var/psize_y = clone_area.height * ICON_SIZE_Y
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
					xo -= base_w * (decompose.scale_x - sign(decompose.scale_x)) / 2 * sign(decompose.scale_x)
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

	if(print_monochrome)
		res.GrayScale()

	return res

/**
 * Data for photography
*/
/datum/photo_snapshot
	var/list/turfs = list()
	var/list/mobs = list()
	var/blueprints = FALSE

/**
 * Builds a snapshot of all turfs and mobs that should appear in the photo
 *
 * Arguments
 *
 * * turf/target_turf - the turf where the picture was taken
 * * turf/viewer - the turf from which the picture is viewed
 * * view_range - the range within which to look for turfs and mobs
 * * mob/user - the user who took the picture
 * * size_x, size_y - the size of the picture area
 * * width, height - the dimensions of the photo
*/
/datum/component/camera/proc/get_photo_snapshot(turf/target_turf, turf/viewer, view_range, mob/user, size_x, size_y, width, height)
	var/list/seen = get_hear_turfs(view_range, viewer)
	var/datum/photo_snapshot/snapshot = new

	var/cameranet_user = isAI(user) || istype(viewer, /mob/eye/camera)
	for(var/turf/seen_placeholder as anything in CORNER_BLOCK_OFFSET(target_turf, width, height, -size_x, -size_y))
		if(isnull(seen_placeholder))
			continue
		if(cameranet_user && !SScameras.is_visible_by_cameras(seen_placeholder))
			continue
		if(!cameranet_user && !(seen_placeholder in seen))
			continue

		//Multi-z photography
		var/turf/target_placeholder = seen_placeholder
		while(!isnull(target_placeholder))
			snapshot.turfs += target_placeholder
			for(var/mob/mob_there in target_placeholder)
				snapshot.mobs += mob_there
			if(locate(/obj/item/blueprints) in target_placeholder)
				snapshot.blueprints = TRUE

			if(isopenspaceturf(target_placeholder) || istype(target_placeholder, /turf/open/floor/glass))
				target_placeholder = GET_TURF_BELOW(target_placeholder)
			else
				break

	return snapshot

/**
 * Renders a picture from a previously built photo snapshot
 *
 * Arguments
 *
 * * turf/target_turf - the turf where the picture was taken
 * * width, height - the dimensions of the photo
 * * see_ghosts - whether the photo should show ghosts or not
 * * datum/photo_snapshot/snapshot - the data to render the photo from
*/
/datum/component/camera/proc/render_photo_snapshot(turf/target_turf, width, height, name, see_ghosts, print_monochrome, datum/photo_snapshot/snapshot)
	if(isnull(snapshot))
		return null

	var/list/mobs_spotted = list()
	var/list/dead_spotted = list()
	var/list/turfs = snapshot.turfs
	var/list/mobs = snapshot.mobs
	var/blueprints = snapshot.blueprints

	///list of human names taken on picture
	var/list/names = list()
	var/datum/turf_reservation/clone_area = SSmapping.request_turf_block_reservation(width, height, 1)

	if(isnull(clone_area))
		return null

	var/list/desc = list("This is a photo of an area of [width] meters by [height] meters.")
	for(var/mob/mob as anything in mobs)
		mobs_spotted += mob
		if(mob.stat == DEAD)
			dead_spotted += mob
		var/info = mob.get_photo_description(see_ghosts)
		if(!isnull(info))
			desc += info

	var/icon/get_icon = camera_get_icon(turfs, target_turf, clone_area, see_ghosts, print_monochrome)
	get_icon.Blend("#000", ICON_UNDERLAY)
	qdel(clone_area)
	for(var/mob/living/carbon/human/person in mobs)
		if(person.obscured_slots & HIDEFACE)
			continue
		names += "[person.name]"

	var/datum/picture/picture = new(
		name,
		desc.Join("<br>"),
		mobs_spotted,
		dead_spotted,
		names,
		get_icon,
		null,
		width * ICON_SIZE_X,
		height * ICON_SIZE_Y,
		blueprints,
		can_see_ghosts = see_ghosts
		)
	qdel(snapshot)
	return picture

/**
 * Captures a photo without access to snapshot data
 *
 * Arguments
 *
 * * turf/target_turf - the turf where the picture was taken
 * * turf/viewer - the turf from which the picture is viewed
 * * view_range - the range within which to look for turfs and mobs
 * * mob/user - the user who took the picture
 * * size_x, size_y - the size of the picture area
 * * width, height - the dimensions of the photo
 * * see_ghosts - whether the photo should show ghosts or not
 * * datum/photo_snapshot/snapshot - the data to render the photo from
*/
/datum/component/camera/proc/capture_photo(turf/target_turf, turf/viewer, view_range, mob/user, size_x, size_y, width, height, name, see_ghosts, print_monochrome)
	var/datum/photo_snapshot/snapshot = get_photo_snapshot(target_turf, viewer, view_range, user, size_x, size_y, width, height)
	return render_photo_snapshot(target_turf, width, height, name, see_ghosts, print_monochrome, snapshot)

#undef PHYSICAL_POSITION
