//The minimum for glide_size to be clamped to.
//Clamped to 5 because byond's glide size scaling is actually just completely broken and "step"
//movement is better than dealing with the awful camera juddering
#define MIN_GLIDE_SIZE 5
//The maximum for glide_size to be clamped to.
//This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

//This is a global so it can be changed in game, if you want to make this a bit faster you can make it a constant/define directly in the code
GLOBAL_VAR_INIT(glide_size_multiplier, 1.25)

///Broken down, here's what this does:
/// divides the world icon_size (32) by delay divided by ticklag to get the number of pixels something should be moving each tick.
/// The division result is given a min value of 1 to prevent obscenely slow glide sizes from being set
/// Then that's multiplied by the global glide size multiplier. 1.25 by default feels pretty close to spot on. This is just to try to get byond to behave.
/// The whole result is then clamped to within the range above.
/// Not very readable but it works
#define DELAY_TO_GLIDE_SIZE(delay) (CLAMP(((32 / max(delay / world.tick_lag, 1)) * GLOB.glide_size_multiplier), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE))
