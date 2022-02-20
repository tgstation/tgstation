/**
 * SSdelayed_verbs, a subsystem that runs every tick and runs through its entire queue without yielding like SSinput.
 * this exists because of how the byond tick works and where user inputted verbs are put within it.
 *
 * The byond tick proceeds as follows:
 * 1. procs sleeping via walk() are resumed (i dont know why these are first)
 * 2. normal sleeping procs are resumed, in the order they went to sleep in the first place, this is where the MC wakes up and processes subsystems.
 *	a consequence of this is that the MC almost never resumes before other sleeping procs, because it only goes to sleep for 1 tick 99% of the time
 *	and 99% of procs either go to sleep for less time than the MC (which guarantees that they entered the sleep queue earlier when its time to wake up)
 *	and/or were called synchronously from the MC's execution
 *
 *
 */
SUBSYSTEM_DEF(delayed_verbs)
	name = "Delayed Verbs"
	wait = 1
	flags = SS_TICKER
	priority = FIRE_PRIORITY_DELAYED_VERBS

	///list of callbacks to procs called from verbs or verblike procs that were executed when the server was overloaded and had to delay to the next tick.
	///this list is ran through every tick, and the subsystem does not yield until this queue is finished.
	var/list/verb_queue = list()

	///running average of how many verb callbacks are executed every second. used for the stat entry
	var/verbs_executed_per_second = 0

///queue a callback on a proc meant to resume processing for a verb for the next tick. returns TRUE if it was queued, FALSE otherwise.
/datum/controller/subsystem/delayed_verbs/proc/queue_verb(datum/callback/verb_callback)
	//since this queue is meant specifically to delay user input as little as possible without overrunning the tick, the callback must have usr.
	//no, you cant queue everything up for this eat shit. if its not user input then it cant go into a queue that never yields
	if(!istype(verb_callback) || !verb_callback.user)
		return FALSE

	verb_queue += verb_callback
	return TRUE

/datum/controller/subsystem/delayed_verbs/fire(resumed)
	var/executed_verbs = 0

	for(var/datum/callback/verb_callback as anything in verb_queue)
		if(!verb_callback)
			continue

		verb_callback.InvokeAsync()
		executed_verbs++

	verb_queue.Cut()
	verbs_executed_per_second = MC_AVG_SECONDS(verbs_executed_per_second, executed_verbs, wait TICKS)

/datum/controller/subsystem/delayed_verbs/stat_entry(msg)
	. = ..()
	. += "V/S: [round(verbs_executed_per_second, 0.01)]"
