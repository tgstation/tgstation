///Calculate the angle between two movables and the west|east coordinate
/proc/get_angle(atom/movable/start, atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/dy =(ICON_SIZE_Y * end.y + end.pixel_y) - (ICON_SIZE_Y * start.y + start.pixel_y)
	var/dx =(ICON_SIZE_X * end.x + end.pixel_x) - (ICON_SIZE_X * start.x + start.pixel_x)
	return delta_to_angle(dx, dy)

/// Calculate the angle produced by a pair of x and y deltas
/proc/delta_to_angle(x, y)
	if(!y)
		return (x >= 0) ? 90 : 270
	. = arctan(x/y)
	if(y < 0)
		. += 180
	else if(x < 0)
		. += 360

/// Angle between two arbitrary points and horizontal line same as [/proc/get_angle]
/proc/get_angle_raw(start_x, start_y, start_pixel_x, start_pixel_y, end_x, end_y, end_pixel_x, end_pixel_y)
	var/dy = (ICON_SIZE_Y * end_y + end_pixel_y) - (ICON_SIZE_Y * start_y + start_pixel_y)
	var/dx = (ICON_SIZE_X * end_x + end_pixel_x) - (ICON_SIZE_X * start_x + start_pixel_x)
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
	var/current_x_step = starting_atom.x//start at x and y, then add 1 or -1 to these to get every turf from starting_atom to ending_atom
	var/current_y_step = starting_atom.y
	var/starting_z = starting_atom.z

	var/list/line = list(get_turf(starting_atom))//get_turf(atom) is faster than locate(x, y, z)

	var/x_distance = ending_atom.x - current_x_step //x distance
	var/y_distance = ending_atom.y - current_y_step

	var/abs_x_distance = abs(x_distance)//Absolute value of x distance
	var/abs_y_distance = abs(y_distance)

	var/x_distance_sign = SIGN(x_distance) //Sign of x distance (+ or -)
	var/y_distance_sign = SIGN(y_distance)

	var/x = abs_x_distance >> 1 //Counters for steps taken, setting to distance/2
	var/y = abs_y_distance >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnecessarily fast.

	if(abs_x_distance >= abs_y_distance) //x distance is greater than y
		for(var/distance_counter in 0 to (abs_x_distance - 1))//It'll take abs_x_distance steps to get there
			y += abs_y_distance

			if(y >= abs_x_distance) //Every abs_y_distance steps, step once in y direction
				y -= abs_x_distance
				current_y_step += y_distance_sign

			current_x_step += x_distance_sign //Step on in x direction
			line += locate(current_x_step, current_y_step, starting_z)//Add the turf to the list
	else
		for(var/distance_counter in 0 to (abs_y_distance - 1))
			x += abs_x_distance

			if(x >= abs_y_distance)
				x -= abs_y_distance
				current_x_step += x_distance_sign

			current_y_step += y_distance_sign
			line += locate(current_x_step, current_y_step, starting_z)
	return line

/**
 * Get a list of turfs in a perimeter given the `center_atom` and `radius`.
 * Automatically rounds down decimals and does not accept values less than positive 1 as they don't play well with it.
 * Is efficient on large circles but ugly on small ones
 * Uses [Jesko`s method to the midpoint circle Algorithm](https://en.wikipedia.org/wiki/Midpoint_circle_algorithm).
 */
/proc/get_perimeter(atom/center, radius)
	if(radius < 1)
		return
	var/rounded_radius = round(radius)
	var/x = center.x
	var/y = center.y
	var/z = center.z
	var/t1 = rounded_radius/16
	var/dx = rounded_radius
	var/dy = 0
	var/t2
	var/list/perimeter = list()
	while(dx >= dy)
		perimeter += locate(x + dx, y + dy, z)
		perimeter += locate(x - dx, y + dy, z)
		perimeter += locate(x + dx, y - dy, z)
		perimeter += locate(x - dx, y - dy, z)
		perimeter += locate(x + dy, y + dx, z)
		perimeter += locate(x - dy, y + dx, z)
		perimeter += locate(x + dy, y - dx, z)
		perimeter += locate(x - dy, y - dx, z)
		dy += 1
		t1 += dy
		t2 = t1 - dx
		if(t2 > 0)
			t1 = t2
			dx -= 1
	return perimeter

/**
 * Formats a number into a list representing the si unit.
 * Access the coefficient with [SI_COEFFICIENT], and access the unit with [SI_UNIT].
 *
 * Supports SI exponents between 1e-15 to 1e15, but properly handles numbers outside that range as well.
 * Arguments:
 * * value - The number to convert to text. Can be positive or negative.
 * * unit - The base unit of the number, such as "Pa" or "W".
 * * maxdecimals - Maximum amount of decimals to display for the final number. Defaults to 1.
 * Returns: [SI_COEFFICIENT = si unit coefficient, SI_UNIT = prefixed si unit.]
 */
/proc/siunit_isolated(value, unit, maxdecimals=1)
	var/static/list/prefixes = list("q","r","y","z","a","f","p","n","μ","m","","k","M","G","T","P","E","Z","Y","R","Q")

	// We don't have prefixes beyond this point
	// and this also captures value = 0 which you can't compute the logarithm for
	// and also byond numbers are floats and doesn't have much precision beyond this point anyway
	if(abs(value) < 1e-30)
		. = list(SI_COEFFICIENT = 0, SI_UNIT = " [unit]")
		return

	var/exponent = clamp(log(10, abs(value)), -30, 30) // Calculate the exponent and clamp it so we don't go outside the prefix list bounds
	var/divider = 10 ** (round(exponent / 3) * 3) // Rounds the exponent to nearest SI unit and power it back to the full form
	var/coefficient = round(value / divider, 10 ** -maxdecimals) // Calculate the coefficient and round it to desired decimals
	var/prefix_index = round(exponent / 3) + 11 // Calculate the index in the prefixes list for this exponent

	// An edge case which happens if we round 999.9 to 0 decimals for example, which gets rounded to 1000
	// In that case, we manually swap up to the next prefix if there is one available
	if(coefficient >= 1000 && prefix_index < 21)
		coefficient /= 1e3
		prefix_index++

	var/prefix = prefixes[prefix_index]
	. = list(SI_COEFFICIENT = coefficient, SI_UNIT = " [prefix][unit]")

/**Format a power value in prefixed watts.
 * Converts from energy if convert is true.
 * Args:
 * - power: The value of power to format.
 * - convert: Whether to convert this from joules.
 * - datum/controller/subsystem/scheduler: used in the conversion
 * Returns: The string containing the formatted power.
 */
/proc/display_power(power, convert = TRUE, datum/controller/subsystem/scheduler = SSmachines)
	power = convert ? energy_to_power(power, scheduler) : power
	return siunit(power, "W", 3)

/**
 * Format an energy value in prefixed joules.
 * Arguments
 *
 * * units - the value t convert
 */
/proc/display_energy(units)
	return siunit(units, "J", 3)

/**
 * Converts the joule to the watt, assuming SSmachines tick rate.
 * Arguments
 *
 * * joules - the value in joules to convert
 * * datum/controller/subsystem/scheduler - the subsystem whos wait time is used in the conversion
 */
/proc/energy_to_power(joules, datum/controller/subsystem/scheduler = SSmachines)
	return joules * (1 SECONDS) / scheduler.wait

/**
 * Converts the watt to the joule, assuming SSmachines tick rate.
 * * Arguments
 *
 * * joules - the value in joules to convert
 * * datum/controller/subsystem/scheduler - the subsystem whos wait time is used in the conversion
 */
/proc/power_to_energy(watts, datum/controller/subsystem/scheduler = SSmachines)
	return watts * scheduler.wait / (1 SECONDS)

///chances are 1:value. anyprob(1) will always return true
/proc/anyprob(value)
	return (rand(1,value) == value)

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

/// Takes a value, and a threshold it has to at least match
/// returns the correctly signed value max'd to the threshold
/proc/at_least(new_value, threshold)
	var/sign = SIGN(new_value)
	// SIGN will return 0 if the value is 0, so we just go to the positive threshold
	if(!sign)
		return threshold
	if(sign == 1)
		return max(new_value, threshold)
	if(sign == -1)
		return min(new_value, threshold * -1)

/// Takes two values x and y, and returns 1/((1/x) + y)
/// Useful for providing an additive modifier to a value that is used as a divisor, such as `/obj/projectile/var/speed`
/proc/reciprocal_add(x, y)
	return 1/((1/x)+y)

/// 180s an angle
/proc/reverse_angle(angle)
	return (angle + 180) % 360
