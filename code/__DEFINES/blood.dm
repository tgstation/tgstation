//Bloody shoes/footprints
/// Minimum alpha of footprints
#define BLOODY_FOOTPRINT_BASE_ALPHA 20
/// How much blood a regular blood splatter contains
#define BLOOD_AMOUNT_PER_DECAL 50
/// How much blood an item can have stuck on it
#define BLOOD_ITEM_MAX 200
/// How much blood a blood decal can contain
#define BLOOD_POOL_MAX 300
/// How much blood a footprint need to at least contain
#define BLOOD_FOOTPRINTS_MIN 5
/// Bloodiness -> reagent units multiplier
#define BLOOD_TO_UNITS_MULTIPLIER 0.1

// Bitflags for mob dismemberment and gibbing
/// Mobs will drop a brain
#define DROP_BRAIN (1<<0)
/// Mobs will drop organs
#define DROP_ORGANS (1<<1)
/// Mobs will drop bodyparts (arms, legs, etc.)
#define DROP_BODYPARTS (1<<2)
/// Mobs will drop items
#define DROP_ITEMS (1<<3)

/// Mobs will drop everything
#define DROP_ALL_REMAINS (DROP_BRAIN | DROP_ORGANS | DROP_BODYPARTS | DROP_ITEMS)

// Keys for indexing blood data lists. HIGHLY INCOMPLETE.
/// Indexing a blood reagent data list with this returns how synthetic the blood is, used for blood worms to nerf common blood sources like monkeys.
#define BLOOD_DATA_SYNTH_CONTENT "synth_content"

/// Returns whether this mob always has synthetic blood. Used to cap growth for blood worms from easily accessible sources of blood.
#define IS_BLOOD_ALWAYS_SYNTHETIC(mob) (!ishuman(mob) || HAS_TRAIT(mob, TRAIT_BORN_MONKEY) || HAS_TRAIT(mob, TRAIT_SPAWNED_MOB))
