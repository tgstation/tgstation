// Process status defines
#define PROCESS_STATUS_IDLE 1
#define PROCESS_STATUS_QUEUED 2
#define PROCESS_STATUS_RUNNING 3
#define PROCESS_STATUS_MAYBE_HUNG 4
#define PROCESS_STATUS_PROBABLY_HUNG 5
#define PROCESS_STATUS_HUNG 6

// Process time thresholds
#define PROCESS_DEFAULT_HANG_WARNING_TIME 	900 // 90 seconds
#define PROCESS_DEFAULT_HANG_ALERT_TIME 	1800 // 180 seconds
#define PROCESS_DEFAULT_HANG_RESTART_TIME 	2400 // 240 seconds
#define PROCESS_DEFAULT_SCHEDULE_INTERVAL 	50  // 50 ticks
#define PROCESS_DEFAULT_TICK_ALLOWANCE		25	// 25% of one tick


//#define UPDATE_QUEUE_DEBUG
// If btime.dll is available, do this shit
#define PRECISE_TIMER_AVAILABLE

#ifdef PRECISE_TIMER_AVAILABLE
var/global/__btime__lastTimeOfHour = 0
var/global/__btime__callCount = 0
var/global/__btime__lastTick = 0
#define TimeOfHour __btime__timeofhour()
#define __extern__timeofhour text2num(call("./btime.[world.system_type==MS_WINDOWS?"dll":"so"]", "gettime")())
proc/__btime__timeofhour()
	if (!(__btime__callCount++ % 50))
		if (world.time > __btime__lastTick)
			__btime__callCount = 0
			__btime__lastTick = world.time
		global.__btime__lastTimeOfHour = __extern__timeofhour
	return global.__btime__lastTimeOfHour
#else
#define TimeOfHour world.timeofday % 36000
#endif
