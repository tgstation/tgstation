

/datum/subsystem
	// Metadata; you should define these.
	var/name = "fire coderbus" //name of the subsystem
	var/init_order = 0		//order of initialization. Higher numbers are initialized first, lower numbers later. Can be decimal and negative values.
	var/wait = 20			//time to wait (in deciseconds) between each call to fire(). Must be a positive integer.
	var/display_order = 100	//display affects the order the subsystem is displayed in the MC tab
	var/priority = 50		//When mutiple subsystems need to run in the same tick, higher priority subsystems will run first and be given a higher share of the tick before MC_TICK_CHECK triggers a sleep

	var/flags = 0			//see MC.dm in __DEFINES Most flags must be set on world start to take full effect. (You can also restart the mc to force them to process again)

	//set to 0 to prevent fire() calls, mostly for admin use or subsystems that may be resumed later
	//	use the SS_NO_FIRE flag instead for systems that never fire to keep it from even being added to the list
	var/can_fire = TRUE

	// Bookkeeping variables; probably shouldn't mess with these.
	var/last_fire = 0		//last world.time we called fire()
	var/next_fire = 0		//scheduled world.time for next fire()
	var/cost = 0			//average time to execute
	var/tick_usage = 0		//average tick usage
	var/paused = 0			//was this subsystem paused mid fire.
	var/paused_ticks = 0	//ticks this ss is taking to run right now.
	var/paused_tick_usage	//total tick_usage of all of our runs while pausing this run
	var/ticks = 1			//how many ticks does this ss take to run on avg.
	var/times_fired = 0		//number of times we have called fire()
	var/queued_time = 0		//time we entered the queue, (for timing and priority reasons)
	var/queued_priority //we keep a running total to make the math easier, if it changes mid-fire that would break our running total, so we store it here
	//linked list stuff for the queue
	var/datum/subsystem/queue_next
	var/datum/subsystem/queue_prev


	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

// Used to initialize the subsystem BEFORE the map has loaded
/datum/subsystem/New()

//cleanup actions
/datum/subsystem/proc/Shutdown()
	return

//previously, this would have been named 'process()' but that name is used everywhere for different things!
//fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
//fire(), and the procs it calls, SHOULD NOT HAVE ANY SLEEP OPERATIONS in them!
//YE BE WARNED!
/datum/subsystem/proc/fire(resumed = 0)
	set waitfor = 0 //this should not be depended upon, this is just to solve issues with sleeps messing up tick tracking
	can_fire = 0
	flags |= SS_NO_FIRE
	throw EXCEPTION("Subsystem [src]([type]) does not fire() but did not set the SS_NO_FIRE flag. Please add the SS_NO_FIRE flag to any subsystem that doesn't fire so it doesn't get added to the processing list and waste cpu.")

/datum/subsystem/Destroy()
	dequeue()
	can_fire = 0
	flags |= SS_NO_FIRE
	Master.subsystems -= src

/datum/subsystem/proc/enqueue()
	var/SS_priority = priority
	var/SS_flags = flags
	var/datum/subsystem/queue_node
	var/queue_node_priority
	var/queue_node_flags

	for (queue_node = Master.queue_head; queue_node; queue_node = queue_node.queue_next)
		queue_node_priority = queue_node.queued_priority
		queue_node_flags = queue_node.flags

		if (queue_node_flags & SS_TICKER)
			if (!(SS_flags & SS_TICKER))
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


/datum/subsystem/proc/dequeue()
	if (queue_next)
		queue_next.queue_prev = queue_prev
	if (queue_prev)
		queue_prev.queue_next = queue_next
	if (src == Master.queue_tail)
		Master.queue_tail = queue_prev
	if (src == Master.queue_head)
		Master.queue_head = queue_next
	queued_time = 0


/datum/subsystem/proc/pause()
	. = 1
	paused = TRUE
	paused_ticks++

//used to initialize the subsystem AFTER the map has loaded
/datum/subsystem/proc/Initialize(start_timeofday)
	var/time = (world.timeofday - start_timeofday) / 10
	var/msg = "Initialized [name] subsystem within [time] seconds!"
	world << "<span class='boldannounce'>[msg]</span>"
	return time

//hook for printing stats to the "MC" statuspanel for admins to see performance and related stats etc.
/datum/subsystem/proc/stat_entry(msg)
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	if(can_fire)
		msg = "[round(cost,1)]ms|[round(tick_usage,1)]%|[round(ticks,0.1)]\t[msg]"
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
/datum/subsystem/vv_edit_var(var_name, var_value)
	switch (var_name)
		if ("can_fire")
			if (var_value)
				next_fire = world.time + wait
		if ("queued_priority") //editing this breaks things.
			return 0
	. = ..()

