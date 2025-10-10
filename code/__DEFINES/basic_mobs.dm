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

///keeps track of how many gutlunches are born
GLOBAL_VAR_INIT(gutlunch_count, 0)

///Pet customization settings saved for every client
GLOBAL_LIST_EMPTY(customized_pets)

//raptor defines
/// Raptor chick, tiny and very frail
#define RAPTOR_BABY "baby"
/// Raptor youngling, cannot be ridden and has reduced stats, but can hunt by itself just fine
#define RAPTOR_YOUNG "young"
/// Fully grown adult raptor
#define RAPTOR_ADULT "adult"

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

///this mob suffers depression
#define BB_BASIC_DEPRESSED "basic_depressed"
///this mob will care for its young
#define BB_RAPTOR_MOTHERLY "raptor_motherly"
///this mob will be playful around their owners
#define BB_RAPTOR_PLAYFUL "raptor_playful"
///this mob will flee combat when it feels threatened
#define BB_RAPTOR_COWARD "raptor_coward"
///our raptor baby target we will take care of
#define BB_RAPTOR_BABY "raptor_baby"
///the raptor we will heal up
#define BB_INJURED_RAPTOR "injured_raptor"
///the cooldown for next time we eat
#define BB_RAPTOR_EAT_COOLDOWN "raptor_eat_cooldown"
///our trough target
#define BB_RAPTOR_TROUGH_TARGET "raptor_trough_target"

#define MAX_RAPTOR_POP 64
