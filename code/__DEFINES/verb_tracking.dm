
/// Returns true if this verb is being ran as a verb (or if it was just invoked by a verb manager)
/// false if it's being ran by some parent call
#define VERB_JUST_FIRED(...) (caller?.proc == GLOB.active_tracker?.proc_path || caller?.proc == /datum/callback/proc/InvokeAsync)

// list keys because this code is decently hot
#define VERB_LIST_COST 1
#define VERB_LIST_TIME 2
/// List of verb path -> list(a running average of its cost, last time it ran)
GLOBAL_LIST_EMPTY(average_verb_cost)
/// Should we collect verb costs into a list. Just in case something explodes
GLOBAL_VAR_INIT(collect_verb_costs, TRUE)
/// List of all the "marked nullifiers" (things like "nullified_verb" which mark the average cost of queuing a "thing")
GLOBAL_LIST_INIT(nullifiying_verblikes, list("nullified_verb", "nullified_click", "nullified_topic", "nullified_act"))

/proc/cmp_verb_cost_desc(list/a, list/b)
	return b[VERB_LIST_COST] - a[VERB_LIST_COST]

GLOBAL_LIST_EMPTY(verb_trackers_this_tick)

/// Verb cost tracker which is currently active
GLOBAL_DATUM(active_tracker, /datum/verb_cost_tracker)

/// Holder datum that tracks cpu usage/metadata about invoked verbs
/datum/verb_cost_tracker
	/// How to categorize ourselves when logging
	var/name_to_use
	/// Path of the proc this is running off
	var/proc_path
	/// Usage before the verb runs
	var/usage_at_start = 0
	/// Usage after the verb runs
	var/usage_at_end = 0
	/// world.time we invoked the verb on
	var/invoked_on = -1
	/// world.time we finished running the verb on
	var/finished_on = -1

/datum/verb_cost_tracker/New(usage_at_start, callee/proc_info)
	proc_path = proc_info.proc
	name_to_use = proc_path
	src.usage_at_start = usage_at_start
	invoked_on = world.time
	GLOB.verb_trackers_this_tick += src
	GLOB.active_tracker = src

/datum/verb_cost_tracker/proc/enter_average(category)
	if(!category)
		category = name_to_use
	GLOB.active_tracker = null
	if(!GLOB.average_verb_cost || !GLOB.collect_verb_costs)
		return

	var/list/intel = GLOB.average_verb_cost[name_to_use]
	if(!intel)
		var/avg_usage = MC_AVG_SLOW_UP_FAST_DOWN(0, usage_at_end - usage_at_start)
		if(SSverb_maintinance.kill_threshold_cost > avg_usage && !(name_to_use in GLOB.nullifiying_verblikes))
			return
		GLOB.average_verb_cost[name_to_use] = list(avg_usage, world.time)
		return

	var/avg_usage = MC_AVG_SLOW_UP_FAST_DOWN(intel[VERB_LIST_COST], usage_at_end - usage_at_start)
	if(SSverb_maintinance.kill_threshold_cost > avg_usage && !(name_to_use in GLOB.nullifiying_verblikes))
		GLOB.average_verb_cost -= name_to_use
		return

	intel[VERB_LIST_TIME] = world.time
	intel[VERB_LIST_COST] = avg_usage

/datum/verb_cost_tracker/proc/get_average_cost()
	var/list/intel = GLOB.average_verb_cost[name_to_use]
	if(!intel)
		return 0
	intel[VERB_LIST_TIME] = world.time
	return intel[VERB_LIST_COST]
