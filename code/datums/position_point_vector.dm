/proc/point_midpoint_points(datum/point/a, datum/point/b) //Obviously will not support multiZ calculations! Same for the two below.
	var/datum/point/P = new
	P.x = a.x + (b.x - a.x) * 0.5
	P.y = a.y + (b.y - a.y) * 0.5
	P.z = a.z
	return P

/proc/pixel_length_between_points(datum/point/a, datum/point/b)
	return sqrt(((b.x - a.x) ** 2) + ((b.y - a.y) ** 2))

/proc/angle_between_points(datum/point/a, datum/point/b)
	return ATAN2((b.y - a.y), (b.x - a.x))

/// For positions with map x/y/z and pixel x/y so you don't have to return lists. Could use addition/subtraction in the future I guess.
/datum/position
	var/x = 0
	var/y = 0
	var/z = 0
	var/pixel_x = 0
	var/pixel_y = 0

/datum/position/proc/valid()
	return x && y && z && !isnull(pixel_x) && !isnull(pixel_y)

/datum/position/New(_x = 0, _y = 0, _z = 0, _pixel_x = 0, _pixel_y = 0) //first argument can also be a /datum/point.
	if(istype(_x, /datum/point))
		var/datum/point/P = _x
		var/turf/T = P.return_turf()
		_x = T.x
		_y = T.y
		_z = T.z
		_pixel_x = P.return_px()
		_pixel_y = P.return_py()
	else if(isatom(_x))
		var/atom/A = _x
		_x = A.x
		_y = A.y
		_z = A.z
		_pixel_x = A.pixel_x
		_pixel_y = A.pixel_y
	x = _x
	y = _y
	z = _z
	pixel_x = _pixel_x
	pixel_y = _pixel_y

/datum/position/proc/return_turf()
	return locate(x, y, z)

/datum/position/proc/return_px()
	return pixel_x

/datum/position/proc/return_py()
	return pixel_y

/datum/position/proc/return_point()
	return new /datum/point(src)

/// A precise point on the map in absolute pixel locations based on world.icon_size. Pixels are FROM THE EDGE OF THE MAP!
/datum/point
	var/x = 0
	var/y = 0
	var/z = 0

/datum/point/proc/valid()
	return x && y && z

/datum/point/proc/copy_to(datum/point/p = new)
	p.x = x
	p.y = y
	p.z = z
	return p

/// First argument can also be a /datum/position or /atom.
/datum/point/New(_x, _y, _z, _pixel_x = 0, _pixel_y = 0)
	if(istype(_x, /datum/position))
		var/datum/position/P = _x
		_x = P.x
		_y = P.y
		_z = P.z
		_pixel_x = P.pixel_x
		_pixel_y = P.pixel_y
	else if(istype(_x, /atom))
		var/atom/A = _x
		_x = A.x
		_y = A.y
		_z = A.z
		_pixel_x = A.pixel_x
		_pixel_y = A.pixel_y
	initialize_location(_x, _y, _z, _pixel_x, _pixel_y)

/datum/point/proc/initialize_location(tile_x, tile_y, tile_z, p_x = 0, p_y = 0)
	if(!isnull(tile_x))
		x = ((tile_x - 1) * ICON_SIZE_X) + ICON_SIZE_X * 0.5 + p_x + 1
	if(!isnull(tile_y))
		y = ((tile_y - 1) * ICON_SIZE_Y) + ICON_SIZE_Y * 0.5 + p_y + 1
	if(!isnull(tile_z))
		z = tile_z

/datum/point/proc/debug_out()
	var/turf/T = return_turf()
	return "[text_ref(src)] aX [x] aY [y] aZ [z] pX [return_px()] pY [return_py()] mX [T.x] mY [T.y] mZ [T.z]"

/datum/point/proc/move_atom_to_src(atom/movable/AM)
	AM.forceMove(return_turf())
	AM.pixel_x = return_px()
	AM.pixel_y = return_py()

/datum/point/proc/return_turf()
	return locate(CEILING(x / ICON_SIZE_X, 1), CEILING(y / ICON_SIZE_Y, 1), z)

/datum/point/proc/return_coordinates() //[turf_x, turf_y, z]
	return list(CEILING(x / ICON_SIZE_X, 1), CEILING(y / ICON_SIZE_Y, 1), z)

/datum/point/proc/return_position()
	return new /datum/position(src)

/datum/point/proc/return_px()
	return MODULUS(x, ICON_SIZE_X) - (ICON_SIZE_X/2) - 1

/datum/point/proc/return_py()
	return MODULUS(y, ICON_SIZE_Y) - (ICON_SIZE_Y/2) - 1

/datum/vector
	var/magnitude = 1
	var/angle = 0
	// Calculated coordinate amounts to prevent having to do trig every step.
	var/pixel_x = 0
	var/pixel_y = 0
	var/total_x = 0
	var/total_y = 0

/datum/vector/New(new_magnitude, new_angle)
	. = ..()
	initialize_trajectory(new_magnitude, new_angle)

/datum/vector/proc/initialize_trajectory(new_magnitude, new_angle)
	if(!isnull(new_magnitude))
		magnitude = new_magnitude
	set_angle(new_angle)

/// Calculations use "byond angle" where north is 0 instead of 90, and south is 180 instead of 270.
/datum/vector/proc/set_angle(new_angle)
	if(isnull(angle))
		return
	angle = new_angle
	update_offsets()

/datum/vector/proc/update_offsets()
	pixel_x = sin(angle)
	pixel_y = cos(angle)
	total_x = pixel_x * magnitude
	total_y = pixel_y * magnitude

/datum/vector/proc/set_speed(new_magnitude)
	if(isnull(new_magnitude) || magnitude == new_magnitude)
		return
	magnitude = new_magnitude
	total_x = pixel_x * magnitude
	total_y = pixel_y * magnitude
