//We start from 30 to not interfere with TG species defines, should they add more
/// We're using all three mutcolor features for our skin coloration
#define MUTCOLOR_MATRIXED	30
#define MUTCOLORS2			31
#define MUTCOLORS3			32
// Defines for whether an accessory should have one or three colors to choose for
#define USE_ONE_COLOR		31
#define USE_MATRIXED_COLORS	32
// Defines for some extra species traits
#define REVIVES_BY_HEALING	33
#define ROBOTIC_LIMBS		34
#define ROBOTIC_DNA_ORGANS	35
//Also.. yes for some reason specie traits and accessory defines are together

//Defines for processing reagents, for synths, IPC's and Vox
#define PROCESS_ORGANIC 1		//Only processes reagents with "ORGANIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_SYNTHETIC 2		//Only processes reagents with "SYNTHETIC" or "ORGANIC | SYNTHETIC"

#define REAGENT_ORGANIC 1
#define REAGENT_SYNTHETIC 2

//Some defines for sprite accessories
// Which color source we're using when the accessory is added
#define DEFAULT_PRIMARY		1
#define DEFAULT_SECONDARY	2
#define DEFAULT_TERTIARY	3
#define DEFAULT_MATRIXED	4 //uses all three colors for a matrix
#define DEFAULT_SKIN_OR_PRIMARY	5 //Uses skin tone color if the character uses one, otherwise primary

// Defines for extra bits of accessories
#define COLOR_SRC_PRIMARY	1
#define COLOR_SRC_SECONDARY	2
#define COLOR_SRC_TERTIARY	3
#define COLOR_SRC_MATRIXED	4

// Defines for mutant bodyparts indexes
#define MUTANT_INDEX_NAME		"name"
#define MUTANT_INDEX_COLOR_LIST	"color"

//The color list that is passed to color matrixed things when a person is husked
#define HUSK_COLOR_LIST list(list(0.64, 0.64, 0.64, 0), list(0.64, 0.64, 0.64, 0), list(0.64, 0.64, 0.64, 0), list(0, 0, 0, 1))

//Defines for an accessory to be randomed
#define ACC_RANDOM		"random"

//organ slots
#define ORGAN_SLOT_WINGS "wings"

#define MAXIMUM_MARKINGS_PER_LIMB 3

#define PREVIEW_PREF_JOB "Job"
#define PREVIEW_PREF_LOADOUT "Loadout"
#define PREVIEW_PREF_NAKED "Naked"

#define BODY_SIZE_NORMAL 		1.00
#define BODY_SIZE_MAX			1.5
#define BODY_SIZE_MIN			0.8

#define MANDATORY_FEATURE_LIST list("mcolor" = "FFB","mcolor2" = "FFB","mcolor3" = "FFB","ethcolor" = "FCC","skin_color" = "FED","flavor_text" = "", "body_size" = BODY_SIZE_NORMAL, "custom_species" = null, "uses_skintones" = FALSE)

#define UNDERWEAR_HIDE_SOCKS		(1<<0)
#define UNDERWEAR_HIDE_SHIRT		(1<<1)
#define UNDERWEAR_HIDE_UNDIES		(1<<2)
