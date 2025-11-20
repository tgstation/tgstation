///Basic mob flags

/// Stamina threshold to not experience stamina crit
#define BASIC_MOB_NO_STAMCRIT 0

/// Max stamina should be equal to max health
#define BASIC_MOB_STAMINA_MATCH_HEALTH -1

/// Delete mob upon death
#define DEL_ON_DEATH (1<<0)
/// Rotate mob 180 degrees while it is dead
#define FLIP_ON_DEATH (1<<1)
/// Mob remains dense while dead
#define REMAIN_DENSE_WHILE_DEAD (1<<2)
/// Mob can be set on fire
#define FLAMMABLE_MOB (1<<3)
/// Mob never takes damage from unarmed attacks
#define IMMUNE_TO_FISTS (1<<4)
/// Mob is immune to getting wet
#define IMMUNE_TO_GETTING_WET (1<<5)
/// Disables the function of attacking random body zones
#define PRECISE_ATTACK_ZONES (1<<6)
/// People would be sad to see this mob die
#define SENDS_DEATH_MOODLETS (1<<7)

/// Temporary trait applied when an attack forecast animation has completed
#define TRAIT_BASIC_ATTACK_FORECAST "trait_basic_attack_forecast"
#define INTERACTION_BASIC_ATTACK_FORCEAST "interaction_basic_attack_forecast"

/// Above this speed we stop gliding because it looks silly
#define END_GLIDE_SPEED 10

///hunger cooldown for basic mobs
#define EAT_FOOD_COOLDOWN 45 SECONDS

///mook attack status flags
#define MOOK_ATTACK_NEUTRAL 0
#define MOOK_ATTACK_WARMUP 1
#define MOOK_ATTACK_ACTIVE 2
#define MOOK_ATTACK_STRIKE 3

/// Keeps track of how many gutlunches are born
GLOBAL_VAR_INIT(gutlunch_count, 0)

/// Pet customization settings saved for every client
GLOBAL_LIST_EMPTY(customized_pets)

// Raptor defines
/// Raptor chick, tiny and very frail
#define RAPTOR_BABY "baby"
/// Raptor youngling, cannot be ridden and has reduced stats, but can hunt by itself just fine
#define RAPTOR_YOUNG "young"
/// Fully grown adult raptor
#define RAPTOR_ADULT "adult"

/// Innate raptor offsets
#define RAPTOR_INNATE_SOURCE "raptor_innate"

// Growth values
/// How much does meal complexity affect our growth?
#define RAPTOR_MEAL_COMPLEXITY_GROWTH_FACTOR 5
/// Base value for raptor growth from meat
#define RAPTOR_GROWTH_BASE_MEAT 10
/// Base value for raptor growth from ash flora
#define RAPTOR_GROWTH_BASE_PLANT 5
/// How much growth progress raptors need to accumulate to fully grow into an adult
#define RAPTOR_GROWTH_REQUIRED 100
/// Minimum random growth value a baby raptor can gain per second
#define RAPTOR_BABY_GROWTH_LOWER 0.5
/// Maximum random growth value a baby raptor can gain per second
#define RAPTOR_BABY_GROWTH_UPPER 0.8
/// How long it takes for a raptor egg to grow up, in seconds
#define RAPTOR_EGG_GROWTH_PROGRESS 100
/// How much happiness percentage affects our growth speed
#define RAPTOR_GROWTH_HAPPINESS_MULTIPLIER 0.005 // Full happiness increases growth rate by 50%

/// Damage boost per happiness percent
#define RAPTOR_HAPPINESS_DAMAGE_BOOST 0.05

// Raptor inheritance stats
/// Maximum amount of traits a raptor can inherit
#define RAPTOR_TRAIT_INHERIT_AMOUNT 2
/// Minimum modifier to base attack values a raptor can get
#define RAPTOR_INHERIT_MIN_ATTACK -5
/// Maximum modifier to base attack values a raptor can get
#define RAPTOR_INHERIT_MAX_ATTACK 5
/// Minimum modifier to the base health value a raptor can get
#define RAPTOR_INHERIT_MIN_HEALTH -30
/// Maximum modifier to the base health value a raptor can get
#define RAPTOR_INHERIT_MAX_HEALTH 30
/// Minimum modifier to base speed values a raptor can get
#define RAPTOR_INHERIT_MIN_SPEED -0.66
/// Maximum modifier to base speed values a raptor can get
#define RAPTOR_INHERIT_MAX_SPEED 0.66
/// Minimum modifier a raptor can get to their modifiers, such as ability effect and growth speed
#define RAPTOR_INHERIT_MIN_MODIFIER -0.25
/// Maximum modifier a raptor can get to their modifiers, such as ability effect and growth speed
#define RAPTOR_INHERIT_MAX_MODIFIER 0.25
/// Genetic drift for raptors, aka min/max value from the cap that stats can receive when breeding
#define RAPTOR_GENETIC_DRIFT 0.2

/// This mob suffers depression
#define BB_BASIC_DEPRESSED "basic_depressed"
/// This mob will care for its young
#define BB_RAPTOR_MOTHERLY "raptor_motherly"
/// This mob will be playful around their owners
#define BB_RAPTOR_PLAYFUL "raptor_playful"
/// This mob will flee combat when it feels threatened
#define BB_RAPTOR_COWARD "raptor_coward"
/// Our raptor baby target we will take care of
#define BB_RAPTOR_BABY "raptor_baby"
/// The raptor we will heal up
#define BB_INJURED_RAPTOR "injured_raptor"
/// The cooldown for next time we eat
#define BB_RAPTOR_EAT_COOLDOWN "raptor_eat_cooldown"
/// Our trough target
#define BB_RAPTOR_TROUGH_TARGET "raptor_trough_target"
/// HP level at which we'll flee from attackers
#define BB_RAPTOR_FLEE_THRESHOLD "raptor_flee_threshold"

#define MAX_RAPTOR_POP 64
