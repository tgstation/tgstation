///electrified_buckle requires a shock kit attached to it in order to shock
#define SHOCK_REQUIREMENT_ITEM (1<<0)
///electrified_buckle requires a live cable to work, and draws power from it
#define SHOCK_REQUIREMENT_LIVE_CABLE (1<<1)
///electrified_buckle requires to be turned on with a signal in order to shock the buckled mob
#define SHOCK_REQUIREMENT_ON_SIGNAL_RECEIVED (1<<2)
///electrified_buckle requires the parent to be alive in order to shock (if parent is a mob)
#define SHOCK_REQUIREMENT_PARENT_MOB_ISALIVE (1<<3)
///a signal can toggle the ability to shock on a timer
#define SHOCK_REQUIREMENT_SIGNAL_RECEIVED_TOGGLE (1<<4)


///This trait signifies that the object can be used to electrify things buckled to it
#define TRAIT_ELECTRIFIED_BUCKLE "electrified buckle"
