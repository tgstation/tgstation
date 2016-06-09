 /**
  * StonedMC
  *
  * Designed to properly split up a given tick among subsystems
  * Note: if you read parts of this code and think "why is it doing it that way"
  * Odds are, there is a reason
  *
 **/
var/datum/controller/master/Master = new()
var/MC_restart_timeout = 0
var/MC_restart_count = 0
//current tick limit, assigned by the queue controller before running a subsystem.
//used by check_tick as well so that the procs subsystems call can obey that SS's tick limits
var/CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING
/datum/controller/master
	name = "Master"

	// Are we processing (higher values increase the processing delay)
	var/processing = 1
	// The iteration of the MC.
	var/iteration = 0
	// The cost (in deciseconds) of the MC loop.
	var/cost = 0
	// A list of subsystems to process().
	var/list/subsystems
	// The cost of running the subsystems (in deciseconds).
	var/subsystem_cost = 0

	var/round_started = 0
	// The type of the last subsystem to be process()'d.
	var/last_type_processed

	var/datum/subsystem/queue_head //Start of queue linked list
	var/datum/subsystem/queue_tail //End of queue linked list (used for appending to the list)
	var/queue_priority_count = 0 //Running total so that we don't have to loop thru the queue each run to split up the tick

/datum/controller/master/New()
	// Highlander-style: there can only be one! Kill off the old and replace it with the new.
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

//returns 1 if we created a new mc, 0 if we couldn't due to a recent restart,
//	-1 if we encountered a runtime trying to recreate it
/proc/Recreate_MC()
	if (world.time > MC_restart_timeout)
		return 0
	. = -1 //so if we runtime, things know we failed
	MC_restart_timeout = world.time + (50 * ++MC_restart_count)
	Master.processing = -1 //stop ticking this one
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

	subsystems = Master.subsystems
	spawn (10)
		Master.StartProcessing()


//Please don't stuff random bullshit here,
//make a subsystem, give it the NO_FIRE flag, and do your work in it's Initialize()
/datum/controller/master/proc/Setup()
	world << "<span class='boldannounce'>Initializing subsystems...</span>"

	var/tally = 0
	var/obj/effect/spawner/lootdrop/maintenance/L = new()
	// Grab it before it gets deleted
	var/list/loot = L.loot.Copy()
	for (var/item in loot)
		tally += loot[item]
	world.log << "There are [tally] items in the \
		maintenance loot table."

	preloadTemplates()
	// Pick a random away mission.
	createRandomZlevel()
	// Generate mining.

	var/mining_type = MINETYPE
	if (mining_type == "lavaland")
		seedRuins(5, config.lavaland_budget, \
			/area/lavaland/surface/outdoors, lava_ruins_templates)
		spawn_rivers()
	else
		make_mining_asteroid_secrets()

	// deep space ruins
	seedRuins(7, rand(0,2), /area/space, space_ruins_templates)
	seedRuins(8, rand(0,2), /area/space, space_ruins_templates)
	seedRuins(9, rand(0,2), /area/space, space_ruins_templates)

	// Set up Z-level transistions.
	setup_map_transitions()

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

	// Set world options.
	world.sleep_offline = 1
	world.fps = config.fps

	sleep(1)

	// Loop.
	Master.StartProcessing()

// Notify the MC that the round has started.
/datum/controller/master/proc/RoundStart()
	round_started = 1
	var/timer = world.time
	for (var/datum/subsystem/SS in subsystems)
		if (SS.flags & SS_FIRE_IN_LOBBY || SS.flags & SS_TICKER)
			continue //already firing
		timer += world.tick_lag
		SS.can_fire = 1
		SS.next_fire = timer + rand(0, SS.wait) // Stagger subsystems.

//starts the mc, and sticks around to restart it if the loop ever ends.
/datum/controller/master/proc/StartProcessing()
	set waitfor = 0
	var/rtn = Loop()
	if (rtn > 0 || processing < 0)
		return //this was suppose to happen.
	//loop ended, restart the mc
	log_game("MC crashed or runtimed, restarting")
	message_admins("MC crashed or runtimed, restarting")
	if (Recreate_MC() <= 0)
		log_game("Failed to recreate MC, its up to the failsafe now")
		message_admins("Failed to recreate MC, its up to the failsafe now")
		Failsafe.defcon = 2

