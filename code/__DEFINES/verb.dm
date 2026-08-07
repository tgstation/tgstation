/**
 * Alright so like, I'm sorry, ok?
 *
 * This macro enables us to track the cost of individual verbs, and queue them up if running them would push us into overtime.
 * The reason we do this is because verbs are not tracked by byond's cpu profiling tools (world.cpu, etc) at all. They're in the profiler, and that's IT.
 * This is a problem because it means we can't account for them when scheduling work, even if we wanted to. We also have no idea if they push us into overtime or not.
 * This macro fixes that.
 * The idea is to shim all verb (or verb like, IE user input so Topic, Click, etc) calls with cost tracking and queuing code, which is what's below.
 * We define a child proc for the actual verb to call, and use macro magic to make any code after a GAME_VERB**() line actually live in that child proc.
 * The only reason this file is so messy and has so many variations is we need to shim verb attribute sets too because they have to be inline
 * with the verb/proc they actually apply to
 * Anyway the actual profiling is pretty simple, we're using the ability to shim to also detect and ignore sleeps. At that point it's just a matter of measuring
 * the usage between the start and end of the verb's call, and boom we have the cost.
 * There's some nuance here, verbs are tracked by name, if we don't want an execution time to "count" for a given verb
 * we need to "change" that name. Some places also rename verbs based off context (Topic does this), etc.
 * We need to be careful to only rename BEFORE checking if we need to queue, doing it after just creates unusable junk data (which is rarely something you want)
**/

/// This is the underlying workhorse. This macro runs the verb we want to execute and tracks its time, assuming thisi s being ran as a verb and all
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


/**
 * Defines a game verb with an associated /datum/verb_metadata.
 *
 * Usage:
 *   GAME_VERB(/client, ooc, "OOC", "Send a message in OOC.", "OOC", msg as text)
 *       // verb body
 */

#define _GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden, is_instant, verb_args...) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(##verb_args) \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(popup_menu, ##show_in_context_menu); \
	VERBLIKE_SET(category, ##verb_category); \
	VERBLIKE_SET(instant, ##is_instant); \
	VERB_QUEUE_OR_FIRE(__gvb_##verb_path_name, src, PROC_REF, SSverb_manager); \
}; \
##owner_type/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, FALSE, ##verb_args)

#define GAME_VERB_DESC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, FALSE, ##verb_args)

#define GAME_VERB_HIDDEN(owner_type, verb_path_name, verb_name, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", null, FALSE, TRUE, FALSE, ##verb_args)

#define GAME_VERB_HIDDEN_INSTANT(owner_type, verb_path_name, verb_name, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", null, FALSE, TRUE, TRUE, ##verb_args)

#define _GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden, verb_args...) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/proc/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/proc/##verb_path_name(##verb_args) \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(popup_menu, ##show_in_context_menu); \
	VERBLIKE_SET(category, ##verb_category); \
	VERB_QUEUE_OR_FIRE(__gvb_##verb_path_name, src, PROC_REF, SSverb_manager); \
}; \
##owner_type/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
_GAME_VERB_PROC(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, ##verb_args)

#define GAME_VERB_PROC_DESC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, ##verb_args)

#define _GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden, verb_args...) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(##verb_args) \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(popup_menu, ##show_in_context_menu); \
	VERBLIKE_SET(category, ##verb_category); \
	set src in src_value; \
	VERB_QUEUE_OR_FIRE(__gvb_##verb_path_name, src, PROC_REF, SSverb_manager); \
}; \
##owner_type/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_category, verb_args...) \
_GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, "", verb_category, TRUE, FALSE, ##verb_args)

#define GAME_VERB_SRC_DESC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, TRUE, FALSE, ##verb_args)

#define _GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, is_hidden, verb_args...) \
/datum/verb_metadata/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = /proc/##verb_path_name; \
	body_path = /proc/__gvb_##verb_path_name; \
}; \
/proc/##verb_path_name(##verb_args) \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(category, ##verb_category); \
	VERB_QUEUE_OR_FIRE(__gvb_##verb_path_name, GLOBAL_PROC, GLOBAL_PROC_REF, SSverb_manager); \
}; \
/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, FALSE, ##verb_args)

#define INVOKE_GAME_VERB(target, owner_type, verb_path_name, args...) SSverbs.invoke(target, /datum/verb_metadata##owner_type/##verb_path_name, ##args)
#define ASSIGN_GAME_VERB(target, owner_type, verb_path_name) SSverbs.assign_verb(target, /datum/verb_metadata##owner_type/##verb_path_name)
#define UNASSIGN_GAME_VERB(target, owner_type, verb_path_name) SSverbs.unassign_verb(target, /datum/verb_metadata##owner_type/##verb_path_name)
