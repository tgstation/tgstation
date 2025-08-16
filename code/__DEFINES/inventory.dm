/*ALL DEFINES RELATED TO INVENTORY OBJECTS, MANAGEMENT, ETC, GO HERE*/

//ITEM INVENTORY WEIGHT, FOR w_class
/// Usually items smaller then a human hand, (e.g. playing cards, lighter, scalpel, coins/holochips)
#define WEIGHT_CLASS_TINY 1
/// Pockets can hold small and tiny items, (e.g. flashlight, multitool, grenades, GPS device)
#define WEIGHT_CLASS_SMALL 2
/// Standard backpacks can carry tiny, small & normal items, (e.g. fire extinguisher, stun baton, gas mask, metal sheets)
#define WEIGHT_CLASS_NORMAL 3
/// Items that can be wielded or equipped but not stored in an inventory, (e.g. defibrillator, backpack, space suits)
#define WEIGHT_CLASS_BULKY 4
/// Usually represents objects that require two hands to operate, (e.g. shotgun, two-handed melee weapons)
#define WEIGHT_CLASS_HUGE 5
/// Essentially means it cannot be picked up or placed in an inventory, (e.g. mech parts, safe)
#define WEIGHT_CLASS_GIGANTIC 6

/// Weight class that can fit in pockets
#define POCKET_WEIGHT_CLASS WEIGHT_CLASS_SMALL

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH 3
#define STORAGE_VIEW_DEPTH 2

//ITEM INVENTORY SLOT BITMASKS
/// Suit slot (armors, costumes, space suits, etc.)
#define ITEM_SLOT_OCLOTHING (1<<0)
/// Jumpsuit slot
#define ITEM_SLOT_ICLOTHING (1<<1)
/// Glove slot
#define ITEM_SLOT_GLOVES (1<<2)
/// Glasses slot
#define ITEM_SLOT_EYES (1<<3)
/// Ear slot (radios, earmuffs)
#define ITEM_SLOT_EARS (1<<4)
/// Mask slot
#define ITEM_SLOT_MASK (1<<5)
/// Head slot (helmets, hats, etc.)
#define ITEM_SLOT_HEAD (1<<6)
/// Shoe slot
#define ITEM_SLOT_FEET (1<<7)
/// ID slot
#define ITEM_SLOT_ID (1<<8)
/// Belt slot
#define ITEM_SLOT_BELT (1<<9)
/// Back slot
#define ITEM_SLOT_BACK (1<<10)
/// Dextrous simplemob "hands" (used for Drones and Dextrous Guardians)
#define ITEM_SLOT_DEX_STORAGE (1<<11)
/// Neck slot (ties, bedsheets, scarves)
#define ITEM_SLOT_NECK (1<<12)
/// A character's hand slots
#define ITEM_SLOT_HANDS (1<<13)
/// Suit Storage slot
#define ITEM_SLOT_SUITSTORE (1<<14)
/// Left Pocket slot
#define ITEM_SLOT_LPOCKET (1<<15)
/// Right Pocket slot
#define ITEM_SLOT_RPOCKET (1<<16)
/// Handcuff slot
#define ITEM_SLOT_HANDCUFFED (1<<17)
/// Legcuff slot (bolas, beartraps)
#define ITEM_SLOT_LEGCUFFED (1<<18)

/// Total amount of slots
#define SLOTS_AMT 19 // Keep this up to date!

///Inventory slots that can be blacklisted by a species from being equipped into
DEFINE_BITFIELD(no_equip_flags, list(
	"EXOSUIT" = ITEM_SLOT_OCLOTHING,
	"JUMPSUIT" = ITEM_SLOT_ICLOTHING,
	"GLOVES" = ITEM_SLOT_GLOVES,
	"GLASSES" = ITEM_SLOT_EYES,
	"EARPIECES" = ITEM_SLOT_EARS,
	"MASKS" = ITEM_SLOT_MASK,
	"HATS" = ITEM_SLOT_HEAD,
	"SHOES" = ITEM_SLOT_FEET,
	"BACKPACKS" = ITEM_SLOT_BACK,
	"TIES" = ITEM_SLOT_NECK,
))

