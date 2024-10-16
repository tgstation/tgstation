#define BASIC_MOB_MAX_STAMINALOSS 200

///Basic mob flags

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

#define RAPTOR_RED "Red"
#define RAPTOR_GREEN "Green"
#define RAPTOR_PURPLE "Purple"
#define RAPTOR_WHITE "White"
#define RAPTOR_YELLOW "Yellow"
#define RAPTOR_BLACK "Black"
#define RAPTOR_BLUE "Blue"

#define RAPTOR_INHERIT_MAX_ATTACK 5
#define RAPTOR_INHERIT_MAX_HEALTH 30

///this mob suffers depression
#define BB_BASIC_DEPRESSED "basic_depressed"
///this mob will care for its young
#define BB_RAPTOR_MOTHERLY "raptor_motherly"
///this mob will be playful around their owners
#define BB_RAPTOR_PLAYFUL "raptor_playful"
///this mob will flee combat when it feels threatened
#define BB_RAPTOR_COWARD "raptor_coward"
///this mob will go out seeking trouble against its kind
#define BB_RAPTOR_TROUBLE_MAKER "raptor_trouble_maker"
///cooldown till we go out cause trouble again
#define BB_RAPTOR_TROUBLE_COOLDOWN "raptor_trouble_maker_cooldown"
///our raptor baby target we will take care of
#define BB_RAPTOR_BABY "raptor_baby"
///the raptor we will heal up
#define BB_INJURED_RAPTOR "injured_raptor"
///the raptor we will bully
#define BB_RAPTOR_VICTIM "raptor_victim"
///the cooldown for next time we eat
#define BB_RAPTOR_EAT_COOLDOWN "raptor_eat_cooldown"
///our trough target
#define BB_RAPTOR_TROUGH_TARGET "raptor_trough_target"

#define MAX_RAPTOR_POP 64