//main loop.
/datum/controller/master/proc/Loop()
	. = -1
	//Prep the loop (most of this is because we want MC restarts to reset as much state as we can, and because
	//	local vars rock

	// Schedule the first run of the Subsystems.
	var/timer = world.time
	round_started = world.has_round_started()
	//all this shit is here so that flag edits can be refreshed by restarting the MC. (and for speed)
	var/list/tickersubsystems = list()
	var/list/normalsubsystems = list()
	var/list/lobbysubsystems = list()
	for (var/thing in subsystems)
		var/datum/subsystem/SS = thing
		if (SS.flags & SS_NO_FIRE)
			continue
		SS.queued_time = 0
		SS.next = null
		SS.prev = null
		if (SS.flags & SS_TICKER)
			tickersubsystems += SS
			continue
		if (SS.flags & SS_FIRE_IN_LOBBY)
			lobbysubsystems += SS
		normalsubsystems += SS

	for (var/thing in normalsubsystems|lobbysubsystems)
		var/datum/subsystem/SS = thing
		if (round_started || SS.flags & SS_FIRE_IN_LOBBY)
			timer += world.tick_lag
			SS.next_fire = timer
	queue_head = null
	queue_tail = null
	//these sort by lower priorities first to reduce the number of loops needed to add subsequent SS's to the queue
	//(higher subsystems will be sooner in the queue, adding them later in the loop means we don't have to loop thru them next queue add)
	sortTim(tickersubsystems, /proc/cmp_subsystem_priority)
	sortTim(normalsubsystems, /proc/cmp_subsystem_priority)
	sortTim(lobbysubsystems, /proc/cmp_subsystem_priority)

	normalsubsystems += tickersubsystems
	lobbysubsystems += tickersubsystems
	debug_admins("MC: Starting main loop")
	//the actual loop.
	while (1)
		if (processing <= 0)
			debug_admins("MC: processing disabled, sleeping")
			sleep(10)
			continue

		//world << "loop start"
		if (!Failsafe || (Failsafe.processing_interval > 0 && (Failsafe.lasttick+(Failsafe.processing_interval*5)) < world.time))
			new/datum/controller/failsafe() // (re)Start the failsafe.
		if (!queue_head || !(iteration % 3))
			debug_admins("MC: checking subsystems")
			if (round_started)
				debug_admins("MC: checking normal subsystems")
				CheckQueue(normalsubsystems)
			else
				debug_admins("MC: checking lobby subsystems")
				CheckQueue(lobbysubsystems)
		else
			debug_admins("MC: not checking subsystems, checking tickers")
			CheckQueue(tickersubsystems)
		debug_admins("MC: checking to run")
		if (queue_head)
			debug_admins("MC: running queue")
			RunQueue()
		iteration++
		debug_admins("MC: sleeping [world.time]|[world.timeofday]")
		if (Debug2)
			processing = max(processing, 5)
		sleep((world.tick_lag * processing) + (world.tick_lag * 0.49)) //the *0.49 ensures we are the last thing to run next tick (after other sleeps)
		debug_admins("MC: end sleeping [world.time]|[world.timeofday]")



//this actually decides if something should run.
/datum/controller/master/proc/CheckQueue(list/subsystemstocheck)
	debug_admins("MC: checking [subsystemstocheck.len] subsystems")
	//we create our variables outside of the loops to save on overhead
	var/datum/subsystem/SS
	var/SS_flags
	//world << "checking queue"

	for (var/thing in subsystemstocheck)
		debug_admins("MC: checking [thing]")
		if (!thing)
			subsystemstocheck -= thing
		SS = thing
		if (SS.queued_time) //already in the queue
			debug_admins("MC: already queued")
			continue
		if (SS.can_fire <= 0)
			debug_admins("MC: not firing")
			continue
		if (SS.next_fire > world.time)
			debug_admins("MC: not its time")
			continue
		SS_flags = SS.flags
		if (!(SS_flags & SS_TICKER) && SS_flags & SS_KEEP_TIMING && SS.last_fire + (SS.wait * 0.75) > world.time)
			debug_admins("MC: fired too recently")
			continue

		//Queue it to run.
		//	(we loop thru a linked list until we get to the end or find the right point)
		//	(this lets us sort our run order correctly without having to re-sort the entire already sorted list)
		debug_admins("MC: queuing to run")
		SS.enqueue()


