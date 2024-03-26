/*
 * For a new plane of (x,x'),(y,y') : offset_x,offset_y,x_size,y_size
 *
 * // Sign changes must account for 0-crossing
 * (-100,100),(0,0) : 101,1,201,1
 * // Otherwise, it does not
 * (-100,-50),(0,0) : 101,1,50,1
 * (50,100) , (0,0) : -49,1,50,1
 */

/datum/cartesian_plane
	/// Lower bound of the X axis
	VAR_PRIVATE/x1
	/// Upper bound of the X axis
	VAR_PRIVATE/x2
	/// Lower bound of the Y axis
	VAR_PRIVATE/y1
	/// Upper bound of the Y axis
	VAR_PRIVATE/y2

	/// Data Storage Hellscape:tm:
	VAR_PRIVATE/list/plane

	/// Added to any accesses to the first array
	VAR_PRIVATE/offset_x
	/// Added to any accesses of a nested array
	VAR_PRIVATE/offset_y

	/// The logical size of the X axis
	var/x_size
	/// The logical size of the Y axis
	var/y_size

/datum/cartesian_plane/New(x1, x2, y1, y2)
	src.x1 = x1
	src.x2 = x2
	src.y1 = y1
	src.y2 = y2

	// Calculate the offsets to push the lower bound within a usable range.
	offset_x = 1 - x1
	offset_y = 1 - y1

	x_size = (x1 < 0 && x2 > 0) ? abs(x1 - x2) + 1 : abs(x1 - x2)
	y_size = (y1 < 0 && y2 > 0) ? abs(y1 - y2) + 1 : abs(y1 - y2)

	plane = new/list(x_size, y_size)

/// Pass in a logical coordinate and see if it's in the map. This does not take array coordinates!
/datum/cartesian_plane/proc/SanitizeCoordinate(x, y)
	PRIVATE_PROC(TRUE)
	if(x > x2 || x < x1 || y < y1  || y > y2)
		return FALSE
	return TRUE

/// Returns the bounds of the map as a list
/datum/cartesian_plane/proc/return_bounds()
	return list(x1, x2, y1, y2)

/// Returns the offsets of the map as a list
/datum/cartesian_plane/proc/return_offsets()
	return list(offset_x, offset_y)

/// Get the content at a given coordinate
/datum/cartesian_plane/proc/return_coordinate(x, y)
	if(!SanitizeCoordinate(x,y))
		CRASH("Received invalid coordinate for cartesian plane.")

	return plane[x + offset_x][y + offset_y]

/// Set the content at a given coordinate
/datum/cartesian_plane/proc/set_coordinate(x, y, content)
	if(!SanitizeCoordinate(x,y))
		CRASH("Received invalid coordinate for cartesian plane.")

	plane[x + offset_x][y + offset_y] = content

/// Return the contents of a block given logical coordinates
/datum/cartesian_plane/proc/return_block(x1, x2, y1, y2)
	. = list()

	for(var/_x in (x1 + offset_x) to (x2 + offset_x))
		for(var/_y in (y1 + offset_y) to (y2 + offset_y))
			var/foo = plane[_x][_y]
			if(foo)
				. += foo

/// Returns the contents of a block of coordinates in chebyshev range from the given coordinate
/datum/cartesian_plane/proc/return_range(x, y, range)
	var/x1 = clamp(x-range, src.x1, src.x2)
	var/x2 = clamp(x+range, src.x1, src.x2)
	var/y1 = clamp(y-range, src.y1, src.y2)
	var/y2 = clamp(y+range, src.y1, src.y2)
	return return_block(x1, x2, y1, y2)
