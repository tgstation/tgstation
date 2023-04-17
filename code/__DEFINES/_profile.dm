// What we're doing here is hooking our profiling tools in at the very START of init, before anything else. See code/game/world.dm for more info
// Basically globals and statics gain their values first (based off dme order), and this stuff happens right at the start
// We don't actually care about storing the output here, this is just an easy way to ensure the profilers hit at the start

#ifdef USE_BYOND_TRACY
#warn USE_BYOND_TRACY is enabled
GLOBAL_REAL_VAR(tracy_profiler) = world.init_byond_tracy()
#endif

GLOBAL_REAL_VAR(world_init_profiler) = world.Profile(PROFILE_RESTART)
