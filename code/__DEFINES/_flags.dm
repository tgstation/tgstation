#define ALL (~0) //For convenience.
#define NONE 0

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

/* Directions */
///All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH|SOUTH|EAST|WEST)

// for /datum/var/datum_flags
#define DF_USE_TAG (1<<0)
#define DF_VAR_EDITED (1<<1)
#define DF_ISPROCESSING (1<<2)

//FLAGS BITMASK
// scroll down before changing the numbers on these

/// Is this object currently processing in the atmos object list?
#define ATMOS_IS_PROCESSING_1 (1<<0)
/// item has priority to check when entering or leaving
#define ON_BORDER_1 (1<<1)
///Whether or not this atom shows screentips when hovered over
#define NO_SCREENTIPS_1 (1<<2)
/// Prevent clicking things below it on the same turf eg. doors/ fulltile windows
#define PREVENT_CLICK_UNDER_1 (1<<3)
///specifies that this atom is a hologram that isnt real
#define HOLOGRAM_1 (1<<4)
///Whether /atom/Initialize() has already run for the object
#define INITIALIZED_1 (1<<5)
/// was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED_1 (1<<6)
/// should not get harmed if this gets caught by an explosion?
#define PREVENT_CONTENTS_EXPLOSION_1 (1<<7)
/// Should this object be paintable with very dark colors?
#define ALLOW_DARK_PAINTS_1 (1<<8)
/// Should this object be unpaintable?
#define UNPAINTABLE_1 (1<<9)
/// Is this atom on top of another atom, and as such has click priority?
#define IS_ONTOP_1 (1<<10)
/// Is this atom immune to being dusted by the supermatter?
#define SUPERMATTER_IGNORES_1 (1<<11)
/// If a turf can be made dirty at roundstart. This is also used in areas.
#define CAN_BE_DIRTY_1 (1<<12)
/// Should we use the initial icon for display? Mostly used by overlay only objects
#define HTML_USE_INITAL_ICON_1 (1<<13)
/// Can players recolor this in-game via vendors (and maybe more if support is added)?
#define IS_PLAYER_COLORABLE_1 (1<<14)
/// Whether or not this atom has contextual screentips when hovered OVER
#define HAS_CONTEXTUAL_SCREENTIPS_1 (1<<15)
/// Whether or not this atom is storing contents for a disassociated storage object
#define HAS_DISASSOCIATED_STORAGE_1 (1<<16)
/// If this atom has experienced a decal element "init finished" sourced appearance update
/// We use this to ensure stacked decals don't double up appearance updates for no rasin
/// Flag as an optimization, don't make this a trait without profiling
/// Yes I know this is a stupid flag, no you can't take him from me
#define DECAL_INIT_UPDATE_EXPERIENCED_1 (1<<17)
/// This atom always returns its turf in get_turf_pixel instead of the turf from its offsets
#define IGNORE_TURF_PIXEL_OFFSET_1 (1<<18)

// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME (1<<0)
/// Update the atom's desc
#define UPDATE_DESC (1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE (1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS (1<<3)
/// Update the atom's greyscaling
#define UPDATE_GREYSCALE (1<<4)
/// Update the atom's smoothing. (More accurately, queue it for an update)
#define UPDATE_SMOOTHING (1<<5)
/// Update the atom's icon
#define UPDATE_ICON (UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/// If the thing can reflect light (lasers/energy)
#define RICOCHET_SHINY (1<<0)
/// If the thing can reflect matter (bullets/bomb shrapnel)
#define RICOCHET_HARD (1<<1)

//TURF FLAGS
/// If a turf cant be jaunted through.
#define NOJAUNT (1<<0)
/// If a turf is an usused reservation turf awaiting assignment
#define UNUSED_RESERVATION_TURF (1<<1)
/// If a turf is a reserved turf
#define RESERVATION_TURF (1<<2)
/// Blocks lava rivers being generated on the turf.
#define NO_LAVA_GEN (1<<3)
/// Blocks ruins spawning on the turf.
#define NO_RUINS (1<<4)
/// Blocks this turf from being rusted
#define NO_RUST (1<<5)
/// Is this turf is "solid". Space and lava aren't for instance
#define IS_SOLID (1<<6)
/// This turf will never be cleared away by other objects on Initialize.
#define NO_CLEARING (1<<7)
/// This atom is a pseudo-floor that blocks map generation's checkPlaceAtom() from placing things like trees ontop of it.
#define TURF_BLOCKS_POPULATE_TERRAIN_FLORAFEATURES (1<<8)


