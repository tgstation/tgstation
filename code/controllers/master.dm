 /**
  * StonedMC
  *
  * Designed to properly split up a given tick among subsystems
  * Note: if you read parts of this code and think "why is it doing it that way"
  * Odds are, there is a reason
  *
 **/
var/datum/controller/master/Master = new()
var/MC_restart_clear = 0
var/MC_restart_timeout = 0
var/MC_restart_count = 0


//current tick limit, assigned by the queue controller before running a subsystem.
//used by check_tick as well so that the procs subsystems call can obey that SS's tick limits
var/CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING

/datum/controller/master
	name = "Master"

	// Are we processing (higher values increase the processing delay by n ticks)
	var/processing = 1
	// How many times have we ran
	var/iteration = 0

	// world.time of last fire, for tracking lag outside of the mc
	var/last_run

	// List of subsystems to process().
	var/list/subsystems

	// Vars for keeping track of tick drift.
	var/init_timeofday
	var/init_time
	var/tickdrift = 0

	var/sleep_delta

	var/make_runtime = 0

	// Has round started? (So we know what subsystems to run)
	var/round_started = 0

	// The type of the last subsystem to be process()'d.
	var/last_type_processed

	var/datum/subsystem/queue_head //Start of queue linked list
	var/datum/subsystem/queue_tail //End of queue linked list (used for appending to the list)
	var/queue_priority_count = 0 //Running total so that we don't have to loop thru the queue each run to split up the tick
	var/queue_priority_count_bg = 0 //Same, but for background subsystems

/datum/controller/master/New()
	// Highlander-style: there can only be one! Kill off the old and replace it with the new.
	check_for_cleanbot_bug()
	subsystems = list()
	if (Master != src)
		if (istype(Master))
			Recover()
			qdel(Master)
		else
			init_subtypes(/datum/subsystem, subsystems)
		Master = src

/datum/controller/master/Destroy()
	..()
	// Tell qdel() to Del() this object.
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/master/proc/Shutdown()
	processing = FALSE
	for(var/datum/subsystem/ss in subsystems)
		ss.Shutdown()

// Returns 1 if we created a new mc, 0 if we couldn't due to a recent restart,
//	-1 if we encountered a runtime trying to recreate it
/proc/Recreate_MC()
	. = -1 //so if we runtime, things know we failed
	if (world.time < MC_restart_timeout)
		return 0
	if (world.time < MC_restart_clear)
		MC_restart_count *= 0.5

	var/delay = 50 * ++MC_restart_count
	MC_restart_timeout = world.time + delay
	MC_restart_clear = world.time + (delay * 2)
	Master.processing = 0 //stop ticking this one
	try
		new/datum/controller/master()
	catch
		return -1
	return 1


/datum/controller/master/proc/Recover()
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for (var/varname in Master.vars)
		switch (varname)
			if("name", "tag", "bestF", "type", "parent_type", "vars", "statclick") // Built-in junk.
				continue
			else
				var/varval = Master.vars[varname]
				if (istype(varval, /datum)) // Check if it has a type var.
					var/datum/D = varval
					msg += "\t [varname] = [D]([D.type])\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg
	if (istype(Master.subsystems))
		subsystems = Master.subsystems
		spawn (10)
			StartProcessing()
	else
		world << "<span class='boldannounce'>The Master Controller is having some issues, we will need to re-initialize EVERYTHING</span>"
		spawn (20)
			init_subtypes(/datum/subsystem, subsystems)
			Setup()


// Please don't stuff random bullshit here,
// 	Make a subsystem, give it the SS_NO_FIRE flag, and do your work in it's Initialize()
/datum/controller/master/proc/Setup()
	check_for_cleanbot_bug()
	world << "<span class='boldannounce'>Initializing subsystems...</span>"

	// Sort subsystems by init_order, so they initialize in the correct order.
	sortTim(subsystems, /proc/cmp_subsystem_init)

	// Initialize subsystems.
	CURRENT_TICKLIMIT = TICK_LIMIT_MC_INIT
	for (var/datum/subsystem/SS in subsystems)
		if (SS.flags & SS_NO_INIT)
			continue
		SS.Initialize(world.timeofday)
		CHECK_TICK
	CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING

	world << "<span class='boldannounce'>Initializations complete!</span>"
	world.log << "Initializations complete."

	// Sort subsystems by display setting for easy access.
	sortTim(subsystems, /proc/cmp_subsystem_display)
	check_for_cleanbot_bug()
	// Set world options.
	world.sleep_offline = 1
	world.fps = config.fps
	check_for_cleanbot_bug()
	sleep(1)
	check_for_cleanbot_bug()
	// Loop.
	Master.StartProcessing()

