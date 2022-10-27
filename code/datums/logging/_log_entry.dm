/datum/log_entry
	/*
	 * The version of this log entry, based on semver: https://semver.org/
	 *
	 * This is used to guarantee to automated tooling that the data it is parsing
	 * is what it is expecting.
	 *
	 * For backwards incompatible changes, such as REMOVING fields, or CHANGING their meaning,
	 * update the MAJOR version number. For instance, 1.2.3 -> 2.0.0.
	 *
	 * For backwards compatible additions, such as ADDING fields,
	 * update the MINOR version number. For instance, 1.2.3 -> 1.3.0.
	 *
	 * Otherwise, if you are changing the datum AT ALL, such as to refactor its code or fix an edge case,
	 * update the PATCH version number. For instance, 1.2.3 -> 1.2.4.
	 * This is so that in the event your code breaks the logging, automated tooling can isolate it.ted for.
	 */
	VAR_PRIVATE/version = "0.0.0"
	/// The unix timestamp this log entry was created.
	VAR_PRIVATE/unix_timestamp = 0
	/// The world.time this log entry was created.
	VAR_PRIVATE/world_timestamp = 0
	/// The round this log entry was created on.
	VAR_PRIVATE/round_id = 0
	/// The server this log entry was created on.
	VAR_PRIVATE/server_name

	// required settings

	/// The category this log entry falls under.
	var/category
	var/can_inspect = FALSE
	/// The message this log entry contains.
	var/message
	/// Whether this log entry is public or not.
	var/private = FALSE
	/// The location this log entry was created at.
	var/list/location
	/// A lazy list of tags that can be used to filter this log entry.
	var/list/tags

	// optional settings

	/// The name of the datum that created this log entry.
	var/source_name
	/// The ckey, if applicable, of the user that created this log entry.
	var/source_ckey
	/// The reference to the source of this log entry; for the default inspection
	var/datum/weakref/source_weakref
	/// The name of the target datum, if applicable, of this log entry.
	var/target_name
	/// The ckey, if applicable, of the target datum, if applicable, of this log entry.
	var/target_ckey

	/// extended information about this log entry; associative list
	var/list/extended_data

/datum/log_entry/New(message)
	..()
	SHOULD_CALL_PARENT(TRUE)
	unix_timestamp = world.realtime
	world_timestamp = world.time
	round_id = GLOB.round_id
	server_name = CONFIG_GET(string/cross_comms_name) || "Unknown"
	if(!category)
		CRASH("Log entry created without a category.")
	if(!message)
		CRASH("Log entry created without a message.")
	src.message = message
	SSlogging.append_entry(src)

/datum/log_entry/proc/as_private()
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	private = TRUE
	return src

/datum/log_entry/proc/with_location(atom/location)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(istype(location, /client)) // heathens
		var/client/client = location
		location = client.mob
	location = list(location.x, location.y, location.z)
	return src

/datum/log_entry/proc/with_tags(...)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	LAZYINITLIST(tags)
	for(var/tag in args)
		tags += tag
	return src

/datum/log_entry/proc/with_source(source, append_client_extended_data = TRUE)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/client/client = get_player_client(source)
	if(client)
		source_ckey = client.ckey
		if(append_client_extended_data)
			with_extended_data("client_mob_name", client.mob.name)
			with_extended_data("client_mob_type", client.mob.type)
			with_extended_data("client_is_observer", isobserver(client.mob))
			with_extended_data("client_is_admin", is_admin(client.mob))
	source = "[source]"
	source_weakref = WEAKREF(source)
	return src

/datum/log_entry/proc/with_target(target)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/client/client = get_player_client(target)
	if(client)
		target_ckey = client.ckey
	target = "[target]"
	return src

/datum/log_entry/proc/with_extended_data(key, value)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	LAZYINITLIST(extended_data)
	extended_data[key] = value
	return src

/// Construct this log entry into a list, ready for JSON encoding. Add your own data to the list before returning it.
/datum/log_entry/proc/to_list()
	RETURN_TYPE(/list)
	SHOULD_CALL_PARENT(TRUE)
	var/list/json = list(
		"version" = version,
		"unix_timestamp" = unix_timestamp,
		"world_timestamp" = world_timestamp,
		"round_id" = round_id,
		"server_name" = server_name,
		"category" = category,
		"private" = private,
		"location" = location,
		"tags" = tags,
		"source_name" = source_name,
		"source_ckey" = source_ckey,
		"target_name" = target_name,
		"target_ckey" = target_ckey,
		"extended_data" = extended_data,
	)
	return json

/datum/log_entry/proc/to_json()
	SHOULD_NOT_OVERRIDE(TRUE)
	return json_encode(to_list())

/**
 * Gets the textual representation of this log entry.
 * The default implementation shows the category, message, source, and target given they exist.
 */
/datum/log_entry/proc/to_text()
	var/source_info = source_ckey || source_name || "Unknown Source"
	var/target_info = target_ckey || target_name
	if(source_info)
		if(source_info == target_info)
			target_info = null
		else
			source_info = "\[[source_info]\]"
	if(target_info)
		target_info = " -> \[[target_info]\]"
	return "<div title='This is the default to_text implementation'><u>?</u></div>([category])[source_info][target_info]: [message]"

/**
 * This proc is called when the log entry is inspected in-game by someone viewing the logs.
 * The default implementation will call debug_variables on the source if it exists.
 */
/datum/log_entry/proc/inspect(mob/inspector)
	var/datum/source_datum = source_weakref?.resolve()
	if(!source_datum)
		to_chat(inspector, span_warning("This log entry has no source or the source has been garbage collected."))
		return
	inspector.client?.debug_variables(source_datum)
