/// The defines of each animal type who have their respective organ and list of sprite accessories beholding to them
//	The string has to much the type name of the organ they represent, i.e. /obj/item/organ/external/tail/dog
#define NO_VARIATION "none"
#define FELINE "cat"
#define CANINE "dog"
#define REPTILE "lizard"
#define LEPORID "bunny"
#define AVIAN "bird"
#define MURIDAE "mouse"
#define PISCINE "fish"
#define SIMIAN "monkey"

///	This list gets read by the dropdown pref when a player chooses what type of sprite accessory to access
GLOBAL_LIST_INIT(mutant_variations, list(
	FELINE,
	CANINE,
	REPTILE,
	LEPORID,
	AVIAN,
	MURIDAE,
	PISCINE,
	SIMIAN,
))
