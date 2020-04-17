#define WOUND_DAMAGE_EXPONENT	1.4

#define WOUND_SEVERITY_MODERATE	0
#define WOUND_SEVERITY_SEVERE	1
#define WOUND_SEVERITY_CRITICAL	2

#define WOUND_BRUTE	0
#define WOUND_SHARP	1
#define WOUND_BURN	2

// list in order of highest severity to lowest
#define WOUND_TYPE_BONE	list(/datum/wound/brute/bone/critical, /datum/wound/brute/bone/severe, /datum/wound/brute/bone/moderate)
#define WOUND_TYPE_CUT	list(/datum/wound/brute/cut/critical, /datum/wound/brute/cut/severe, /datum/wound/brute/cut/moderate)
#define WOUND_TYPE_BURN	list(/datum/wound/burn/critical, /datum/wound/burn/severe, /datum/wound/burn/moderate)