////////////////Area flags\\\\\\\\\\\\\\
/// If it's a valid territory for cult summoning or the CRAB-17 phone to spawn
#define VALID_TERRITORY (1<<0)
/// If blobs can spawn there and if it counts towards their score.
#define BLOBS_ALLOWED (1<<1)
/// If mining tunnel generation is allowed in this area
#define CAVES_ALLOWED (1<<2)
/// If flora are allowed to spawn in this area randomly through tunnel generation
#define FLORA_ALLOWED (1<<3)
/// If mobs can be spawned by natural random generation
#define MOB_SPAWN_ALLOWED (1<<4)
/// If megafauna can be spawned by natural random generation
#define MEGAFAUNA_SPAWN_ALLOWED (1<<5)
/// Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
#define NOTELEPORT (1<<6)
/// Hides area from player Teleport function.
#define HIDDEN_AREA (1<<7)
/// If false, loading multiple maps with this area type will create multiple instances.
#define UNIQUE_AREA (1<<8)
/// If people are allowed to suicide in it. Mostly for OOC stuff like minigames
#define BLOCK_SUICIDE (1<<9)
/// If set, this area will be innately traversable by Xenobiology camera consoles.
#define XENOBIOLOGY_COMPATIBLE (1<<10)
/// If blood cultists can draw runes or build structures on this AREA.
#define CULT_PERMITTED (1<<11)
/// If engravings are persistent in this area
#define PERSISTENT_ENGRAVINGS (1<<12)
/// Mobs that die in this area don't produce a dead chat message
#define NO_DEATH_MESSAGE (1<<13)
/// This area should have extra shielding from certain event effects
#define EVENT_PROTECTED (1<<14)
/// This Area Doesn't have Flood or Bomb Admin Messages, but will still log
#define QUIET_LOGS (1<<15)
/// This area does not allow virtual entities to enter.
#define VIRTUAL_SAFE_AREA (1<<16)
/// This area does not allow the Binary channel
#define BINARY_JAMMING (1<<17)
/// This area prevents Bag of Holding rifts from being opened.
#define NO_BOH (1<<18)

/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
/// Allows you to pass over tables.
#define PASSTABLE (1<<0)
/// Allows you to pass over glass(this generally includes anything see-through that's glass-adjacent, ie. windows, windoors, airlocks with glass, etc.)
#define PASSGLASS (1<<1)
/// Allows you to pass over grilles.
#define PASSGRILLE (1<<2)
/// Allows you to pass over blob tiles.
#define PASSBLOB (1<<3)
/// Allows you to pass over mobs.
#define PASSMOB (1<<4)
/// Allows you to pass over closed turfs, ie. walls.
#define PASSCLOSEDTURF (1<<5)
/// Let thrown things past us. **ONLY MEANINGFUL ON pass_flags_self!**
#define LETPASSTHROW (1<<6)
/// Allows you to pass over machinery, ie. vending machines, computers, protolathes, etc.
#define PASSMACHINE (1<<7)
/// Allows you to pass over structures, ie. racks, tables(if you don't already have PASSTABLE), etc.
#define PASSSTRUCTURE (1<<8)
/// Allows you to pass over plastic flaps, often found at cargo or MULE dropoffs.
#define PASSFLAPS (1<<9)
/// Allows you to pass over airlocks and mineral doors.
#define PASSDOORS (1<<10)
/// Allows you to pass over vehicles, ie. mecha, secways, the pimpin' ride, etc.
#define PASSVEHICLE (1<<11)
/// Allows you to pass over dense items.
#define PASSITEM (1<<12)
/// Do not intercept click attempts during Adjacent() checks. See [turf/proc/ClickCross]. **ONLY MEANINGFUL ON pass_flags_self!**
#define LETPASSCLICKS (1<<13)
/// Allows you to pass over windows and window-adjacent stuff, like windows and windoors. Does not include airlocks with glass in them.
#define PASSWINDOW (1<<14)

//Movement Types
#define GROUND (1<<0)
#define FLYING (1<<1)
#define VENTCRAWLING (1<<2)
#define FLOATING (1<<3)
/// When moving, will Cross() everything, but won't stop or Bump() anything.
#define PHASING (1<<4)
/// The mob is walking on the ceiling. Or is generally just, upside down.
#define UPSIDE_DOWN (1<<5)

/// Combination flag for movetypes which, for all intents and purposes, mean the mob is not touching the ground
#define MOVETYPES_NOT_TOUCHING_GROUND (FLYING|FLOATING|UPSIDE_DOWN)

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF (1<<0)
/// 100% immune to fire damage (but not necessarily to lava or heat)
#define FIRE_PROOF (1<<1)
/// atom is flammable and can have the burning component
#define FLAMMABLE (1<<2)
/// currently burning
#define ON_FIRE (1<<3)
/// acid can't even appear on it, let alone melt it.
#define UNACIDABLE (1<<4)
/// acid stuck on it doesn't melt it.
#define ACID_PROOF (1<<5)
/// doesn't take damage
#define INDESTRUCTIBLE (1<<6)
/// can't be frozen
#define FREEZE_PROOF (1<<7)
/// can't be shuttle crushed.
#define SHUTTLE_CRUSH_PROOF (1<<8)

//tesla_zap
#define ZAP_MACHINE_EXPLOSIVE (1<<0)
#define ZAP_ALLOW_DUPLICATES (1<<1)
#define ZAP_OBJ_DAMAGE (1<<2)
#define ZAP_MOB_DAMAGE (1<<3)
#define ZAP_MOB_STUN (1<<4)
#define ZAP_GENERATES_POWER (1<<5)
/// Zaps with this flag will generate less power through tesla coils
#define ZAP_LOW_POWER_GEN (1<<6)

