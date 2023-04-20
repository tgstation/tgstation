/// (id, name, description, permissions, category, args...)
/// Used to define an admin verb.
/// The final arguments will be expanded to (client/user, args...)
#define ADMIN_VERB(id, name_, description, permissions, category_, arguments...) \
/datum/admin_verb_holder/##id/verb_id = "avd_" + #id; \
/datum/admin_verb_holder/##id/verb_name = name_; \
/datum/admin_verb_holder/##id/verb_description = description; \
/datum/admin_verb_holder/##id/verb_permissions = ##permissions; \
/datum/admin_verb_holder/##id/verb_category = category_; \
/datum/admin_verb_holder/##id/proc/invoke_client(##arguments) { \
	set category = category_; \
	set waitfor = FALSE; \
	___proxy_admin_verb_invocation(usr.client, "avd_" + #id, args); \
} \
/datum/admin_verb_holder/##id/create_verb_instance() { \
	return new /datum/admin_verb_holder/##id/proc/invoke_client(null, verb_name, verb_description); \
} \
/datum/admin_verb_holder/##id/proc/invoke_actual(client/user, ##arguments)

GENERAL_PROTECT_DATUM(/datum/admin_verb_holder)

/datum/admin_verb_holder/Read(F)
	message_admins("[usr] attempted to create [type] via byond save loading.")
	del(src) // hard del now, don't let anything else do anything

/datum/admin_verb_holder/Write(F)
	message_admins("[usr] attempted to create [type] via byond save loading.")
	del(src) // hard del now, don't let anything else do anything

#define ADMIN_VERB_HIDDEN(id, name_, description, permissions, category_, hidden_id_, arguments...) \
/datum/admin_verb_holder/##id/starts_hidden = TRUE; \
/datum/admin_verb_holder/##id/hidden_id = hidden_id_; \
ADMIN_VERB(##id, ##name_, ##description, ##permissions, ##category_, ##arguments)

/// (id, name, permissions, args...)
/// Used to denote an admin verb that is context menu only and should not be shown in the verbs panel
#define ADMIN_VERB_CONTEXT_MENU(id, name, permissions, arguments...) ADMIN_VERB(##id, ##name, "", ##permissions, "Context Menu", ##arguments)

/// A global map for admin verbs, used to lookup the holder datum for a given id.
GLOBAL_LIST(admin_verb_holder_map)
GLOBAL_PROTECT(admin_verb_holder_map)

/// Acts as a stand in to move the proc call from the client to the datum holder.
/proc/___proxy_admin_verb_invocation(client/user, verb_id, list/arguments)
	SHOULD_NOT_SLEEP(TRUE)

	if(!(verb_id in GLOB.admin_verb_holder_map))
		stack_trace("attempted to invoke non-existent admin verb [verb_id]")
		return

	var/datum/admin_verb_holder/holder = GLOB.admin_verb_holder_map[verb_id]
	if(!check_rights_for(user, holder.verb_permissions))
		to_chat(user, span_warning("You do not have permission perform this action."))
		return

	var/list/args_actual = arguments.Copy()
	args_actual.Insert(1, user)

	SSblackbox.record_feedback("tally", "admin_verb", 1, verb_id)
	ASYNC
		// yes I know this is bad, but it's defined using the macro and not a base proc, sue me
		call(holder, "invoke_actual")(arglist(args_actual))
