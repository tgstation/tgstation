/**
	* # Subsystem base class
	*
	* Defines a subsystem to be managed by the [Master Controller][/datum/controller/master]
	*
	* Simply define a child of this subsystem, using the [SUBSYSTEM_DEF] macro, and the MC will handle registration.
	* Changing the name is required
**/

/datum/controller/subsystem
	// Metadata; you should define these.

	/// Name of the subsystem - you must change this
	name = "fire coderbus"

	/// Determines which subsystems this subsystem is dependant on to initialize. Will initialize after all specified subsystems.
	/// If init_stage is earlier than a dependent subsystem, will throw an error and push the init stage forward to that subsystem.
	/// Usage: Put the typepaths of the subsystems that need to init before this one in this list.
	var/list/dependencies = list()

	/// The inverse of the dependencies. Can be set manually, but will also get evaluated at runtime. Turns into a list of instances at runtime.
	/// Usage: Put the typepaths of the subsystems that need to init after this one in this list.
	var/list/dependents

	/// ID of the subsystem. Set automatically when the dependency graph is evaluated. Used primarily in determining order.
	var/ordering_id = 0

	/// Do not modify. Automatically set when the dependency graph is evaluated. Similar to ordering_id, but evaluated after init_stage.
	var/init_order = 0

	/// Time to wait (in deciseconds) between each call to fire(). Must be a positive integer.
	var/wait = 20

	/// Priority Weight: When multiple subsystems need to run in the same tick, higher priority subsystems will be given a higher share of the tick before MC_TICK_CHECK triggers a sleep, higher priority subsystems also run before lower priority subsystems
	var/priority = FIRE_PRIORITY_DEFAULT

	/// [Subsystem Flags][SS_NO_INIT] to control binary behavior. Flags must be set at compile time or before preinit finishes to take full effect. (You can also restart the mc to force them to process again)
	var/flags = NONE

	/// Which stage does this subsystem init at. Earlier stages can fire while later stages init.
	var/init_stage = INITSTAGE_MAIN

	/// This var is set to `INITIALIZATION_INNEW_REGULAR` after the subsystem has been initialized.
	var/initialized = FALSE

	/// Set to 0 to prevent fire() calls, mostly for admin use or subsystems that may be resumed later
	/// use the [SS_NO_FIRE] flag instead for systems that never fire to keep it from even being added to list that is checked every tick
	var/can_fire = TRUE

	///Bitmap of what game states can this subsystem fire at. See [RUNLEVELS_DEFAULT] for more details.
	var/runlevels = RUNLEVELS_DEFAULT //points of the game at which the SS can fire

	/**
	 * boolean set by admins. if TRUE then this subsystem will stop the world profiler after ignite() returns and start it again when called.
	 * used so that you can audit a specific subsystem or group of subsystems' synchronous call chain.
	 */
	var/profiler_focused = FALSE

	/*
	 * The following variables are managed by the MC and should not be modified directly.
	 */

	/// Last world.time the subsystem completed a run (as in wasn't paused by [MC_TICK_CHECK])
	var/last_fire = 0

	/// Scheduled world.time for next fire()
	var/next_fire = 0

	/// Running average of the amount of milliseconds it takes the subsystem to complete a run (including all resumes but not the time spent paused)
	var/cost = 0

	/// Running average of the amount of tick usage in percents of a tick it takes the subsystem to complete a run
	var/tick_usage = 0

	/// Running average of the amount of tick usage (in percents of a game tick) the subsystem has spent past its allocated time without pausing
	var/tick_overrun = 0

	/// Flat list of usage and time, every odd index is a log time, every even index is a usage
	var/list/rolling_usage = list()

	/// How much of a tick (in percents of a tick) were we allocated last fire.
	var/tick_allocation_last = 0

	/// How much of a tick (in percents of a tick) do we get allocated by the mc on avg.
	var/tick_allocation_avg = 0

	/// Tracks the current execution state of the subsystem. Used to handle subsystems that sleep in fire so the mc doesn't run them again while they are sleeping
	var/state = SS_IDLE

	/// Tracks how many times a subsystem has ever slept in fire().
	var/slept_count = 0

	/// Tracks how many fires the subsystem has consecutively paused on in the current run
	var/paused_ticks = 0

	/// Tracks how much of a tick the subsystem has consumed in the current run
	var/paused_tick_usage

	/// Tracks how many fires the subsystem takes to complete a run on average.
	var/ticks = 1

	/// Tracks the amount of completed runs for the subsystem
	var/times_fired = 0

	/// How many fires have we been requested to postpone
	var/postponed_fires = 0

	/// Time the subsystem entered the queue, (for timing and priority reasons)
	var/queued_time = 0

	/// Priority at the time the subsystem entered the queue. Needed to avoid changes in priority (by admins and the like) from breaking things.
	var/queued_priority

	/// How many times we suspect a subsystem type has crashed the MC, 3 strikes and you're out!
	var/static/list/failure_strikes

	/// Next subsystem in the queue of subsystems to run this tick
	var/datum/controller/subsystem/queue_next
	/// Previous subsystem in the queue of subsystems to run this tick
	var/datum/controller/subsystem/queue_prev

	/// String to store an applicable error message for a subsystem crashing, used to help debug crashes in contexts such as Continuous Integration/Unit Tests
	var/initialization_failure_message = null

	//Do not blindly add vars here to the bottom, put it where it goes above
	//If your var only has two values, put it in as a flag.


