/// The defines of each animal type who have their respective organ and list of sprite accessories beholding to them
//	The string has to much the type name of the organ they represent, i.e. /obj/item/organ/external/tail/dog
#define NO_VARIATION "none"
#define CAT "cat"
#define DOG "dog"
#define FOX "fox"
#define LIZARD "lizard"
#define BUNNY "bunny"
#define BIRD "bird"
#define MOUSE "mouse"
#define FISH "fish"
#define MONKEY "monkey"
#define DEER "deer"
#define BUG "bug"
#define CYBERNETIC "cybernetic"
#define HUMANOID "humanoid"
#define ALIEN "alien"

///	This list gets read by the dropdown pref when a player chooses what type of sprite accessory to access
GLOBAL_LIST_INIT(mutant_variations, list(
	BIRD,
	BUG,
	BUNNY,
	CAT,
	DEER,
	DOG,
	FISH,
	FOX,
	HUMANOID,
	LIZARD,
	MONKEY,
	MOUSE,
	CYBERNETIC,
	ALIEN,
))

///	This list gets read by the animalistic preference for genemod and anthros
GLOBAL_LIST_INIT(genemod_variations, list(
	NO_VARIATION,
	BIRD,
	BUNNY,
	CAT,
	DEER,
	DOG,
	FISH,
	FOX,
	LIZARD,
	MONKEY,
	MOUSE,
))
