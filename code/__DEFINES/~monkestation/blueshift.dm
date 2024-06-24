#define RESKIN_ICON "reskin_icon"
#define RESKIN_ICON_STATE "reskin_icon_state"
#define RESKIN_WORN_ICON "reskin_worn_icon"
#define RESKIN_WORN_ICON_STATE "reskin_worn_icon_state"
#define RESKIN_SUPPORTS_VARIATIONS_FLAGS "reskin_supports_variations_flags"
#define RESKIN_INHAND_L "reskin_inhand_l"
#define RESKIN_INHAND_R "reskin_inhand_r"
#define RESKIN_INHAND_STATE "reskin_inhand_state"

/// Traits granted by glassblowing
#define TRAIT_GLASSBLOWING "glassblowing"

/// Trait that is applied whenever someone or something is glassblowing
#define TRAIT_CURRENTLY_GLASSBLOWING "currently_glassblowing"

#define TOOL_BILLOW "billow"
#define TOOL_TONG "tong"
#define TOOL_HAMMER "hammer"
#define TOOL_BLOWROD "blowrod"

// Prefix values.
#define QUECTO * 1e-30
#define RONTO * 1e-27
#define YOCTO * 1e-24
#define ZEPTO * 1e-21
#define ATTO * 1e-18
#define FEMPTO * 1e-15
#define PICO * 1e-12
#define NANO * 1e-9
#define MICRO * 1e-6
#define MILLI * 1e-3
#define KILO * 1e3
#define MEGA * 1e6
#define GIGA * 1e9
#define TERA * 1e12
#define PETA * 1e15
#define EXA * 1e18
#define ZETTA * 1e21
#define YOTTA * 1e24
#define RONNA * 1e27
#define QUETTA * 1e30

/// Category for clothing in the organics printer
#define RND_CATEGORY_AKHTER_CLOTHING "Clothing"
/// Category for equipment like belts and bags in the organics printer
#define RND_CATEGORY_AKHTER_EQUIPMENT "Equipment"
/// Category for resources made by the organics printer
#define RND_CATEGORY_AKHTER_RESOURCES "Resources"

/// Category for ingredients in the ration printer
#define RND_CATEGORY_AKHTER_FOODRICATOR_INGREDIENTS "Ingredients"
/// Category for bags and containers of reagents in the ration printer
#define RND_CATEGORY_AKHTER_FOODRICATOR_BAGS "Containers"
/// Category for snacks in the ration printer
#define RND_CATEGORY_AKHTER_FOODRICATOR_SNACKS "Luxuries"
/// Category for utensils and whatnot in the ration printer
#define RND_CATEGORY_AKHTER_FOODRICATOR_UTENSILS "Utensils"
/// Category for the seeds the organics printer can make
#define RND_CATEGORY_AKHTER_SEEDS "Synthesized Seeds"

/// Medical items in the deforest medstation
#define RND_CATEGORY_DEFOREST_MEDICAL "Emergency Medical"
/// Blood and blood bags
#define RND_CATEGORY_DEFOREST_BLOOD "Synthesized Blood"


/// The items the frontier clothing can hold
GLOBAL_LIST_INIT(colonist_suit_allowed, list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun,
	/obj/item/melee,
	/obj/item/tank/internals,
	/obj/item/storage/belt/holster,
	/obj/item/construction,
	/obj/item/fireaxe,
	/obj/item/pipe_dispenser,
	/obj/item/storage/bag,
	/obj/item/pickaxe,
	/obj/item/resonator,
	/obj/item/t_scanner,
	/obj/item/analyzer,
))

/// Trait given to objects with the wallmounted component
#define TRAIT_WALLMOUNTED "wallmounted"

/// BYOND's string procs don't support being used on datum references (as in it doesn't look for a name for stringification)
/// We just use this macro to ensure that we will only pass strings to this BYOND-level function without developers needing to really worry about it.
#define LOWER_TEXT(thing) lowertext(UNLINT("[thing]"))

// Converts cable layer to its human readable name
GLOBAL_LIST_INIT(cable_layer_to_name, list(
	"[CABLE_LAYER_1]" = CABLE_LAYER_1_NAME,
	"[CABLE_LAYER_2]" = CABLE_LAYER_2_NAME,
	"[CABLE_LAYER_3]" = CABLE_LAYER_3_NAME
))

// Converts cable color name to its layer
GLOBAL_LIST_INIT(cable_name_to_layer, list(
	CABLE_LAYER_1_NAME = CABLE_LAYER_1,
	CABLE_LAYER_2_NAME = CABLE_LAYER_2,
	CABLE_LAYER_3_NAME = CABLE_LAYER_3
))


