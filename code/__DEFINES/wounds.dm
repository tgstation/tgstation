// ~wound damage/rolling defines
/// the cornerstone of the wound threshold system, your base wound roll for any attack is rand(1, damage^this), after armor reduces said damage. See [/obj/item/bodypart/proc/check_wounding]
#define WOUND_DAMAGE_EXPONENT 1.4
/// any damage dealt over this is ignored for damage rolls unless the target has the frail quirk (35^1.4=145, for reference)
#define WOUND_MAX_CONSIDERED_DAMAGE 35
/// an attack must do this much damage after armor in order to roll for being a wound (so pressure damage/being on fire doesn't proc it)
#define WOUND_MINIMUM_DAMAGE 5
/// an attack must do this much damage after armor in order to be eliigible to dismember a suitably mushed bodypart
#define DISMEMBER_MINIMUM_DAMAGE 10
/// If an attack rolls this high with their wound (including mods), we try to outright dismember the limb. Note 250 is high enough that with a perfect max roll of 145 (see max cons'd damage), you'd need +100 in mods to do this
#define WOUND_DISMEMBER_OUTRIGHT_THRESH 250
/// set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

#define WOUND_DEFAULT_WEIGHT 50

// ~wound severities
/// for jokey/meme wounds like stubbed toe, no standard messages/sounds or second winds
#define WOUND_SEVERITY_TRIVIAL 0
#define WOUND_SEVERITY_MODERATE 1
#define WOUND_SEVERITY_SEVERE 2
#define WOUND_SEVERITY_CRITICAL 3
/// outright dismemberment of limb
#define WOUND_SEVERITY_LOSS 4

/// A "chronological" list of wound severities, starting at the least severe.
GLOBAL_LIST_INIT(wound_severities_chronological, list(
	"[WOUND_SEVERITY_TRIVIAL]",
	"[WOUND_SEVERITY_MODERATE]",
	"[WOUND_SEVERITY_SEVERE]",
	"[WOUND_SEVERITY_CRITICAL]"
))

// ~wound categories
/// any brute weapon/attack that doesn't have sharpness. rolls for blunt bone wounds
#define WOUND_BLUNT "wound_blunt"
/// any brute weapon/attack with sharpness = SHARP_EDGED. rolls for slash wounds
#define WOUND_SLASH "wound_slash"
/// any brute weapon/attack with sharpness = SHARP_POINTY. rolls for piercing wounds
#define WOUND_PIERCE "wound_pierce"
/// any concentrated burn attack (lasers really). rolls for burning wounds
#define WOUND_BURN "wound_burn"

/// Mainly a define used for wound_pregen_data, if a pregen data instance expects this, it will accept any and all wound types, even none at all
#define WOUND_ALL "wound_all"


// ~determination second wind defines
// How much determination reagent to add each time someone gains a new wound in [/datum/wound/proc/second_wind]
#define WOUND_DETERMINATION_MODERATE 1
#define WOUND_DETERMINATION_SEVERE 2.5
#define WOUND_DETERMINATION_CRITICAL 5
#define WOUND_DETERMINATION_LOSS 7.5
/// the max amount of determination you can have
#define WOUND_DETERMINATION_MAX 10

/// While someone has determination in their system, their bleed rate is slightly reduced
#define WOUND_DETERMINATION_BLEED_MOD 0.85

/// Wounds using this competition mode will remove any wounds of a greater severity than itself in a random wound roll. In most cases, you dont want to use this.
#define WOUND_COMPETITION_OVERPOWER_GREATERS "wound_submit"
/// Wounds using this competition mode will remove any wounds of a lower severity than itself in a random wound roll. Used for ensuring the worse case scenario of a given injury_roll.
#define WOUND_COMPETITION_OVERPOWER_LESSERS "wound_dominate"

