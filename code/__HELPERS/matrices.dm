/matrix/proc/TurnTo(old_angle, new_angle)
	. = new_angle - old_angle
	Turn(.) //BYOND handles cases such as -270, 360, 540 etc. DOES NOT HANDLE 180 TURNS WELL, THEY TWEEN AND LOOK LIKE SHIT

/atom/proc/SpinAnimation(speed = 10, loops = -1, clockwise = 1, segments = 3)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/M = matrix(transform)
		M.Turn(segment*i)
		matrices += M
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	animate(src, transform = matrices[1], time = speed, loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional


//Dumps the matrix data in format a-f
/matrix/proc/tolist()
	. = list()
	. += a
	. += b
	. += c
	. += d
	. += e
	. += f

//Dumps the matrix data in a matrix-grid format
/*
  a d 0
  b e 0
  c f 1
*/
/matrix/proc/togrid()
	. = list()
	. += a
	. += d
	. += 0
	. += b
	. += e
	. += 0
	. += c
	. += f
	. += 1

//The X pixel offset of this matrix
/matrix/proc/get_x_shift()
	. = c

//The Y pixel offset of this matrix
/matrix/proc/get_y_shift()
	. = f

// Color matrices:

//Luma coefficients suggested for HDTVs. If you change these, make sure they add up to 1.
#define LUMR 0.2126
#define LUMG 0.7152
#define LUMB 0.0722

//Still need color matrix addition, negation, and multiplication.

//Returns an identity color matrix which does nothing
/proc/color_identity()
	return list(1,0,0, 0,1,0, 0,0,1)

//Moves all colors angle degrees around the color wheel while maintaining intensity of the color and not affecting whites
//TODO: Need a version that only affects one color (ie shift red to blue but leave greens and blues alone)
/proc/color_rotation(angle)
	if(angle == 0)
		return color_identity()
	angle = Clamp(angle, -180, 180)
	var/cos = cos(angle)
	var/sin = sin(angle)

	var/constA = 0.143
	var/constB = 0.140
	var/constC = -0.283
	return list(
	LUMR + cos * (1-LUMR) + sin * -LUMR, LUMR + cos * -LUMR + sin * constA, LUMR + cos * -LUMR + sin * -(1-LUMR),
	LUMG + cos * -LUMG + sin * -LUMG, LUMG + cos * (1-LUMG) + sin * constB, LUMG + cos * -LUMG + sin * LUMG,
	LUMB + cos * -LUMB + sin * (1-LUMB), LUMB + cos * -LUMB + sin * constC, LUMB + cos * (1-LUMB) + sin * LUMB
	)

//Makes everything brighter or darker without regard to existing color or brightness
/proc/color_brightness(power)
	power = Clamp(power, -255, 255)
	power = power/255

	return list(1,0,0, 0,1,0, 0,0,1, power,power,power)

/var/list/delta_index = list(
	0,    0.01, 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1,  0.11,
	0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.21, 0.22, 0.24,
	0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
	0.44, 0.46, 0.48, 0.5,  0.53, 0.56, 0.59, 0.62, 0.65, 0.68,
	0.71, 0.74, 0.77, 0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98,
	1.0,  1.06, 1.12, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48, 1.54,
	1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0,  2.12, 2.25,
	2.37, 2.50, 2.62, 2.75, 2.87, 3.0,  3.2,  3.4,  3.6,  3.8,
	4.0,  4.3,  4.7,  4.9,  5.0,  5.5,  6.0,  6.5,  6.8,  7.0,
	7.3,  7.5,  7.8,  8.0,  8.4,  8.7,  9.0,  9.4,  9.6,  9.8,
	10.0)

//Exxagerates or removes brightness
/proc/color_contrast(value)
	value = Clamp(value, -100, 100)
	if(value == 0)
		return color_identity()

	var/x = 0
	if (value < 0)
		x = 127 + value / 100 * 127;
	else
		x = value % 1
		if(x == 0)
			x = delta_index[value]
		else
			x = delta_index[value] * (1-x) + delta_index[value+1] * x//use linear interpolation for more granularity.
		x = x * 127 + 127

	var/mult = x / 127
	var/add = 0.5 * (127-x) / 255
	return list(mult,0,0, 0,mult,0, 0,0,mult, add,add,add)

//Exxagerates or removes colors
/proc/color_saturation(value as num)
	if(value == 0)
		return color_identity()
	value = Clamp(value, -100, 100)
	if(value > 0)
		value *= 3
	var/x = 1 + value / 100
	var/inv = 1 - x
	var/R = LUMR * inv
	var/G = LUMG * inv
	var/B = LUMB * inv

	return list(R + x,R,R, G,G + x,G, B,B,B + x)

#undef LUMR
#undef LUMG
#undef LUMB
