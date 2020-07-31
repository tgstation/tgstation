
#define WOUND_DAMAGE_EXPONENT	1.4

/// an attack must do this much damage after armor in order to roll for being a wound (incremental pressure damage need not apply)
#define WOUND_MINIMUM_DAMAGE		5
/// an attack must do this much damage after armor in order to be eliigible to dismember a suitably mushed bodypart
#define DISMEMBER_MINIMUM_DAMAGE	10
/// any damage dealt over this is ignored for damage rolls unless the target has the frail quirk (35^1.4=145)
#define WOUND_MAX_CONSIDERED_DAMAGE	35


#define WOUND_SEVERITY_TRIVIAL	0 // for jokey/meme wounds like stubbed toe, no standard messages/sounds or second winds
#define WOUND_SEVERITY_MODERATE	1
#define WOUND_SEVERITY_SEVERE	2
#define WOUND_SEVERITY_CRITICAL	3
#define WOUND_SEVERITY_LOSS		4 // theoretical total limb loss, like dismemberment for cuts

/// any brute weapon/attack that doesn't have sharpness. rolls for blunt bone wounds
#define WOUND_BLUNT		1
/// any brute weapon/attack with sharpness = SHARP_EDGED. rolls for slash wounds
#define WOUND_SLASH		2
/// any brute weapon/attack with sharpness = SHARP_POINTY. rolls for piercing wounds
#define WOUND_PIERCE	3
/// any concentrated burn attack (lasers really). rolls for burning wounds
#define WOUND_BURN		4

// How much determination reagent to add each time someone gains a new wound in [/datum/wound/proc/second_wind()]
#define WOUND_DETERMINATION_MODERATE	1
#define WOUND_DETERMINATION_SEVERE		2.5
#define WOUND_DETERMINATION_CRITICAL	5
#define WOUND_DETERMINATION_LOSS		7.5

/// the max amount of determination you can have
#define WOUND_DETERMINATION_MAX			10

/// set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

// list in order of highest severity to lowest
GLOBAL_LIST_INIT(global_wound_types, list(WOUND_BLUNT = list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate),
		WOUND_SLASH = list(/datum/wound/slash/critical, /datum/wound/slash/severe, /datum/wound/slash/moderate),
		WOUND_PIERCE = list(/datum/wound/pierce/critical, /datum/wound/pierce/severe, /datum/wound/pierce/moderate),
		WOUND_BURN = list(/datum/wound/burn/critical, /datum/wound/burn/severe, /datum/wound/burn/moderate)
		))

GLOBAL_LIST_INIT(global_all_wound_types, list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate,
	/datum/wound/slash/critical, /datum/wound/slash/severe, /datum/wound/slash/moderate,
	/datum/wound/pierce/critical, /datum/wound/pierce/severe, /datum/wound/pierce/moderate,
	/datum/wound/burn/critical, /datum/wound/burn/severe, /datum/wound/burn/moderate))

// Thresholds for infection for burn wounds, once infestation hits each threshold, things get steadily worse
/// below this has no ill effects from infection
#define WOUND_INFECTION_MODERATE	4
/// then below here, you ooze some pus and suffer minor tox damage, but nothing serious
#define WOUND_INFECTION_SEVERE		8
/// then below here, your limb occasionally locks up from damage and infection and briefly becomes disabled. Things are getting really bad
#define WOUND_INFECTION_CRITICAL	12
/// below here, your skin is almost entirely falling off and your limb locks up more frequently. You are within a stone's throw of septic paralysis and losing the limb
#define WOUND_INFECTION_SEPTIC		20
// above WOUND_INFECTION_SEPTIC, your limb is completely putrid and you start rolling to lose the entire limb by way of paralyzation. After 3 failed rolls (~4-5% each probably), the limb is paralyzed


/// how quickly sanitization removes infestation and decays per tick
#define WOUND_BURN_SANITIZATION_RATE 	0.15
/// how much blood you can lose per tick per slash max. 8 is a LOT of blood for one cut so don't worry about hitting it easily
#define WOUND_SLASH_MAX_BLOODFLOW		8
/// dead people don't bleed, but they can clot! this is the minimum amount of clotting per tick on dead people, so even critical cuts will slowly clot in dead people
#define WOUND_SLASH_DEAD_CLOT_MIN		0.05
/// if we suffer a bone wound to the head that creates brain traumas, the timer for the trauma cycle is +/- by this percent (0-100)
#define WOUND_BONE_HEAD_TIME_VARIANCE 	20

// The following are for persistent scar save formats
/// The version number of the scar we're saving
#define SCAR_SAVE_VERS				1
/// The body_zone we're applying to on granting
#define SCAR_SAVE_ZONE				2
/// The description we're loading
#define SCAR_SAVE_DESC				3
/// The precise location we're loading
#define SCAR_SAVE_PRECISE_LOCATION	4
/// The severity the scar had
#define SCAR_SAVE_SEVERITY			5
///how many fields there are above (NOT INCLUDING THIS OBVIOUSLY)
#define SCAR_SAVE_LENGTH			5

// increment this number when you update the persistent scarring format in a way that invalidates previous saved scars (new fields, reordering, etc)
/// saved scars with a version lower than this will be discarded
#define SCAR_CURRENT_VERSION				1


// With the wounds pt. 2 update, general dismemberment now requires 2 things for a limb to be dismemberable (bone only creatures just need the second):
// 	1. Skin is mangled: A critical slash or pierce wound on that limb
// 	2. Bone is mangled: At least a severe bone wound on that limb
// see [/obj/item/bodypart/proc/get_mangled_state] for more information
#define BODYPART_MANGLED_NONE	0
#define BODYPART_MANGLED_BONE	1
#define BODYPART_MANGLED_FLESH	2
#define BODYPART_MANGLED_BOTH	3

// What kind of biology we have, and what wounds we can suffer, mostly relies on the HAS_FLESH and HAS_BONE species traits on human species
/// golems and androids, cannot suffer any wounds
#define BIO_INORGANIC	0
/// skeletons and plasmemes, can only suffer bone wounds, only needs mangled bone to be able to dismember
#define BIO_JUST_BONE	1
/// nothing right now, maybe slimepeople in the future, can only suffer slashing, piercing, and burn wounds
#define BIO_JUST_FLESH	2
/// standard humanoids, can suffer all wounds, needs mangled bone and flesh to dismember
#define BIO_FLESH_BONE	3

/// If this wound requires having the HAS_FLESH flag for humanoids
#define FLESH_WOUND		(1<<0)
/// If this wound requires having the HAS_BONE flag for humanaoids
#define BONE_WOUND		(1<<1)
/// If having this wound counts as mangled flesh for dismemberment
#define MANGLES_FLESH	(1<<2)
/// If having this wound counts as mangled bone for dismemberment
#define MANGLES_BONE	(1<<3)
/// If this wound marks the limb as being allowed to have gauze applied
#define ACCEPTS_GAUZE	(1<<4)

