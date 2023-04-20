/// A datum used to represent an admin verb.
/datum/admin_verb_holder
	/// The id of the verb, must be unique for every verb. Used to assign the datum into the holder map.
	var/verb_id

	/// Internal id for this verb, used for Topic relaying
	var/verb_topic_id
	var/static/next_topic_id = 1

	var/verb_name
	var/verb_description
	var/verb_permissions
	var/verb_category

	/// Whether the verb is hidden from the verb list by default
	var/starts_hidden = FALSE

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
		deassosciate_client(user) // just ensure they dont get two copies of the same verb in their verbs
	assosciated_clients += user.ckey
	add_verb(user, verb_instance)

/datum/admin_verb_holder/proc/deassosciate_client(client/user)
	assosciated_clients -= user.ckey
	remove_verb(user, verb_instance)