//SLOT GROUP HELPERS
#define ITEM_SLOT_POCKETS (ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET)
/// Slots that are physically on you
#define ITEM_SLOT_ON_BODY (ITEM_SLOT_ICLOTHING | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_EYES | ITEM_SLOT_EARS | \
	ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_FEET | ITEM_SLOT_ID | ITEM_SLOT_BELT | ITEM_SLOT_BACK | ITEM_SLOT_NECK )

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
//Make sure to update check_obscured_slots() if you add more.
#define HIDEGLOVES (1<<0)
#define HIDESUITSTORAGE (1<<1)
#define HIDEJUMPSUIT (1<<2) //these first four are only used in exterior suits
#define HIDESHOES (1<<3)
#define HIDEMASK (1<<4) //these next seven are only used in masks and headgear.
#define HIDEEARS (1<<5) // (ears means headsets and such)
#define HIDEEYES (1<<6) // Whether eyes and glasses are hidden
#define HIDEFACE (1<<7) // Whether we appear as unknown.
#define HIDEHAIR (1<<8)
#define HIDEFACIALHAIR (1<<9)
#define HIDENECK (1<<10)
/// for wigs, only obscures the headgear
#define HIDEHEADGEAR (1<<11)
///for lizard snouts, because some HIDEFACE clothes don't actually conceal that portion of the head.
#define HIDESNOUT (1<<12)
///hides mutant/moth wings, does not apply to functional wings
#define HIDEMUTWINGS (1<<13)
///hides belts and riggings
#define HIDEBELT (1<<14)
///hides antennae
#define HIDEANTENNAE (1<<15)

//Bitflags for hair appendage zones
#define HAIR_APPENDAGE_FRONT (1<<0)
#define HAIR_APPENDAGE_LEFT (1<<1)
#define HAIR_APPENDAGE_RIGHT (1<<2)
#define HAIR_APPENDAGE_REAR (1<<3)
#define HAIR_APPENDAGE_TOP (1<<4)
#define HAIR_APPENDAGE_HANGING_FRONT (1<<5)
#define HAIR_APPENDAGE_HANGING_REAR (1<<6)
#define HAIR_APPENDAGE_ALL (HAIR_APPENDAGE_FRONT|HAIR_APPENDAGE_LEFT|HAIR_APPENDAGE_RIGHT|HAIR_APPENDAGE_REAR|HAIR_APPENDAGE_TOP|HAIR_APPENDAGE_HANGING_FRONT|HAIR_APPENDAGE_HANGING_REAR)

//bitflags for clothing coverage - also used for limbs
#define CHEST (1<<0)
#define GROIN (1<<1)
#define HEAD (1<<2)
#define LEG_LEFT (1<<3)
#define LEG_RIGHT (1<<4)
#define LEGS (LEG_LEFT | LEG_RIGHT)
#define FOOT_LEFT (1<<5)
#define FOOT_RIGHT (1<<6)
#define FEET (FOOT_LEFT | FOOT_RIGHT)
#define ARM_LEFT (1<<7)
#define ARM_RIGHT (1<<8)
#define ARMS (ARM_LEFT | ARM_RIGHT)
#define HAND_LEFT (1<<9)
#define HAND_RIGHT (1<<10)
#define HANDS (HAND_LEFT | HAND_RIGHT)
#define NECK (1<<11)
#define FULL_BODY ALL

//defines for the index of hands
#define LEFT_HANDS 1
#define RIGHT_HANDS 2
/// Checks if the value is "right" - same as ISEVEN, but used primarily for hand or foot index contexts
#define IS_RIGHT_INDEX(value) (value % 2 == 0)
/// Checks if the value is "left" - same as ISODD, but used primarily for hand or foot index contexts
#define IS_LEFT_INDEX(value) (value % 2 != 0)

