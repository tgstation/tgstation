/// Uses the left operator when compiling, uses the right operator when not compiling.
// Currently uses the CBT macro, but if http://www.byond.com/forum/post/2831057 is ever added,
// or if map tools ever agree on a standard, this should switch to use that.
#ifdef CBT
#define MAP_SWITCH(compile_time, map_time) ##compile_time
#else
#define MAP_SWITCH(compile_time, map_time) ##map_time
#endif
