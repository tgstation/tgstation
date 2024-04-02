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

/// Temporary trait applied when an attack forecast animation has completed
#define TRAIT_BASIC_ATTACK_FORECAST "trait_basic_attack_forecast"
#define INTERACTION_BASIC_ATTACK_FORCEAST "interaction_basic_attack_forecast"

/// Above this speed we stop gliding because it looks silly
#define END_GLIDE_SPEED 10

///mook attack status flags
#define MOOK_ATTACK_NEUTRAL 0
#define MOOK_ATTACK_WARMUP 1
#define MOOK_ATTACK_ACTIVE 2
#define MOOK_ATTACK_STRIKE 3

///keeps track of how many gutlunches are born
GLOBAL_VAR_INIT(gutlunch_count, 0)

//raptor defines

#define RAPTOR_RED "Red"
#define RAPTOR_GREEN "Green"
#define RAPTOR_PURPLE "Purple"
#define RAPTOR_WHITE "White"
#define RAPTOR_YELLOW "Yellow"
#define RAPTOR_BLACK "Black"

#define RAPTOR_INHERIT_MAX_ATTACK 5
#define RAPTOR_INHERIT_MAX_HEALTH 30

GLOBAL_LIST_INIT(raptor_growth_paths, list(
	/mob/living/basic/mining/raptor/baby_raptor/red = list(RAPTOR_PURPLE, RAPTOR_WHITE),
	/mob/living/basic/mining/raptor/baby_raptor/white = list(RAPTOR_GREEN, RAPTOR_PURPLE),
	/mob/living/basic/mining/raptor/baby_raptor/purple = list(RAPTOR_GREEN, RAPTOR_WHITE),
	/mob/living/basic/mining/raptor/baby_raptor/yellow = list(RAPTOR_GREEN, RAPTOR_RED),
	/mob/living/basic/mining/raptor/baby_raptor/green = list(RAPTOR_RED, RAPTOR_YELLOW),
))