// ~biology defines
// What kind of biology a limb has, and what wounds it can suffer
/// Has absolutely fucking nothing, no wounds
#define BIO_INORGANIC NONE
/// Has bone - allows the victim to suffer T2-T3 bone blunt wounds
#define BIO_BONE (1<<0)
/// Has flesh - allows the victim to suffer fleshy slash pierce and burn wounds
#define BIO_FLESH (1<<1)
/// Self explanatory
#define BIO_FLESH_BONE (BIO_BONE|BIO_FLESH)
/// Has metal - allows the victim to suffer robotic blunt and burn wounds
#define BIO_METAL (1<<2)
/// Is wired internally - allows the victim to suffer electrical wounds (robotic T1-T3 slash/pierce)
#define BIO_WIRED (1<<3)
/// Robotic: shit like cyborg limbs, mostly. BIO_METAL and BIO_WIRED
#define BIO_ROBOTIC (BIO_METAL|BIO_WIRED)
/// Has bloodflow - can suffer bleeding wounds and can bleed
#define BIO_BLOODED (1<<4)
/// Is connected by a joint - can suffer T1 bone blunt wounds (dislocation)
#define BIO_JOINTED (1<<5)
/// Standard humanoid - can suffer all flesh wounds, such as: T1-3 slash/pierce/burn/blunt. Can also bleed
#define BIO_STANDARD (BIO_FLESH_BONE|BIO_BLOODED)
/// Standard humanoid limbs - can suffer all flesh wounds, such as: T1-3 slash/pierce/burn/blunt. Can also bleed, and be dislocated
#define BIO_STANDARD_JOINTED (BIO_STANDARD|BIO_JOINTED)

// "Where" a specific biostate is within a given limb
// Interior is hard shit, the last line, shit like bones
// Exterior is soft shit, targetted by slashes and pierces (usually), protects exterior
// A limb needs both mangled interior and exterior to be dismembered, but slash/pierce must mangle exterior to attack the interior
// Not having exterior/interior counts as mangled exterior/interior for the purposes of dismemberment
/// The given biostate is on the "interior" of the limb - hard shit, protected by exterior
#define BIO_INTERIOR (1<<0)
/// The given biostate is on the "exterior" of the limb - soft shit, protects interior
#define BIO_EXTERIOR (1<<1)
#define BIO_EXTERIOR_AND_INTERIOR (BIO_EXTERIOR|BIO_INTERIOR)

/// A assoc list of BIO_ define to EXTERIOR/INTERIOR defines.
/// This is where the interior/exterior state of a given biostate is set.
/// Note that not all biostates are guaranteed to be one of these - and in fact, many are not
/// IMPORTANT NOTE: All keys are stored as text and must be converted via text2num
GLOBAL_LIST_INIT(bio_state_states, list(
	"[BIO_WIRED]" = BIO_EXTERIOR,
	"[BIO_METAL]" = BIO_INTERIOR,
	"[BIO_FLESH]" = BIO_EXTERIOR,
	"[BIO_BONE]" = BIO_INTERIOR,
))

// Wound series
// A "wound series" is just a family of wounds that logically follow eachother
// Multiple wounds in a single series cannot be on a limb - the highest severity will always be prioritized, and lower ones will be skipped

/// T1-T3 Bleeding slash wounds. Requires flesh. Can cause bleeding, but doesn't require it. From: slash.dm
#define WOUND_SERIES_FLESH_SLASH_BLEED "wound_series_flesh_slash_bled"
/// T1-T3 Basic blunt wounds. T1 requires jointed, but 2-3 require bone. From: bone.dm
#define WOUND_SERIES_BONE_BLUNT_BASIC "wound_series_bone_blunt_basic"
/// T1-T3 Basic burn wounds. Requires flesh. From: burns.dm
#define WOUND_SERIES_FLESH_BURN_BASIC "wound_series_flesh_burn_basic"
/// T1-T3 Bleeding puncture wounds. Requires flesh. Can cause bleeding, but doesn't require it. From: pierce.dm
#define WOUND_SERIES_FLESH_PUNCTURE_BLEED "wound_series_flesh_puncture_bleed"
/// Generic loss wounds. See loss.dm
#define WOUND_SERIES_LOSS_BASIC "wound_series_loss_basic"

