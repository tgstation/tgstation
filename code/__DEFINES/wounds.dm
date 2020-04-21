#define WOUND_DAMAGE_EXPONENT	1.4

#define WOUND_SEVERITY_MODERATE	0
#define WOUND_SEVERITY_SEVERE	1
#define WOUND_SEVERITY_CRITICAL	2

#define WOUND_BRUTE	0
#define WOUND_SHARP	1
#define WOUND_BURN	2

// How much determination reagent to add each time someone gains a new wound in [/datum/wound/proc/second_wind()]
#define WOUND_DETERMINATION_MODERATE	1
#define WOUND_DETERMINATION_SEVERE		2.5
#define WOUND_DETERMINATION_CRITICAL	5

// set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

// list in order of highest severity to lowest
#define WOUND_TYPE_BONE	list(/datum/wound/brute/bone/critical, /datum/wound/brute/bone/severe, /datum/wound/brute/bone/moderate)
#define WOUND_TYPE_CUT	list(/datum/wound/brute/cut/critical, /datum/wound/brute/cut/severe, /datum/wound/brute/cut/moderate)
#define WOUND_TYPE_BURN	list(/datum/wound/burn/critical, /datum/wound/burn/severe, /datum/wound/burn/moderate)
