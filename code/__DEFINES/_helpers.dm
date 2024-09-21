// Stuff that is relatively "core" and is used in other defines/helpers

/**
 * The game's world.icon_size. \
 * Ideally divisible by 16. \
 * Ideally a number. \
 * Can be a string (32x32), so more exotic coders
 * will be sad if you use this in math. \
 * Preferably use ICONSIZE_X or ICONSIZE_Y when you can.
 */
#define ICONSIZE_ALL 32
/// The X dimension of the ICONSIZE. This will more than likely be the bigger one.
#define ICONSIZE_X 32
/// The Y dimension of the ICONSIZE. This will more than likely be the smaller one.
#define ICONSIZE_Y 32

//Returns the hex value of a decimal number
//len == length of returned string
#define num2hex(X, len) num2text(X, len, 16)

//Returns an integer given a hex input, supports negative values "-ff"
//skips preceding invalid characters
#define hex2num(X) text2num(X, 16)

/// Stringifies whatever you put into it.
#define STRINGIFY(argument) #argument

/// subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

/// Until a condition is true, sleep
#define UNTIL(X) while(!(X)) stoplag()

/// Sleep if we haven't been deleted
/// Otherwise, return
#define SLEEP_NOT_DEL(time) \
	if(QDELETED(src)) { \
		return; \
	} \
	sleep(time);

/// Takes a datum as input, returns its ref string
#define text_ref(datum) ref(datum)

// Refs contain a type id within their string that can be used to identify byond types.
// Custom types that we define don't get a unique id, but this is useful for identifying
// types that don't normally have a way to run istype() on them.
#define TYPEID(thing) copytext(REF(thing), 4, 6)

/// A null statement to guard against EmptyBlock lint without necessitating the use of pass()
/// Used to avoid proc-call overhead. But use sparingly. Probably pointless in most places.
#define EMPTY_BLOCK_GUARD ;
