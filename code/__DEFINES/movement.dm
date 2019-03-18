//The minimum for glide_size to be clamped to.
//If you want more classic style "delay" movement while still retaining the smoothness improvements at higher framerates, set this to 8
#define MIN_GLIDE_SIZE 0
//The maximum for glide_size to be clamped to.
//This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

#define DELAY_TO_GLIDE_SIZE(delay) (CLAMP((world.icon_size / max(CEILING(delay / world.tick_lag, 0.1), 1)), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE))
 