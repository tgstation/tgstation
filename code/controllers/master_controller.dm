//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)

//Update: all core-systems are now placed inside subsystem datums. This makes them highly configurable and easy to work with.

var/global/datum/controller/game_controller/master_controller = new()

/datum/controller/game_controller
	var/name = "Master"
	var/processing_interval = 1	// The minimum length of time between MC ticks (in deciseconds). The highest this can be without affecting schedules, is the GCD of all subsystem var/wait. Set to 0 to disable all processing.
	var/iteration = 0
	var/cost = 0
	var/SSCostPerSecond = 0
	var/last_thing_processed

	var/list/subsystems = list()

	var/obj/effect/statclick/statclick // clickable stat button

/datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		if(istype(master_controller))
			Recover()
			qdel(master_controller)
		else
			init_subtypes(/datum/subsystem, subsystems)

		master_controller = src
	calculateGCD()

/datum/controller/game_controller/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW


/*
calculate the longest number of ticks the MC can wait between each cycle without causing subsystems to not fire on schedule
*/
/datum/controller/game_controller/proc/calculateGCD()
	var/GCD
	//shortest fire rate is the lower of two ticks or 1ds
	var/minimumInterval = min(world.tick_lag*2,1)
	for(var/datum/subsystem/SS in subsystems)
		if(SS.wait)
			GCD = Gcd(round(SS.wait*10), GCD)
	GCD = round(GCD)
	if(GCD < minimumInterval*10)
		GCD = minimumInterval*10
	processing_interval = GCD/10

/datum/controller/game_controller/proc/setup(zlevel)
	if (zlevel && zlevel > 0 && zlevel <= world.maxz)
		for(var/datum/subsystem/S in subsystems)
			S.Initialize(world.timeofday, zlevel)
			sleep(-1)
		return
	world << "<span class='boldannounce'>Initializing Subsystems...</span>"


	//sort subsystems by priority, so they initialize in the correct order
	sortTim(subsystems, /proc/cmp_subsystem_priority)

	createRandomZlevel()	//gate system
	setup_map_transitions()
	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	//Eventually all this other setup stuff should be contained in subsystems and done in subsystem.Initialize()
	for(var/datum/subsystem/S in subsystems)
		S.Initialize(world.timeofday, zlevel)
		sleep(-1)

	crewmonitor.generateMiniMaps()
	populate_asset_cache()

	world << "<span class='boldannounce'>Initializations Complete!</span>"

	world.sleep_offline = 1
	world.fps = config.fps

	sleep(-1)

	process()

//used for smoothing out the cost values so they don't fluctuate wildly
#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))

/datum/controller/game_controller/process()
	if(!Failsafe)
		new /datum/controller/failsafe() // (re)Start the failsafe.
	spawn(0)
		var/timer = world.time
		for(var/datum/subsystem/SS in subsystems)
			timer += processing_interval
			SS.next_fire = timer

		var/start_time

		while(1)	//far more efficient than recursively calling ourself
			if(processing_interval > 0)
				++iteration
				var/startingtick = world.time
				start_time = world.timeofday
				var/SubSystemRan = 0
				for(var/datum/subsystem/SS in subsystems)
					if(SS.can_fire > 0)
						if(SS.next_fire <= world.time && SS.last_fire+(SS.wait*0.5) <= world.time)
							SubSystemRan = 1
							timer = world.timeofday
							last_thing_processed = SS.type
							SS.last_fire = world.time
							SS.fire()
							SS.cost = MC_AVERAGE(SS.cost, world.timeofday - timer)
							if (SS.dynamic_wait)
								var/oldwait = SS.wait
								var/GlobalCostDelta = (SSCostPerSecond-(SS.cost/(SS.wait/10)))-1
								var/NewWait = (SS.cost-SS.dwait_buffer+GlobalCostDelta)*SS.dwait_delta
								NewWait = NewWait*(world.cpu/100+1)
								NewWait = MC_AVERAGE(oldwait,NewWait)
								SS.wait = Clamp(NewWait,SS.dwait_lower,SS.dwait_upper)
								if (oldwait != SS.wait)
									calculateGCD()
							SS.next_fire += SS.wait
							++SS.times_fired
							//we caused byond to miss a tick, stop processing for a bit
							if (startingtick < world.time || start_time+1 < world.timeofday)
								break
							sleep(-1)

				cost = MC_AVERAGE(cost, world.timeofday - start_time)
				if(SubSystemRan)
					calculateSScost()
				var/extrasleep = 0
				if(startingtick < world.time || start_time+1 < world.timeofday)
					//we caused byond to miss a tick, sleep a bit extra
					extrasleep += world.tick_lag*2
				if(world.cpu > 80)
					extrasleep += extrasleep+processing_interval
				sleep(processing_interval+extrasleep)
			else
				sleep(50)

/datum/controller/game_controller/proc/calculateSScost()
	var/newcost = 0
	for(var/datum/subsystem/SS in subsystems)
		if (!SS.can_fire)
			continue
		newcost += SS.cost/(SS.wait/10)
	SSCostPerSecond = MC_AVERAGE(SSCostPerSecond,newcost)

#undef MC_AVERAGE

/datum/controller/game_controller/proc/roundHasStarted()
	for(var/datum/subsystem/SS in subsystems)
		SS.can_fire = 1
		SS.next_fire = world.time + rand(0,SS.wait)

/datum/controller/game_controller/proc/Recover()
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg

	subsystems = master_controller.subsystems

/datum/controller/game_controller/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	stat("Master Controller:", statclick.update("[round(master_controller.cost, 0.001)]ds (Interval: [master_controller.processing_interval] | Iteration:[master_controller.iteration])"))
