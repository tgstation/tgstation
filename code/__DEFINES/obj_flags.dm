// Flags for the obj_flags var on /obj


#define EMAGGED (1<<0)
#define CAN_BE_HIT (1<<1) //can this be bludgeoned by items?
#define DANGEROUS_POSSESSION (1<<2) //Admin possession yes/no
#define UNIQUE_RENAME (1<<3) // can you customize the description/name of the thing?
#define BLOCK_Z_OUT_DOWN (1<<4)  // Should this object block z falling from loc?
#define BLOCK_Z_OUT_UP (1<<5) // Should this object block z uprise from loc?
#define BLOCK_Z_IN_DOWN (1<<6) // Should this object block z falling from above?
#define BLOCK_Z_IN_UP (1<<7) // Should this object block z uprise from below?
#define BLOCKS_CONSTRUCTION (1<<8) //! Does this object prevent things from being built on it?
#define BLOCKS_CONSTRUCTION_DIR (1<<9) //! Does this object prevent same-direction things from being built on it?
#define IGNORE_DENSITY (1<<10) //! Can we ignore density when building on this object? (for example, directional windows and grilles)
#define INFINITE_RESKIN (1<<11) // We can reskin this item infinitely
#define CONDUCTS_ELECTRICITY (1<<12) //! Can this object conduct electricity?
#define NO_DEBRIS_AFTER_DECONSTRUCTION (1<<13) //! Atoms don't spawn anything when deconstructed. They just vanish

// If you add new ones, be sure to add them to /obj/Initialize as well for complete mapping support

// Flags for the item_flags var on /obj/item

#define BEING_REMOVED (1<<0)
#define IN_INVENTORY (1<<1) //is this item equipped into an inventory slot or hand of a mob? used for tooltips
#define FORCE_STRING_OVERRIDE (1<<2) // used for tooltips
///Used by security bots to determine if this item is safe for public use.
#define NEEDS_PERMIT (1<<3)
#define SLOWS_WHILE_IN_HAND (1<<4)
#define NO_MAT_REDEMPTION (1<<5) // Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define DROPDEL (1<<6) // When dropped, it calls qdel on itself
#define NOBLUDGEON (1<<7) // when an item has this it produces no "X has been hit by Y with Z" message in the default attackby()
#define ABSTRACT (1<<9) // for all things that are technically items but used for various different stuff <= wow thanks for the fucking insight sherlock
#define IMMUTABLE_SLOW (1<<10) // When players should not be able to change the slowdown of the item (Speed potions, etc)
#define IN_STORAGE (1<<11) //is this item in the storage item, such as backpack? used for tooltips
#define SURGICAL_TOOL (1<<12) //Tool commonly used for surgery: won't attack targets in an active surgical operation on help intent (in case of mistakes)
#define CRUEL_IMPLEMENT (1<<13) //This object, when used for surgery, is a lot worse at the job if the target is alive rather than dead
#define HAND_ITEM (1<<14) // If an item is just your hand (circled hand, slapper) and shouldn't block things like riding
#define XENOMORPH_HOLDABLE (1<<15) // A Xenomorph can hold this item.
#define NO_PIXEL_RANDOM_DROP (1<<16) //if dropped, it wont have a randomized pixel_x/pixel_y
///Can be equipped on digitigrade legs.
#define IGNORE_DIGITIGRADE (1<<17)
/// Has contextual screentips when HOVERING OVER OTHER objects
#define ITEM_HAS_CONTEXTUAL_SCREENTIPS (1 << 18)
/// No blood overlay is allowed to appear on this item, and it cannot gain blood DNA forensics
#define NO_BLOOD_ON_ITEM (1 << 19)
/// Whether this item should skip the /datum/component/fantasy applied on spawn on the RPG event. Used on things like stacks
#define SKIP_FANTASY_ON_SPAWN (1<<20)

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
/// mask filters toxins and other harmful gases
#define GAS_FILTERING (1<<4)
/// prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag.
/// Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define THICKMATERIAL (1<<5)
/// The voicebox in this clothing can be toggled.
#define VOICEBOX_TOGGLABLE (1<<6)
/// The voicebox is currently turned off.
#define VOICEBOX_DISABLED (1<<7)
/// Prevents knock-off from things like hat-throwing.
#define SNUG_FIT (1<<8)
/// Hats with negative effects when worn (i.e the tinfoil hat).
#define ANTI_TINFOIL_MANEUVER (1<<9)
/// Clothes that cause a larger notification when placed on a person.
#define DANGEROUS_OBJECT (1<<10)
/// Clothes that use large icons, for applying the proper overlays like blood
#define LARGE_WORN_ICON (1<<11)
/// prevents from placing on plasmaman helmet or modsuit hat holder
#define STACKABLE_HELMET_EXEMPT (1<<12)
/// Prevents plasmamen from igniting when wearing this
#define PLASMAMAN_PREVENT_IGNITION (1<<13)
/// Usable as casting clothes by wizards (matters for suits, glasses and headwear)
#define CASTING_CLOTHES (1<<14)
///Moths can't eat the clothing that has this flag.
#define INEDIBLE_CLOTHING (1<<15)
/// Headgear/helmet allows internals
#define HEADINTERNALS (1<<16)
/// Prevents masks from getting adjusted from enabling internals
#define INTERNALS_ADJUST_EXEMPT (1<<17)

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
