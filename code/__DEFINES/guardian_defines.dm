#define GUARDIAN_THEME_TECH "tech"
#define GUARDIAN_THEME_MAGIC "magic"
#define GUARDIAN_THEME_CARP "carp"
#define GUARDIAN_THEME_MINER "miner"

#define GUARDIAN_COLOR_LAYER 1
#define GUARDIAN_TOTAL_LAYERS 1

#define GUARDIAN_ASSASSIN "assassin"
#define GUARDIAN_CHARGER "charger"
#define GUARDIAN_DEXTROUS "dextrous"
#define GUARDIAN_EXPLOSIVE "explosive"
#define GUARDIAN_GASEOUS "gaseous"
#define GUARDIAN_GRAVITOKINETIC "gravitokinetic"
#define GUARDIAN_LIGHTNING "lightning"
#define GUARDIAN_PROTECTOR "protector"
#define GUARDIAN_RANGED "ranged"
#define GUARDIAN_STANDARD "standard"
#define GUARDIAN_SUPPORT "support"

GLOBAL_LIST_INIT(guardian_themes, list(
	GUARDIAN_THEME_TECH = new /datum/guardian_fluff/tech,
	GUARDIAN_THEME_MAGIC = new /datum/guardian_fluff,
	GUARDIAN_THEME_CARP = new /datum/guardian_fluff/carp,
	GUARDIAN_THEME_MINER = new /datum/guardian_fluff/miner,
))
