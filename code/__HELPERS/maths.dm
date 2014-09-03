/**
 * Credits to Nickr5 for the useful procs I've taken from his library resource.
 */

var/const/E		= 2.71828183
var/const/Sqrt2	= 1.41421356

// List of square roots for the numbers 1-100.
var/list/sqrtTable = list(1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5,
                          5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7,
                          7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                          8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10)

/proc/Atan2(x, y)
	if(!x && !y) return 0
	var/a = arccos(x / sqrt(x*x + y*y))
	return y >= 0 ? a : -a

/proc/Ceiling(x)
	return -round(-x)

/proc/Clamp(const/val, const/min, const/max)
	if (val <= min)
		return min

	if (val >= max)
		return max

	return val

// cotangent
/proc/Cot(x)
	return 1 / Tan(x)

// cosecant
/proc/Csc(x)
	return 1 / sin(x)

/proc/Default(a, b)
	return a ? a : b

/proc/Floor(x)
	return round(x)

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
	return Floor(x) == x

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

/proc/Mean(...)
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
	return x ** (1 / n)

/*
 * Secant.
 */
/proc/Sec(const/x)
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

/*
 * Tangent.
 */
/proc/Tan(const/x)
	return sin(x) / cos(x)

/proc/ToDegrees(const/radians)
					// 180 / Pi
	return radians * 57.2957795

/proc/ToRadians(const/degrees)
					// Pi / 180
	return degrees * 0.0174532925

// min is inclusive, max is exclusive
/proc/Wrap(val, min, max)
	var/d = max - min
	var/t = Floor((val - min) / d)
	return val - (t * d)

/*
 * A very crude linear approximatiaon of pythagoras theorem.
 */
/proc/cheap_pythag(const/Ax, const/Ay)
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
	var/dx = abs(Ax - Bx) // Sides of right-angled triangle.
	var/dy = abs(Ay - By)

	if (dx >= dy)
		return (k1*dx) + (k2*dy) // No sqrt or powers :).
	else
		return (k2*dx) + (k1*dy)
#undef k1
#undef k2
