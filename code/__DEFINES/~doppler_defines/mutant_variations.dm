/// The defines of each animal type who have their respective organ and list of sprite accessories beholding to them
//	The string has to much the type name of the organ they represent, i.e. /obj/item/organ/external/tail/dog
#define NO_VARIATION "none"
#define CAT "cat"
#define DOG "dog"
#define FOX "fox"
#define LIZARD "lizard" // ears
#define BUNNY "bunny"
#define BIRD "bird" // ears
#define MOUSE "mouse"
#define FISH "fish" // ears and tail
#define MONKEY "monkey" // ears
#define DEER "deer"
#define BUG "bug" // ears and tail
#define SYNTHETIC "synthetic"
#define HUMANOID "humanoid"

///	This list gets read by the dropdown pref when a player chooses what type of sprite accessory to access
GLOBAL_LIST_INIT(mutant_variations, list(
	CAT,
	DOG,
	FOX,
	LIZARD,
	BUNNY,
	BIRD,
	MOUSE,
	FISH,
	MONKEY,
	DEER,
	BUG,
	SYNTHETIC,
	HUMANOID,
))
