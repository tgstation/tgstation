/**
 * SSverb_manager, a subsystem that runs every tick and runs through its entire queue without yielding like SSinput.
 * this exists because of how the byond tick works and where user inputted verbs are put within it.
 *
 * The byond tick proceeds as follows:
 * 1. procs sleeping via walk() are resumed (i dont know why these are first)
 * 2. normal sleeping procs are resumed, in the order they went to sleep in the first place, this is where the MC wakes up and processes subsystems.
 *	a consequence of this is that the MC almost never resumes before other sleeping procs, because it only goes to sleep for 1 tick 99% of the time
 *	and 99% of procs either go to sleep for less time than the MC (which guarantees that they entered the sleep queue earlier when its time to wake up)
 *	and/or were called synchronously from the MC's execution, almost all of the time the MC is the last sleeping proc to resume in any given tick.
 *	This is good because it means the MC can account for the cost of previous resuming procs in the tick, and minimizes overtime.
 * 3. control is passed to byond after all of our code's procs stop execution for this tick
 * 4. a few small things happen in byond internals
 * 5. SendMaps is called for this tick, which processes the game state for all clients connected to the game and handles sending them changes
 * 	in appearances within their view range. This is expensive and takes up a significant portion of our tick, about 0.45% per connected player
 * 	as of 3/20/2022. meaning that with 50 players, 22.5% of our tick is being used up by just SendMaps, after all of our code has stopped executing.
 *	Thats only the average across all rounds, for most highpop rounds it can look like 0.6% of the tick per player, which is 30% for 50 players.
 * 6. After SendMaps ends, client verbs sent to the server are executed, and its the last major step before the next tick begins.
 *	During the course of the tick, a client can send a command to the server saying that they have executed any verb. The actual code defined
 *	for that /verb/name() proc isnt executed until this point, and the way the MC is designed makes this especially likely to make verbs
 *	"overrun" the bounds of the tick they executed in, stopping the other tick from starting and thus delaying the MC firing in that tick.
 *
 * The way the MC allots its time is via TICK_LIMIT_RUNNING, it simply subtracts the cost of SendMaps (MAPTICK_LAST_INTERNAL_TICK_USAGE)
 * plus TICK_BYOND_RESERVE from the tick and uses up to that amount of time (minus the percentage of the tick used by the time it executes subsystems)
 * on subsystems running cool things like atmospherics or Life or SSInput or whatever.
 *
 * Without this subsystem, verbs are likely to cause overtime if the MC uses all of the time it has alloted for itself in the tick, and SendMaps
 * uses as much as its expected to, and an expensive verb ends up executing that tick. This is because the MC is completely blind to the cost of
 * verbs, it can't account for it at all. The only chance for verbs to not cause overtime in a tick where the MC used as much of the tick
 * as it alloted itself and where SendMaps costed as much as it was expected to is if the verb(s) take less than TICK_BYOND_RESERVE percent of
 * the tick, which isnt much. Not to mention if SendMaps takes more than 30% of the tick and the MC forces itself to take at least 70% of the
 * normal tick duration which causes ticks to naturally overrun even in the absence of verbs.
 *
 * With this subsystem, the MC can account for the cost of verbs and thus stop major overruns of ticks. This means that the most important subsystems
 * like SSinput can start at the same time they were supposed to, leading to a smoother experience for the player since ticks arent riddled with
 * minor hangs over and over again.
 */
SUBSYSTEM_DEF(verb_manager)
	name = "Verb Manager"
	wait = 1
	flags = SS_TICKER
	priority = FIRE_PRIORITY_DELAYED_VERBS
	runlevels = ALL//trollface

	///list of callbacks to procs called from verbs or verblike procs that were executed when the server was overloaded and had to delay to the next tick.
	///this list is ran through every tick, and the subsystem does not yield until this queue is finished.
	var/list/verb_queue = list()

	///running average of how many verb callbacks are executed every second. used for the stat entry
	var/verbs_executed_per_second = 0

	var/FOR_ADMINS_IF_VERBS_FUCKED_immediately_execute_all_verbs = FALSE

///queue a callback on a proc meant to resume processing for a verb for the next tick. returns TRUE if it was queued, FALSE otherwise.
/datum/controller/subsystem/verb_manager/proc/queue_verb(datum/thing_to_call, proc_to_call, ...)
	//since this queue is meant specifically to delay user input as little as possible without overrunning the tick, the callback must have usr.
	//no, you cant queue everything up for this eat shit. if its not user input then it cant go into a queue that never yields
	if(QDELETED(thing_to_call) \
	|| !proc_to_call \
	|| !ismob(usr) \
	|| QDELING(usr) \
	|| usr.client?.holder /*dont worry admins cant cause overtime :clueless:*/ \
	|| FOR_ADMINS_IF_VERBS_FUCKED_immediately_execute_all_verbs \
	|| !initialized \
	|| !(runlevels & Master.current_runlevel))
		return FALSE

	verb_queue += CALLBACK(arglist(args))
	return TRUE

/datum/controller/subsystem/verb_manager/fire(resumed)
	var/executed_verbs = 0

	for(var/datum/callback/verb_callback as anything in verb_queue)
		if(!verb_callback)
			continue

		verb_callback.InvokeAsync()
		executed_verbs++

	verb_queue.Cut()
	verbs_executed_per_second = MC_AVG_SECONDS(verbs_executed_per_second, executed_verbs, wait TICKS)

/datum/controller/subsystem/verb_manager/stat_entry(msg)
	. = ..()
	. += "V/S: [round(verbs_executed_per_second, 0.01)]"