#define WOUND_SERIES_METAL_BLUNT_BASIC "wound_series_metal_blunt_basic"
#define WOUND_SERIES_METAL_BURN_OVERHEAT "wound_series_metal_burn_basic"
#define WOUND_SERIES_WIRE_SLASH_ELECTRICAL_DAMAGE "wound_series_metal_slash_electrical_damage_basic"
#define WOUND_SERIES_WIRE_PIERCE_ELECTRICAL_DAMAGE "wound_series_metal_pierce_electrical_damage_basic"

// SERIES TYPES
// A series type is basically our way of declaring how "mainstream" a series is.
// WOUND_SERIES_TYPE_BASIC is totally mainline, and will be picked for random generations
// However, anything else needs to be specifically picked out
// This can be used to create a secondary series of wounds that only show up under specific circumstances

/// The "mainline" wound series. Bleed wounds for slash, broken bones for blunt, etc.
#define WOUND_SERIES_TYPE_BASIC "wound_series_type_basic"
/// A generic alternate wound series. Unused, currently.
#define WOUND_SERIES_TYPE_ALTERNATE_GENERIC "wound_series_type_alternate_generic"

// SPECIFIC TYPES
// A specific type is a individual wound's version of a series type
// While they still occupy the same series as mainstream wounds, you can make any wound a alternate specific type
// to do the same thing as above: A secondary series of wounds within a given series, but a series that operates on the same
// severity overridding rules despite having different effects

// Both series and specific types are unused but exist for future extension

/// A "mainline" wound of a series. Ex. a bleeding slesh for a flesh slash wound.
#define WOUND_SPECIFIC_TYPE_BASIC "wound_specific_type_basic"

/// A assoc list of (wound typepath -> wound_pregen_data instance). Every wound should have a pregen data.
GLOBAL_LIST_INIT_TYPED(all_wound_pregen_data, /datum/wound_pregen_data, generate_wound_static_data())

/// Constructs [GLOB.all_wound_pregen_data] by iterating through a typecache of pregen data, ignoring abstract types, and instantiating the rest.
/proc/generate_wound_static_data()
	RETURN_TYPE(/list/datum/wound_pregen_data)

	var/list/datum/wound_pregen_data/data = list()

	for (var/datum/wound_pregen_data/path as anything in typecacheof(path = /datum/wound_pregen_data, ignore_root_path = TRUE))
		if (initial(path.abstract))
			continue

		if (!isnull(data[initial(path.wound_path_to_generate)]))
			stack_trace("pre-existing pregen data for [initial(path.wound_path_to_generate)] when [path] was being considered: [data[initial(path.wound_path_to_generate)]]. \
						this is definitely a bug, and is probably because one of the two pregen data have the wrong wound typepath defined. [path] will not be instantiated")

			continue

		var/datum/wound_pregen_data/pregen_data = new path
		data[pregen_data.wound_path_to_generate] = pregen_data

	return data

/// A branching assoc list of (series -> (severity -> (specific type) -> (typepath) -> (weight))). Allows you to say "I want a generic slash wound",
/// then "Of severity 2", then "normal type", and get a wound of that description - via get_corresponding_wound_type()
/// Series: A generic wound_series, such as WOUND_SERIES_BONE_BLUNT_BASIC
/// Severity: Any wounds held within this will be of this severity.
/// Specific type: Any wounds held within this will be of this "specific type". See wound_pregen_data.specific_type for more info.
/// Typepath, Weight: Merely a pairing of a given typepath to its weight, held for convenience in pickweight.
GLOBAL_LIST_INIT(wound_series_collections, generate_wound_series_collection())

