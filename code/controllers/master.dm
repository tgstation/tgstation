 /**
  * CarnMC
  *
  * Simplified MC; designed to fail fast and respawn.
  * This ensures Master.process() never doubles up.
  * It will kill itself and any sleeping procs if needed.
  *
  * All core systems are subsystems.
  * They are process()'d by this Master Controller.
 **/
var/global/datum/controller/master/Master = new()

/datum/controller/master
	name = "Master"

	// The minimum length of time between MC ticks (in deciseconds).
	// The highest this can be without affecting schedules is the GCD of all subsystem waits.
	// Set to 0 to disable all processing.
	var/processing_interval = 1
	// The iteration of the MC.
	var/iteration = 0
	// The cost (in deciseconds) of the MC loop.
	var/cost = 0

	// A list of subsystems to process().
	var/list/subsystems = list()
	// The cost of running the subsystems (in deciseconds).
	var/subsystem_cost = 0
	// The type of the last subsystem to be process()'d.
	var/last_type_processed

/datum/controller/master/New()
	// Highlander-style: there can only be one! Kill off the old and replace it with the new.
	if(Master != src)
		if(istype(Master))
			Recover()
			qdel(Master)
		else
			init_subtypes(/datum/subsystem, subsystems)
		Master = src
	processing_interval = calculate_gcd()

/datum/controller/master/Destroy()
	..()
	// Tell qdel() to Del() this object.
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/master/proc/Recover()
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in Master.vars)
		switch(varname)
			if("name", "tag", "bestF", "type", "parent_type", "vars", "statclick") // Built-in junk.
				continue
			else
				var/varval = Master.vars[varname]
				if(istype(varval, /datum)) // Check if it has a type var.
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg

	subsystems = Master.subsystems

/datum/controller/master/proc/Setup(zlevel)
	// Per-Z-level subsystems.
	if (zlevel && zlevel > 0 && zlevel <= world.maxz)
		for(var/datum/subsystem/SS in subsystems)
			SS.Initialize(world.timeofday, zlevel)
			sleep(-1)
		return
	world << "<span class='boldannounce'>Initializing subsystems...</span>"

	// Pick a random away mission.
	createRandomZlevel()
	// Generate asteroid.
	make_mining_asteroid_secrets()
	// Set up Z-level transistions.
	setup_map_transitions()

	// Sort subsystems by priority, so they initialize in the correct order.
	sortTim(subsystems, /proc/cmp_subsystem_priority)

	// Initialize subsystems.
	for(var/datum/subsystem/SS in subsystems)
		SS.Initialize(world.timeofday, zlevel)
		sleep(-1)

	world << "<span class='boldannounce'>Initializations complete!</span>"

	// Sort subsystems by display setting for easy access.
	sortTim(subsystems, /proc/cmp_subsystem_display)

	// Set world options.
	world.sleep_offline = 1
	world.fps = config.fps

	sleep(-1)

	// Loop.
	Master.process()

// Notify the MC that the round has started.
/datum/controller/master/proc/RoundStart()
	for(var/datum/subsystem/SS in subsystems)
		SS.can_fire = 1
		SS.next_fire = world.time + rand(0, SS.wait) // Stagger subsystems.

// Used to smooth out costs to try and avoid oscillation.
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
/datum/controller/master/process()
	if(!Failsafe)
		new/datum/controller/failsafe() // (re)Start the failsafe.
	spawn(0)
		// Schedule the first run of the Subsystems.
		var/timer = world.time
		for(var/datum/subsystem/SS in subsystems)
			timer += processing_interval
			SS.next_fire = timer

		var/start_time
		while(1) // More efficient than recursion, 1 to avoid an infinite loop.
			if(processing_interval > 0)
				++iteration
				var/startingtick = world.time // Store when we started this iteration.
				start_time = world.timeofday

				var/ran_subsystems = 0
				for(var/datum/subsystem/SS in subsystems)
					if(SS.can_fire > 0)
						if(SS.next_fire <= world.time && SS.last_fire + (SS.wait * 0.5) <= world.time) // Check if it's time.
							ran_subsystems = 1
							timer = world.timeofday
							last_type_processed = SS.type
							SS.last_fire = world.time
							SS.fire() // Fire the subsystem and record the cost.
							SS.cost = MC_AVERAGE(SS.cost, world.timeofday - timer)
							if(SS.dynamic_wait) // Adjust wait depending on lag.
								var/oldwait = SS.wait
								var/global_delta = (subsystem_cost - (SS.cost / (SS.wait / 10))) - 1
								var/newwait = (SS.cost - SS.dwait_buffer + global_delta) * SS.dwait_delta
								newwait = newwait * (world.cpu / 100 + 1)
								newwait = MC_AVERAGE(oldwait, newwait)
								SS.wait = Clamp(newwait, SS.dwait_lower, SS.dwait_upper)
								if(oldwait != SS.wait)
									processing_interval = calculate_gcd()
							SS.next_fire += SS.wait
							++SS.times_fired
							// If we caused BYOND to miss a tick, stop processing for a bit...
							if(startingtick < world.time || start_time + 1 < world.timeofday)
								break
							sleep(0)

				cost = MC_AVERAGE(cost, world.timeofday - start_time)
				if(ran_subsystems)
					var/oldcost = subsystem_cost
					var/newcost = 0
					for(var/datum/subsystem/SS in subsystems)
						if (!SS.can_fire)
							continue
						newcost += SS.cost / (SS.wait / 10)
						subsystem_cost = MC_AVERAGE(oldcost, newcost)

				var/extrasleep = 0
				// If we caused BYOND to miss a tick, sleep a bit extra...
				if(startingtick < world.time || start_time + 1 < world.timeofday)
					extrasleep += world.tick_lag * 2
				// If we are loading the server too much, sleep a bit extra...
				if(world.cpu > 80)
					extrasleep += extrasleep + processing_interval
				sleep(processing_interval + extrasleep)
			else
				sleep(50)
#undef MC_AVERAGE

// Determine the GCD of subsystem waits: the longest the MC can wait while still staying on schedule.
/datum/controller/master/proc/calculate_gcd()
	var/GCD
	// The shortest possible fire rate is the lowest of two ticks or 1 decisecond.
	var/minimumInterval = min(world.tick_lag * 2, 1)

	// Loop over each subsystem and determine the GCD based on its wait value.
	for(var/datum/subsystem/SS in subsystems)
		if(SS.wait)
			GCD = Gcd(round(SS.wait * 10), GCD)
	GCD = round(GCD)
	// If the GCD is less than the minimum, just use the minimum.
	if(GCD < minimumInterval * 10)
		GCD = minimumInterval * 10
	// Return GCD.
	return GCD / 10

/datum/controller/master/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	stat("Master Controller:", statclick.update("[round(Master.cost, 0.001)]ds (Interval: [Master.processing_interval] | Iteration:[Master.iteration])"))

