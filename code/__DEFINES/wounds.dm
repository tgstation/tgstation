#define WOUND_DAMAGE_EXPONENT	1.4

#define WOUND_SEVERITY_TRIVIAL	0 // for jokey/meme wounds like stubbed toe, no standard messages/sounds or second winds
#define WOUND_SEVERITY_MODERATE	1
#define WOUND_SEVERITY_SEVERE	2
#define WOUND_SEVERITY_CRITICAL	3
#define WOUND_SEVERITY_LOSS		4 // theoretical total limb loss, like dismemberment for cuts

#define WOUND_BRUTE	0
#define WOUND_SHARP	1
#define WOUND_BURN	2

// How much determination reagent to add each time someone gains a new wound in [/datum/wound/proc/second_wind()]
#define WOUND_DETERMINATION_MODERATE	1
#define WOUND_DETERMINATION_SEVERE		2.5
#define WOUND_DETERMINATION_CRITICAL	5

#define WOUND_DETERMINATION_MAX			10

// set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

// list in order of highest severity to lowest
#define WOUND_TYPE_BONE		list(/datum/wound/brute/bone/critical, /datum/wound/brute/bone/severe, /datum/wound/brute/bone/moderate)
#define WOUND_TYPE_CUT		list(/datum/wound/brute/cut/loss, /datum/wound/brute/cut/critical, /datum/wound/brute/cut/severe, /datum/wound/brute/cut/moderate)
#define WOUND_TYPE_BURN		list(/datum/wound/burn/critical, /datum/wound/burn/severe, /datum/wound/burn/moderate)
#define WOUND_TYPE_SPECIAL	list(/datum/wound/brute/stubbed_toe)

// Thresholds for infection for burn wounds, once infestation hits each threshold, things get steadily worse
#define WOUND_INFECTION_MODERATE	4 // below this has no ill effects from infection
#define WOUND_INFECTION_SEVERE		8 // then below here, you ooze some pus and suffer minor tox damage, but nothing serious
#define WOUND_INFECTION_CRITICAL	12 // then below here, your limb occasionally locks up from damage and infection and briefly becomes disabled. Things are getting really bad
#define WOUND_INFECTION_SEPTIC		20 // below here, your skin is almost entirely falling off and your limb locks up more frequently. You are within a stone's throw of septic paralysis and losing the limb
// above WOUND_INFECTION_SEPTIC, your limb is completely putrid and you start rolling to lose the entire limb by way of paralyzation. After 3 failed rolls (~4-5% each probably), the limb is paralyzed

#define WOUND_BURN_SANITIZATION_RATE 0.3 // how quickly sanitization removes infestation and decays per tick
