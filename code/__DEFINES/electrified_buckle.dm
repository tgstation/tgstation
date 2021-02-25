///parent requires a shock kit attached to it in order to shock
#define SHOCK_REQUIREMENT_ITEM (1<<0)

#define SHOCK_REQUIREMENT_LIVE_CABLE (1<<1)

#define SHOCK_REQUIREMENT_ON_SIGNAL_RECIEVED (1<<2)

#define SHOCK_REQUIREMENT_PARENT_MOB_ISALIVE (1<<3)
///a signal can toggle the ability to shock on a timer
#define SHOCK_REQUIREMENT_SIGNAL_RECIEVED_TOGGLE (1<<4)


///does nothing except allow us to not use GetComponent
#define TRAIT_ELECTRIFIED_CHAIR "electrified chair"