// Zipties, cable cuffs, etc. Can be cut with wirecutters instantly.
#define HANDCUFFS_TYPE_WEAK 0
// Handcuffs... alien handcuffs. Can be cut through only by jaws of life.
#define HANDCUFFS_TYPE_STRONG 1

#define DIVINE_INTERVENTION 3
/// Sent when supermatter begins its delam countdown/when the suppression system is triggered: (var/trigger_reason)
#define COMSIG_MAIN_SM_DELAMINATING "delam_time"

#define ACCOUNT_CMD "CMD"
#define ACCOUNT_CMD_NAME "Command Budget"

#define PLAYTIME_GREEN 6000 // 100 hours

/// Macro to turn a number of laser shots into an energy cost, based on the above define
/// e.g. LASER_SHOTS(12, STANDARD_CELL_CHARGE) means 12 shots
#define LASER_SHOTS(X, MAX_CHARGE) (((100 * MAX_CHARGE) - ((100 * MAX_CHARGE) % X)) / (100 * X)) // I wish I could just use round, but it can't be used in datum members

/// Trait source for xeno innate abilities
#define TRAIT_XENO_INNATE "xeno_innate"
/// Trait source for something added BY a xeno ability
#define TRAIT_XENO_ABILITY_GIVEN "xeno_ability_given"
/// Determines if something can receive healing from a xeno
#define TRAIT_XENO_HEAL_AURA "trait_xeno_heal_aura"

/// Takes in a typepath of a `/datum/action` and adds it to `src`.
/// Only useful if you want to add the action and never desire to reference it again ever.
#define GRANT_ACTION(typepath) do {\
	var/datum/action/_ability = new typepath(src);\
	_ability.Grant(src);\
} while (FALSE)


/// Whenever we need to check if a mob is currently inside of soulcatcher.
#define COMSIG_SOULCATCHER_CHECK_SOUL "soulcatcher_check_soul"

/// Whenever we need to get the soul of the mob inside of the soulcatcher.
#define COMSIG_SOULCATCHER_SCAN_BODY "soulcatcher_scan_body"

#define EXAMINE_SECTION_BREAK "<hr>"


/// Trait that was granted by a NIFSoft
#define TRAIT_NIFSOFT "nifsoft"

/// Trait given to a piece of eyewear that allows the user to use NIFSoft HUDs
#define TRAIT_NIFSOFT_HUD_GRANTER "nifsoft_hud_granter"

//Bitflags for what kind product category a NIFSoft goes under

#define NIFSOFT_CATEGORY_GENERAL "General"
#define NIFSOFT_CATEGORY_COSMETIC "Cosmetic"
#define NIFSOFT_CATEGORY_UTILITY "Utility"
#define NIFSOFT_CATEGORY_FUN "Fun"
#define NIFSOFT_CATEGORY_INFORMATION "Information"
// Trait sources
#define TRAIT_GHOSTROLE "ghostrole"

/*
These are the defines for controlling what conditions are required to display
an items special description.

See the examinemore module for information.
*/

#define EXAMINE_CHECK_NONE "none"			//Displays the special_desc regardless if it's set.
#define EXAMINE_CHECK_SYNDICATE "syndicate"		//For displaying descriptors for those with the SYNDICATE faction assigned.
#define EXAMINE_CHECK_SYNDICATE_TOY "syndicate_toy" //Ditto, only instead of displaying nothing for heathens, it shows "The src looks like a toy, not the real thing."
#define EXAMINE_CHECK_MINDSHIELD "mindshield"	//For displaying descriptors for those with a mindshield implant.
#define EXAMINE_CHECK_ROLE "role"			//For displaying description information based on a specific ROLE, e.g. traitor. Remember to set the special_desc_role var on the item.
#define EXAMINE_CHECK_JOB "job"			//For displaying descriptors for specific jobs, e.g scientist. Remember to set the special_desc_job var on the item.
#define EXAMINE_CHECK_FACTION "faction"		//For displaying descriptors for mob factions, e.g. a zombie, or... turrets. Or syndicate. Remember to set special_desc_factions.
#define EXAMINE_CHECK_CONTRACTOR "contractor" // For contractors and syndicate agents.
#define TRAIT_DETECTIVE "detective_ability" //Given to the detective, if they have this, they can see syndicate special descriptions.

// Armament categories
#define ARMAMENT_CATEGORY_STANDARD "Standard Equipment"
#define ARMAMENT_CATEGORY_STANDARD_LIMIT 1

