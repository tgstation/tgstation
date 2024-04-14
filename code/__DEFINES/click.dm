/**
 * The difference between NONE and BLOCKING should be whether the source atom gave some sort of feedback to the user.
 * Examples:
 *
 * User is a ghost, alt clicks on item with special disk eject: NONE
 * Machine broken, no feedback: NONE
 * User unauthorized, machine beeps: BLOCKING
 *
 * Generally in the flow of a proc, the NONE flags should returned by guard clauses, and BLOCKING flags occur thereafter
 */

/// Action has succeeded, preventing further alt click interaction
#define CLICK_ACTION_SUCCESS (1<<0)
/// Action failed, preventing further alt click interaction
#define CLICK_ACTION_BLOCKING (1<<1)
/// Use NONE for continue interaction
