/**
 * # Admin Verbs Subsystem
 *
 * Handles admin verbsand is responsible for assigning them to clients.
 */
SUBSYSTEM_DEF(admin_verbs)
	name = "Admin Verbs"
	init_order = INIT_ORDER_ADMIN_VERBS
	flags = SS_NO_FIRE

	/// List of admin verb holders.
	var/list/admin_verb_datum_holder_map

	/// List of admin verbs by permission.
	var/list/admin_verbs_by_permission

	/// List of admin verbs by category.
	var/list/admin_verbs_by_category

	/// List of ckeys that are assosciated with the admin verbs subsystem.
	var/list/assosciated_clients

	/// List of ckeys that are waiting to be assosciated
	var/list/waiting_assoscations

	/// List of revealed categories by admin
	var/list/revealed_categories

/datum/controller/subsystem/admin_verbs/stat_entry(msg)
	return "V: [length(admin_verb_datum_holder_map)] | A: [length(assosciated_clients)] | C: [length(admin_verbs_by_category)]"

/// Sets up the admin verb holder map; aswell as the sorting lists.
/datum/controller/subsystem/admin_verbs/proc/setup_holder_map()
	admin_verb_datum_holder_map = list()
	for(var/datum/admin_verb_holder/holder as anything in subtypesof(/datum/admin_verb_holder))
		admin_verb_datum_holder_map[holder] = new holder

	admin_verbs_by_permission = list()
	admin_verbs_by_category = list()
	for(var/datum/admin_verb_holder/holder as anything in admin_verb_datum_holder_map)
		holder = admin_verb_datum_holder_map[holder]

		var/holder_permissions = "[holder.verb_permissions]"
		admin_verbs_by_permission[holder_permissions] ||= list()
		admin_verbs_by_permission[holder_permissions] += holder

		var/holder_category = holder.verb_category
		admin_verbs_by_category[holder_category] ||= list()
		admin_verbs_by_category[holder_category] += holder

/datum/controller/subsystem/admin_verbs/Initialize()
	revealed_categories = list()
	assosciated_clients = list()
	setup_holder_map()
	process_waiting()
	return SS_INIT_SUCCESS

/// Assigns all verbs to the client; given they have the required permissions.
/datum/controller/subsystem/admin_verbs/proc/assign_verbs_to_client(client/target)
	for(var/permission in admin_verbs_by_permission)
		if(!check_rights_for(target, text2num(permission)))
			continue
		for(var/datum/admin_verb_holder/holder as anything in admin_verbs_by_permission[permission])
			holder.assosciate_client(target)

/// Removes all admin verbs from the client.
/datum/controller/subsystem/admin_verbs/proc/remove_verbs_from_client(client/target)
	for(var/datum/admin_verb_holder/holder as anything in admin_verb_datum_holder_map)
		holder = admin_verb_datum_holder_map[holder]
		holder.deassosciate_client(target) // no point to check for permissions here

/// Assosciates a client with the admin verbs subsystem.
/datum/controller/subsystem/admin_verbs/proc/assosciate_client(client/target)
	if(!initialized)
		waiting_assoscations ||= list()
		if(!(target.ckey in waiting_assoscations))
			waiting_assoscations |= target.ckey
			to_chat(target, span_notice("Admin Verb subsystem is still initializing, you will be automatically assosciated when it is done."))
		return

	assosciated_clients |= target.ckey
	assign_verbs_to_client(target)

/// Processes the waiting assosciations list.
/datum/controller/subsystem/admin_verbs/proc/process_waiting()
	for(var/waiting in waiting_assoscations)
		if(waiting in GLOB.directory)
			assosciate_client(GLOB.directory[waiting])
		waiting_assoscations -= waiting
	waiting_assoscations = null

/// Deassosciates a client from the admin verbs subsystem.
/datum/controller/subsystem/admin_verbs/proc/deassosciate_client(client/target)
	if(!(target.ckey in assosciated_clients))
		return
	assosciated_clients -= target.ckey
	remove_verbs_from_client(target)

/// Checks if a client is assosciated with the admin verbs subsystem.
/datum/controller/subsystem/admin_verbs/proc/is_client_assosciated(client/target)
	return (target.ckey in assosciated_clients)

/// Signal handler for when a client connects; if assosciated, assign verbs to them.
/datum/controller/subsystem/admin_verbs/proc/on_client_connection(datum/source, client/target)
	SIGNAL_HANDLER
	if(target.ckey in assosciated_clients)
		assign_verbs_to_client(target)

/// Checks if a client has the given category revealed.
/datum/controller/subsystem/admin_verbs/proc/check_hidden_revealed(client/target, category)
	return (category in revealed_categories[target.ckey])

/// Reveals a category for a client.
/datum/controller/subsystem/admin_verbs/proc/reveal_category(client/target, category)
	if(!(target.ckey in revealed_categories))
		revealed_categories[target.ckey] = list()
	revealed_categories[target.ckey] |= category
	SEND_SIGNAL(src, COMSIG_ADMIN_VERBS_CATEGORY_REVEALED, target, category)

/// Hides a category for a client.
/datum/controller/subsystem/admin_verbs/proc/hide_category(client/target, category)
	if(!(target.ckey in revealed_categories))
		return
	revealed_categories[target.ckey] -= category
	SEND_SIGNAL(src, COMSIG_ADMIN_VERBS_CATEGORY_HIDDEN, target, category)

/// Invokes a verb for a given client based on the typepath of the holder given
/datum/controller/subsystem/admin_verbs/proc/dynamic_invoke_verb(target, datum/admin_verb_holder/verb_path, ...)
	if(isnull(target))
		CRASH("Attempted to invoke an admin verb with a null client target!")

	if(!istype(target, /client))
		stack_trace("Attempted to invoke an admin verb with a non-client target! Passed in ([target:type])")
		target = CLIENT_FROM_VAR(target)
		if(!istype(target, /client))
			CRASH("Failed to retrieve client from passed in target!")

	if(!(verb_path in admin_verb_datum_holder_map))
		stack_trace("We tried to dynamically invoke a verb ([verb_path]) that doesn't exist in the map. This is really bad!")
		to_chat(usr, span_userdanger("Something broke for admin verbs that really shouldn't. Contact coders!"))
		return

	var/datum/admin_verb_holder/holder = admin_verb_datum_holder_map[verb_path]
	if(!check_rights_for(target, holder.verb_permissions))
		// alright, maybe an admin is doing this for them
		if(!check_rights_for(usr.client, holder.verb_permissions))
			return // nope!
		// yep.
		log_admin("[key_name(usr)] has invoked admin verb '[holder.verb_name]' for client [key_name(target)]")
		message_admins("[key_name_admin(usr)] has invoked admin verb '[holder.verb_name]' for client [key_name_admin(target)]")

	var/list/verb_arguments = args.Copy()
	verb_arguments.Cut(2, 2)

	// Verbs should NOT have a return value that we care about. But existing functionality expects and relies on it, god save me.
	return call(holder, "invoke_actual")(arglist(verb_arguments))
