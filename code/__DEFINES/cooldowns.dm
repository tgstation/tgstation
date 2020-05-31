/*
 * Cooldown system based on an datum-level associative lazylist using timers.
 * If you are running hot procs that require high performance, checking world.time directly through a variable will always be faster.
 * If you are not, then this should be fine to use, it's not very expensive.
 * If you want a stoppable timer either make new macros or use a different system. Do not make every timer stoppable, that increases performance cost.
*/

//INDEXES
#define COOLDOWN_BORG_SELF_REPAIR	"borg_self_repair"


//TIMER COOLDOWN MACROS

#define TIMER_COOLDOWN_START(cd_source, cd_index, cd_time) LAZYSET(cd_source.cooldowns, cd_index, addtimer(CALLBACK(GLOBAL_PROC, /proc/end_cooldown, cd_source, cd_index), cd_time))

#define TIMER_COOLDOWN_CHECK(cd_source, cd_index) LAZYACCESS(cd_source.cooldowns, cd_index)

#define TIMER_COOLDOWN_END(cd_source, cd_index) LAZYREMOVE(cd_source.cooldowns, cd_index)

/*
 * Stoppable timer cooldowns.
 * Use indexes the same as the regular tiemr cooldowns.
 * They make use of the TIMER_COOLDOWN_CHECK() and TIMER_COOLDOWN_END() macros the same, just not the TIMER_COOLDOWN_START() one.
 * A bit more expensive than the regular timers, but can be reset before they end and the time left can be checked.
*/

#define S_TIMER_COOLDOWN_START(cd_source, cd_index, cd_time) LAZYSET(cd_source.cooldowns, cd_index, addtimer(CALLBACK(GLOBAL_PROC, /proc/end_cooldown, cd_source, cd_index), cd_time, TIMER_STOPPABLE))

#define S_TIMER_COOLDOWN_RESET(cd_source, cd_index) LAZYREMOVE(cd_source.cooldowns, cd_index)

#define S_TIMER_COOLDOWN_TIMELEFT(cd_source, cd_index) (timeleft(TIMER_COOLDOWN_CHECK(cd_source, cd_index)))


/*
 * Cooldown system based on storing world.time on a variable, plus the cooldown time.
 * Better performance over timer cooldowns, lower control. Same functionality.
*/

#define COOLDOWN_DECLARE(cd_index) var/##cd_index = 0

#define COOLDOWN_START(cd_source, cd_index, cd_time) (cd_source.cd_index = world.time + cd_time)

#define COOLDOWN_CHECK(cd_source, cd_index) (cd_source.cd_index < world.time)

#define COOLDOWN_RESET(cd_source, cd_index) cd_source.cd_index = 0

#define COOLDOWN_TIMELEFT(cd_source, cd_index) ((cd_source.cd_index - world.time) < 0 ? 0 : cd_source.cd_index - world.time)
