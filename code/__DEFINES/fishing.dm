/// Use in fish tables to denote miss chance.
#define FISHING_DUD "dud"

// Baseline fishing difficulty levels
#define FISHING_DEFAULT_DIFFICULTY 15

/// Difficulty modifier when bait is fish's favorite
#define FAV_BAIT_DIFFICULTY_MOD -5
/// Difficulty modifier when bait is fish's disliked
#define DISLIKED_BAIT_DIFFICULTY_MOD 15
/// Difficulty modifier when our fisherman has the trait TRAIT_SETTLER
#define SETTLER_DIFFICULTY_MOD -5


#define FISH_TRAIT_MINOR_DIFFICULTY_BOOST 5

// These define how the fish will behave in the minigame
#define FISH_AI_DUMB "dumb"
#define FISH_AI_ZIPPY "zippy"
#define FISH_AI_SLOW "slow"

#define ADDITIVE_FISHING_MOD "additive"
#define MULTIPLICATIVE_FISHING_MOD "multiplicative"

// These defines are intended for use to interact with fishing hooks when going
// through the fishing rod, and not the hook itself. They could probably be
// handled differently, but for now that's how they work. It's grounds for
// a future refactor, however.
/// Fishing hook trait that signifies that it's shiny. Useful for fishes
/// that care about shiner hooks more.
#define FISHING_HOOK_SHINY (1 << 0)
/// Fishing hook trait that's used to make the bait more weighted, for the
/// fishing minigame itself.
#define FISHING_HOOK_WEIGHTED (1 << 1)
/**
 * During the fishing minigame, it stops the bait from being pulled down by gravity,
 * while also allowing the player to move it down with right-click.
 */
#define FISHING_HOOK_BIDIRECTIONAL (1 << 2)
///Prevents the user from losing the game by letting the fish get away.
#define FISHING_HOOK_NO_ESCAPE (1 << 3)
///Limits the completion loss of the minigame when the fsh is not on the bait area.
#define FISHING_HOOK_ENSNARE (1 << 4)
///Slowly damages the fish, until it dies, then it's victory.
#define FISHING_HOOK_KILL (1 << 5)

///Reduces the difficulty of the minigame
#define FISHING_LINE_CLOAKED (1 << 0)
///Required to cast a line on lava.
#define FISHING_LINE_REINFORCED (1 << 1)
/// Much like FISHING_HOOK_ENSNARE but for the reel.
#define FISHING_LINE_BOUNCY (1 << 2)

#define FISHING_MINIGAME_RULE_HEAVY_FISH "heavy"
#define FISHING_MINIGAME_RULE_LUBED_FISH "lubed"
#define FISHING_MINIGAME_RULE_WEIGHTED_BAIT "weighted"
#define FISHING_MINIGAME_RULE_LIMIT_LOSS "limit_loss"
#define FISHING_MINIGAME_RULE_BIDIRECTIONAL "bidirectional"
#define FISHING_MINIGAME_RULE_NO_ESCAPE "no_escape"
#define FISHING_MINIGAME_RULE_KILL "kill"
#define FISHING_MINIGAME_RULE_NO_EXP "no_exp"

/// The default additive value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_ADDITIVE 0
/// The default multiplicative value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_MULTIPLICATIVE 1
