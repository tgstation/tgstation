// ROLE PREFERENCES
#define ROLE_BLOODSUCKER			"Bloodsucker"
#define ROLE_MONSTERHUNTER			"Monster Hunter"

// ANTAGS
#define ANTAG_DATUM_BLOODSUCKER			/datum/antagonist/bloodsucker
#define ANTAG_DATUM_VASSAL				/datum/antagonist/vassal
#define ANTAG_DATUM_HUNTER				/datum/antagonist/vamphunter

// TRAITS
#define TRAIT_COLDBLOODED		"coldblooded"
#define TRAIT_NONATURALHEAL		"nonaturalheal"
#define TRAIT_NORUNNING			"norunning"

// HUD
#define ANTAG_HUD_BLOODSUCKER		27  // Check atom_hud.dm to see what the current top number is.

// BLOODSUCKER
#define BLOODSUCKER_LEVEL_TO_EMBRACE	3
#define BLOODSUCKER_FRENZY_TIME	25		// How long the vamp stays in frenzy.
#define BLOODSUCKER_FRENZY_OUT_TIME	300	// How long the vamp goes back into frenzy.
#define BLOODSUCKER_STARVE_VOLUME	5	// Amount of blood, below which a Vamp is at risk of frenzy.

// RECIPES
#define CAT_STRUCTURE	"Structures"

// MARTIAL ARTS
#define MARTIALART_HUNTER "hunter-fu"


// MISSING REF
/obj/item/circuitboard/machine/vr_sleeper
	var/whydoesthisexist = "because somebody fucked up putting this on TG, and vr_sleeper.dm is pointing to an object that was never defined. Here it is as a temp ref, so we can compile."