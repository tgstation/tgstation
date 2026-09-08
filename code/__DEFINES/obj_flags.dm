// Flags for the obj_flags var on /obj

/// Object has been affected by a cryptographic sequencer (EMAG) disabling it or causing other malicious effects
#define EMAGGED (1<<0)
/// Can this be bludgeoned by items
#define CAN_BE_HIT (1<<1)
/// Admin possession yes/no
#define DANGEROUS_POSSESSION (1<<2)
/// Can you customize the description/name of the thing
#define UNIQUE_RENAME (1<<3)
/// If it can be renamed, is its description excluded
#define RENAME_NO_DESC (1<<4)
/// Should this object block z falling from loc
#define BLOCK_Z_OUT_DOWN (1<<5)
/// Should this object block z uprise from loc
#define BLOCK_Z_OUT_UP (1<<6)
/// Should this object block z falling from above
#define BLOCK_Z_IN_DOWN (1<<7)
/// Should this object block z uprise from below
#define BLOCK_Z_IN_UP (1<<8)
/// Does this object prevent things from being built on it
#define BLOCKS_CONSTRUCTION (1<<9)
/// Does this object prevent same-direction things from being built on it
#define BLOCKS_CONSTRUCTION_DIR (1<<10)
/// Can we ignore density when building on this object (for example, directional windows and grilles)
#define IGNORE_DENSITY (1<<11)
/// Can this object conduct electricity
#define CONDUCTS_ELECTRICITY (1<<12)
/// Atoms don't spawn anything when deconstructed (they just vanish)
#define NO_DEBRIS_AFTER_DECONSTRUCTION (1<<13)
/// Flag which tells an object to hang onto an support atom on late initialize. Usefull only during mapload and supported by some atoms only
#define MOUNT_ON_LATE_INITIALIZE (1<<14)

// If you add new ones, be sure to add them to /obj/Initialize as well for complete mapping support

// Flags for the item_flags var on /obj/item

/// Is this item equipped into an inventory slot or hand of a mob?
#define IN_INVENTORY (1<<0)
/// If set, calls set_force_string when retrieving force for tooltips
#define FORCE_STRING_OVERRIDE (1<<1)
/// Used by security bots to determine if this item is safe for public use.
#define NEEDS_PERMIT (1<<2)
/// Must be set for an item's slowdown to apply when held rather than just worn
#define SLOWS_WHILE_IN_HAND (1<<3)
// Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define NO_MAT_REDEMPTION (1<<4)
/// When dropped, it calls qdel on itself
#define DROPDEL (1<<5)
/// Item cannot be used for attacks, even if it has a force set.
#define NOBLUDGEON (1<<6)
/**
 * for all things that are technically items but don't want to be treated as such, given on a case-by-case basis
 * examples of use are hand items, omni-toolsets, non-limb limbs (hand eater, mounted chainsaw, many null rods), borg modules, bodyparts, organs, etc.
 * This is used for general exclusion, such as preventing insertions into other items
 * Basically, these aren't "real" items. <= wow thanks for the fucking insight sherlock
*/
#define ABSTRACT (1<<7)
/// When players should not be able to change the slowdown of the item (Speed potions, etc)
#define IMMUTABLE_SLOW (1<<8)
/// is this item in the storage item, such as backpack?
#define IN_STORAGE (1<<9)
/// Tool commonly used for surgery, so it has some unique handling around surgical operations
#define SURGICAL_TOOL (1<<10)
/// This object, when used for surgery, causes a lot more pain for the patient, and is more efficient in a morbid users hands
#define CRUEL_IMPLEMENT (1<<11)
/// If an item represents a hand (circled hand, slapper) and shouldn't block things like riding
#define HAND_ITEM (1<<12)
/// if dropped, it wont have a randomized pixel_x/pixel_y
#define NO_PIXEL_RANDOM_DROP (1<<13)
///Can be equipped on digitigrade legs.
#define IGNORE_DIGITIGRADE (1<<14)
/// Has contextual screentips when HOVERING OVER OTHER objects
#define ITEM_HAS_CONTEXTUAL_SCREENTIPS (1<<15)
/// No blood overlay is allowed to appear on this item, and it cannot gain blood DNA forensics
#define NO_BLOOD_ON_ITEM (1<<16)
/// Whether this item should skip the /datum/component/fantasy applied on spawn on the RPG event. Used on things like stacks
#define SKIP_FANTASY_ON_SPAWN (1<<17)
/// If an item has had its /datum/element/weapon_description initialized or not.
#define WEAPON_DESCRIPTION_INITIALIZED (1<<18)

