/*
 * Cooldown system based on an datum-level associative lazylist using timers.
 * If you are running hot procs that require high performance, checking world.time directly through a variable will always be faster.
 * If you are not, then this should be fine to use, it's not very expensive.
 * If you want a stoppable timer either make new macros or use a different system. Do not make every timer stoppable, that increases performance cost.
*/

//INDEXES
#define COOLDOWN_BOX_DEPLOYMENT	"box deployment"

//MACROS
#define COOLDOWN_START(cd_source, cd_index, cd_time) LAZYSET(cd_source.cooldowns, cd_index, addtimer(CALLBACK(GLOBAL_PROC, /proc/end_cooldown, cd_source, cd_index), cd_time))

#define COOLDOWN_CHECK(cd_source, cd_index) LAZYACCESS(cd_source.cooldowns, cd_index)

#define COOLDOWN_END(cd_source, cd_index) LAZYREMOVE(cd_source.cooldowns, cd_index)
