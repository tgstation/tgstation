//NORTH default dir
/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/effects/docking_ports.dmi'
	icon_state = "static"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	///Common standard is for this to point -away- from the dockingport door, ie towards the ship
	dir = NORTH
	/// The identifier of the port or ship.
	/// This will be used in numerous other places like the console,
	/// stationary ports and whatnot to tell them your ship's mobile
	/// port can be used in these places, or the docking port is compatible, etc.
	var/shuttle_id
	/// Possible destinations
	var/port_destinations
	///size of covered area, perpendicular to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/width = 0
	///size of covered area, parallel to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/height = 0
	///position relative to covered area, perpendicular to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/dwidth = 0
	///position relative to covered area, parallel to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/dheight = 0

	var/area_type
	///are we invisible to shuttle navigation computers?
	var/hidden = FALSE

	///Delete this port after ship fly off.
	var/delete_after = FALSE

	///are we registered in SSshuttles?
	var/registered = FALSE

///register to SSshuttles
/obj/docking_port/proc/register()
	if(registered)
		WARNING("docking_port registered multiple times")
		unregister()
	registered = TRUE
	return

///unregister from SSshuttles
/obj/docking_port/proc/unregister()
	if(!registered)
		WARNING("docking_port unregistered multiple times")
	registered = FALSE
	return

/obj/docking_port/proc/Check_id()
	return

//these objects are indestructible
/obj/docking_port/Destroy(force)
	// unless you assert that you know what you're doing. Horrible things
	// may result.
	if(force)
		..()
		return QDEL_HINT_QUEUE
	else
		return QDEL_HINT_LETMELIVE

/obj/docking_port/has_gravity(turf/current_turf)
	return TRUE

/obj/docking_port/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	return

/obj/docking_port/singularity_pull(atom/singularity, current_size)
	return

/obj/docking_port/singularity_act()
	return FALSE

/obj/docking_port/shuttleRotate()
	return //we don't rotate with shuttles via this code.

///returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
		_y = y

	//byond's sin and cos functions are inaccurate. This is faster and perfectly accurate
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	return list(
		_x + (-dwidth*cos) - (-dheight*sin),
		_y + (-dwidth*sin) + (-dheight*cos),
		_x + (-dwidth+width-1)*cos - (-dheight+height-1)*sin,
		_y + (-dwidth+width-1)*sin + (-dheight+height-1)*cos,
	)

///returns turfs within our projected rectangle in no particular order
/obj/docking_port/proc/return_turfs()
	var/list/coords = return_coords()
	return block(
		coords[1], coords[2], z,
		coords[3], coords[4], z
	)

///returns turfs within our projected rectangle in a specific order.this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir)
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	for(var/dx in 0 to width-1)
		var/compX = dx-dwidth
		for(var/dy in 0 to height-1)
			var/compY = dy-dheight
			// realX = _x + compX*cos - compY*sin
			// realY = _y + compY*cos - compX*sin
			// locate(realX, realY, _z)
			var/turf/T = locate(_x + compX*cos - compY*sin, _y + compY*cos + compX*sin, _z)
			.[T] = NONE

#ifdef TESTING

//Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color = "#f00")
	SetInvisibility(INVISIBILITY_NONE)
	SET_PLANE_IMPLICIT(src, GHOST_PLANE)
	var/list/coords = return_coords()
	for(var/turf/T in block(coords[1], coords[2], z, coords[3], coords[4], z))
		T.color = _color
		LAZYINITLIST(T.atom_colours)
		T.maptext = null
	if(_color)
		var/turf/T = locate(coords[1], coords[2], z)
		T.color = "#0f0"
		T = locate(coords[3], coords[4], z)
		T.color = "#00f"

#endif

//return first-found touching dockingport
/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

// Return id of the docked docking_port
/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P)
		return P.shuttle_id

// Say that A in the absolute (rectangular) bounds of this shuttle or no.
/obj/docking_port/proc/is_in_shuttle_bounds(atom/A)
	var/turf/T = get_turf(A)
	if(T.z != z)
		return FALSE
	var/list/bounds = return_coords()
	var/x0 = bounds[1]
	var/y0 = bounds[2]
	var/x1 = bounds[3]
	var/y1 = bounds[4]
	if(!ISINRANGE(T.x, min(x0, x1), max(x0, x1)))
		return FALSE
	if(!ISINRANGE(T.y, min(y0, y1), max(y0, y1)))
		return FALSE
	return TRUE
