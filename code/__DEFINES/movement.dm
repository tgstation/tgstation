/// The minimum for glide_size to be clamped to.
#define MIN_GLIDE_SIZE 1
/// The maximum for glide_size to be clamped to.
/// This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

/// Compensating for time dialation
GLOBAL_VAR_INIT(glide_size_multiplier, 1.0)

///Broken down, here's what this does:
/// divides the world icon_size (32) by delay divided by ticklag to get the number of pixels something should be moving each tick.
/// The division result is given a min value of 1 to prevent obscenely slow glide sizes from being set
/// Then that's multiplied by the global glide size multiplier. 1.25 by default feels pretty close to spot on. This is just to try to get byond to behave.
/// The whole result is then clamped to within the range above.
/// Not very readable but it works
#define DELAY_TO_GLIDE_SIZE(delay) (clamp(((32 / max((delay) / world.tick_lag, 1)) * GLOB.glide_size_multiplier), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE))

///Similar to DELAY_TO_GLIDE_SIZE, except without the clamping, and it supports piping in an unrelated scalar
#define MOVEMENT_ADJUSTED_GLIDE_SIZE(delay, movement_disparity) (32 / ((delay) / world.tick_lag) * movement_disparity)

//Movement subsystem precedence. Who gets to run over who
// Lower numbers beat higher numbers
// Pretty simple for now, if you want to add loops that run in parrael it's gonna need some modification
#define MOVEMENT_SPACE_PRECEDENCE 2 //Very few things should override this
///Standard, go lower then this if you want to override, higher otherwise
#define MOVEMENT_DEFAULT_PRECEDENCE 10

//Movement datum flags
///If the object being moved is a cliented mob, our moves will be treated as steps, and they won't be able to cancel out of them
#define MOVELOOP_OVERRIDE_CLIENT_CONTROL (1<<0)
