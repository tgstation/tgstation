/**
 * Credits to Nickr5 for the useful procs I've taken from his library resource.
 */

var/const/E		= 2.71828183
var/const/Sqrt2	= 1.41421356

/* //All point fingers and laugh at this joke of a list, I even heard using sqrt() is faster than this list lookup, honk.
// List of square roots for the numbers 1-100.
var/list/sqrtTable = list(1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5,
                          5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7,
                          7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                          8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10)
*/

/proc/Atan2(x, y)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Atan2() called tick#: [world.time]")
	if (!x && !y)
		return 0

	var/invcos = arccos(x / sqrt(x * x + y * y))
	return y >= 0 ? invcos : -invcos

/proc/arctan(x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/arctan() called tick#: [world.time]")
	var/y=arcsin(x/sqrt(1+x*x))
	return y

/proc/Ceiling(x, y = 1)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Ceiling() called tick#: [world.time]")
	. = -round(-x / y) * y

//Moved to macros.dm to reduce pure calling overhead, this was being called shitloads, like, most calls of all procs.
/*
/proc/Clamp(const/val, const/min, const/max)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Clamp() called tick#: [world.time]")
	if (val <= min)
		return min

	if (val >= max)
		return max

	return val
*/

// cotangent
/proc/Cot(x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Cot() called tick#: [world.time]")
	return 1 / Tan(x)

// cosecant
/proc/Csc(x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Csc() called tick#: [world.time]")
	return 1 / sin(x)

/proc/Default(a, b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Default() called tick#: [world.time]")
	return a ? a : b

/proc/Floor(x, y = 1)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Floor() called tick#: [world.time]")
	. = round(x / y) * y

// Greatest Common Divisor - Euclid's algorithm
/proc/Gcd(a, b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Gcd() called tick#: [world.time]")
	return b ? Gcd(b, a % b) : a

/proc/Inverse(x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Inverse() called tick#: [world.time]")
	return 1 / x

/proc/IsAboutEqual(a, b, deviation = 0.1)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/IsAboutEqual() called tick#: [world.time]")
	return abs(a - b) <= deviation

/proc/IsEven(x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/IsEven() called tick#: [world.time]")
	return x % 2 == 0

// Returns true if val is from min to max, inclusive.
/proc/IsInRange(val, min, max)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/IsInRange() called tick#: [world.time]")
	return min <= val && val <= max

/proc/IsInteger(x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/IsInteger() called tick#: [world.time]")
	return Floor(x) == x

/proc/IsOdd(x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/IsOdd() called tick#: [world.time]")
	return !IsEven(x)

/proc/IsMultiple(x, y)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/IsMultiple() called tick#: [world.time]")
	return x % y == 0

// Least Common Multiple
/proc/Lcm(a, b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Lcm() called tick#: [world.time]")
	return abs(a) / Gcd(a, b) * abs(b)

// Performs a linear interpolation between a and b.
// Note that amount=0 returns a, amount=1 returns b, and
// amount=0.5 returns the mean of a and b.
/proc/Lerp(a, b, amount = 0.5)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Lerp() called tick#: [world.time]")
	return a + (b - a) * amount

/proc/Mean(...)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Mean() called tick#: [world.time]")
	var/values 	= 0
	var/sum		= 0
	for(var/val in args)
		values++
		sum += val
	return sum / values


/*
 * Returns the nth root of x.
 */
/proc/Root(const/n, const/x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Root() called tick#: [world.time]")
	return x ** (1 / n)

/*
 * Secant.
 */
/proc/Sec(const/x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Sec() called tick#: [world.time]")
	return 1 / cos(x)

// The quadratic formula. Returns a list with the solutions, or an empty list
// if they are imaginary.
/proc/SolveQuadratic(a, b, c)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/SolveQuadratic() called tick#: [world.time]")
	ASSERT(a)
	. = list()
	var/d		= b*b - 4 * a * c
	var/bottom  = 2 * a
	if(d < 0) return
	var/root = sqrt(d)
	. += (-b + root) / bottom
	if(!d) return
	. += (-b - root) / bottom

/*
 * Tangent.
 */
/proc/Tan(const/x)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Tan() called tick#: [world.time]")
	return sin(x) / cos(x)

/proc/ToDegrees(const/radians)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/ToDegrees() called tick#: [world.time]")
	// 180 / Pi
	return radians * 57.2957795

/proc/ToRadians(const/degrees)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/ToRadians() called tick#: [world.time]")
	// Pi / 180
	return degrees * 0.0174532925

// min is inclusive, max is exclusive
/proc/Wrap(val, min, max)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/Wrap() called tick#: [world.time]")
	var/d = max - min
	var/t = Floor((val - min) / d)
	return val - (t * d)

/*
 * A very crude linear approximatiaon of pythagoras theorem.
 */
/proc/cheap_pythag(const/Ax, const/Ay)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cheap_pythag() called tick#: [world.time]")
	var/dx = abs(Ax)
	var/dy = abs(Ay)

	if (dx >= dy)
		return dx + (0.5 * dy) // The longest side add half the shortest side approximates the hypotenuse.
	else
		return dy + (0.5 * dx)

/*
 * Magic constants obtained by using linear regression on right-angled triangles of sides 0<x<1, 0<y<1
 * They should approximate pythagoras theorem well enough for our needs.
 */
#define k1 0.934
#define k2 0.427
/proc/cheap_hypotenuse(const/Ax, const/Ay, const/Bx, const/By)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cheap_hypotenuse() called tick#: [world.time]")
	var/dx = abs(Ax - Bx) // Sides of right-angled triangle.
	var/dy = abs(Ay - By)

	if (dx >= dy)
		return (k1*dx) + (k2*dy) // No sqrt or powers :).
	else
		return (k2*dx) + (k1*dy)
#undef k1
#undef k2

//Checks if something's a power of 2, to check bitflags.
//Thanks to wwjnc for this.
/proc/test_bitflag(var/bitflag)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/test_bitflag() called tick#: [world.time]")
	return bitflag != 0 && !(bitflag & (bitflag - 1))
