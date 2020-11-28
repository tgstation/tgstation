#define LOADOUT_POINTS_MAX 10
#define LOADOUT_POINTS_MAX_DONATOR 20

#define LOADOUT_CATEGORY_NONE				"ERROR"
//Those three subcategories are good to apply to any category
#define LOADOUT_SUBCATEGORY_DONATOR			"Donator"
#define LOADOUT_SUBCATEGORY_MISC			"Miscellaneous"
#define LOADOUT_SUBCATEGORY_JOB 			"Job-related"

//In backpack
#define LOADOUT_CATEGORY_BACKPACK 				"In backpack"
#define LOADOUT_SUBCATEGORY_BACKPACK_TOYS 		"Toys"

//Neck
#define LOADOUT_CATEGORY_NECK 				"Neck"
#define LOADOUT_SUBCATEGORY_NECK_TIE 		"Ties"
#define LOADOUT_SUBCATEGORY_NECK_SCARVES 	"Scarves"

//Mask
#define LOADOUT_CATEGORY_MASK 				"Mask"

//In hands
#define LOADOUT_CATEGORY_HANDS 				"In hands"

//Uniform
#define LOADOUT_CATEGORY_UNIFORM 			"Uniform"
#define LOADOUT_SUBCATEGORY_UNIFORM_SUITS	"Suits"
#define LOADOUT_SUBCATEGORY_UNIFORM_SKIRTS	"Skirts"
#define LOADOUT_SUBCATEGORY_UNIFORM_DRESSES	"Dresses"
#define LOADOUT_SUBCATEGORY_UNIFORM_SWEATERS	"Sweaters"
#define LOADOUT_SUBCATEGORY_UNIFORM_PANTS	"Pants"
#define LOADOUT_SUBCATEGORY_UNIFORM_SHORTS	"Shorts"

//Suit
#define LOADOUT_CATEGORY_SUIT 				"Suit"
#define LOADOUT_SUBCATEGORY_SUIT_COATS 		"Coats"
#define LOADOUT_SUBCATEGORY_SUIT_JACKETS 	"Jackets"

//Head
#define LOADOUT_CATEGORY_HEAD 				"Head"

//Shoes
#define LOADOUT_CATEGORY_SHOES 				"Shoes"

//Gloves
#define LOADOUT_CATEGORY_GLOVES				"Gloves"

//Glasses
#define LOADOUT_CATEGORY_GLASSES			"Glasses"

//Loadout information types, allowing a user to set more customization to them
//Doesn't store any extra information a user could set
#define LOADOUT_INFO_NONE			0
//Stores a "style", which user can set from a pre-defined list on the loadout datum
#define LOADOUT_INFO_STYLE			1
//Stores a single color for use by the loadout datum
#define LOADOUT_INFO_ONE_COLOR 		2
//Stores three colors! Good for polychromatic stuff
#define LOADOUT_INFO_THREE_COLORS	3
