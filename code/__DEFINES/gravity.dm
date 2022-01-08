///range of values where you suffer from negative gravity
#define NEGATIVE_GRAVITY_RANGE -INFINITY to NEGATIVE_GRAVITY
///range of values where you have no gravity
#define WEIGHTLESS_RANGE NEGATIVE_GRAVITY + 0.01 to 0
///range of values where you have normal gravity
#define STANDRARD_GRAVITY_RANGE 0.01 to STANDARD_GRAVITY
///range of values where you have heavy gravity
#define HIGH_GRAVITY_RANGE STANDARD_GRAVITY + 0.01 to GRAVITY_DAMAGE_THRESHOLD - 0.01
///range of values where you suffer from crushing gravity
#define CRUSHING_GRAVITY_RANGE GRAVITY_DAMAGE_THRESHOLD to INFINITY

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
