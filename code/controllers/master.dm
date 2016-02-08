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
#if DM_VERSION < 510
	// The old fps when we slow it down to prevent lag.
	var/old_fps
#endif
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
	if(zlevel && zlevel > 0 && zlevel <= world.maxz)
		for(var/datum/subsystem/SS in subsystems)
			SS.Initialize(world.timeofday, zlevel)
			sleep(-1)
		return
	world << "<span class='boldannounce'>Initializing subsystems...</span>"

	preloadTemplates()
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
#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))
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
#if DM_VERSION >= 510
					if (world.tick_usage > 80)
#else
					if(world.cpu >= 100)
#endif
						break

					if(SS.can_fire > 0)
						if(SS.next_fire <= world.time && SS.last_fire + (SS.wait * 0.75) <= world.time) // Check if it's time.
#if DM_VERSION >= 510
							if (world.tick_usage + SS.tick_usage > 80 && SS.last_fire + (SS.wait*1.25) > world.time)
								continue
#endif
							ran_subsystems = 1
							timer = world.timeofday
							last_type_processed = SS.type
							SS.last_fire = world.time
#if DM_VERSION >= 510
							var/tick_usage = world.tick_usage
#endif
							SS.fire() // Fire the subsystem and record the cost.
#if DM_VERSION >= 510
							var/newusage = max(world.tick_usage - tick_usage, 0)
							if (newusage < SS.tick_usage)
								SS.tick_usage = MC_AVERAGE_SLOW(SS.tick_usage,world.tick_usage - tick_usage)
							else
								SS.tick_usage = MC_AVERAGE_FAST(SS.tick_usage,world.tick_usage - tick_usage)
#endif
							SS.cost = max(MC_AVERAGE(SS.cost, world.timeofday - timer), 0)
							if(SS.dynamic_wait) // Adjust wait depending on lag.
								var/oldwait = SS.wait
								var/global_delta = (subsystem_cost - (SS.cost / (SS.wait / 10))) - 1
								var/newwait = (SS.cost - SS.dwait_buffer + global_delta) * SS.dwait_delta
								newwait = newwait * (world.cpu / 100 + 1)
								//smooth out wait changes, but only if going down
								if(newwait < oldwait)
									newwait = MC_AVERAGE(oldwait, newwait)
								SS.wait = Clamp(newwait, SS.dwait_lower, SS.dwait_upper)
								SS.next_fire = world.time + SS.wait
							else
								SS.next_fire += SS.wait
							++SS.times_fired
							// If we caused BYOND to miss a tick, stop processing for a bit...
							if(startingtick < world.time || start_time + 1 < world.timeofday)
								break
							sleep(0)

				cost = max(MC_AVERAGE(cost, world.timeofday - start_time), 0)
				if(ran_subsystems)
					var/oldcost = subsystem_cost
					var/newcost = 0
					for(var/datum/subsystem/SS in subsystems)
						if (!SS.can_fire)
							continue
						newcost += SS.cost / (SS.wait / 10)
						subsystem_cost = MC_AVERAGE(oldcost, newcost)

				var/extrasleep = 0
				// If we are loading the server too much, sleep a bit extra...
				if(world.cpu >= 75)
					extrasleep += (extrasleep + processing_interval) * ((world.cpu-50)/10)
#if DM_VERSION < 510
				if(world.cpu >= 100)
					if(!old_fps)
						old_fps = world.fps
						//byond bug, if we go over 120 fps and world.fps is higher then 10, the bad things that happen are made worst.
						world.fps = 10
				else if(old_fps && world.cpu < 50)
					world.fps = old_fps
					old_fps = null
#endif
				sleep(processing_interval + extrasleep)

			else
				sleep(50)
#undef MC_AVERAGE

/datum/controller/master/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	stat("Master Controller:", statclick.update("[round(Master.cost, 0.01)]ds (Interval: [Master.processing_interval] | Iteration:[Master.iteration])"))

