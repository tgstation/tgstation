//singularity defines
/// Singularity is stage 1 (1x1)
#define STAGE_ONE 1
/// Singularity is stage 2 (3x3)
#define STAGE_TWO 3
/// Singularity is stage 3 (5x5)
#define STAGE_THREE 5
/// Singularity is stage 4 (7x7)
#define STAGE_FOUR 7
/// Singularity is stage 5 (9x9)
#define STAGE_FIVE 9
/// Singularity is stage 6 (11x11)
#define STAGE_SIX 11 //From supermatter shard

/**
 * The point where gravity is negative enough to pull you upwards.
 * That means walking checks for a ceiling instead of a floor, and you can fall "upwards"
 *
 * This should only be possible on multi-z maps because it works like shit on maps that aren't.
 */
#define NEGATIVE_GRAVITY -1

#define STANDARD_GRAVITY 1 //Anything above this is high gravity, anything below no grav until negative gravity
/// The gravity strength threshold for high gravity damage.
#define GRAVITY_DAMAGE_THRESHOLD 3
/// The scaling factor for high gravity damage.
#define GRAVITY_DAMAGE_SCALING 0.5
/// The maximum [BRUTE] damage a mob can take from high gravity per second.
#define GRAVITY_DAMAGE_MAXIMUM 1.5
