#define BITRUNNER_COST_NONE 0
#define BITRUNNER_COST_LOW 1
#define BITRUNNER_COST_MEDIUM 2
#define BITRUNNER_COST_HIGH 3
#define BITRUNNER_COST_EXTREME 20

/// Yay you did it
#define BITRUNNER_REWARD_MIN 1
/// You faced some decent odds
#define BITRUNNER_REWARD_LOW 3
/// One of your teammates might've died
#define BITRUNNER_REWARD_MEDIUM 4
/// Heroic effort
#define BITRUNNER_REWARD_HIGH 5
/// For the priciest domains, free loot basically
#define BITRUNNER_REWARD_EXTREME 6

/// Blue in ui. Basically the only threat is rogue ghosts roles
#define BITRUNNER_DIFFICULTY_NONE 0
/// Yellow. Mobs are kinda dumb and largely avoidable
#define BITRUNNER_DIFFICULTY_LOW 1
/// Orange. Mobs will shoot at you or are pretty aggressive
#define BITRUNNER_DIFFICULTY_MEDIUM 2
/// Red with skull. I am trying to kill bitrunners.
#define BITRUNNER_DIFFICULTY_HIGH 3

/// Camera network bitrunner bodycams are on
#define BITRUNNER_CAMERA_NET "bitrunner"

/**
 * Bitrunner Domain External Load Restriction Bitflags
 */
/// Domain forbids external sources from loading items onto avatars
#define DOMAIN_FORBIDS_ITEMS (1<<0)
/// Domain forbids external sources from loading abilities onto avatars
#define DOMAIN_FORBIDS_ABILITIES (1<<1)

/// Combination flag for blocking anything from being loaded onto avatars by external sources
#define DOMAIN_FORBIDS_ALL ALL

/**
 * COMSIG_BITRUNNER_STOCKING_GEAR Return Bitflags
 */
/// Something failed to load
#define BITRUNNER_GEAR_LOAD_FAILED (1<<0)
/// The domain restrictions blocked something from loading
#define BITRUNNER_GEAR_LOAD_BLOCKED (1<<1)