// Flags for the clothing_flags var on /obj/item/clothing

/// SUIT and HEAD items which stop lava from hurting the wearer
#define LAVAPROTECT (1<<0)
/// SUIT and HEAD items which stop pressure damage.
/// To stop you taking all pressure damage you must have both a suit and head item with this flag.
#define STOPSPRESSUREDAMAGE (1<<1)
/// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define BLOCK_GAS_SMOKE_EFFECT (1<<2)
/// mask allows internals
#define MASKINTERNALS (1<<3)
/// prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag.
/// Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define THICKMATERIAL (1<<4)
/// The voicebox in this clothing can be toggled.
#define VOICEBOX_TOGGLABLE (1<<5)
/// The voicebox is currently turned off.
#define VOICEBOX_DISABLED (1<<6)
/// Prevents knock-off from things like hat-throwing.
#define SNUG_FIT (1<<7)
/// Clothes that use large icons, for applying the proper overlays like blood
#define LARGE_WORN_ICON (1<<8)
/// prevents from placing on plasmaman helmet or modsuit hat holder
#define STACKABLE_HELMET_EXEMPT (1<<9)
/// Prevents plasmamen from igniting when wearing this
#define PLASMAMAN_PREVENT_IGNITION (1<<10)
/// Headgear/helmet allows internals
#define HEADINTERNALS (1<<11)
/// Prevents masks from getting adjusted from enabling internals
#define INTERNALS_ADJUST_EXEMPT (1<<12)
/// Indicates that the piece of clothing contributes towards Sleeping Carp's style factor, which determines evasion probabilities. See /datums/martial/sleeping_carp/carp_style_check().
#define CARP_STYLE_FACTOR (1<<13)
/// Prevents clothing from losing bodyparts coverage when shredded
#define NO_ZONE_DISABLING (1<<14)

/// Integrity defines for clothing (not flags but close enough)
#define CLOTHING_PRISTINE 0 // We have no damage on the clothing
#define CLOTHING_DAMAGED 1 // There's some damage on the clothing but it still has at least one functioning bodypart and can be equipped
#define CLOTHING_SHREDDED 2 // The clothing is useless and cannot be equipped unless repaired first

/// Flags for the pod_flags var on /obj/structure/closet/supplypod
#define FIRST_SOUNDS (1<<0) // If it shouldn't play sounds the first time it lands, used for reverse mode

/// Flags for the gun_flags var for firearms
#define TOY_FIREARM_OVERLAY (1<<0) // If update_overlay would add some indicator that the gun is a toy, like a plastic cap on a pistol
/// Currently used to identify valid guns to steal
#define NOT_A_REAL_GUN (1<<1)
/// This gun shouldn't be allowed to go in a turret (it probably causes a bug/exploit)
#define TURRET_INCOMPATIBLE (1<<2)

/// Flags for sharpness in obj/item
#define SHARP_EDGED (1<<0)
#define SHARP_POINTY (1<<1)

/// Flags for specifically what kind of items to get in get_equipped_items
#define INCLUDE_POCKETS (1<<0)
#define INCLUDE_ACCESSORIES (1<<1)
#define INCLUDE_HELD (1<<2)
/// Include prosthetic item limbs (which are not flavoured as being equipped items)
#define INCLUDE_PROSTHETICS (1<<3)
/// Include items that are not "real" items, such as hand items
#define INCLUDE_ABSTRACT (1<<4)
