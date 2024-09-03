/// Action has succeeded, preventing further alt click interaction
#define CLICK_ACTION_SUCCESS (1<<0)
/// Action failed, preventing further alt click interaction
#define CLICK_ACTION_BLOCKING (1<<1)
/// Either return state
#define CLICK_ACTION_ANY (CLICK_ACTION_SUCCESS | CLICK_ACTION_BLOCKING)
/// Use NONE for continue interaction
