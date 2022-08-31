
// Cleaning flags

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