// Series -> severity -> specific type -> type -> weight
/// Generates [wound_series_collections] by iterating through all pregen_data. Refer to the mentioned list for documentation
/proc/generate_wound_series_collection()
	RETURN_TYPE(/list/datum/wound)

	var/list/datum/wound/wound_collection = list()

	for (var/datum/wound/wound_type as anything in typecacheof(/datum/wound, FALSE, TRUE))
		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[wound_type]
		if (!pregen_data)
			continue

		if (pregen_data.abstract)
			continue

		var/series = pregen_data.wound_series
		var/list/datum/wound/series_list = wound_collection[series]
		if (isnull(series_list))
			wound_collection[series] = list()
			series_list = wound_collection[series]

		var/severity = "[(initial(wound_type.severity))]"
		var/list/datum/wound/severity_list = series_list[severity]
		if (isnull(severity_list))
			series_list[severity] = list()
			severity_list = series_list[severity]

		var/specific_type = pregen_data.specific_type
		var/list/datum/specific_type_list = severity_list[specific_type]
		if (isnull(specific_type_list))
			severity_list[specific_type] = list()
			specific_type_list = severity_list[specific_type]

		var/weight = pregen_data.weight
		specific_type_list[wound_type] = weight

	return wound_collection

/// A branching assoc list of (wound_type -> (wound_series_type -> (wound_series))).
/// Allows for determining of which wound series are caused by what, and in that list, which of those series are "mainline" and which are not.
GLOBAL_LIST_INIT(wound_types_to_series, list(
	WOUND_BLUNT = list(
		WOUND_SERIES_TYPE_BASIC = list(
			WOUND_SERIES_BONE_BLUNT_BASIC,
			WOUND_SERIES_METAL_BLUNT_BASIC,
		),
	),
	WOUND_SLASH = list(
		WOUND_SERIES_TYPE_BASIC = list(
			WOUND_SERIES_FLESH_SLASH_BLEED,
			WOUND_SERIES_WIRE_SLASH_ELECTRICAL_DAMAGE,
		),
	),
	WOUND_BURN = list(
		WOUND_SERIES_TYPE_BASIC = list(
			WOUND_SERIES_FLESH_BURN_BASIC,
			WOUND_SERIES_METAL_BURN_OVERHEAT
		),
	),
	WOUND_PUNCTURE = list(
		WOUND_SERIES_TYPE_BASIC = list(
			WOUND_SERIES_FLESH_PUNCTURE_BLEED,
			WOUND_SERIES_WIRE_PIERCE_ELECTRICAL_DAMAGE
		),
	),
))

/// Used in get_corresponding_wound_type(): Will pick the highest severity wound out of severity_min and severity_max
#define WOUND_PICK_HIGHEST_SEVERITY 1
/// Used in get_corresponding_wound_type(): Will pick the lowest severity wound out of severity_min and severity_max
#define WOUND_PICK_LOWEST_SEVERITY 2

/**
 * Searches through all wounds for any of proper type, series, specific type, and biostate, and then returns a single one via pickweight.
 * Is able to discern between, say, a flesh slash wound, and a metallic slash wound, and will return the respective one for the provided limb.
 *
 * Args:
 * * list/wound_types: A list of wound_types. Only wounds that accept these wound types will be considered.
 * * obj/item/bodypart/part: The limb we are considering. Extremely important for biostates.
 * * severity_min: The minimum wound severity we will search for.
 * * severity_max = severity_min: The maximum wound severity we will search for.
 * * severity_pick_mode = WOUND_PICK_HIGHEST_SEVERITY: The "pick mode" we will use when considering multiple wounds of acceptable severity. See the above defines.
 * * series_type = WOUND_SERIES_TYPE_BASIC: The type of wound series we are searching for. Defaults to basic, that being the mainline series, like hairline fractures if looking for blunt bone wounds.
 * * specific_type = WOUND_SPECIFIC_TYPE_BASIC: The individual "specific type" of wounds we are searching for. See wound_pregen_data.specific_type for more documentation.
 * * random_roll = TRUE: If this is considered a "random" consideration. If true, only wounds that can be randomly generated will be considered.
 * * duplicates_allowed = FALSE: If exact duplicates of a given wound on part are tolerated. Useful for simply getting a path and not instantiating.
 * * care_about_existing_wounds = TRUE: If we iterate over wounds to see if any are above or at a given wounds severity, and disregard it if any are. Useful for simply getting a path and not instantiating.
 *
 * Returns:
 * A randomly picked wound typepath meeting all the above criteria and being applicable to the part's biotype - or null if there were none.
 */
