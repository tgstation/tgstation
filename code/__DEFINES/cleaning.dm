
// Cleaning flags

// Different kinds of things that can be cleaned.
// Use these when overriding the wash proc or registering for the clean signals to check if your thing should be cleaned
#define CLEAN_TYPE_BLOOD (1 << 0)
#define CLEAN_TYPE_RUNES (1 << 1)
#define CLEAN_TYPE_FINGERPRINTS (1 << 2)
#define CLEAN_TYPE_FIBERS (1 << 3)
#define CLEAN_TYPE_RADIATION (1 << 4)
#define CLEAN_TYPE_DISEASE (1 << 5)
#define CLEAN_TYPE_WEAK (1 << 6) // Special type, add this flag to make some cleaning processes non-instant. Currently only used for showers when removing radiation.
#define CLEAN_TYPE_PAINT (1 << 7)

// Different cleaning methods.
// Use these when calling the wash proc for your cleaning apparatus
#define CLEAN_WASH (CLEAN_TYPE_BLOOD | CLEAN_TYPE_RUNES | CLEAN_TYPE_DISEASE)
#define CLEAN_SCRUB (CLEAN_WASH | CLEAN_TYPE_FINGERPRINTS | CLEAN_TYPE_FIBERS | CLEAN_TYPE_PAINT)
#define CLEAN_RAD CLEAN_TYPE_RADIATION
#define CLEAN_ALL (ALL & ~CLEAN_TYPE_WEAK)
