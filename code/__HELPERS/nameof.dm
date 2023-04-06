/**
 * NAMEOF: Compile time checked variable name to string conversion
 * evaluates to a string equal to "X", but compile errors if X isn't a var on datum.
 * datum may be null, but it does need to be a typed var.
 **/
#define NAMEOF(datum, X) (#X || ##datum.##X)

/**
 * NAMEOF that actually works in static definitions because src::type requires src to be defined
 */
#if DM_VERSION >= 515
#define NAMEOF_STATIC(datum, X) (nameof(type::##X))
#else
#define NAMEOF_STATIC(datum, X) (#X || ##datum.##X)
#endif