// Notify the MC that the round has started.
/datum/controller/master/proc/RoundStart()
	round_started = 1
	var/timer = world.time
	for (var/datum/subsystem/SS in subsystems)
		if (SS.flags & SS_FIRE_IN_LOBBY || SS.flags & SS_TICKER)
			continue //already firing
		// Stagger subsystems.
		timer += world.tick_lag * rand(1, 5)
		SS.next_fire = timer

// Starts the mc, and sticks around to restart it if the loop ever ends.
/datum/controller/master/proc/StartProcessing()
	set waitfor = 0
	var/rtn = Loop()
	if (rtn > 0 || processing < 0)
		return //this was suppose to happen.
	//loop ended, restart the mc
	log_game("MC crashed or runtimed, restarting")
	message_admins("MC crashed or runtimed, restarting")
	var/rtn2 = Recreate_MC()
	if (rtn2 <= 0)
		log_game("Failed to recreate MC (Error code: [rtn2]), it's up to the failsafe now")
		message_admins("Failed to recreate MC (Error code: [rtn2]), it's up to the failsafe now")
		Failsafe.defcon = 2

// Main loop.
/datum/controller/master/proc/Loop()
	. = -1
	//Prep the loop (most of this is because we want MC restarts to reset as much state as we can, and because
	//	local vars rock

	// Schedule the first run of the Subsystems.
	round_started = world.has_round_started()
	//all this shit is here so that flag edits can be refreshed by restarting the MC. (and for speed)
	var/list/tickersubsystems = list()
	var/list/normalsubsystems = list()
	var/list/lobbysubsystems = list()
	var/timer = world.time
	for (var/thing in subsystems)
		var/datum/subsystem/SS = thing
		if (SS.flags & SS_NO_FIRE)
			continue
		SS.queued_time = 0
		SS.queue_next = null
		SS.queue_prev = null
		if (SS.flags & SS_TICKER)
			tickersubsystems += SS
			timer += world.tick_lag * rand(1, 5)
			SS.next_fire = timer
			continue
		if (SS.flags & SS_FIRE_IN_LOBBY)
			lobbysubsystems += SS
			timer += world.tick_lag * rand(1, 5)
			SS.next_fire = timer
		else if (round_started)
			timer += world.tick_lag * rand(1, 5)
			SS.next_fire = timer
		normalsubsystems += SS

	queue_head = null
	queue_tail = null
	//these sort by lower priorities first to reduce the number of loops needed to add subsequent SS's to the queue
	//(higher subsystems will be sooner in the queue, adding them later in the loop means we don't have to loop thru them next queue add)
	sortTim(tickersubsystems, /proc/cmp_subsystem_priority)
	sortTim(normalsubsystems, /proc/cmp_subsystem_priority)
	sortTim(lobbysubsystems, /proc/cmp_subsystem_priority)

	normalsubsystems += tickersubsystems
	lobbysubsystems += tickersubsystems

	init_timeofday = world.timeofday
	init_time = world.time

	iteration = 1
	var/error_level = 0
	var/sleep_delta = 0
	var/list/subsystems_to_check
	//the actual loop.
	while (1)
		tickdrift = max(0, MC_AVERAGE_FAST(tickdrift, (((world.timeofday - init_timeofday) - (world.time - init_time)) / world.tick_lag)))
		if (processing <= 0)
			CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING
			sleep(10)
			continue

		//if there are mutiple sleeping procs running before us hogging the cpu, we have to run later
		//	because sleeps are processed in the order received, so longer sleeps are more likely to run first
		if (world.tick_usage > TICK_LIMIT_MC)
			sleep_delta += 2
			CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING - (TICK_LIMIT_RUNNING * 0.5)
			sleep(world.tick_lag * (processing + sleep_delta))
			continue

		sleep_delta = MC_AVERAGE_FAST(sleep_delta, 0)
		if (last_run + (world.tick_lag * processing) > world.time)
			sleep_delta += 1
		if (world.tick_usage > (TICK_LIMIT_MC*0.5))
			sleep_delta += 1

		if (make_runtime)
			var/datum/subsystem/SS
			SS.can_fire = 0
		if (!Failsafe || (Failsafe.processing_interval > 0 && (Failsafe.lasttick+(Failsafe.processing_interval*5)) < world.time))
			new/datum/controller/failsafe() // (re)Start the failsafe.
		if (!queue_head || !(iteration % 3))
			if (round_started)
				subsystems_to_check = normalsubsystems
			else
				subsystems_to_check = lobbysubsystems
		else
			subsystems_to_check = tickersubsystems
		if (CheckQueue(subsystems_to_check) <= 0)
			if (!SoftReset(tickersubsystems, normalsubsystems, lobbysubsystems))
				world.log << "MC: SoftReset() failed, crashing"
				return
			if (!error_level)
				iteration++
			error_level++
			CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING
			sleep(10)
			continue

		if (queue_head)
			if (RunQueue() <= 0)
				if (!SoftReset(tickersubsystems, normalsubsystems, lobbysubsystems))
					world.log << "MC: SoftReset() failed, crashing"
					return
				if (!error_level)
					iteration++
				error_level++
				CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING
				sleep(10)
				continue
		error_level--
		if (!queue_head) //reset the counts if the queue is empty, in the off chance they get out of sync
			queue_priority_count = 0
			queue_priority_count_bg = 0

		iteration++
		last_run = world.time
		src.sleep_delta = MC_AVERAGE_FAST(src.sleep_delta, sleep_delta)
		CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING - (TICK_LIMIT_RUNNING * 0.25) //reserve the tail 1/4 of the next tick for the mc.
		sleep(world.tick_lag * (processing + sleep_delta))




