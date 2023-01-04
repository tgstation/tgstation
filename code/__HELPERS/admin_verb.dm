/**
 * Creates an admin verb with the specified module(category) name, desc, permissions, and parameters as needed.
 * If module is ADMIN_VERB_MODULE_CONTEXT, it will not be visible in the verb panel
 */
#define ADMIN_VERB(module, verb_name, verb_desc, permissions, params...) \
/mob/admin_module_holder/##module/##verb_name/verb/invoke(##params){ \
	set src in usr.group; \
	set name = #verb_name; \
	set desc = verb_desc; \
	if(datum_flags & DF_VAR_EDITED) { \
		message_admins("[key_name_admin(usr)] attempted to elevate permissions by executing from a var edited admin verb holder!"); \
		del(src); \
		return; \
	} \
	if(check_rights_for(usr.client, permissions)) { \
		_##verb_name(arglist(args)); \
	} else { \
		to_chat(usr, span_warning("You lack the permissions ([rights2text(permissions, " ")]) for this verb!")); \
	} \
} \
/datum/controller/subsystem/admin_verbs/populate_verb_map(list/verb_map){ \
	..(); \
	verb_map[/mob/admin_module_holder/##module/##verb_name] = list(#module, #verb_name, verb_desc, permissions); \
} \
/mob/admin_module_holder/##module/##verb_name/proc/_##verb_name(##params)

#define ADMIN_CONTEXT_ENTRY(context_id, context_name, permissions, params...) \
/client/proc/_DEF_admin_verb_##context_id(##params){ \
	if(check_rights_for(src, permissions)) { \
		_IMP_##context_id(arglist(args)); \
	} else { \
		to_chat(usr, span_warning("You lack the permissions ([rights2text(permissions, " ")]) for this context menu action!")); \
	} \
} \
/datum/controller/subsystem/admin_verbs/populate_context_map(list/context_map){ \
	..(); \
	context_map[/client/proc/_DEF_admin_verb_##context_id] = list(context_name, permissions); \
} \
/client/proc/_IMP_##context_id(##params)
