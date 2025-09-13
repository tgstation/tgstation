#define VERB_QUEUE_OR_FIRE(proc_name, call_on, lookup_method, queue_on) \
	if(caller) { \
		proc_name(arglist(args)); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		if(INTELIGENT_TRY_QUEUE_VERB(HELL_CALLBACK(call_on, lookup_method(proc_name),  args.Copy()), VERB_HIGH_PRIORITY_QUEUE_THRESHOLD, queue_on)) { \
			__store_cost.name_to_use = "nullified_verb"; \
			__store_cost.usage_at_end = TICK_USAGE; \
			__store_cost.finished_on = world.time; \
			__store_cost.enter_average(); \
			return; \
		} \
		ASYNC { \
			proc_name(arglist(args)); \
		} \
		__store_cost.usage_at_end = TICK_USAGE; \
		__store_cost.finished_on = world.time; \
		__store_cost.enter_average(); \
	}

#define VERB_QUEUE_OR_FIRE_CUSTOM_ARGS(proc_name, call_on, lookup_method, queue_on, arguments...) \
	if(caller) { \
		proc_name(arguments); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		if(INTELIGENT_TRY_QUEUE_VERB(VERB_CALLBACK(call_on, lookup_method(proc_name), arguments), VERB_HIGH_PRIORITY_QUEUE_THRESHOLD, queue_on)) { \
			__store_cost.name_to_use = "nullified_verb"; \
			__store_cost.usage_at_end = TICK_USAGE; \
			__store_cost.finished_on = world.time; \
			__store_cost.enter_average(); \
			return; \
		} \
		ASYNC { \
			proc_name(arguments); \
		} \
		__store_cost.usage_at_end = TICK_USAGE; \
		__store_cost.finished_on = world.time; \
		__store_cost.enter_average(); \
	}

#define DEFINE_VERBLIKE(proc_type, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_instant, show_in_context_menu, queue_on, verb_args...) \
##parent_path/##proc_type/##verb_proc_name(##verb_args) { \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##verb_hidden;  \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	set instant = ##verb_instant; \
	SHOULD_NOT_OVERRIDE(TRUE); \
	VERB_QUEUE_OR_FIRE(__##verb_proc_name, src, PROC_REF, queue_on); \
}; \
\
##parent_path/proc/__##verb_proc_name(##verb_args)

#define DEFINE_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(verb, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, FALSE, TRUE, SSverb_manager, ##verb_args)

#define DEFINE_INSTANT_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(verb, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, TRUE, TRUE, SSverb_manager, ##verb_args)

#define DEFINE_POPUP_HIDDEN_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(verb, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, FALSE, FALSE, SSverb_manager, ##verb_args)

#define DEFINE_PROC_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(proc, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, FALSE, TRUE, SSverb_manager, ##verb_args)

// Verbs on objects that require a bespoke src
#define DEFINE_WORLD_OBJECT_VERB(parent_path, verb_proc_name, src_value, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
##parent_path/verb/##verb_proc_name(##verb_args) { \
	set src in src_value; \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##verb_hidden;  \
	set category = ##verb_category; \
	SHOULD_NOT_OVERRIDE(TRUE); \
	VERB_QUEUE_OR_FIRE(__##verb_proc_name, src, PROC_REF, SSverb_manager); \
}; \
\
##parent_path/proc/__##verb_proc_name(##verb_args)

// HHHHH WHY DOES THIS EXIST DOES IT EVEN DO ANYTHING WHAT THE FUCK
#define DEFINE_PROC_NO_PARENT_VERB(verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
/proc/##verb_proc_name(##verb_args) { \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##verb_hidden;  \
	set category = ##verb_category; \
	VERB_QUEUE_OR_FIRE(__##verb_proc_name, GLOBAL_PROC, GLOBAL_PROC_REF, SSverb_manager); \
}; \
\
/proc/__##verb_proc_name(##verb_args)

#define OVERRIDE_INTERNAL_VERB(parent_path, verb_proc_name, verb_args...) \
##parent_path/##verb_proc_name(##verb_args) { \
	SHOULD_NOT_OVERRIDE(TRUE); \
	VERB_QUEUE_OR_FIRE(__##verb_proc_name, src, PROC_REF, SSverb_manager); \
}; \
\
##parent_path/proc/__##verb_proc_name(##verb_args)

#define VERB_JUST_FIRED(...) (caller.proc == GLOB.active_tracker?.proc_name)

#define VERB_LIST_COST 1
#define VERB_LIST_TIME 2
/// List of verb path -> list(a running average of its cost, last time it ran)
GLOBAL_LIST_EMPTY(average_verb_cost)
/// Should we collect verb costs
GLOBAL_VAR_INIT(collect_verb_costs, FALSE)
/// List of all the "marked nullifiers" (things like "nullified_verb" which mark the average cost of queuing a "thing")
GLOBAL_LIST_INIT(nullifiying_verblikes, list("nullified_verb", "nullified_click", "nullified_topic"))

/proc/cmp_verb_cost_desc(list/a, list/b)
	return b[VERB_LIST_COST] - a[VERB_LIST_COST]

GLOBAL_LIST_EMPTY(verb_trackers_this_tick)

/// Verb cost tracker which is currently active
GLOBAL_DATUM(active_tracker, /datum/verb_cost_tracker)

/datum/verb_cost_tracker
	// How to categorize ourselves when logging
	var/name_to_use
	var/proc_name
	var/usage_at_start = 0
	var/usage_at_end = 0
	var/invoked_on = -1
	var/finished_on = -1

/datum/verb_cost_tracker/New(usage_at_start, callee/proc_info)
	proc_name = proc_info.proc
	name_to_use = proc_name
	src.usage_at_start = usage_at_start
	invoked_on = world.time
	GLOB.verb_trackers_this_tick += src
	GLOB.active_tracker = src

/datum/verb_cost_tracker/proc/enter_average(category)
	if(!category)
		category = name_to_use
	GLOB.active_tracker = null
	if(!GLOB.average_verb_cost)
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
