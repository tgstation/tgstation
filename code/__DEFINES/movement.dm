#define DELAY_TO_GLIDE_SIZE(delay) (world.icon_size / max(CEILING(delay / world.tick_lag, 0.1), 1))
 