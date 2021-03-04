//ninjacost() specificCheck defines
#define N_STEALTH_CANCEL 1
#define N_ADRENALINE 2

//ninjaDrainAct() defines for non numerical returns
#define INVALID_DRAIN "INVALID" //This one is if the drain proc needs to cancel, eg missing variables, etc, it's important.
#define DRAIN_RD_HACK_FAILED "RDHACKFAIL"
#define DRAIN_MOB_SHOCK "MOBSHOCK"
#define DRAIN_MOB_SHOCK_FAILED "MOBSHOCKFAIL"

//Tells whether or not someone is a space ninja
#define IS_SPACE_NINJA(ninja) (ninja.mind && ninja.mind.has_antag_datum(/datum/antagonist/ninja))

//Defines for the suit's unique abilities
#define IS_NINJA_SUIT_INITIALIZATION(action) (istype(action, /datum/action/item_action/initialize_ninja_suit))
#define IS_NINJA_SUIT_STATUS(action) (istype(action, /datum/action/item_action/ninjastatus))
#define IS_NINJA_SUIT_BOOST(action) (istype(action, /datum/action/item_action/ninjaboost))
#define IS_NINJA_SUIT_EMP(action) (istype(action, /datum/action/item_action/ninjapulse))
#define IS_NINJA_SUIT_STAR_CREATION(action) (istype(action, /datum/action/item_action/ninjastar))
#define IS_NINJA_SUIT_NET_CREATION(action) (istype(action, /datum/action/item_action/ninjanet))
#define IS_NINJA_SUIT_SWORD_RECALL(action) (istype(action, /datum/action/item_action/ninja_sword_recall))
#define IS_NINJA_SUIT_STEALTH(action) (istype(action, /datum/action/item_action/ninja_stealth))