/proc/get_corresponding_wound_type(list/wound_types, obj/item/bodypart/part, severity_min, severity_max = severity_min, severity_pick_mode = WOUND_PICK_HIGHEST_SEVERITY, series_type = WOUND_SERIES_TYPE_BASIC, specific_type = WOUND_SPECIFIC_TYPE_BASIC, random_roll = TRUE, duplicates_allowed = FALSE, care_about_existing_wounds = TRUE)

	var/list/wound_type_list = list()
	for (var/wound_type as anything in wound_types)
		wound_type_list += GLOB.wound_types_to_series[wound_type]
	if (!length(wound_type_list))
		return null

	var/list/series_list = wound_type_list[series_type]
	if (!length(series_list))
		return null

	var/list/datum/wound/paths_to_pick_from = list()
	for (var/series as anything in shuffle(series_list))
		var/list/severity_list = GLOB.wound_series_collections[series]
		if (!length(severity_list))
			continue

		var/picked_severity
		for (var/severity_text as anything in shuffle(GLOB.wound_severities_chronological))
			var/severity = text2num(severity_text)
			if (severity > severity_min || severity < severity_max)
				continue

			if (isnull(picked_severity) || ((severity_pick_mode == WOUND_PICK_HIGHEST_SEVERITY && severity > picked_severity) || (severity_pick_mode == WOUND_PICK_LOWEST_SEVERITY && severity < picked_severity)))
				picked_severity = severity

		var/list/specific_types = severity_list["[picked_severity]"]
		if (!length(specific_types))
			continue

		var/list/datum/wound/wound_typepaths = specific_types[specific_type]
		if (!length(wound_typepaths))
			continue

		for (var/datum/wound/iterated_path as anything in wound_typepaths)
			var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[iterated_path]
			if (pregen_data.can_be_applied_to(part, wound_types, random_roll, duplicates_allowed = duplicates_allowed, care_about_existing_wounds = care_about_existing_wounds))
				paths_to_pick_from[iterated_path] = wound_typepaths[iterated_path]

	return pick_weight(paths_to_pick_from) // we found our winners!

/// Assoc list of biotype -> ideal scar file to be used and grab stuff from.
GLOBAL_LIST_INIT(biotypes_to_scar_file, list(
	"[BIO_FLESH]" = FLESH_SCAR_FILE,
	"[BIO_BONE]" = BONE_SCAR_FILE,
	"[BIO_METAL]" = METAL_SCAR_FILE
))

// ~burn wound infection defines
// Thresholds for infection for burn wounds, once infestation hits each threshold, things get steadily worse
/// below this has no ill effects from infection
#define WOUND_INFECTION_MODERATE 4
/// then below here, you ooze some pus and suffer minor tox damage, but nothing serious
#define WOUND_INFECTION_SEVERE 8
/// then below here, your limb occasionally locks up from damage and infection and briefly becomes disabled. Things are getting really bad
#define WOUND_INFECTION_CRITICAL 12
/// below here, your skin is almost entirely falling off and your limb locks up more frequently. You are within a stone's throw of septic paralysis and losing the limb
#define WOUND_INFECTION_SEPTIC 20
// above WOUND_INFECTION_SEPTIC, your limb is completely putrid and you start rolling to lose the entire limb by way of paralyzation. After 3 failed rolls (~4-5% each probably), the limb is paralyzed


// ~random wound balance defines
/// how quickly sanitization removes infestation and decays per second
#define WOUND_BURN_SANITIZATION_RATE 0.075
/// how much blood you can lose per tick per slash max.
#define WOUND_SLASH_MAX_BLOODFLOW 4.5
/// ^ but for robotic wounds
#define WOUND_SLASH_ROBOTIC_MAX_BLOODFLOW WOUND_SLASH_MAX_BLOODFLOW * 10
/// further slash attacks on a bodypart with a slash wound have their blood_flow further increased by damage * this (10 damage slash adds .25 flow)
#define WOUND_SLASH_DAMAGE_FLOW_COEFF 0.025
/// if we suffer a bone wound to the head that creates brain traumas, the timer for the trauma cycle is +/- by this percent (0-100)
#define WOUND_BONE_HEAD_TIME_VARIANCE 20



