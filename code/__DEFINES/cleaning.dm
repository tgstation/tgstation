
// Cleaning flags

// Different kinds of things that can be cleaned.
// Use these when overriding the wash proc or registering for the clean signals to check if your thing should be cleaned
/// Cleans blood off of the cleanable atom.
#define CLEAN_TYPE_BLOOD (1 << 0)
/// Cleans runes off of the cleanable atom.
#define CLEAN_TYPE_RUNES (1 << 1)
/// Cleans fingerprints off of the cleanable atom.
#define CLEAN_TYPE_FINGERPRINTS (1 << 2)
/// Cleans fibres off of the cleanable atom.
#define CLEAN_TYPE_FIBERS (1 << 3)
/// Cleans diseases off of the cleanable atom.
#define CLEAN_TYPE_DISEASE (1 << 4)
/// Special type, add this flag to make some cleaning processes non-instant. Currently only used for showers when removing radiation.
#define CLEAN_TYPE_WEAK (1 << 5)
/// Cleans paint off of the cleanable atom.
#define CLEAN_TYPE_PAINT (1 << 6)
/// Cleans acid off of the cleanable atom.
#define CLEAN_TYPE_ACID (1 << 7)
/// Cleans decals such as dirt and oil off the floor
#define CLEAN_TYPE_LIGHT_DECAL (1 << 8)
/// Cleans decals such as cobwebs off the floor
#define CLEAN_TYPE_HARD_DECAL (1 << 9)

// Different cleaning methods.
// Use these when calling the wash proc for your cleaning apparatus
#define CLEAN_WASH (CLEAN_TYPE_BLOOD | CLEAN_TYPE_RUNES | CLEAN_TYPE_DISEASE | CLEAN_TYPE_ACID | CLEAN_TYPE_LIGHT_DECAL)
#define CLEAN_SCRUB (CLEAN_WASH | CLEAN_TYPE_FINGERPRINTS | CLEAN_TYPE_FIBERS | CLEAN_TYPE_PAINT | CLEAN_TYPE_HARD_DECAL)
#define CLEAN_ALL (ALL & ~CLEAN_TYPE_WEAK)