// This is what decides if something should run.
/datum/controller/master/proc/CheckQueue(list/subsystemstocheck)
	. = 0 //so the mc knows if we runtimed
	//we create our variables outside of the loops to save on overhead
	var/datum/subsystem/SS
	var/SS_flags

	for (var/thing in subsystemstocheck)
		if (!thing)
			subsystemstocheck -= thing
		SS = thing
		if (SS.queued_time) //already in the queue
			continue
		if (SS.can_fire <= 0)
			continue
		if (SS.next_fire > world.time)
			continue
		SS_flags = SS.flags
		if (SS_flags & SS_NO_FIRE)
			subsystemstocheck -= SS
		if (!(SS_flags & SS_TICKER) && (SS_flags & SS_KEEP_TIMING) && SS.last_fire + (SS.wait * 0.75) > world.time)
			continue

		//Queue it to run.
		//	(we loop thru a linked list until we get to the end or find the right point)
		//	(this lets us sort our run order correctly without having to re-sort the entire already sorted list)
		SS.enqueue()
	. = 1


// Run thru the queue of subsystems to run, running them while balancing out their allocated tick precentage
/datum/controller/master/proc/RunQueue()
	. = 0
	var/datum/subsystem/queue_node
	var/queue_node_flags
	var/queue_node_priority
	var/queue_node_paused

	var/current_tick_budget
	var/tick_precentage
	var/tick_remaining
	var/ran = TRUE //this is right
	var/ran_non_ticker = FALSE
	var/bg_calc //have we swtiched current_tick_budget to background mode yet?
	var/tick_usage

	//keep running while we have stuff to run and we haven't gone over a tick
	//	this is so subsystems paused eariler can use tick time that later subsystems never used
	while (ran && queue_head && world.tick_usage < TICK_LIMIT_MC)
		ran = FALSE
		bg_calc = FALSE
		current_tick_budget = queue_priority_count
		queue_node = queue_head
		while (queue_node)
			if (ran && world.tick_usage > TICK_LIMIT_RUNNING)
				break
			if (!istype(queue_node))
				world.log << "[__FILE__]:[__LINE__] queue_node bad, now equals: [queue_node](\ref[queue_node])"
				return
			queue_node_flags = queue_node.flags
			queue_node_priority = queue_node.queued_priority

			//super special case, subsystems where we can't make them pause mid way through
			//if we can't run them this tick (without going over a tick)
			//we bump up their priority and attempt to run them next tick
			//(unless we haven't even ran anything this tick, since its unlikely they will ever be able run
			//	in those cases, so we just let them run)
			if (queue_node_flags & SS_NO_TICK_CHECK)
				if (queue_node.tick_usage > TICK_LIMIT_RUNNING - world.tick_usage && ran_non_ticker)
					queue_node.queued_priority += queue_priority_count * 0.10
					queue_priority_count -= queue_node_priority
					queue_priority_count += queue_node.queued_priority
					current_tick_budget -= queue_node_priority
					if (!istype(queue_node))
						world.log << "[__FILE__]:[__LINE__] queue_node bad, now equals: [queue_node](\ref[queue_node])"
						return
					queue_node = queue_node.queue_next
					continue

			if ((queue_node_flags & SS_BACKGROUND) && !bg_calc)
				current_tick_budget = queue_priority_count_bg
				bg_calc = TRUE

			tick_remaining = TICK_LIMIT_RUNNING - world.tick_usage

			if (current_tick_budget > 0 && queue_node_priority > 0)
				tick_precentage = tick_remaining / (current_tick_budget / queue_node_priority)
			else
				tick_precentage = tick_remaining

			CURRENT_TICKLIMIT = world.tick_usage + tick_precentage

			if (!(queue_node_flags & SS_TICKER))
				ran_non_ticker = TRUE
			ran = TRUE
			tick_usage = world.tick_usage
			queue_node_paused = queue_node.paused
			queue_node.paused = FALSE
			last_type_processed = queue_node

			queue_node.fire(queue_node_paused)

			current_tick_budget -= queue_node_priority
			tick_usage = world.tick_usage - tick_usage

			if (tick_usage < 0)
				tick_usage = 0

			if (queue_node.paused)
				queue_node.paused_ticks++
				queue_node.paused_tick_usage += tick_usage
				if (!istype(queue_node))
					world.log << "[__FILE__]:[__LINE__] queue_node bad, now equals: [queue_node](\ref[queue_node])"
					return
				queue_node = queue_node.queue_next
				continue

			queue_node.ticks = MC_AVERAGE(queue_node.ticks, queue_node.paused_ticks)
			tick_usage += queue_node.paused_tick_usage

			queue_node.tick_usage = MC_AVERAGE_FAST(queue_node.tick_usage, tick_usage)

			queue_node.cost = MC_AVERAGE_FAST(queue_node.cost, TICK_DELTA_TO_MS(tick_usage))
			queue_node.paused_ticks = 0
			queue_node.paused_tick_usage = 0

			if (queue_node_flags & SS_BACKGROUND) //update our running total
				queue_priority_count_bg -= queue_node_priority
			else
				queue_priority_count -= queue_node_priority

			queue_node.last_fire = world.time
			queue_node.times_fired++

			if (queue_node_flags & SS_TICKER)
				queue_node.next_fire = world.time + (world.tick_lag * queue_node.wait)
			else if (queue_node_flags & SS_POST_FIRE_TIMING)
				queue_node.next_fire = world.time + queue_node.wait
			else if (queue_node_flags & SS_KEEP_TIMING)
				queue_node.next_fire += queue_node.wait
			else
				queue_node.next_fire = queue_node.queued_time + queue_node.wait

			queue_node.queued_time = 0

			//remove from queue
			queue_node.dequeue()
			if (!istype(queue_node))
				world.log << "[__FILE__]:[__LINE__] queue_node bad, now equals: [queue_node](\ref[queue_node])"
				return
			queue_node = queue_node.queue_next

	. = 1

