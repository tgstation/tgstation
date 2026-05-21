/// Uses the left operator when compiling, uses the right operator when not compiling.
// Currently uses the CBT macro, but if http://www.byond.com/forum/post/2831057 is ever added,
// or if map tools ever agree on a standard, this should switch to use that.
#ifdef CBT
#define MAP_SWITCH(compile_time, map_time) ##compile_time
#define WHEN_MAP(map_time) // Not mapping, nothing here
#define WHEN_COMPILE(compile_time) ##compile_time
#else
#define MAP_SWITCH(compile_time, map_time) ##map_time
#define WHEN_MAP(map_time) ##map_time
#define WHEN_COMPILE(compile_time) // Not compiling, nothing here
#endif