//flags for female outfits: How much the game can safely "take off" the uniform without it looking weird
/// For when there's simply no need for a female version of this uniform.
#define NO_FEMALE_UNIFORM 0
/// For the game to take off everything, disregards other flags.
#define FEMALE_UNIFORM_FULL (1<<0)
/// For when you really need to avoid the game cutting off that one pixel between the legs, to avoid the comeback of the infamous "dixel".
#define FEMALE_UNIFORM_TOP_ONLY (1<<1)
/// For when you don't want the "breast" effect to be applied (the one that cuts two pixels in the middle of the front of the uniform when facing east or west).
#define FEMALE_UNIFORM_NO_BREASTS (1<<2)

//flags for alternate styles: These are hard sprited so don't set this if you didn't put the effort in
#define NORMAL_STYLE 0
#define ALT_STYLE 1
#define DIGITIGRADE_STYLE 2

//Flags (actual flags, fucker ^) for /obj/item/var/supports_variations_flags
/// No alternative sprites or handling based on bodytype
#define CLOTHING_NO_VARIATION (1<<0)
/// Has a sprite for digitigrade legs specifically.
#define CLOTHING_DIGITIGRADE_VARIATION (1<<1)
/// The sprite works fine for digitigrade legs as-is.
#define CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON (1<<2)
/// Auto-generates the leg portion of the sprite with GAGS
#define CLOTHING_DIGITIGRADE_MASK (1<<3)

/// All variation flags which render "correctly" on a digitigrade leg setup
#define DIGITIGRADE_VARIATIONS (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON|CLOTHING_DIGITIGRADE_MASK)

//flags for covering body parts
#define GLASSESCOVERSEYES (1<<0)
#define MASKCOVERSEYES (1<<1) // get rid of some of the other stupidness in these flags
#define HEADCOVERSEYES (1<<2) // feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH (1<<3) // on other items, these are just for mask/head
#define HEADCOVERSMOUTH (1<<4)
#define PEPPERPROOF (1<<5) //protects against pepperspray
#define EARS_COVERED (1<<6)

#define TINT_DARKENED 2 //Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3 //Threshold of tint level to obscure vision fully

// defines for AFK theft
/// How many messages you can remember while logged out before you stop remembering new ones
#define AFK_THEFT_MAX_MESSAGES 10
/// If someone logs back in and there are entries older than this, just tell them they can't remember who it was or when
#define AFK_THEFT_FORGET_DETAILS_TIME (5 MINUTES)
/// The index of the entry in 'afk_thefts' with the person's visible name at the time
#define AFK_THEFT_NAME 1
/// The index of the entry in 'afk_thefts' with the text
#define AFK_THEFT_MESSAGE 2
/// The index of the entry in 'afk_thefts' with the time it happened
#define AFK_THEFT_TIME 3

/// A list of things that any suit storage can hold
/// Should consist of ubiquitous, non-specialized items
/// or items that are meant to be "suit storage agnostic" as
/// a benefit, which of the time of this commit only applies
/// to the captain's jetpack, here
GLOBAL_LIST_INIT(any_suit_storage, typecacheof(list(
	/obj/item/clipboard,
	/obj/item/flashlight,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman,
	/obj/item/lighter,
	/obj/item/pen,
	/obj/item/modular_computer/pda,
	/obj/item/toy,
	/obj/item/radio,
	/obj/item/storage/bag/books,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/tank/jetpack/oxygen/captain,
	/obj/item/stack/spacecash,
	/obj/item/storage/wallet,
	/obj/item/folder,
	/obj/item/storage/box/matches,
	/obj/item/cigarette,
	/obj/item/gun/energy/laser/bluetag,
	/obj/item/gun/energy/laser/redtag,
	/obj/item/storage/belt/holster
)))

//Allowed equipment lists for security vests.

GLOBAL_LIST_INIT(detective_vest_allowed, list(
	/obj/item/detective_scanner,
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/lighter,
	/obj/item/melee/baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/taperecorder,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman,
	/obj/item/storage/belt/holster/detective,
	/obj/item/storage/belt/holster/nukie,
	/obj/item/storage/belt/holster/energy,
	/obj/item/gun/ballistic/shotgun/automatic/combat/compact,
))

