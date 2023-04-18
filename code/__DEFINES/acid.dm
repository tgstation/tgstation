/// The acid power required to destroy most closed turfs.
#define ACID_POWER_MELT_TURF 200
/// The maximum amount of damage (per second) acid can deal to an [/obj].
#define MOVABLE_ACID_DAMAGE_MAX 300
/// Maximum acid volume that can be applied to an [/obj].
#define MOVABLE_ACID_VOLUME_MAX 300
/// Maximum acid volume that can be applied to a [/mob/living].
#define MOB_ACID_VOLUME_MAX 1000
/// Maximum acid volume that can be applied to a [/turf].
#define TURF_ACID_VOLUME_MAX 12000

// Acid decay rate constants.
/// The constant factor for the acid decay rate.
#define ACID_DECAY_BASE 1
/// The scaling factor for the acid decay rate.
#define ACID_DECAY_SCALING 1

/// The combined acid power and acid volume required to burn hands.
#define ACID_LEVEL_HANDBURN 20
