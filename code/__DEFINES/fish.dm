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

///The fish will swim up slowlier and down faster.
#define FISHING_MINIGAME_RULE_HEAVY_FISH "heavy"
///Multiplies the acceleration of the bait by a slippery 1.4
#define FISHING_MINIGAME_RULE_LUBED "lubed"
///Reduces the bounce coefficient when hitting the bounds from 0.6 to 0.1
#define FISHING_MINIGAME_RULE_WEIGHTED_BAIT "weighted"
///Limits the completion loss of the minigame when the fsh is not on the bait area
#define FISHING_MINIGAME_RULE_LIMIT_LOSS "limit_loss"
///Stops the bait from getting dragged down by gravity, instead allowing the player to do so by pressing the ctrl key.
#define FISHING_MINIGAME_RULE_BIDIRECTIONAL "bidirectional"
///Prevents the fish from getting away and thus the user losing the minigame
#define FISHING_MINIGAME_RULE_NO_ESCAPE "no_escape"
///Slowly damages the fish, until it dies, then it's victory
#define FISHING_MINIGAME_RULE_KILL "kill"
///Prevents the fishing skill from having an effect on the minigame and experience being given
#define FISHING_MINIGAME_RULE_NO_EXP "no_exp"
///If enabled, the minigame will screw around and occasionally flip the velocity of the bait
#define FISHING_MINIGAME_RULE_ANTIGRAV "antigrav"
///When activated, The position of both fish and bait will be shown flipped for the duration of the effect.
#define FISHING_MINIGAME_RULE_FLIP "flip"

///These are fishing traits not handled by minigame itself but fish traits.

/// Fishing hook trait that signifies that it's shiny. Useful for fishes that care about shiner hooks more.
#define FISHING_HOOK_SHINY "shiny"
///Reduces the difficulty of the minigame for wary fishes.
#define FISHING_LINE_CLOAKED "cloaked"
///Required to cast a line on lava.
#define FISHING_LINE_REINFORCED "reinforced"

/// The default additive value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_ADDITIVE 0
/// The default multiplicative value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_MULTIPLICATIVE 1

#define AQUARIUM_ANIMATION_FISH_SWIM "fish"
#define AQUARIUM_ANIMATION_FISH_DEAD "dead"

#define AQUARIUM_PROPERTIES_PX_MIN "px_min"
#define AQUARIUM_PROPERTIES_PX_MAX "px_max"
#define AQUARIUM_PROPERTIES_PY_MIN "py_min"
#define AQUARIUM_PROPERTIES_PY_MAX "py_max"

#define AQUARIUM_LAYER_MODE_BOTTOM "bottom"
#define AQUARIUM_LAYER_MODE_TOP "top"
#define AQUARIUM_LAYER_MODE_AUTO "auto"

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
