/// Use in fish tables to denote miss chance.
#define FISHING_DUD "dud"

// Baseline fishing difficulty levels
#define FISHING_DEFAULT_DIFFICULTY 15
#define FISHING_EASY_DIFFICULTY 10

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

///Slot defines for the fishing rod and its equipment
#define ROD_SLOT_BAIT "bait"
#define ROD_SLOT_LINE "line"
#define ROD_SLOT_HOOK "hook"

#define ADDITIVE_FISHING_MOD "additive"
#define MULTIPLICATIVE_FISHING_MOD "multiplicative"

// These defines are intended for use to interact with fishing hooks when going
// through the fishing rod, and not the hook itself. They could probably be
// handled differently, but for now that's how they work. It's grounds for
// a future refactor, however.
/// Fishing hook trait that signifies that it's shiny. Useful for fishes
/// that care about shiner hooks more.
#define FISHING_HOOK_SHINY (1 << 0)
/// Fishing hook trait that lessens the bounce from hitting the edges of the minigame bar.
#define FISHING_HOOK_WEIGHTED (1 << 1)
///See FISHING_MINIGAME_RULE_BIDIRECTIONAL
#define FISHING_HOOK_BIDIRECTIONAL (1 << 2)
///Prevents the user from losing the game by letting the fish get away.
#define FISHING_HOOK_NO_ESCAPE (1 << 3)
///Limits the completion loss of the minigame when the fsh is not on the bait area.
#define FISHING_HOOK_ENSNARE (1 << 4)
///Automatically kills the fish after a while, at the cost of killing it.
#define FISHING_HOOK_KILL (1 << 5)

///Reduces the difficulty of the minigame
#define FISHING_LINE_CLOAKED (1 << 0)
///Required to cast a line on lava.
#define FISHING_LINE_REINFORCED (1 << 1)
/// Much like FISHING_HOOK_ENSNARE but for the fishing line.
#define FISHING_LINE_BOUNCY (1 << 2)
/// The sorta opposite of FISHING_LINE_BOUNCY. It makes it slower to gain completion and faster to lose it.
#define FISHING_LINE_STIFF (1 << 3)
///Skip the biting phase and go straight to the fishing phase.
#define FISHING_LINE_AUTOREEL (1 << 4)

///Keeps the bait from falling from gravity, instead allowing the player to move the bait down with right click.
#define FISHING_MINIGAME_RULE_BIDIRECTIONAL (1 << 0)
///Prevents the player from losing the minigame when the completion reaches 0
#define FISHING_MINIGAME_RULE_NO_ESCAPE (1 << 1)
///Automatically kills the fish after a while, at the cost of killing it
#define FISHING_MINIGAME_RULE_KILL (1 << 2)
///Prevents the fishing skill from having an effect on the minigame and experience from being awarded
#define FISHING_MINIGAME_RULE_NO_EXP (1 << 3)
///If enabled, the minigame will occasionally screw around and invert the velocity of the bait
#define FISHING_MINIGAME_RULE_ANTIGRAV (1 << 4)
///Will filp the minigame hud for the duration of the effect
#define FISHING_MINIGAME_RULE_FLIP (1 << 5)
///Skip the biting phase and go straight to the minigame, avoiding the penalty for having slow reflexes.
#define FISHING_MINIGAME_AUTOREEL (1 << 6)

///all the effects that are active and will last for a few seconds before triggering a cooldown
#define FISHING_MINIGAME_ACTIVE_EFFECTS (FISHING_MINIGAME_RULE_ANTIGRAV|FISHING_MINIGAME_RULE_FLIP)

/// The default additive value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_ADDITIVE 0
/// The default multiplicative value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_MULTIPLICATIVE 1

//Fish icon defines, used by fishing minigame
#define FISH_ICON_DEF "fish"
#define FISH_ICON_HOSTILE "hostile"
#define FISH_ICON_STAR "star"
#define FISH_ICON_CHUNKY "chunky"
#define FISH_ICON_SLIME "slime"
#define FISH_ICON_COIN "coin"
#define FISH_ICON_GEM "gem"
#define FISH_ICON_CRAB "crab"
#define FISH_ICON_JELLYFISH "jellyfish"
#define FISH_ICON_BONE "bone"

#define AQUARIUM_ANIMATION_FISH_SWIM "fish"
#define AQUARIUM_ANIMATION_FISH_DEAD "dead"

#define AQUARIUM_PROPERTIES_PX_MIN "px_min"
#define AQUARIUM_PROPERTIES_PX_MAX "px_max"
#define AQUARIUM_PROPERTIES_PY_MIN "py_min"
#define AQUARIUM_PROPERTIES_PY_MAX "py_max"

#define AQUARIUM_LAYER_MODE_BOTTOM "bottom"
#define AQUARIUM_LAYER_MODE_TOP "top"
#define AQUARIUM_LAYER_MODE_AUTO "auto"
#define AQUARIUM_LAYER_MODE_BEHIND_GLASS "behind_glass"

#define FISH_ALIVE "alive"
#define FISH_DEAD "dead"

///Fish size thresholds for w_class.
#define FISH_SIZE_TINY_MAX 30
#define FISH_SIZE_SMALL_MAX 50
#define FISH_SIZE_NORMAL_MAX 90
#define FISH_SIZE_BULKY_MAX 130

///The coefficient for maximum weight/size divergence relative to the averages.
#define MAX_FISH_DEVIATION_COEFF 2.5

///The volume of the grind results is multiplied by the fish' weight and divided by this.
#define FISH_GRIND_RESULTS_WEIGHT_DIVISOR 500
///The number of fillets is multiplied by the fish' size and divided by this.
#define FISH_FILLET_NUMBER_SIZE_DIVISOR 30

///The breeding timeout for newly instantiated fish is multiplied by this.
#define NEW_FISH_BREEDING_TIMEOUT_MULT 2
///The last feeding timestamp of newly instantiated fish is multiplied by this: ergo, they spawn 50% hungry.
#define NEW_FISH_LAST_FEEDING_MULT 0.5

#define MIN_AQUARIUM_TEMP T0C
#define MAX_AQUARIUM_TEMP (T0C + 100)
#define DEFAULT_AQUARIUM_TEMP (T0C + 24)

///How likely one's to find a given fish from random fish cases.
#define FISH_RARITY_BASIC 1000
#define FISH_RARITY_RARE 400
#define FISH_RARITY_VERY_RARE 200
#define FISH_RARITY_GOOD_LUCK_FINDING_THIS 5
#define FISH_RARITY_NOPE 0

///Aquarium fluid variables. The fish' required fluid has to match this, or it'll slowly die.
#define AQUARIUM_FLUID_FRESHWATER "Freshwater"
#define AQUARIUM_FLUID_SALTWATER "Saltwater"
#define AQUARIUM_FLUID_SULPHWATEVER "Sulfuric Water"
#define AQUARIUM_FLUID_AIR "Air"
#define AQUARIUM_FLUID_ANADROMOUS "Adaptive to both Freshwater and Saltwater"
#define AQUARIUM_FLUID_ANY_WATER "Adaptive to all kind of water"

///Fluff. The name of the aquarium company shown in the fish catalog
#define AQUARIUM_COMPANY "Aquatech Ltd."

/// how long between electrogenesis zaps
#define ELECTROGENESIS_DURATION 40 SECONDS
/// a random range the electrogenesis cooldown varies by
#define ELECTROGENESIS_VARIANCE (rand(-10 SECONDS, 10 SECONDS))
