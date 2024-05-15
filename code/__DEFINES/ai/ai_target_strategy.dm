//targeting datum defines

//relationship flags

/// target those who have good relations with the controller
#define TARGET_FRIENDS (1<<0)
/// target those who have no special relations to the controller
#define TARGET_NEUTRALS (1<<1)
/// target those who have bad relations with the controller
#define TARGET_FOES (1<<2)

/// do not check for faction
#define FACTION_CHECK_SKIP 0
/// check if any factions are in common
#define FACTION_CHECK_ANY 1
/// check if factions match
#define FACTION_CHECK_MATCHING 2
