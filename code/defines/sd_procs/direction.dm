/* Direction procs
	These procs deal with BYOND directions.

	sd_get_approx_dir(atom/ref,atom/target)
		returns the approximate direction from ref to target.

	sd_degrees2dir(degrees as num)
		Accepts an angle in degrees and returns the closest BYOND
		direction value.

	sd_dir2degrees(dir as num)
		Accepts a BYOND direction value and returns the angle North of
		East in degrees.

	sd_dir2radial(dir as num)
		Accepts a BYOND direction value and returns the radial direction
		(0-7) North of East.

	sd_dir2radians(dir as num)
		Accepts a BYOND direction value and returns the angle North of
		East in radians.

	sd_dir2text(dir as num)
		Accepts a BYOND direction value and returns the lowercase text
		name of the direction.

	sd_dir2Text(dir as num)
		Accepts a BYOND direction value and returns the Capitalized text
		name of the direction

	sd_radial2dir(radial as num)
		Accepts a radial direction (0-7) and returns the BYOND direction
		value.
*/

/*********************************************
*  Implimentation: No need to read further.  *
*********************************************/
proc
	sd_get_approx_dir(atom/ref,atom/target)
	/* returns the approximate direction from ref to target.
		Code by Lummox JR
		http://www.byond.com/forum/forum.cgi?action=message_list&query=Post+ID%3A153964#153964
		*/
		var/d=get_dir(ref,target)
		if(d&d-1)        // diagonal
			var/ax=abs(ref.x-target.x)
			var/ay=abs(ref.y-target.y)
			if(ax>=ay<<1) return d&12     // keep east/west (4 and 8)
			else if(ay>=ax<<1) return d&3 // keep north/south (1 and 2)
		return d

	sd_degrees2dir(degrees as num)
	/* accepts an angle in degrees and returns the closest BYOND
		direction value */
		var/error_report = degrees	// for error tracking

		// force angle into a range between 0 and 360
		degrees %= 360
		if(degrees < 0)
			degrees += 360

		// BYOND dirs are at 45 degree angles
		degrees = round(degrees,45)

		switch(degrees)
			if(0,360) return EAST
			if(45) return NORTHEAST
			if(90) return NORTH
			if(135) return NORTHWEST
			if(180) return WEST
			if(225) return SOUTHWEST
			if(270) return SOUTH
			if(315) return SOUTHEAST
			else
				world.log << "Error in sd_degrees2dir(): [error_report] -> [degrees]"

	sd_dir2degrees(dir as num)
	/* accepts a BYOND direction value and returns the angle North of
		East in degrees */
		switch(dir)
			if(EAST)		return 0
			if(NORTHEAST)	return 45
			if(NORTH)		return 90
			if(NORTHWEST)	return 135
			if(WEST)		return 180
			if(SOUTHWEST)	return 225
			if(SOUTH)		return 270
			if(SOUTHEAST)	return 315

	sd_dir2radial(dir as num)
	/* accepts a BYOND direction value and returns the radial direction
		(0-7) North of East */
		switch(dir)
			if(EAST)		return 0
			if(NORTHEAST)	return 1
			if(NORTH)		return 2
			if(NORTHWEST)	return 3
			if(WEST)		return 4
			if(SOUTHWEST)	return 5
			if(SOUTH)		return 6
			if(SOUTHEAST)	return 7

	sd_dir2radians(dir as num)
	/* accepts a BYOND direction value and returns the angle North of
		East in radians */
		switch(dir)
			if(EAST)		return 0
			if(NORTHEAST)	return PI/4
			if(NORTH)		return PI/2
			if(NORTHWEST)	return PI*3/4
			if(WEST)		return PI
			if(SOUTHWEST)	return PI*5/4
			if(SOUTH)		return PI*3/2
			if(SOUTHEAST)	return PI*7/4

	sd_dir2text(dir as num)
	/* accepts a direction and returns the lowercase text name of
		the direction */
		switch(dir)
			if(NORTH)		return "north"
			if(SOUTH)		return "south"
			if(EAST)		return "east"
			if(WEST)		return "west"
			if(NORTHEAST)	return "northeast"
			if(SOUTHEAST)	return "southeast"
			if(NORTHWEST)	return "northwest"
			if(SOUTHWEST)	return "southwest"

	sd_dir2Text(dir as num)
	/* accepts a direction and returns the Capitalized text name of
		the direction */
		switch(dir)
			if(NORTH)		return "North"
			if(SOUTH)		return "South"
			if(EAST)		return "East"
			if(WEST)		return "West"
			if(NORTHEAST)	return "Northeast"
			if(SOUTHEAST)	return "Southeast"
			if(NORTHWEST)	return "Northwest"
			if(SOUTHWEST)	return "Southwest"

	sd_radial2dir(radial as num)
	/* accepts a radial direction (0-7) and returns the BYOND direction
		value */
		switch(radial)
			if(0) return EAST
			if(1) return NORTHEAST
			if(2) return NORTH
			if(3) return NORTHWEST
			if(4) return WEST
			if(5) return SOUTHWEST
			if(6) return SOUTH
			if(7) return SOUTHEAST
