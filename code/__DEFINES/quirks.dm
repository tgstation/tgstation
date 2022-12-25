//Medical Categories for quirks
#define CAT_QUIRK_ALL 0
#define CAT_QUIRK_NOTES 1
#define CAT_QUIRK_MINOR_DISABILITY 2
#define CAT_QUIRK_MAJOR_DISABILITY 3

/// This quirk can only be applied to humans
#define QUIRK_HUMAN_ONLY (1<<0)
/// This quirk processes on SSquirks (and should implement quirk process)
#define QUIRK_PROCESSES (1<<1)
/// This quirk is has a visual aspect in that it changes how the player looks. Used in generating dummies.
#define QUIRK_CHANGES_APPEARANCE (1<<2)
/// The only thing this quirk effects is mood so it should be disabled if mood is
#define QUIRK_MOODLET_BASED (1<<3)
