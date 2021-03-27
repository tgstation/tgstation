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

/// defines for [/atom/movable/var/currently_z_moving]. Higher numbers mean higher priority.
#define CURRENTLY_Z_MOVING_GENERIC 1
/// This one is for falling down open space from stuff such as deleted tile, pit grate...
#define CURRENTLY_Z_FALLING 2
/// This one is for falling down open space from movement.
#define CURRENTLY_Z_FALLING_FROM_MOVE 3
/// This one is for going upstairs.
#define CURRENTLY_Z_ASCENDING 4

/// possible bitflag return values of [atom/proc/intercept_zImpact] calls
#define FALL_INTERCEPTED (1<<0) //Stops the movable from falling further and crashing on the ground
#define FALL_NO_MESSAGE (1<<1) //Suppresses the "[A] falls through [old_turf]" messages where it'd make little sense at all, like going downstairs.
#define FALL_STOP_INTERCEPTING (1<<2) //Used in situations where halting the whole "intercept" loop would be better, like supermatter dusting (and thus deleting) the atom.

/// Runs check_pulling() by the end of [/atom/movable/proc/zMove] for every movable that's pulling something. Should be kept enabled unless you know what you are doing.
#define ZMOVE_CHECK_PULLING (1<<0)
/// Checks if pulledby is nearby. if not, stop being pulled.
#define ZMOVE_CHECK_PULLEDBY (1<<1)
/// flags for different checks done in [/atom/movable/proc/can_z_move]
#define ZMOVE_FALL_CHECKS (1<<2)
#define ZMOVE_CAN_FLY_CHECKS (1<<3)
#define ZMOVE_INCAPACITATED_CHECKS (1<<4)
/// Doesn't call zPassIn() and zPassOut()
#define ZMOVE_IGNORE_OBSTACLES (1<<5)
/// Gives players chat feedbacks if they're unable to move through z levels.
#define ZMOVE_FEEDBACK (1<<6)
/// Whether we check the movable (if it exists) the living mob is buckled on instead or not.
#define ZMOVE_ALLOW_BUCKLED (1<<7)

#define ZMOVE_CHECK_PULLS (ZMOVE_CHECK_PULLING|ZMOVE_CHECK_PULLEDBY)

/// flags used in "Move Upwards" and "Move Downwards" verbs.
#define ZMOVE_FLIGHT_FLAGS (ZMOVE_CAN_FLY_CHECKS|ZMOVE_INCAPACITATED_CHECKS|ZMOVE_CHECK_PULLS|ZMOVE_ALLOW_BUCKLED)
/// Used for falling down open space.
#define ZMOVE_FALL_FLAGS (ZMOVE_FALL_CHECKS|ZMOVE_ALLOW_BUCKLED)

/// Defines used in [/atom/movable/proc/z_move_conga_step] && [/atom/movable/proc/z_move_conga_callback]
#define ZMOVE_CONGA_METHOD_MOVE 1