//resets the queue, and all subsystems, while filtering out the subsystem lists
//	called if any mc's queue procs runtime or exit improperly.
/datum/controller/master/proc/SoftReset(list/ticker_SS, list/normal_SS, list/lobby_SS)
	. = 0
	world.log << "MC: SoftReset called, resetting MC queue state."
	if (!istype(subsystems) || !istype(ticker_SS) || !istype(normal_SS) || !istype(lobby_SS))
		world.log << "MC: SoftReset: Bad list contents: '[subsystems]' '[ticker_SS]' '[normal_SS]' '[lobby_SS]' Crashing!"
		return
	var/subsystemstocheck = subsystems + ticker_SS + normal_SS + lobby_SS

	for (var/thing in subsystemstocheck)
		var/datum/subsystem/SS = thing
		if (!SS || !istype(SS))
			//list(SS) is so if a list makes it in the subsystem list, we remove the list, not the contents
			subsystems -= list(SS)
			ticker_SS -= list(SS)
			normal_SS -= list(SS)
			lobby_SS -= list(SS)
			world.log << "MC: SoftReset: Found bad entry in subsystem list, '[SS]'"
			continue
		if (SS.queue_next && !istype(SS.queue_next))
			world.log << "MC: SoftReset: Found bad data in subsystem queue, queue_next = '[SS.queue_next]'"
		SS.queue_next = null
		if (SS.queue_prev && !istype(SS.queue_prev))
			world.log << "MC: SoftReset: Found bad data in subsystem queue, queue_prev = '[SS.queue_prev]'"
		SS.queue_prev = null
		SS.queued_priority = 0
		SS.queued_time = 0
		SS.paused = 0
	if (queue_head && !istype(queue_head))
		world.log << "MC: SoftReset: Found bad data in subsystem queue, queue_head = '[queue_head]'"
	queue_head = null
	if (queue_tail && !istype(queue_tail))
		world.log << "MC: SoftReset: Found bad data in subsystem queue, queue_tail = '[queue_tail]'"
	queue_tail = null
	queue_priority_count = 0
	queue_priority_count_bg = 0
	world.log << "MC: SoftReset: Finished."
	. = 1



/datum/controller/master/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)


	stat("Master Controller:", statclick.update("(TickRate:[Master.processing]) (TickDrift:[round(Master.tickdrift)]) (Iteration:[Master.iteration])"))