#define ZAP_DEFAULT_FLAGS ZAP_MOB_STUN | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
#define ZAP_FUSION_FLAGS ZAP_OBJ_DAMAGE | ZAP_MOB_DAMAGE | ZAP_MOB_STUN
#define ZAP_SUPERMATTER_FLAGS ZAP_GENERATES_POWER

///EMP will protect itself.
#define EMP_PROTECT_SELF (1<<0)
///EMP will protect the contents from also being EMPed.
#define EMP_PROTECT_CONTENTS (1<<1)
///EMP will protect the wires.
#define EMP_PROTECT_WIRES (1<<2)

///Protects against all EMP types.
#define EMP_PROTECT_ALL (EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS | EMP_PROTECT_WIRES)

//Mob mobility var flags
/// can move
#define MOBILITY_MOVE (1<<0)
/// can, and is, standing up
#define MOBILITY_STAND (1<<1)
/// can pickup items
#define MOBILITY_PICKUP (1<<2)
/// can hold and use items
#define MOBILITY_USE (1<<3)
/// can use interfaces like machinery
#define MOBILITY_UI (1<<4)
/// can use storage item
#define MOBILITY_STORAGE (1<<5)
/// can pull things
#define MOBILITY_PULL (1<<6)
/// can rest
#define MOBILITY_REST (1<<7)
/// can lie down
#define MOBILITY_LIEDOWN (1<<8)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL)
#define MOBILITY_FLAGS_CARBON_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL | MOBILITY_REST | MOBILITY_LIEDOWN)
#define MOBILITY_FLAGS_REST_CAPABLE_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL | MOBILITY_REST | MOBILITY_LIEDOWN)

//alternate appearance flags
#define AA_TARGET_SEE_APPEARANCE (1<<0)
#define AA_MATCH_TARGET_OVERLAYS (1<<1)

#define KEEP_TOGETHER_ORIGINAL "keep_together_original"

//setter for KEEP_TOGETHER to allow for multiple sources to set and unset it
#define ADD_KEEP_TOGETHER(x, source)\
	if ((x.appearance_flags & KEEP_TOGETHER) && !HAS_TRAIT(x, TRAIT_KEEP_TOGETHER)) ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL); \
	ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	x.appearance_flags |= KEEP_TOGETHER

#define REMOVE_KEEP_TOGETHER(x, source)\
	REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	if(HAS_TRAIT_FROM_ONLY(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL))\
		REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL);\
	else if(!HAS_TRAIT(x, TRAIT_KEEP_TOGETHER))\
		x.appearance_flags &= ~KEEP_TOGETHER

//religious_tool flags
#define RELIGION_TOOL_INVOKE (1<<0)
#define RELIGION_TOOL_SACRIFICE (1<<1)
#define RELIGION_TOOL_SECTSELECT (1<<2)

// ---- Skillchip incompatability flags ---- //
// These flags control which skill chips are compatible with eachother.
// By default, skillchips are incompatible with themselves and multiple of the same istype() cannot be implanted together. Set this flag to disable that check.
#define SKILLCHIP_ALLOWS_MULTIPLE (1<<0)
// This skillchip is incompatible with other skillchips from the incompatible_category list.
#define SKILLCHIP_RESTRICTED_CATEGORIES (1<<1)

#define MAX_BITFIELD_SIZE 24

/// 33554431 (2^24 - 1) is the maximum value our bitflags can reach.
#define MAX_BITFLAG_DIGITS 8

// timed_action_flags parameter for `/proc/do_after`
/// Can do the action even if mob moves location
#define IGNORE_USER_LOC_CHANGE (1<<0)
/// Can do the action even if the target moves location
#define IGNORE_TARGET_LOC_CHANGE (1<<1)
/// Can do the action even if the item is no longer being held
#define IGNORE_HELD_ITEM (1<<2)
/// Can do the action even if the mob is incapacitated (ex. handcuffed)
#define IGNORE_INCAPACITATED (1<<3)
/// Used to prevent important slowdowns from being abused by drugs like kronkaine
#define IGNORE_SLOWDOWNS (1<<4)

// Spacevine-related flags
/// Is the spacevine / flower bud heat resistant
#define SPACEVINE_HEAT_RESISTANT (1 << 0)
/// Is the spacevine / flower bud cold resistant
#define SPACEVINE_COLD_RESISTANT (1 << 1)

// Flags for flora structures
#define FLORA_HERBAL (1 << 0)
#define FLORA_WOODEN (1 << 1)
#define FLORA_STONE (1 << 2)

// Bitflags for emotes, used in var/emote_type of the emote datum
/// Is the emote audible
#define EMOTE_AUDIBLE (1<<0)
/// Is the emote visible
#define EMOTE_VISIBLE (1<<1)
/// Is it an emote that should be shown regardless of blindness/deafness
#define EMOTE_IMPORTANT (1<<2)
/// Emote only prints to runechat, not to the chat window
#define EMOTE_RUNECHAT (1<<3)
