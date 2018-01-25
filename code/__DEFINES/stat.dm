/*
	Used with the various stat variables (mob, machines)
*/

//mob/var/stat things
#define CONSCIOUS	0
#define SOFT_CRIT	1
#define UNCONSCIOUS	2
#define DEAD		3

//mob disabilities stat

#define DISABILITY_BLIND 		"blind"
#define DISABILITY_MUTE			"mute"
#define DISABILITY_DEAF			"deaf"
#define DISABILITY_NEARSIGHT	"nearsighted"
#define DISABILITY_FAT			"fat"
#define DISABILITY_HUSK			"husk"
#define DISABILITY_NOCLONE		"noclone"
#define DISABILITY_CLUMSY		"clumsy"
#define DISABILITY_DUMB			"dumb"
#define DISABILITY_MONKEYLIKE	"monkeylike" //sets IsAdvancedToolUser to FALSE
#define DISABILITY_PACIFISM		"pacifism"

// common disability sources
#define EYE_DAMAGE "eye_damage"
#define GENETIC_MUTATION "genetic"
#define OBESITY "obesity"
#define MAGIC_DISABILITY "magic"
#define STASIS_MUTE "stasis"
#define GENETICS_SPELL "genetics_spell"
#define TRAUMA_DISABILITY "trauma"
#define CHEMICAL_DISABILITY "chemical"

// unique disability sources, still defines
#define STATUE_MUTE "statue"
#define CHANGELING_DRAIN "drain"
#define ABYSSAL_GAZE_BLIND "abyssal_gaze"

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define MAINT		4			// under maintaince
#define EMPED		8		// temporary broken by EMP pulse

//ai power requirement defines
#define POWER_REQ_NONE 0
#define POWER_REQ_ALL 1
#define POWER_REQ_CLOCKCULT 2
