///Calculate the angle between two points and the west|east coordinate
/proc/get_angle(atom/movable/start, atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/dy
	var/dx
	dy=(32 * end.y + end.pixel_y) - (32 * start.y + start.pixel_y)
	dx=(32 * end.x + end.pixel_x) - (32 * start.x + start.pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx/dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

///for getting the angle when animating something's pixel_x and pixel_y
/proc/get_pixel_angle(y, x)
	if(!y)
		return (x >= 0) ? 90 : 270
	. = arctan(x/y)
	if(y < 0)
		. += 180
	else if(x < 0)
		. += 360

/**
 * Get a list of turfs in a line from `starting_atom` to `ending_atom`.
 *
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/get_line(atom/starting_atom, atom/ending_atom)
	var/px = starting_atom.x //starting x
	var/py = starting_atom.y
	var/line[] = list(locate(px, py, starting_atom.z))
	var/dx = ending_atom.x - px //x distance
	var/dy = ending_atom.y - py
	var/dxabs = abs(dx)//Absolute value of x distance
	var/dyabs = abs(dy)
	var/sdx = SIGN(dx) //Sign of x distance (+ or -)
	var/sdy = SIGN(dy)
	var/x = dxabs >> 1 //Counters for steps taken, setting to distance/2
	var/y = dyabs >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnessecarrily fast.
	var/j //Generic integer for counting
	if(dxabs >= dyabs) //x distance is greater than y
		for(j = 0; j < dxabs; j++)//It'll take dxabs steps to get there
			y += dyabs
			if(y >= dxabs) //Every dyabs steps, step once in y direction
				y -= dxabs
				py += sdy
			px += sdx //Step on in x direction
			line += locate(px, py, starting_atom.z)//Add the turf to the list
	else
		for(j=0 ;j < dyabs; j++)
			x += dxabs
			if(x >= dyabs)
				x -= dyabs
				px += sdx
			py += sdy
			line += locate(px, py, starting_atom.z)
	return line

///Format a power value in W, kW, MW, or GW.
/proc/display_power(powerused)
	if(powerused < 1000) //Less than a kW
		return "[powerused] W"
	else if(powerused < 1000000) //Less than a MW
		return "[round((powerused * 0.001),0.01)] kW"
	else if(powerused < 1000000000) //Less than a GW
		return "[round((powerused * 0.000001),0.001)] MW"
	return "[round((powerused * 0.000000001),0.0001)] GW"

///Format an energy value in J, kJ, MJ, or GJ. 1W = 1J/s.
/proc/display_joules(units)
	if (units < 1000) // Less than a kJ
		return "[round(units, 0.1)] J"
	else if (units < 1000000) // Less than a MJ
		return "[round(units * 0.001, 0.01)] kJ"
	else if (units < 1000000000) // Less than a GJ
		return "[round(units * 0.000001, 0.001)] MJ"
	return "[round(units * 0.000000001, 0.0001)] GJ"

/proc/joules_to_energy(joules)
	return joules * (1 SECONDS) / SSmachines.wait

/proc/energy_to_joules(energy_units)
	return energy_units * SSmachines.wait / (1 SECONDS)

///Format an energy value measured in Power Cell units.
/proc/display_energy(units)
	// APCs process every (SSmachines.wait * 0.1) seconds, and turn 1 W of
	// excess power into watts when charging cells.
	// With the current configuration of wait=20 and CELLRATE=0.002, this
	// means that one unit is 1 kJ.
	return display_joules(energy_to_joules(units) WATTS)

///chances are 1:value. anyprob(1) will always return true
/proc/anyprob(value)
	return (rand(1,value)==value)

///counts the number of bits in Byond's 16-bit width field, in constant time and memory!
/proc/bit_count(bit_field)
	var/temp = bit_field - ((bit_field >> 1) & 46811) - ((bit_field >> 2) & 37449) //0133333 and 0111111 respectively
	temp = ((temp + (temp >> 3)) & 29127) % 63 //070707
	return temp

/// Returns the name of the mathematical tuple of same length as the number arg (rounded down).
/proc/make_tuple(number)
	var/static/list/units_prefix = list("", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem")
	var/static/list/tens_prefix = list("", "decem", "vigin", "trigin", "quadragin", "quinquagin", "sexagin", "septuagin", "octogin", "nongen")
	var/static/list/one_to_nine = list("monuple", "double", "triple", "quadruple", "quintuple", "sextuple", "septuple", "octuple", "nonuple")
	number = round(number)
	switch(number)
		if(0)
			return "empty tuple"
		if(1 to 9)
			return one_to_nine[number]
		if(10 to 19)
			return "[units_prefix[(number%10)+1]]decuple"
		if(20 to 99)
			return "[units_prefix[(number%10)+1]][tens_prefix[round((number % 100)/10)+1]]tuple"
		if(100)
			return "centuple"
		else //It gets too tedious to use latin prefixes from here.
			return "[number]-tuple"
