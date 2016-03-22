#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

/datum/subsystem
	// Metadata; you should define these.
	var/name				//name of the subsystem
	var/priority = 0		//priority affects order of initialization. Higher priorities are initialized first, lower priorities later. Can be decimal and negative values.
	var/wait = 20			//time to wait (in deciseconds) between each call to fire(). Must be a positive integer.
	var/display = 100		//display affects order the subsystem is displayed in the MC tab

	// Dynamic Wait
	// A system for scaling a subsystem's fire rate based on lag.
	// The algorithm is: (cost - dwait_buffer + subsystem_cost) * dwait_delta
	// Defaults are pretty sane for most use cases.
	// You can change how quickly it starts scaling back with dwait_buffer,
	// and you can change how much it scales back with dwait_delta.

	var/dynamic_wait = 0	//changes the wait based on the amount of time it took to process
	var/dwait_upper = 20	//longest wait can be under dynamic_wait
	var/dwait_lower = 5		//shortest wait can be under dynamic_wait
	var/dwait_delta = 7		//How much should processing time effect dwait. or basically: wait = cost*dwait_delta
	var/dwait_buffer = 0.7	//This number is subtracted from the processing time before calculating its new wait

	// Bookkeeping variables; probably shouldn't mess with these.
	var/can_fire = 0		//prevent fire() calls
	var/last_fire = 0		//last world.time we called fire()
	var/next_fire = 0		//scheduled world.time for next fire()
	var/cost = 0			//average time to execute
#if DM_VERSION >= 510
	var/tick_usage = 0		//average tick usage
#endif
	var/paused =0			//was this subsystem paused mid fire.
	var/times_fired = 0		//number of times we have called fire()

	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

// Used to initialize the subsystem BEFORE the map has loaded
/datum/subsystem/New()

//previously, this would have been named 'process()' but that name is used everywhere for different things!
//fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
//fire(), and the procs it calls, SHOULD NOT HAVE ANY SLEEP OPERATIONS in them!
//YE BE WARNED!
/datum/subsystem/proc/fire(resumed = 0)
	set waitfor = 0 //this should not be depended upon, this is just to solve issues with sleeps messing up tick tracking
	can_fire = 0

#if DM_VERSION >= 510
/datum/subsystem/proc/pause()
	. = 1
	if (!dynamic_wait)
		Master.priority_queue += src
	paused = 1
#endif

//used to initialize the subsystem AFTER the map has loaded
/datum/subsystem/proc/Initialize(start_timeofday, zlevel)
	var/time = (world.timeofday - start_timeofday) / 10
	var/msg = "Initialized [name] subsystem within [time] seconds!"
	if(zlevel) // If only initialized for one Z-level.
		testing(msg)
		return time
	world << "<span class='boldannounce'>[msg]</span>"
	return time

//hook for printing stats to the "MC" statuspanel for admins to see performance and related stats etc.
/datum/subsystem/proc/stat_entry(msg)
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	var/dwait = ""
	if(dynamic_wait)
		dwait = "DWait:[round(wait,0.1)]ds "

	if(can_fire)
#if DM_VERSION >= 510
		msg = "[round(cost,0.01)]ds|[round(tick_usage,1)]%\t[dwait][msg]"
#else
		msg = "[round(cost,0.01)]ds\t[dwait][msg]"
#endif
	else
		msg = "OFFLINE\t[msg]"

	stat(name, statclick.update(msg))

//could be used to postpone a costly subsystem for (default one) var/cycles, cycles
//for instance, during cpu intensive operations like explosions
/datum/subsystem/proc/postpone(cycles = 1)
	if(next_fire - world.time < wait)
		next_fire += (wait*cycles)

//usually called via datum/subsystem/New() when replacing a subsystem (i.e. due to a recurring crash)
//should attempt to salvage what it can from the old instance of subsystem
/datum/subsystem/proc/Recover()

//this is so the subsystem doesn't rapid fire to make up missed ticks causing more lag
/datum/subsystem/on_varedit(edited_var)
	if (edited_var == "can_fire" && can_fire)
		next_fire = world.time + wait

