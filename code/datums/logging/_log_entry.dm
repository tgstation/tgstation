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
	VAR_PROTECTED/version = "0.0.0"
	/// The unix timestamp this log entry was created.
	VAR_PRIVATE/unix_timestamp = 0
	/// The world.time this log entry was created.
	VAR_PRIVATE/world_timestamp = 0
	/// The round this log entry was created on.
	VAR_PRIVATE/round_id = 0
	/// The server this log entry was created on.
	VAR_PRIVATE/server_name

	VAR_PRIVATE/key

	/// Required. The category this log entry falls under.
	var/category
	/// Required. The message this log entry contains.
	var/message
	/// Required but defaults to FALSE. Whether this log entry is public or not.
	var/private = FALSE
	/// Optional. The location this log entry was created at.
	var/list/location
	/// Optional but highly recommeneded. A lazy list of tags that can be used to filter this log entry.
	var/list/tags

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
	/// Is this log entry finalized and sent to SSlogging
	VAR_PRIVATE/finalized = FALSE

/datum/log_entry/New(message)
	..()
	SHOULD_CALL_PARENT(TRUE)
	var/static/next_key = 0
	key = "[next_key++]"
	unix_timestamp = world.realtime + 946702800 // Waiting on rustg update // rustg_unix_timestamp()
	world_timestamp = world.time
	round_id = GLOB.round_id
	server_name = "[world.address]:[world.port]"
	if(!category)
		CRASH("Log entry created without a category.")
	if(!message)
		CRASH("Log entry created without a message.")
	src.message = message
	// automatically finalize after a tick, if not finalized manually
	addtimer(CALLBACK(src, .proc/finalize), 1)

/datum/log_entry/proc/finalize()
	if(finalized)
		return
	SSlogging.append_entry(src)
	finalized = TRUE

/datum/log_entry/Destroy(force, ...)
	if(!force)
		stack_trace("Attempting to Destroy a log entry; this is likely a bug.")
		if(!finalized)
			// We were attempted to be del'd by Byond because nothing held a reference to us
			// This is almost guarenteed to be due to a runtime in /New so we will now yell loudly about that
			finalize()
			stack_trace("[type] was never finalized. Finalize should be called in /New() of the log entry after all data is set.")
		return QDEL_HINT_LETMELIVE
	// I don't know why we are being force del'd but we will acknowledge it
	LAZYREMOVEASSOC(SSlogging.entries, category, src)
	return ..()

/datum/log_entry/proc/as_private()
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(finalized)
		CRASH("Cannot modify finalized log entry.")
	private = TRUE
	return src

/datum/log_entry/proc/with_location(atom/location)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(finalized)
		CRASH("Cannot modify finalized log entry.")
	if(istype(location, /client)) // heathens
		var/client/client = location
		location = client.mob
	location = list(location.x, location.y, location.z)
	return src

/datum/log_entry/proc/with_tags(...)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(finalized)
		CRASH("Cannot modify finalized log entry.")
	LAZYINITLIST(tags)
	for(var/tag in args)
		tags += tag
	return src

/datum/log_entry/proc/with_source(source, append_client_extended_data = TRUE)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(finalized)
		CRASH("Cannot modify finalized log entry.")
	var/client/client = get_player_client(source)
	if(client)
		source_ckey = client.ckey
		source_name = client.mob.name
		if(append_client_extended_data)
			with_extended_data("source_mob_type", client.mob.type)
			with_extended_data("source_client_is_admin", is_admin(client.mob))
	source_name = "[source]"
	source_weakref = WEAKREF(source)
	return src

/datum/log_entry/proc/with_target(target)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(finalized)
		CRASH("Cannot modify finalized log entry.")
	var/client/client = get_player_client(target)
	if(client)
		target_ckey = client.ckey
	target = "[target]"
	return src

/datum/log_entry/proc/with_extended_data(key, value)
	RETURN_TYPE(/datum/log_entry)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(finalized)
		CRASH("Cannot modify finalized log entry.")
	LAZYINITLIST(extended_data)
	extended_data[key] = value
	return src

/// Construct this log entry into a list, ready for JSON encoding. Duplicate keys will be overwritten during json encoding.
/datum/log_entry/proc/to_list()
	RETURN_TYPE(/list)
	return list()

/datum/log_entry/proc/final_list()
	RETURN_TYPE(/list)
	. = to_list()
	. += list(
		"key" = key,
		"version" = version,
		"unix_timestamp" = unix_timestamp,
		"world_timestamp" = world_timestamp,
		"round_id" = round_id,
		"server_name" = server_name,
		"category" = category,
		"message" = message,
		"private" = private,
		"text" = to_text(),
	)
	if(location)
		.["location"] = location
	if(tags)
		.["tags"] = tags
	if(source_name)
		.["source_name"] = source_name
	if(source_ckey)
		.["source_ckey"] = source_ckey
	if(target_name)
		.["target_name"] = target_name
	if(target_ckey)
		.["target_ckey"] = target_ckey
	if(extended_data)
		.["extended_data"] = extended_data

/datum/log_entry/proc/to_json()
	SHOULD_NOT_OVERRIDE(TRUE)
	return json_encode(final_list())

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
	return "[source_info][target_info]: [message]"

/**
 * This proc is called when the log entry is inspected in-game by someone viewing the logs.
 * The default implementation will call debug_variables on the source if it exists.
 */
/datum/log_entry/proc/inspect(mob/inspector)
	var/datum/source_datum = source_weakref?.resolve()
	if(!source_datum)
		to_chat(inspector, span_warning("This log entry has no source or the source has been garbage collected."))
		return
	if(ismob(source_datum))
		var/mob/mob = source_datum
		if(mob.client)
			return inspector.client?.holder?.show_player_panel(mob)
	inspector.client?.debug_variables(source_datum)

/datum/log_entry/proc/get_key()
	return key