// ~mangling defines
// With the wounds pt. 2 update, general dismemberment now requires 2 things for a limb to be dismemberable (exterior/bone only creatures just need the second):
// 1. Exterior is mangled: A critical slash or pierce wound on that limb
// 2. Interior is mangled: At least a severe bone wound on that limb
// Lack of exterior or interior count as mangled exterior/interior respectively
// see [/obj/item/bodypart/proc/get_mangled_state] for more information, as well as GLOB.bio_state_states
#define BODYPART_MANGLED_NONE NONE
#define BODYPART_MANGLED_INTERIOR (1<<0)
#define BODYPART_MANGLED_EXTERIOR (1<<1)
#define BODYPART_MANGLED_BOTH (BODYPART_MANGLED_INTERIOR | BODYPART_MANGLED_EXTERIOR)

// ~wound flag defines
/// If having this wound counts as mangled exterior for dismemberment
#define MANGLES_EXTERIOR (1<<0)
/// If having this wound counts as mangled interior for dismemberment
#define MANGLES_INTERIOR (1<<1)
/// If this wound marks the limb as being allowed to have gauze applied
#define ACCEPTS_GAUZE (1<<2)


// ~scar persistence defines
// The following are the order placements for persistent scar save formats
/// The version number of the scar we're saving, any scars being loaded below this number will be discarded, see SCAR_CURRENT_VERSION below
#define SCAR_SAVE_VERS 1
/// The body_zone we're applying to on granting
#define SCAR_SAVE_ZONE 2
/// The description we're loading
#define SCAR_SAVE_DESC 3
/// The precise location we're loading
#define SCAR_SAVE_PRECISE_LOCATION 4
/// The severity the scar had
#define SCAR_SAVE_SEVERITY 5
/// Whether this is a BIO_BONE scar, a BIO_FLESH scar, or a BIO_FLESH_BONE scar (so you can't load fleshy human scars on a plasmaman character)
#define SCAR_SAVE_BIOLOGY 6
/// Which character slot this was saved to
#define SCAR_SAVE_CHAR_SLOT 7
/// if the scar will check for any or all biostates on the limb (defaults to FALSE, so all)
#define SCAR_SAVE_CHECK_ANY_BIO 8
///how many fields we save for each scar (so the number of above fields)
#define SCAR_SAVE_LENGTH 8

/// saved scars with a version lower than this will be discarded, increment when you update the persistent scarring format in a way that invalidates previous saved scars (new fields, reordering, etc)
#define SCAR_CURRENT_VERSION 4
/// how many scar slots, per character slot, we have to cycle through for persistent scarring, if enabled in character prefs
#define PERSISTENT_SCAR_SLOTS 3

// ~blood_flow rates of change, these are used by [/datum/wound/proc/get_bleed_rate_of_change] from [/mob/living/carbon/proc/bleed_warn] to let the player know if their bleeding is getting better/worse/the same
/// Our wound is clotting and will eventually stop bleeding if this continues
#define BLOOD_FLOW_DECREASING -1
/// Our wound is bleeding but is holding steady at the same rate.
#define BLOOD_FLOW_STEADY 0
/// Our wound is bleeding and actively getting worse, like if we're a critical slash or if we're afflicted with heparin
#define BLOOD_FLOW_INCREASING 1

/// How often can we annoy the player about their bleeding? This duration is extended if it's not serious bleeding
#define BLEEDING_MESSAGE_BASE_CD (10 SECONDS)

/// Skeletons and other BIO_ONLY_BONE creatures respond much better to bone gel and can have severe and critical bone wounds healed by bone gel alone. The duration it takes to heal is also multiplied by this, lucky them!
#define WOUND_BONE_BIO_BONE_GEL_MULT 0.25
