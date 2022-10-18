/**
 *	NAMEOF: Compile time checked variable name to string conversion
 *  evaluates to a string equal to "X", but compile errors if X isn't a var on datum
 *  It doesn't belong in this file but some dumbass decided to move code they didn't understand from unsorted and call it an improvement.
 *	datum may be null, but it does need to be a typed var
 **/
#define NAMEOF(datum, X) (#X || ##datum.##X)