// Armament subcategories
#define ARMAMENT_SUBCATEGORY_NONE "Uncategorised"

/// To identify the limit of the category type in the associative list. Techical stuff.
#define CATEGORY_LIMIT "Category Limit"
#define CATEGORY_ENTRY "Category Entry"

// All the categories
#define ARMAMENT_CATEGORY_MELEE "Melee Weapons"
#define ARMAMENT_CATEGORY_MELEE_LIMIT 1
#define ARMAMENT_CATEGORY_PRIMARY "Primary Weapons"
#define ARMAMENT_CATEGORY_PRIMARY_LIMIT 1
#define ARMAMENT_CATEGORY_SECONDARY "Secondary Weapons"
#define ARMAMENT_CATEGORY_SECONDARY_LIMIT 1
#define ARMAMENT_CATEGORY_ARMOR_HEAD "Headgear"
#define ARMAMENT_CATEGORY_ARMOR_HEAD_LIMIT 1
#define ARMAMENT_CATEGORY_MEDICAL "Medical Supplies"
#define ARMAMENT_CATEGORY_MEDICAL_LIMIT 5


// All the subcategories
#define ARMAMENT_SUBCATEGORY_AMMO "Ammunition"
#define ARMAMENT_SUBCATEGORY_MELEE_LETHAL "Lethal Weaponry"
#define ARMAMENT_SUBCATEGORY_MELEE_NONLETHAL "Non-Lethal Weaponry"
#define ARMAMENT_SUBCATEGORY_SUBMACHINEGUN "Submachine Guns"
#define ARMAMENT_SUBCATEGORY_ASSAULTRIFLE "Assault Rifles"
#define ARMAMENT_SUBCATEGORY_SPECIAL "Special Weapons"
#define ARMAMENT_SUBCATEGORY_PISTOL "Pistols"
#define ARMAMENT_SUBCATEGORY_HELMET "Helmets"
#define ARMAMENT_SUBCATEGORY_BERETS "Berets"
#define ARMAMENT_SUBCATEGORY_MEDKIT "Medkits"
#define ARMAMENT_SUBCATEGORY_INJECTOR "Injectors"
#define ARMAMENT_SUBCATEGORY_SHOTGUN "Shotguns"
#define ARMAMENT_SUBCATEGORY_LASER "Laser Weaponry"
#define ARMAMENT_SUBCATEGORY_ARMOR "Armor"
#define ARMAMENT_SUBCATEGORY_GUNPART "Gun Parts"
#define ARMAMENT_SUBCATEGORY_EMITTER "Phase Emitter"
#define ARMAMENT_SUBCATEGORY_CELL_UPGRADE "Cell Upgrade"
#define ARMAMENT_SUBCATEGORY_CHEMICAL "Chemicals"
#define ARMAMENT_SUBCATEGORY_CQC "Close Quarters"

// Bitflags for what company a cargo order datum should belong to
#define CARGO_COMPANY_NAKAMURA_MODSUITS (1<<0)
#define CARGO_COMPANY_BLACKSTEEL (1<<1)
#define CARGO_COMPANY_NRI_SURPLUS (1<<2)
#define CARGO_COMPANY_DEFOREST (1<<3)
#define CARGO_COMPANY_DONK (1<<4)
#define CARGO_COMPANY_KAHRAMAN (1<<5)
#define CARGO_COMPANY_FRONTIER_EQUIPMENT (1<<6)
#define CARGO_COMPANY_SOL_DEFENSE (1<<7)
#define CARGO_COMPANY_MICROSTAR (1<<8)
#define CARGO_COMPANY_VITEZSTVI_AMMO (1<<9)

// Company names, because the armament category and company name need to be the exact same, so use defines like this
#define NAKAMURA_ENGINEERING_MODSUITS_NAME "Nakamura Engineering MOD Divison"
#define BLACKSTEEL_FOUNDATION_NAME "Jarnsmiour Blacksteel Foundation"
#define NRI_SURPLUS_COMPANY_NAME "Izlishek Company Military Supplier"
#define DEFOREST_MEDICAL_NAME "DeForest Medical Corporation"
#define DONK_CO_NAME "Donk Corporation"
#define KAHRAMAN_INDUSTRIES_NAME "Kahraman Heavy Industries"
#define FRONTIER_EQUIPMENT_NAME "Akhter Company Frontier Equipment"
#define SOL_DEFENSE_DEFENSE_NAME "Sol Defense Imports"
#define MICROSTAR_ENERGY_NAME "MicroStar Energy Weapon Coalition"
#define VITEZSTVI_AMMO_NAME "Vitezstvi Ammo & Weapon Accessories"

