/// Organ flag for organs of hemophage origin, or organs that have since been infected by an hemophage's tumor.
#define ORGAN_TUMOR_CORRUPTED (1<<12) // Not taking chances, hopefully this number remains good for a little while.

/// We have a pulsating tumor, it's active.
#define PULSATING_TUMOR_ACTIVE 0
/// We have a pulsating tumor, it's dormant.
#define PULSATING_TUMOR_DORMANT 1
/// We don't have a pulsating tumor.
#define PULSATING_TUMOR_MISSING 2

/// Minimum amount of blood that you can reach via blood regeneration, regeneration will stop below this.
#define MINIMUM_VOLUME_FOR_REGEN (BLOOD_VOLUME_BAD + 1) // We do this to avoid any jankiness, and because we want to ensure that they don't fall into a state where they're constantly passing out in a locker.
/// Vomit flags for hemophages who eat food
#define HEMOPHAGE_VOMIT_FLAGS (MOB_VOMIT_MESSAGE | MOB_VOMIT_FORCE)
/// The ratio of reagents that get purged while a Hemophage vomits from trying to eat/drink something that their tumor doesn't like.
#define HEMOPHAGE_VOMIT_PURGE_RATIO 0.95
/// How much disgust we're at after eating/drinking something the tumor doesn't like.
#define TUMOR_DISLIKED_FOOD_DISGUST DISGUST_LEVEL_GROSS + 15