//Do not override
///datum/controller/subsystem/New()

// Used to initialize the subsystem BEFORE the map has loaded
// Called AFTER Recover if that is called
// Prefer to use Initialize if possible
/datum/controller/subsystem/proc/PreInit()
	return

///This is used so the mc knows when the subsystem sleeps. do not override.
/datum/controller/subsystem/proc/ignite(resumed = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	set waitfor = FALSE
	. = SS_IDLE

	tick_allocation_last = Master.current_ticklimit-(TICK_USAGE)
	tick_allocation_avg = MC_AVERAGE(tick_allocation_avg, tick_allocation_last)

	. = SS_SLEEPING
	fire(resumed)
	. = state
	if (state == SS_SLEEPING)
		slept_count++
		state = SS_IDLE
	if (state == SS_PAUSING)
		slept_count++
		var/QT = queued_time
		enqueue()
		state = SS_PAUSED
		queued_time = QT

///previously, this would have been named 'process()' but that name is used everywhere for different things!
///fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
///Sleeping in here prevents future fires until returned.
/datum/controller/subsystem/proc/fire(resumed = FALSE)
	flags |= SS_NO_FIRE
	CRASH("Subsystem [src]([type]) does not fire() but did not set the SS_NO_FIRE flag. Please add the SS_NO_FIRE flag to any subsystem that doesn't fire so it doesn't get added to the processing list and waste cpu.")

/datum/controller/subsystem/Destroy()
	dequeue()
	can_fire = 0
	flags |= SS_NO_FIRE
	if (Master)
		Master.subsystems -= src
	return ..()


/** Update next_fire for the next run.
 *  reset_time (bool) - Ignore things that would normally alter the next fire, like tick_overrun, and last_fire. (also resets postpone)
 */
/datum/controller/subsystem/proc/update_nextfire(reset_time = FALSE)
	var/queue_node_flags = flags

	if (reset_time)
		postponed_fires = 0
		if (queue_node_flags & SS_TICKER)
			next_fire = world.time + (world.tick_lag * wait)
		else
			next_fire = world.time + wait
		return

	if (queue_node_flags & SS_TICKER)
		next_fire = world.time + (world.tick_lag * wait)
	else if (queue_node_flags & SS_POST_FIRE_TIMING)
		next_fire = world.time + wait + (world.tick_lag * (tick_overrun/100))
	else if (queue_node_flags & SS_KEEP_TIMING)
		next_fire += wait
	else
		next_fire = queued_time + wait + (world.tick_lag * (tick_overrun/100))


///Queue it to run.
/// (we loop thru a linked list until we get to the end or find the right point)
/// (this lets us sort our run order correctly without having to re-sort the entire already sorted list)
/datum/controller/subsystem/proc/enqueue()
	var/SS_priority = priority
	var/SS_flags = flags
	var/datum/controller/subsystem/queue_node
	var/queue_node_priority
	var/queue_node_flags

	for (queue_node = Master.queue_head; queue_node; queue_node = queue_node.queue_next)
		queue_node_priority = queue_node.queued_priority
		queue_node_flags = queue_node.flags

		if (queue_node_flags & (SS_TICKER|SS_BACKGROUND) == SS_TICKER)
			if ((SS_flags & (SS_TICKER|SS_BACKGROUND)) != SS_TICKER)
				continue
			if (queue_node_priority < SS_priority)
				break

		else if (queue_node_flags & SS_BACKGROUND)
			if (!(SS_flags & SS_BACKGROUND))
				break
			if (queue_node_priority < SS_priority)
				break

		else
			if (SS_flags & SS_BACKGROUND)
				continue
			if (SS_flags & SS_TICKER)
				break
			if (queue_node_priority < SS_priority)
				break

	queued_time = world.time
	queued_priority = SS_priority
	state = SS_QUEUED
	if (SS_flags & SS_BACKGROUND) //update our running total
		Master.queue_priority_count_bg += SS_priority
	else
		Master.queue_priority_count += SS_priority

	queue_next = queue_node
	if (!queue_node)//we stopped at the end, add to tail
		queue_prev = Master.queue_tail
		if (Master.queue_tail)
			Master.queue_tail.queue_next = src
		else //empty queue, we also need to set the head
			Master.queue_head = src
		Master.queue_tail = src

	else if (queue_node == Master.queue_head)//insert at start of list
		Master.queue_head.queue_prev = src
		Master.queue_head = src
		queue_prev = null
	else
		queue_node.queue_prev.queue_next = src
		queue_prev = queue_node.queue_prev
		queue_node.queue_prev = src


/datum/controller/subsystem/proc/dequeue()
	if (queue_next)
		queue_next.queue_prev = queue_prev
	if (queue_prev)
		queue_prev.queue_next = queue_next
	if (Master && (src == Master.queue_tail))
		Master.queue_tail = queue_prev
	if (Master && (src == Master.queue_head))
		Master.queue_head = queue_next
	queued_time = 0
	if (state == SS_QUEUED)
		state = SS_IDLE


/datum/controller/subsystem/proc/pause()
	. = 1
	switch(state)
		if(SS_RUNNING)
			state = SS_PAUSED
		if(SS_SLEEPING)
			state = SS_PAUSING

/// Called after the config has been loaded or reloaded.
/datum/controller/subsystem/proc/OnConfigLoad()

/**
 * Used to initialize the subsystem. This is expected to be overridden by subtypes.
 */
/datum/controller/subsystem/Initialize()
	return SS_INIT_NONE

/datum/controller/subsystem/stat_entry(msg)
	if(can_fire && !(SS_NO_FIRE & flags) && init_stage <= Master.init_stage_completed)
		msg = "[round(cost,1)]ms|[round(tick_usage,1)]%([round(tick_overrun,1)]%)|[round(ticks,0.1)] [msg]"
	else
		msg = "OFFLINE\t[msg]"
	return msg

/datum/controller/subsystem/proc/state_letter()
	switch (state)
		if (SS_RUNNING)
			. = "R"
		if (SS_QUEUED)
			. = "Q"
		if (SS_PAUSED, SS_PAUSING)
			. = "P"
		if (SS_SLEEPING)
			. = "S"
		if (SS_IDLE)
			. = "  "

/// Causes the next "cycle" fires to be missed. Effect is accumulative but can reset by calling update_nextfire(reset_time = TRUE)
/datum/controller/subsystem/proc/postpone(cycles = 1)
	if (can_fire && cycles >= 1)
		postponed_fires += cycles

/// Prunes out of date entries in our rolling usage list
/datum/controller/subsystem/proc/prune_rolling_usage()
	var/list/rolling_usage = src.rolling_usage
	var/cut_to = 0
	while(cut_to + 2 <= length(rolling_usage) && rolling_usage[cut_to + 1] < DS2TICKS(world.time - Master.rolling_usage_length))
		cut_to += 2
	if(cut_to)
		rolling_usage.Cut(1, cut_to + 1)

//usually called via datum/controller/subsystem/New() when replacing a subsystem (i.e. due to a recurring crash)
//should attempt to salvage what it can from the old instance of subsystem
/datum/controller/subsystem/Recover()

/datum/controller/subsystem/vv_edit_var(var_name, var_value)
	switch (var_name)
		if (NAMEOF(src, can_fire))
			//this is so the subsystem doesn't rapid fire to make up missed ticks causing more lag
			if (var_value)
				update_nextfire(reset_time = TRUE)
		if (NAMEOF(src, queued_priority)) //editing this breaks things.
			return FALSE
	. = ..()
