/**
 * NAMEOF: Compile time checked variable name to string conversion
 * evaluates to a string equal to "X", but compile errors if X isn't a var on datum.
 * datum may be null, but it does need to be a typed var.
 **/
#define NAMEOF(datum, X) (#X || ##datum.##X)

/**
 * NAMEOF that actually works in static definitions because src::type requires src to be defined
 */
#define NAMEOF_STATIC(datum, X) (nameof(type::##X))

/**
 * NAMEOF_TYPEPATH: Compile time checked variable name to string conversion for typepath.
 * Unlike NAMEOF, this uses the '::' operator to check for a var on the typepath, and will error if X is not defined.
 */
#define NAMEOF_TYPEPATH(datum, X) (#X || ##datum::##X)

/**
 * NAMEOF_UNIVERSAL: Compile time checked variable name to string conversion that works for both instances and typepaths.
 * Checks both datum.X and datum::X to handle both cases.
 * Will compile error if X doesn't exist as either an instance var or a typepath var.
 */
#define NAMEOF_UNIVERSAL(datum, X) (#X || ##datum.##X || ##datum::##X)
