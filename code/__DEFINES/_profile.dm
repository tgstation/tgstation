#if DM_BUILD >= 1506
// We don't actually care about storing the output here, this is just an easy way to ensure the profile runs first.
GLOBAL_REAL_VAR(world_init_profiler) = world.Profile(PROFILE_START)
#endif
