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
/// Effectively, shuttles rotate the anchoring point for their pixel offsets every time they move.
/// This leads to about sixteen or so *theoretical* ways for a multi-tile object to rotate. In *practice*,
/// rotations of 0 or 360 do not occur and for every rotation of the anchoring point there is one rotation
/// which requires no correction. This leads to nine actual possibilities.
/datum/component/multi_tile_rotation
	/// The angle (positive is clockwise) to which our loc has been rotated.
	var/loc_rotation = LOC_BOTTOMLEFT
	/// How our parent should rotate
	var/rotation_type = NONE
	// The pixel offsets of our parent upon this components addition
	var/x_offset = 0
	var/y_offset = 0
	var/w_offset = 0
	var/z_offset = 0
	// Bound offsets upon this component's addition
	var/x_bound_offset = 0
	var/y_bound_offset = 0

// In general this component should be added with
// `AddComponent(/datum/component/multi_tile_rotation, pixel_x, pixel_y, pixel_w, pixel_z)`
/datum/component/multi_tile_rotation/Initialize(base_x_offset, base_y_offset, base_w_offset, base_z_offset)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	// if(parent.bound_x != 0 || parent.bound_y != 0)
	// 	return COMPONENT_INCOMPATIBLE

	if(base_x_offset || base_y_offset || base_w_offset || base_z_offset)
		rotation_type = MULTI_TILE_ROTATION_CENTRAL
		x_offset = base_x_offset
		y_offset = base_y_offset
		w_offset = base_w_offset
		z_offset = base_z_offset
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

	switch(loc_rotation) // `rotation` of 0 or 360 does not occur
		if(LOC_BOTTOMLEFT)
			switch(rotation) // Nonexistant `rotation` of 0 requires no correction
				if(90)
					object_parent.pixel_y -= (object_parent.bound_height - ICON_SIZE_Y)
				if(180)
					object_parent.pixel_y -= (object_parent.bound_height - ICON_SIZE_Y)
					object_parent.pixel_x -= (object_parent.bound_width - ICON_SIZE_X)
				if(270)
					object_parent.pixel_x -= (object_parent.bound_width - ICON_SIZE_X)
		if(LOC_BOTTOMRIGHT)
			switch(rotation) // `rotation` of 270 requires no correction
				if(90)
					object_parent.pixel_y -= (object_parent.bound_height - ICON_SIZE_Y)
					object_parent.pixel_x -= (object_parent.bound_width - ICON_SIZE_X)
				if(180)
					object_parent.pixel_x -= (object_parent.bound_width - ICON_SIZE_X)
		if(LOC_TOPRIGHT)
			switch(rotation) // `rotation` of 180 requires no correction
				if(90)
					object_parent.pixel_x -= (object_parent.bound_height - ICON_SIZE_Y)
				if(270)
					object_parent.pixel_y -= (object_parent.bound_height - ICON_SIZE_Y)
		if(LOC_TOPLEFT)
			switch(rotation) // `rotation` of 90 requires no correction
				if(180)
					object_parent.pixel_y -= (object_parent.bound_height - ICON_SIZE_Y)
				if(270)
					object_parent.pixel_x -= (object_parent.bound_width - ICON_SIZE_X)
					object_parent.pixel_y -= (object_parent.bound_height - ICON_SIZE_Y)

	object_parent.bound_y = object_parent.pixel_y
	object_parent.bound_x = object_parent.pixel_x
	// DEBUG ONLY. SHOULD UNDER NO CIRCUMSTANCES BE INCLUDED IN FINAL, POST-DRAFT PR
	send_to_playing_players("[object_parent.name] rotated with `loc_rotation` of [loc_rotation] and rotation of [rotation]")
	loc_rotation += rotation
	loc_rotation %= 360

#undef MULTI_TILE_ROTATION_NORMAL
#undef MULTI_TILE_ROTATION_CENTRAL

#undef LOC_BOTTOMLEFT
#undef LOC_BOTTOMRIGHT
#undef LOC_TOPRIGHT
#undef LOC_TOPLEFT
