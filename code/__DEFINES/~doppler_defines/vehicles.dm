// Defines for the vehicle component

/// For use in ride_check_flags. Prevents the piggyback slowdown, causes the riding offsets to be applied.
#define RIDING_TAUR (1<<10) // high, to avoid flag conflict with tg)

// Vehicle offset defines

/// Applied when the ridee is oversized. Applied to front offsets.
#define OVERSIZED_OFFSET 18
/// Applied when the ridee is oversized. Applied to side offsets.
#define OVERSIZED_SIDE_OFFSET 11
/// Applied when the ridee is normal sized. Applies to front offsets.
#define REGULAR_OFFSET 6
/// Applied when the ridee is normal sized. Applies to side offsets.
#define REGULAR_SIDE_OFFSET 4

/// Sent when a mob attempts to ride our saddle. Should return a bitfield containing riding flags, ex. RIDER_NEEDS_ARMS (mob/living/carbon)
#define COMSIG_HUMAN_SADDLE_RIDE_ATTEMPT "human_saddle_ride_attempt"

/// If true, the saddled mob can have someone clickdragged onto them to be ridden.
#define TRAIT_SADDLED "trait_saddled"