//run thru the queue of subsystems to run, balancing out their tick precentage
/datum/controller/master/proc/RunQueue()
	debug_admins("MC: queue start")
	var/datum/subsystem/queue_node
	var/queue_node_flags
	var/queue_node_priority
	var/queue_node_paused

	var/current_tick_budget = queue_priority_count
	var/tick_precentage
	var/tick_remaining
	var/ran = TRUE //this is right
	var/ran_non_ticker = FALSE
	var/tick_usage

	while (ran && queue_head && world.tick_usage < TICK_LIMIT_MC)
		ran = FALSE
		debug_admins("MC: Starting a pass thru thru the queue")
		for (queue_node = queue_head; queue_node; queue_node = queue_node.next)
			debug_admins("MC: processing [queue_node]")
			if (world.tick_usage > TICK_LIMIT_RUNNING)
				debug_admins("MC: tick limit reached")
				break
			queue_node_flags = queue_node.flags
			queue_node_priority = queue_node.queued_priority

			//super special case, subsystems where we can't make them pause mid way through
			//if we can't run them this tick (without going over a tick)
			//we bump up their priority and attempt to run them next tick
			//(unless we haven't even ran anything this tick, since its unlikely they will ever be able run
			//	in those cases, so we just let them run)
			if (queue_node_flags & SS_NO_TICK_CHECK)
				debug_admins("MC: no tick check")
				if (queue_node.tick_usage > TICK_LIMIT_RUNNING - world.tick_usage && ran_non_ticker)
					debug_admins("MC: no time to run tick checkless system this tick")
					queue_node.queued_priority += queue_priority_count * 0.10
					queue_priority_count -= queue_node_priority
					queue_priority_count += queue_node.queued_priority
					current_tick_budget -= queue_node_priority
					continue

			tick_remaining = TICK_LIMIT_RUNNING - world.tick_usage
			if (current_tick_budget > 0 && queue_node_priority > 0)
				tick_precentage = tick_remaining / (current_tick_budget / queue_node_priority)
			else
				tick_precentage = tick_remaining

			if (queue_node_flags & SS_BACKGROUND)
				CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING
			else
				CURRENT_TICKLIMIT = world.tick_usage + tick_precentage
			debug_admins("MC: running [queue_node] until tick_usage of [CURRENT_TICKLIMIT]%, current tick_usage [world.tick_usage] meaning [CURRENT_TICKLIMIT-world.tick_usage]% of a tick")
			if (!(queue_node_flags & SS_TICKER))
				ran_non_ticker = TRUE
			ran = TRUE
			tick_usage = world.tick_usage
			queue_node_paused = queue_node.paused
			queue_node.paused = FALSE
			debug_admins("MC: [( queue_node_paused ? "resuming" : "running" )] subsystem [queue_node]")
			queue_node.fire(queue_node_paused)
			if (!(queue_node_flags & SS_BACKGROUND))
				current_tick_budget -= queue_node_priority
			tick_usage = world.tick_usage - tick_usage

			if (tick_usage < 0)
				tick_usage = 0
			debug_admins("MC: [queue_node].fire() exit, used [tick_usage]% of a tick")
			if (queue_node.paused)
				debug_admins("MC: [queue_node] paused, moving on")
				queue_node.paused_ticks++
				queue_node.paused_tick_usage += tick_usage
				continue

			queue_node.ticks = MC_AVERAGE(queue_node.ticks, queue_node.paused_ticks)
			tick_usage += queue_node.paused_tick_usage

			queue_node.tick_usage = MC_AVERAGE_FAST(queue_node.tick_usage, tick_usage)

			queue_node.cost = MC_AVERAGE_FAST(queue_node.cost, TICK_DELTA_TO_MS(tick_usage))
			queue_node.paused_ticks = 0
			queue_node.paused_tick_usage = 0

			if (!(queue_node_flags & SS_BACKGROUND)) //update our running total
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

	CURRENT_TICKLIMIT = TICK_LIMIT_RUNNING

/datum/controller/master/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	stat("Master Controller:", statclick.update("[round(Master.cost, 1)]ms (Iteration:[Master.iteration])"))

