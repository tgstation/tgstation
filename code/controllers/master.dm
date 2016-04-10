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

	// are we processing (higher values increase the processing delay)
	var/processing = 1
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
#if DM_VERSION >= 510
	var/list/priority_queue = list() //any time we pause or skip a ss for tick reasons, we run it first next tick
#endif

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
			CHECK_TICK
		return
	world << "<span class='boldannounce'>Initializing subsystems...</span>"

	preloadTemplates()
	// Pick a random away mission.
	createRandomZlevel()
	// Generate mining.

	var/mining_type = MINETYPE
	if(mining_type == "lavaland")
		seedRuins(5, 5, /area/lavaland/surface/outdoors, lava_ruins_templates)
		spawn_rivers()
	else
		make_mining_asteroid_secrets()

	// Set up Z-level transistions.
	setup_map_transitions()

	// Sort subsystems by priority, so they initialize in the correct order.
	sortTim(subsystems, /proc/cmp_subsystem_priority)

	// Initialize subsystems.
	for(var/datum/subsystem/SS in subsystems)
		SS.Initialize(world.timeofday, zlevel)
		CHECK_TICK

	world << "<span class='boldannounce'>Initializations complete!</span>"

	// Sort subsystems by display setting for easy access.
	sortTim(subsystems, /proc/cmp_subsystem_display)

	// Set world options.
	world.sleep_offline = 1
	world.fps = config.fps

	sleep(1)

	// Loop.
	Master.process()

// Notify the MC that the round has started.
/datum/controller/master/proc/RoundStart()
	var/timer = world.time
	for(var/datum/subsystem/SS in subsystems)
		timer += world.tick_lag
		SS.can_fire = 1
		SS.next_fire = timer + rand(0, SS.wait) // Stagger subsystems.

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
			if (SS.can_fire)
				timer += world.tick_lag
				SS.next_fire = timer

		var/list/subsystemstorun = subsystems.Copy()
		var/start_time
		while(1) // More efficient than recursion.
			if(processing) //are we processing
				++iteration
				start_time = world.timeofday
				if (!subsystemstorun.len)
					subsystemstorun = subsystems.Copy()
				var/priorityrunning = 0 //so we know if there are priority queue items
#if DM_VERSION >= 510
				//this is a queue for any SS skipped or paused for tick reasons, to be ran first next tick
				if (priority_queue.len)
					priorityrunning = priority_queue.len
					subsystemstorun = priority_queue | subsystemstorun
#endif
				var/ran_subsystems = 0
				while(subsystemstorun.len)
					var/datum/subsystem/SS = subsystemstorun[1]
					subsystemstorun.Cut(1, 2)
#if DM_VERSION >= 510
					if (world.tick_usage > TICK_LIMIT_MC)
#else
					if(world.cpu >= 100)
#endif
						break
#if DM_VERSION >= 510
					if(priorityrunning)
						if(!priority_queue.len || !(SS in priority_queue))
							priorityrunning = 0 //end of priority queue items
						else
							priority_queue -= SS
#endif
					if(SS.can_fire > 0)
						if(priorityrunning || ((SS.next_fire <= world.time) && (SS.last_fire + (SS.wait * 0.75) <= world.time)))
#if DM_VERSION >= 510
							if(!priorityrunning && (world.tick_usage + SS.tick_usage > TICK_LIMIT_TO_RUN) && (SS.last_fire + (SS.wait*1.25) > world.time))
								if(!SS.dynamic_wait)
									priority_queue += SS
								continue
#endif
							//we can't reset SS.paused after we fire, incase it pauses again, so we cache it and
							//	send it to SS.fire()
							var/paused = SS.paused
							SS.paused = 0
							ran_subsystems = 1
							timer = world.timeofday
							last_type_processed = SS.type
							SS.last_fire = world.time
#if DM_VERSION >= 510
							var/tick_usage = world.tick_usage
#endif
							SS.fire(paused) // Fire the subsystem
#if DM_VERSION >= 510
							if(priorityrunning)
								priorityrunning--
							var/newusage = max(world.tick_usage - tick_usage, 0)
							if(newusage < SS.tick_usage)
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
								if(!paused)
									SS.next_fire += SS.wait
							if(!SS.paused)
								SS.times_fired++
#if DM_VERSION < 510
							sleep(0)
#endif

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
					extrasleep += (extrasleep + world.tick_lag) * ((world.cpu-50)/10)
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
				sleep(world.tick_lag*processing+extrasleep)

			else
				sleep(50)

#undef MC_AVERAGE_FAST
#undef MC_AVERAGE
#undef MC_AVERAGE_SLOW

/datum/controller/master/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	stat("Master Controller:", statclick.update("[round(Master.cost, 0.01)]ds (Iteration:[Master.iteration])"))