#define COMPANY_INTEREST_GAIN_BIG 10
#define COMPANY_INTEREST_GAIN_AVERAGE 5
#define COMPANY_INTEREST_GAIN_LOW 3
#define COMPANY_INTEREST_GAIN_PITIFUL 1

#define ARMOR_LEVEL_TINY 10
#define ARMOR_LEVEL_WEAK 30
#define ARMOR_LEVEL_MID 50
#define ARMOR_LEVEL_INSANE 90

#define WOUND_ARMOR_WEAK 10
#define WOUND_ARMOR_STANDARD 20
#define WOUND_ARMOR_HIGH 30

//Default text for different messages for the user.
#define HELMET_UNSEAL_MESSAGE "hisses open"
#define HELMET_SEAL_MESSAGE "hisses closed"
#define CHESTPLATE_UNSEAL_MESSAGE "releases your chest"
#define CHESTPLATE_SEAL_MESSAGE "cinches tightly around your chest"
#define GAUNTLET_UNSEAL_MESSAGE "become loose around your fingers"
#define GAUNTLET_SEAL_MESSAGE "tighten around your fingers and wrists"
#define BOOT_UNSEAL_MESSAGE "relax their grip on your legs"
#define BOOT_SEAL_MESSAGE "seal around your feet"

/// Colors for pride week
#define COLOR_PRIDE_RED "#FF6666"
#define COLOR_PRIDE_ORANGE "#FC9F3C"
#define COLOR_PRIDE_YELLOW "#EAFF51"
#define COLOR_PRIDE_GREEN "#41FC66"
#define COLOR_PRIDE_BLUE "#42FFF2"
#define COLOR_PRIDE_PURPLE "#5D5DFC"

/// Trait that changes the ending effects of twitch leaving your system
#define TRAIT_TWITCH_ADAPTED "twitch_adapted"

// Have to put it here so I can use it in the global list of wound series
/// See muscle.dm and robotic_blunt.dm
#define WOUND_SERIES_MUSCLE_DAMAGE "nova_wound_series_muscle_damage"

//defines for antag opt in objective checking
//objectives check for all players with a value equal or greater than the 'threat' level of an objective then pick from that list
//command + sec roles are always opted in regardless of opt in status

/// For temporary or otherwise 'inconvenient' objectives like kidnapping or theft
#define OPT_IN_YES_TEMP 1
/// Cool with being killed or otherwise occupied but not removed from the round
#define OPT_IN_YES_KILL 2
/// Fine with being round removed.
#define OPT_IN_YES_ROUND_REMOVE 3

#define OPT_IN_YES_TEMP_STRING "Yes - Temporary/Inconvenience"
#define OPT_IN_YES_KILL_STRING "Yes - Kill"
#define OPT_IN_YES_ROUND_REMOVE_STRING "Yes - Round Remove"
#define OPT_IN_NOT_TARGET_STRING "No"

/// Assoc list of stringified opt_in_## define to the front-end string to show users as a representation of the setting.
GLOBAL_LIST_INIT(antag_opt_in_strings, list(
	"0" = OPT_IN_NOT_TARGET_STRING,
	"1" = OPT_IN_YES_TEMP_STRING,
	"2" = OPT_IN_YES_KILL_STRING,
	"3" = OPT_IN_YES_ROUND_REMOVE_STRING,
))

/// Assoc list of stringified opt_in_## define to the color associated with it.
GLOBAL_LIST_INIT(antag_opt_in_colors, list(
	OPT_IN_NOT_TARGET_STRING = COLOR_GRAY,
	OPT_IN_YES_TEMP_STRING = COLOR_EMERALD,
	OPT_IN_YES_KILL_STRING = COLOR_ORANGE,
	OPT_IN_YES_ROUND_REMOVE_STRING = COLOR_RED
))

/// Prefers not to be a target. Will still be a potential target if playing sec or command.
#define OPT_IN_NOT_TARGET 0

/// The minimum opt-in level for people playing sec.
#define SECURITY_OPT_IN_LEVEL OPT_IN_YES_ROUND_REMOVE
/// The minimum opt-in level for people playing command.
#define COMMAND_OPT_IN_LEVEL OPT_IN_YES_ROUND_REMOVE

/// The default opt in level for preferences and mindless mobs.
#define OPT_IN_DEFAULT_LEVEL OPT_IN_YES_KILL

/// If the player has any non-ghost role antags enabled, they are forced to use a minimum of this.
#define OPT_IN_ANTAG_ENABLED_LEVEL OPT_IN_YES_TEMP
