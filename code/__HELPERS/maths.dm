// Credits to Nickr5 for the useful procs I've taken from his library resource.

GLOBAL_VAR_INIT(E, 2.71828183)
GLOBAL_VAR_INIT(Sqrt2, 1.41421356)

// List of square roots for the numbers 1-100.
GLOBAL_LIST_INIT(sqrtTable, list(1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5,
                          5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7,
                          7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                          8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10))

/proc/sign(x)
	return x!=0?x/abs(x):0

/proc/Atan2(x, y)
	if(!x && !y) return 0
	var/a = arccos(x / sqrt(x*x + y*y))
	return y >= 0 ? a : -a

/proc/Ceiling(x, y=1)
	return -round(-x / y) * y

/proc/Floor(x, y=1)
	return round(x / y) * y

#define Clamp(CLVALUE,CLMIN,CLMAX) ( max( (CLMIN), min((CLVALUE), (CLMAX)) ) )

// cotangent
/proc/Cot(x)
	return 1 / Tan(x)

// cosecant
/proc/Csc(x)
	return 1 / sin(x)

/proc/Default(a, b)
	return a ? a : b

// Greatest Common Divisor - Euclid's algorithm
/proc/Gcd(a, b)
	return b ? Gcd(b, a % b) : a

/proc/Inverse(x)
	return 1 / x

/proc/IsAboutEqual(a, b, deviation = 0.1)
	return abs(a - b) <= deviation

/proc/IsEven(x)
	return x % 2 == 0

// Returns true if val is from min to max, inclusive.
/proc/IsInRange(val, min, max)
	return min <= val && val <= max

/proc/IsInteger(x)
	return round(x) == x

/proc/IsOdd(x)
	return !IsEven(x)

/proc/IsMultiple(x, y)
	return x % y == 0

// Least Common Multiple
/proc/Lcm(a, b)
	return abs(a) / Gcd(a, b) * abs(b)

// Performs a linear interpolation between a and b.
// Note that amount=0 returns a, amount=1 returns b, and
// amount=0.5 returns the mean of a and b.
/proc/Lerp(a, b, amount = 0.5)
	return a + (b - a) * amount

//Calculates the sum of a list of numbers.
/proc/Sum(var/list/data)
	. = 0
	for(var/val in data)
		.+= val

//Calculates the mean of a list of numbers.
/proc/Mean(var/list/data)
	. = Sum(data) / (data.len)


// Returns the nth root of x.
/proc/Root(n, x)
	return x ** (1 / n)

// secant
/proc/Sec(x)
	return 1 / cos(x)

// The quadratic formula. Returns a list with the solutions, or an empty list
// if they are imaginary.
/proc/SolveQuadratic(a, b, c)
	ASSERT(a)
	. = list()
	var/d		= b*b - 4 * a * c
	var/bottom  = 2 * a
	if(d < 0) return
	var/root = sqrt(d)
	. += (-b + root) / bottom
	if(!d) return
	. += (-b - root) / bottom

// tangent
/proc/Tan(x)
	return sin(x) / cos(x)

/proc/ToDegrees(radians)
				  // 180 / Pi
	return radians * 57.2957795

/proc/ToRadians(degrees)
				  // Pi / 180
	return degrees * 0.0174532925

// Will filter out extra rotations and negative rotations
// E.g: 540 becomes 180. -180 becomes 180.
/proc/SimplifyDegrees(degrees)
	degrees = degrees % 360
	if(degrees < 0)
		degrees += 360
	return degrees

// min is inclusive, max is exclusive
/proc/Wrap(val, min, max)
	var/d = max - min
	var/t = round((val - min) / d)
	return val - (t * d)


//A logarithm that converts an integer to a number scaled between 0 and 1 (can be tweaked to be higher).
//Currently, this is used for hydroponics-produce sprite transforming, but could be useful for other transform functions.
/proc/TransformUsingVariable(input, inputmaximum, scaling_modifier = 0)

		var/inputToDegrees = (input/inputmaximum)*180 //Converting from a 0 -> 100 scale to a 0 -> 180 scale. The 0 -> 180 scale corresponds to degrees
		var/size_factor = ((-cos(inputToDegrees) +1) /2) //returns a value from 0 to 1

		return size_factor + scaling_modifier //scale mod of 0 results in a number from 0 to 1. A scale modifier of +0.5 returns 0.5 to 1.5
		//to_chat(world, "Transform multiplier of [src] is [size_factor + scaling_modifer]")



//converts a uniform distributed random number into a normal distributed one
//since this method produces two random numbers, one is saved for subsequent calls
//(making the cost negligble for every second call)
//This will return +/- decimals, situated about mean with standard deviation stddev
//68% chance that the number is within 1stddev
//95% chance that the number is within 2stddev
//98% chance that the number is within 3stddev...etc
#define ACCURACY 10000
/proc/gaussian(mean, stddev)
	var/static/gaussian_next
	var/R1;var/R2;var/working
	if(gaussian_next != null)
		R1 = gaussian_next
		gaussian_next = null
	else
		do
			R1 = rand(-ACCURACY,ACCURACY)/ACCURACY
			R2 = rand(-ACCURACY,ACCURACY)/ACCURACY
			working = R1*R1 + R2*R2
		while(working >= 1 || working==0)
		working = sqrt(-2 * log(working) / working)
		R1 *= working
		gaussian_next = R2 * working
	return (mean + stddev * R1)
#undef ACCURACY
