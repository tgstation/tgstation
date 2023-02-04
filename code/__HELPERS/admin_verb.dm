/**
 * Creates an admin verb with the specified module(category) name, desc, permissions, and parameters as needed.
 */
#define ADMIN_VERB(module, verb_id, verb_name, verb_desc, permissions, params...) \
/mob/admin_module_holder/##module/##verb_id/verb/invoke(##params){ \
	set src in usr.group; \
	set name = verb_name; \
	set desc = verb_desc; \
	if(datum_flags & DF_VAR_EDITED) { \
		message_admins("[key_name_admin(usr)] attempted to elevate permissions by executing from a var edited admin verb holder!"); \
		del(src); \
		return; \
	} \
	if(IsAdminAdvancedProcCall()) { \
		message_admins("[key_name_admin(usr)] attempted to elevate permissions by executing an admin verb using ProcCall!"); \
		return; \
	} \
	if(check_rights_for(usr.client, permissions)) { \
		_##verb_id(arglist(args)); \
		SSblackbox.record_feedback("tally", "admin_verb", 1, "[#module]/[#verb_id]"); \
	} else { \
		to_chat(usr, span_warning("You lack the permissions ([rights2text(permissions, " ")]) for this verb!")); \
	} \
} \
/mob/admin_module_holder/##module/##verb_id/dynamic_map_generate(){ \
	return list(#module, verb_name, verb_desc, permissions); \
} \
/mob/admin_module_holder/##module/##verb_id/proc/_##verb_id(##params)

/**
 * Creates a context menu entry for the client. The source of this proc will be the client!
 */
#define ADMIN_CONTEXT_ENTRY(context_id, context_name, permissions, params...) \
/client/proc/admin_context_wrapper_##context_id(##params){ \
	if(check_rights_for(src, permissions)) { \
		__admin_context_verb_##context_id(arglist(args)); \
		SSblackbox.record_feedback("tally", "admin_context", 1, "[#context_id]/[context_name]"); \
	} else { \
		to_chat(usr, span_warning("You lack the permissions ([rights2text(permissions, " ")]) for this context menu action!")); \
	} \
} \
/datum/controller/subsystem/admin_verbs/populate_context_map(list/context_map){ \
	..(); \
	context_map[/client/proc/admin_context_wrapper_##context_id] = list(context_name, permissions); \
} \
/client/proc/__admin_context_verb_##context_id(##params)

// THIS IS DONE HERE TO ENSURE IT ALWAYS MATCHES THE ABOVE MACRO.
// IF YOU CHANGE THE MACRO MAKE SURE THIS STILL WORKS CORRECTLY!! -Zephyr

/client/CanProcCall(procname)
	if(findtext(procname, "admin_context_wrapper_") == 1)
		return FALSE
	if(findtext(procname, "__admin_context_verb") == 1)
		return FALSE
	return ..()
