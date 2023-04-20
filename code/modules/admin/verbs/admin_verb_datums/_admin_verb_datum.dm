/// A datum used to represent an admin verb.
/datum/admin_verb_holder
	/// The id of the verb, must be unique for every verb. Used to assign the datum into the holder map.
	var/verb_id

	var/verb_name
	var/verb_description
	var/verb_permissions
	var/verb_category

	/// Whether the verb is hidden from the verb list by default
	var/starts_hidden = FALSE
	/// The category id of the verb, to reveal
	var/hidden_id

	/// The verb instance created by the holder; for assignment to clients.
	var/procpath/verb_instance

	/// A list of all clients that have this verb assigned to them; via ckey
	var/list/assosciated_clients

GENERAL_PROTECT_DATUM(/datum/admin_verb_holder)

/datum/admin_verb_holder/New()
	GLOB.admin_verb_holder_map ||= list()
	if(verb_id in GLOB.admin_verb_holder_map)
		stack_trace("attempted to create duplicate admin verb [verb_id]")
		qdel(src)

	GLOB.admin_verb_holder_map[verb_id] = src
	verb_instance = create_verb_instance()
	RegisterSignal(SSadmin_verbs, COMSIG_ADMIN_VERBS_CATEGORY_REVEALED, PROC_REF(on_category_revealed))
	RegisterSignal(SSadmin_verbs, COMSIG_ADMIN_VERBS_CATEGORY_HIDDEN, PROC_REF(on_category_hidden))

	return ..()

/datum/admin_verb_holder/Destroy(force, ...)
	GLOB.admin_verb_holder_map -= verb_id
	for(var/assosciated in assosciated_clients)
		deassosciate_client(assosciated)
	QDEL_NULL(verb_instance)
	return ..()

/datum/admin_verb_holder/proc/create_verb_instance()
	return

/datum/admin_verb_holder/proc/assosciate_client(client/user)
	assosciated_clients ||= list()
	if(user.ckey in assosciated_clients)
		deassosciate_client(user)
	assosciated_clients += user.ckey

	#ifdef UNIT_TESTS
	if(starts_hidden && !hidden_id)
		stack_trace("[type] is hidden but has no hidden_id")
	#endif

	if(starts_hidden && hidden_id && !SSadmin_verbs.check_hidden_revealed(user, hidden_id))
		return
	add_verb(user, verb_instance)

/datum/admin_verb_holder/proc/deassosciate_client(client/user)
	assosciated_clients -= user.ckey
	remove_verb(user, verb_instance)

/datum/admin_verb_holder/proc/on_category_revealed(datum/source, client/user, category_id)
	SIGNAL_HANDLER

	if(!(user.ckey in assosciated_clients))
		return
	if(hidden_id != category_id)
		return
	add_verb(user, verb_instance)

/datum/admin_verb_holder/proc/on_category_hidden(datum/source, client/user, category_id)
	SIGNAL_HANDLER

	if(!(user.ckey in assosciated_clients))
		return
	if(hidden_id != category_id)
		return
	remove_verb(user, verb_instance)
