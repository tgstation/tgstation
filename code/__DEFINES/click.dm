/**
 * The difference between NONE and BLOCKING can get hazy, but I like to keep NONE limited to guard clauses and "never" cases.
 * A good usage for BLOCKING over NONE is when it's situational for the item and there's some feedback indicating this.
 * Examples:
 *
 * User is a ghost, alt clicks on item with special disk eject: NONE
 * Machine broken, no feedback: NONE
 * Alt click a pipe to max output but its already max: BLOCKING
 * Alt click a gun that normally works, but is out of ammo: BLOCKING
 * User unauthorized, machine beeps: BLOCKING
 */

/// Action has succeeded, preventing further alt click interaction
#define CLICK_ACTION_SUCCESS (1<<0)
/// Action failed, preventing further alt click interaction
#define CLICK_ACTION_BLOCKING (1<<1)
/// Use NONE for continue interaction
