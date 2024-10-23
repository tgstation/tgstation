/// The defines of each animal type who have their respective organ and list of sprite accessories beholding to them
//	The string has to much the type name of the organ they represent, i.e. /obj/item/organ/external/tail/dog
#define NO_VARIATION "none"
#define ALIEN "alien"
#define BIRD "bird"
#define BUG "bug"
#define BUNNY "bunny"
#define CAT "cat"
#define CYBERNETIC "cybernetic"
#define DEER "deer"
#define DOG "dog"
#define FISH "fish"
#define FOX "fox"
#define FROG "frog"
#define HUMANOID "humanoid"
#define LIZARD "lizard"
#define MONKEY "monkey"
#define MOUSE "mouse"

///	This list gets read by the dropdown pref when a player chooses what type of sprite accessory to access
GLOBAL_LIST_INIT(mutant_variations, list(
	ALIEN,
	BIRD,
	BUG,
	BUNNY,
	CAT,
	CYBERNETIC,
	DEER,
	DOG,
	FISH,
	FOX,
	HUMANOID,
	LIZARD,
	MONKEY,
	MOUSE,
))

///	This list gets read by the animalistic preference for genemod and anthros
GLOBAL_LIST_INIT(genemod_variations, list(
	BIRD,
	BUG,
	BUNNY,
	CAT,
	DEER,
	DOG,
	FISH,
	FOX,
	FROG,
	LIZARD,
	MONKEY,
	MOUSE,
	NO_VARIATION,
))
