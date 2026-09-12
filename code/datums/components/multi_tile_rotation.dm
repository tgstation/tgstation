/// For objects which rotate with their "actual" loc at their bottom-left corner.
#define MULTI_TILE_ROTATION_NORMAL 1
/// For objects which rotate with their "actual" loc disguised as their center through offsets.
#define MULTI_TILE_ROTATION_CENTRAL 2

// Degrees of rotation associated with the position of our true loc.
// Does not *necessarily* imply the loc is in a corner.
#define LOC_BOTTOMLEFT 0
#define LOC_BOTTOMRIGHT 90
#define LOC_TOPRIGHT 180
#define LOC_TOPLEFT 270

/// Component managing shuttle rotation behavior for multi-tile objects.
///
/// As per DM documentation on `locs`: "The loc var can be thought of as an anchor point. . ."
/// Effectively, shuttles rotate the anchoring point for object icons every time they move. With four
/// possible shuttle directions and four possible rotations of a multi-tile atom's true loc, there are
/// about sixteen or so *theoretical* ways for a multi-tile atom to rotate. In *practice*, rotations of
/// 0 or 360 do not occur, and for every rotation of the anchoring point there is one shuttle rotation
/// which requires no correction. This leads to nine actual possibilities.
/datum/component/multi_tile_rotation
	/// The angle (positive is clockwise) to which our loc has been rotated
	var/loc_rotation = LOC_BOTTOMLEFT
	/// How our parent should rotate
	var/rotation_type = NONE
	// The pixel offsets of our parent upon this components addition.
	// These alone are preserved by the component as the atom's default offsets.
	var/x_offset = 0
	var/y_offset = 0
	var/w_offset = 0
	var/z_offset = 0

/datum/component/multi_tile_rotation/Initialize()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/object_parent = parent
	if(!is_multi_tile_object(object_parent))
		return COMPONENT_INCOMPATIBLE

	if(object_parent.pixel_x || object_parent.pixel_y || object_parent.pixel_w || object_parent.pixel_z)
		rotation_type = MULTI_TILE_ROTATION_CENTRAL
		x_offset = object_parent.pixel_x
		y_offset = object_parent.pixel_y
		w_offset = object_parent.pixel_w
		z_offset = object_parent.pixel_z
	else
		rotation_type = MULTI_TILE_ROTATION_NORMAL

/datum/component/multi_tile_rotation/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_SHUTTLE_ROTATE, PROC_REF(on_shuttle_rotation))

/datum/component/multi_tile_rotation/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_SHUTTLE_ROTATE)

/datum/component/multi_tile_rotation/proc/on_shuttle_rotation(datum/source, rotation, params)
	if(!(params & ROTATE_OFFSET))
		return

	if(rotation < 0)
		rotation += 360

	var/obj/object_parent = parent
	object_parent.pixel_x = x_offset
	object_parent.pixel_y = y_offset
	object_parent.pixel_w = w_offset
	object_parent.pixel_z = z_offset

	// Centrally offset multi-tile objects don't require further correction
	// for reasons which I am not entirely sure of \_( . _ . )_/
	if(rotation_type == MULTI_TILE_ROTATION_CENTRAL)
		finalize_rotation(object_parent, rotation)
		return

	switch(loc_rotation) // Shuttle rotations of 0 or 360 do not occur
		if(LOC_BOTTOMLEFT)
			switch(rotation) // Nonexistant `rotation` of 0 requires no correction
				if(90)
					move_parent_down(object_parent)
				if(180)
					move_parent_down(object_parent)
					move_parent_left(object_parent)
				if(270)
					move_parent_left(object_parent)
		if(LOC_BOTTOMRIGHT)
			switch(rotation) // `rotation` of 270 requires no correction
				if(90)
					move_parent_down(object_parent)
					move_parent_left(object_parent)
				if(180)
					move_parent_left(object_parent)
		if(LOC_TOPRIGHT)
			switch(rotation) // `rotation` of 180 requires no correction
				if(90)
					move_parent_left(object_parent)
				if(270)
					move_parent_down(object_parent)
		if(LOC_TOPLEFT)
			switch(rotation) // `rotation` of 90 requires no correction
				if(180)
					move_parent_down(object_parent)
				if(270)
					move_parent_left(object_parent)
					move_parent_down(object_parent)

	finalize_rotation(object_parent, rotation)

/// Updates our parent's bounds and keeps up with the true loc's rotation.
/datum/component/multi_tile_rotation/proc/finalize_rotation(obj/object_parent, rotation)
	object_parent.bound_y = object_parent.pixel_y
	object_parent.bound_x = object_parent.pixel_x
	loc_rotation += rotation
	loc_rotation %= 360

// The following two procs visually offset our parent by its height/width. Since the anchoring point
// always remains in the area where the object should appear, one respective ICON_SIZE is subtracted.
/datum/component/multi_tile_rotation/proc/move_parent_down(obj/object_parent)
	object_parent.pixel_y -= object_parent.bound_height - ICON_SIZE_Y

/datum/component/multi_tile_rotation/proc/move_parent_left(obj/object_parent)
	object_parent.pixel_x -= object_parent.bound_width - ICON_SIZE_X

#undef MULTI_TILE_ROTATION_NORMAL
#undef MULTI_TILE_ROTATION_CENTRAL

#undef LOC_BOTTOMLEFT
#undef LOC_BOTTOMRIGHT
#undef LOC_TOPRIGHT
#undef LOC_TOPLEFT
