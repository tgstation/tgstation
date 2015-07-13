#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

/datum/subsystem
	//things you will want to define
	var/name				//name of the subsystem
	var/priority = 0		//priority affects order of initialization. Higher priorities are initialized first, lower priorities later. Can be decimal and negative values.
	var/wait = 20			//time to wait (in deciseconds) between each call to fire(). Must be a positive integer.

	//Dynamic Wait - A system for scaling a subsystem's fire rate based on lag
	//The algorithm is: (cost-dwait_buffer+AvgCostOfAllOtherSSPerSecond)*dwait_delta
	//defaults are pretty sane for most use cases.
	//you can change how quickly it starts scaling back with dwait_buffer,
	//and you can change how much it scales back with dwait_delta
	var/dynamic_wait = 0	//changes the wait based on the amount of time it took to process
	var/dwait_upper = 20	//longest wait can be under dynamic_wait
	var/dwait_lower = 5		//shortest wait can be under dynamic_wait
	var/dwait_delta = 7		//How much should processing time effect dwait. or basically: wait = cost*dwait_delta
	var/dwait_buffer = 1.5	//This number is subtracted from the processing time before calculating its new wait

	//things you will probably want to leave alone
	var/can_fire = 0		//prevent fire() calls
	var/last_fire = 0		//last world.time we called fire()
	var/next_fire = 0		//scheduled world.time for next fire()
	var/cost = 0			//average time to execute
	var/times_fired = 0		//number of times we have called fire()

//used to initialize the subsystem BEFORE the map has loaded
/datum/subsystem/New()

//previously, this would have been named 'process()' but that name is used everywhere for different things!
//fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
//fire(), and the procs it calls, SHOULD NOT HAVE ANY SLEEP OPERATIONS in them!
//YE BE WARNED!
/datum/subsystem/proc/fire()
	can_fire = 0

//used to initialize the subsystem AFTER the map has loaded
/datum/subsystem/proc/Initialize(start_timeofday, zlevel)
	var/time = (world.timeofday - start_timeofday) / 10
	var/msg = "Initialized [name] SubSystem within [time] seconds"
	if (zlevel)
		testing(msg)
		return
	world << "<span class='boldannounce'>[msg]</span>"
	world.log << msg

/datum/subsystem/proc/AfterInitialize()
	return

//hook for printing stats to the "MC" statuspanel for admins to see performance and related stats etc.
/datum/subsystem/proc/stat_entry(msg)
	var/dwait = ""
	if (dynamic_wait)
		dwait = "DWait:[wait]ds "

	stat(name, "[round(cost,0.001)]ds\t[dwait][msg]")

//could be used to postpone a costly subsystem for (default one) var/cycles, cycles
//for instance, during cpu intensive operations like explosions
/datum/subsystem/proc/postpone(var/cycles = 1)
	if(next_fire - world.time < wait)
		next_fire += (wait*cycles)

//usually called via datum/subsystem/New() when replacing a subsystem (i.e. due to a recurring crash)
//should attempt to salvage what it can from the old instance of subsystem
/datum/subsystem/proc/Recover()