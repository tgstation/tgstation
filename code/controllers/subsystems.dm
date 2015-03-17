#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

/datum/subsystem
	//things you will want to define
	var/name			//name of the subsystem
	var/priority = 0	//priority affects order of initialization. Higher priorities are initialized first, lower priorities later. Can be decimal and negative values.
	var/wait = 20		//time to wait (in deciseconds) between each call to fire(). Must be a positive integer.

	//things you will probably want to leave alone
	var/can_fire = 0	//prevent fire() calls
	var/last_fire = 0	//last world.time we called fire()
	var/next_fire = 0	//scheduled world.time for next fire()
	var/cpu = 0			//cpu-usage stats (somewhat vague)
	var/cost = 0		//average time to execute
	var/times_fired = 0	//number of times we have called fire()

//used to initialize the subsystem BEFORE the map has loaded
/datum/subsystem/New()

//previously, this would have been named 'process()' but that name is used everywhere for different things!
//fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
//fire(), and the procs it calls, SHOULD NOT HAVE ANY SLEEP OPERATIONS in them!
//YE BE WARNED!
/datum/subsystem/proc/fire()
	can_fire = 0

//used to initialize the subsystem AFTER the map has loaded
/datum/subsystem/proc/Initialize(start_timeofday)
	var/time = (world.timeofday - start_timeofday) / 10
	var/msg = "Initialized [name] SubSystem within [time] seconds"
	world << "<span class='boldannounce'>[msg]</span>"
	world.log << msg

//hook for printing stats to the "MC" statuspanel for admins to see performance and related stats etc.
/datum/subsystem/proc/stat_entry()
	stat(name, "[round(cost,0.001)]ds\t(CPU:[round(cpu,1)]%)")

//could be used to postpone a costly subsystem for one cycle
//for instance, during cpu intensive operations like explosions
/datum/subsystem/proc/postpone()
	if(next_fire - world.time < wait)
		next_fire += wait

//usually called via datum/subsystem/New() when replacing a subsystem (i.e. due to a recurring crash)
//should attempt to salvage what it can from the old instance of subsystem
/datum/subsystem/proc/Recover()