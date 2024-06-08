
// Cleaning flags

/// Return to prevent clean attempts
#define CLEAN_BLOCKED (1<<0)
/// Return to allow clean attempts
/// This is (currently) the same as returning null / none but more explicit
#define CLEAN_ALLOWED (1<<1)
/// Return to prevent XP gain
/// Only does anything if [CLEAN_ALLOWED] is also returned
#define CLEAN_NO_XP (1<<2)
/// Return to stop cleaner component from blocking interaction chain further
/// Only does anything if [CLEAN_BLOCKED] is also returned
#define CLEAN_DONT_BLOCK_INTERACTION (1<<3)

// Different kinds of things that can be cleaned.
// Use these when overriding the wash proc or registering for the clean signals to check if your thing should be cleaned
/// Cleans blood off of the cleanable atom.
#define CLEAN_TYPE_BLOOD (1 << 0)
/// Cleans fingerprints off of the cleanable atom.
#define CLEAN_TYPE_FINGERPRINTS (1 << 1)
/// Cleans fibres off of the cleanable atom.
#define CLEAN_TYPE_FIBERS (1 << 2)
/// Cleans radiation off of the cleanable atom.
#define CLEAN_TYPE_RADIATION (1 << 3)
/// Cleans diseases off of the cleanable atom.
#define CLEAN_TYPE_DISEASE (1 << 4)
/// Cleans acid off of the cleanable atom.
#define CLEAN_TYPE_ACID (1 << 5)
/// Cleans decals such as dirt and oil off the floor
#define CLEAN_TYPE_LIGHT_DECAL (1 << 6)
/// Cleans decals such as cobwebs off the floor
#define CLEAN_TYPE_HARD_DECAL (1 << 7)

// Different cleaning methods.
// Use these when calling the wash proc for your cleaning apparatus
#define CLEAN_WASH (CLEAN_TYPE_BLOOD | CLEAN_TYPE_DISEASE | CLEAN_TYPE_ACID | CLEAN_TYPE_LIGHT_DECAL)
#define CLEAN_SCRUB (CLEAN_WASH | CLEAN_TYPE_FINGERPRINTS | CLEAN_TYPE_FIBERS | CLEAN_TYPE_HARD_DECAL)
#define CLEAN_RAD CLEAN_TYPE_RADIATION
#define CLEAN_ALL ALL

// Footprint sprites to use when making footprints in blood, oil, etc.
#define FOOTPRINT_SPRITE_SHOES "shoes"
#define FOOTPRINT_SPRITE_PAWS "paws"
#define FOOTPRINT_SPRITE_CLAWS "claws"