GLOBAL_LIST_INIT(security_vest_allowed, list(
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/knife/combat,
	/obj/item/melee/baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman,
	/obj/item/storage/belt/holster/detective,
	/obj/item/storage/belt/holster/nukie,
	/obj/item/storage/belt/holster/energy,
	/obj/item/gun/ballistic/shotgun/automatic/combat/compact,
	/obj/item/pen/red/security,
))

GLOBAL_LIST_INIT(security_wintercoat_allowed, list(
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/melee/baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/storage/belt/holster/detective,
	/obj/item/storage/belt/holster/nukie,
	/obj/item/storage/belt/holster/energy,
	/obj/item/gun/ballistic/shotgun/automatic/combat/compact,
))

//Allowed list for all chaplain suits (except the honkmother robe)

GLOBAL_LIST_INIT(chaplain_suit_allowed, list(
	/obj/item/book/bible,
	/obj/item/nullrod,
	/obj/item/reagent_containers/cup/glass/bottle/holywater,
	/obj/item/storage/fancy/candle_box,
	/obj/item/flashlight/flare/candle,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman,
	/obj/item/gun/ballistic/bow/divine,
	/obj/item/gun/ballistic/revolver/chaplain,
))

//Allowed list for all mining suits

GLOBAL_LIST_INIT(mining_suit_allowed, list(
	/obj/item/t_scanner/adv_mining_scanner,
	/obj/item/melee/cleaving_saw,
	/obj/item/climbing_hook,
	/obj/item/flashlight,
	/obj/item/grapple_gun,
	/obj/item/tank/internals,
	/obj/item/gun/energy/recharge/kinetic_accelerator,
	/obj/item/kinetic_crusher,
	/obj/item/knife,
	/obj/item/mining_scanner,
	/obj/item/organ/monster_core,
	/obj/item/storage/bag/ore,
	/obj/item/pickaxe,
	/obj/item/resonator,
	/obj/item/spear,
))

/// List of all "tools" that can fit into belts or work from toolboxes

GLOBAL_LIST_INIT(tool_items, list(
	/obj/item/airlock_painter,
	/obj/item/analyzer,
	/obj/item/assembly/signaler,
	/obj/item/construction/rcd,
	/obj/item/construction/rld,
	/obj/item/construction/rtd,
	/obj/item/crowbar,
	/obj/item/extinguisher/mini,
	/obj/item/flashlight,
	/obj/item/forcefield_projector,
	/obj/item/geiger_counter,
	/obj/item/holosign_creator/atmos,
	/obj/item/holosign_creator/engineering,
	/obj/item/inducer,
	/obj/item/lightreplacer,
	/obj/item/multitool,
	/obj/item/pipe_dispenser,
	/obj/item/pipe_painter,
	/obj/item/plunger,
	/obj/item/radio,
	/obj/item/screwdriver,
	/obj/item/stack/cable_coil,
	/obj/item/t_scanner,
	/obj/item/weldingtool,
	/obj/item/wirecutters,
	/obj/item/wrench,
	/obj/item/spess_knife,
))

// Keys for equip_in_one_of_slots, if you add new ones update the assoc lists in equip_in_one_of_slots
/// Items placed into the left pocket.
#define LOCATION_LPOCKET "in your left pocket"
/// Items placed into the right pocket
#define LOCATION_RPOCKET "in your right pocket"
/// Items placed into the backpack.
#define LOCATION_BACKPACK "in your backpack"
/// Items placed into the hands.
#define LOCATION_HANDS "in your hands"
/// Items placed in the glove slot.
#define LOCATION_GLOVES "on your hands"
/// Items placed in the eye/glasses slot.
#define LOCATION_EYES "covering your eyes"
/// Items placed in the mask slot.
#define LOCATION_MASK "covering your face"
/// Items placed on the head/hat slot.
#define LOCATION_HEAD "on your head"
/// Items placed in the neck slot.
#define LOCATION_NECK "around your neck"
/// Items placed in the id slot
#define LOCATION_ID "in your ID slot"
