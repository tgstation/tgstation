
#define DEFINE_VERBLIKE(proc_type, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_instant, show_in_context_menu, verb_args...) \
##parent_path/##proc_type/##verb_proc_name(##verb_args) { \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##verb_hidden;  \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	set instant = ##verb_instant; \
	SHOULD_NOT_OVERRIDE(TRUE); \
	if(caller) { \
		__##verb_proc_name(arglist(args)); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		ASYNC { \
			__##verb_proc_name(arglist(args)); \
		}\
		__store_cost.usage_at_end = TICK_USAGE; \
		__store_cost.finished_on = world.time; \
	} \
}; \
\
##parent_path/proc/__##verb_proc_name(##verb_args)

#define DEFINE_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(verb, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, FALSE, TRUE, ##verb_args)

#define DEFINE_INSTANT_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(verb, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, TRUE, TRUE, ##verb_args)

#define DEFINE_POPUP_HIDDEN_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(verb, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, FALSE, FALSE, ##verb_args)

#define DEFINE_PROC_VERB(parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
	DEFINE_VERBLIKE(proc, parent_path, verb_proc_name, verb_name, verb_desc, verb_hidden, verb_category, FALSE, TRUE, ##verb_args)

// Verbs on objects that require a bespoke src
#define DEFINE_WORLD_OBJECT_VERB(parent_path, verb_proc_name, src_value, verb_name, verb_desc, verb_hidden, verb_category, verb_args...) \
##parent_path/verb/##verb_proc_name(##verb_args) { \
	set src in src_value; \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##verb_hidden;  \
	set category = ##verb_category; \
	SHOULD_NOT_OVERRIDE(TRUE); \
	if(caller) { \
		__##verb_proc_name(arglist(args)); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		ASYNC { \
			__##verb_proc_name(arglist(args)); \
		}\
		__store_cost.usage_at_end = TICK_USAGE; \
		__store_cost.finished_on = world.time; \
	} \
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
	SHOULD_NOT_OVERRIDE(TRUE); \
	if(caller) { \
		__##verb_proc_name(arglist(args)); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		ASYNC { \
			__##verb_proc_name(arglist(args)); \
		}\
		__store_cost.usage_at_end = TICK_USAGE; \
		__store_cost.finished_on = world.time; \
	} \
}; \
\
/proc/__##verb_proc_name(##verb_args)

#define OVERRIDE_INTERNAL_VERB(parent_path, verb_proc_name, verb_args...) \
##parent_path/##verb_proc_name(##verb_args) { \
	SHOULD_NOT_OVERRIDE(TRUE); \
	if(caller) { \
		__##verb_proc_name(arglist(args)); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		ASYNC { \
			__##verb_proc_name(arglist(args)); \
		}\
		__store_cost.usage_at_end = TICK_USAGE; \
		__store_cost.finished_on = world.time; \
	} \
}; \
\
##parent_path/proc/__##verb_proc_name(##verb_args)

GLOBAL_LIST_EMPTY(verb_trackers_this_tick)

/datum/verb_cost_tracker
	var/proc_name
	var/proc_type
	var/file
	var/line
	var/string_args
	var/datum/weakref/detector_weakref
	var/useage_at_start = 0
	var/usage_at_end = 0
	var/invoked_on = -1
	var/finished_on = -1

/datum/verb_cost_tracker/New(useage_at_start, callee/proc_info)
	src.useage_at_start = useage_at_start
	proc_name = proc_info.proc
	proc_type = proc_info.type
	file = proc_info.file
	line = proc_info.line
	invoked_on = world.time
	string_args = json_encode(proc_info.args)
	GLOB.verb_trackers_this_tick += src
