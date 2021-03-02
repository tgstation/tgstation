// JATUM. System for making the serializing and deserializing of PoD types easier

/**
 * Gets the flat list that can be passed in a `new /type(argslist(retval))` expression to recreate the datum. Must only return a list containing values that can be JATUM serialized
 */
/datum/proc/jatum_new_arglist()
	return null

/// The JATUM version used for serializing and deserializing
#define JATUM_VERSION 1

/**
 * Attempt to serialize a given value to the JATUM format.
 *
 * * value - The var to serialize.
 */
/world/proc/jatum_serialize(value)
	var/list/json_structure
	try
		json_structure = _jatum_serialize_value(value, list())
	catch(var/exception/e)
		CRASH(e)

	return json_encode(list(
		"jatum\\version" = JATUM_VERSION,
		"content" = json_structure
	))

/world/proc/_jatum_serialize_value(value, list/seen_references)
	if(isnull(value))
		return null

	if(isnum(value) || istext(value))
		return list(
			"type" = "jatum\\raw",
			"value" = value
		)

	if(ispath(value))
		return list(
			"type" = "jatum\\path",
			"path" = value
		)

	var/ref = "\ref[value]"
	var/existing_ref = seen_references[ref]
	if(existing_ref)
		return list(
			"type" = "jatum\\ref",
			"jatum\\id" = existing_ref)

	// Simple incrementing ID system
	var/ref_id = seen_references.len + 1
	seen_references[ref] = ref_id

	if(istype(value, /matrix)) // matricies work with json_encode so use a custom arglist
		return list(
			"jatum\\id" = ref_id,
			"type" = "/matrix",
			"jatum\\new_arglist" = _jatum_serialize_value(json_decode(json_encode(value))), seen_references)

	if(istype(value, /savefile)) // Just store the path, rely on BYOND for the rest
		var/savefile/save = value
		return list(
			"jatum\\id" = ref_id,
			"type" = "/savefile",
			"jatum\\new_arglist" = _jatum_serialize_value(list(save.name), seen_references)
		)

	if(istype(value, /regex)) // store construct params
		var/regex/rx = value
		return list(
			"jatum\\id" = ref_id,
			"type" = "/regex",
			"name" = rx.name,
			"flags" = rx.flags
		)

	if(islist(value))
		// Serialize all lists as dicts, list("a") and list("a" = null) can't be differentiated in DM
		var/list_contents = list()
		for(var/key in value)
			var/got_l_value
			var/l_value
			try
				l_value = value[key]
				got_l_value = TRUE
			catch
				// Expected, indicates a flat list

			if(got_l_value)
				list_contents += list(list(
					"key" = _jatum_serialize_value(key, seen_references),
					"value" = _jatum_serialize_value(l_value, seen_references)
				))
			else
				list_contents += list(list(
					"value" = _jatum_serialize_value(key, seen_references)
				))
		return list(
			"jatum\\id" = ref_id,
			"type" = "/list",
			"contents" = list_contents)

	// JATUM is really only meant for PoD types
	if(!istype(value, /datum)\
		|| istype(value, /image)\
		|| istype(value, /icon)\
		|| istype(value, /sound)\
		|| istype(value, /atom)\
		|| istype(value, /mutable_appearance)\
		|| istype(value, /client)\
		|| istype(value, /database))
		CRASH("Incompatible type for JATUM: [value]([ref])")

	// Confirmed /datum type
	var/datum/D = value
	var/json_structure = list(
		"jatum\\id" = ref_id,
		"type" = "[D.type]"
		)
	var/new_arglist = D.jatum_new_arglist()
	if(new_arglist)
		if(!islist(new_arglist))
			CRASH("Non-list return from jatum_new_arglist from [D.type]!")
		json_structure["jatum\\new_arglist"] = _jatum_serialize_value(new_arglist, seen_references)

	for(var/var_name in D.vars)
		if(var_name == "vars" || var_name == "parent_type" || var_name == "type")
			continue

		var/d_value = D.vars[var_name]
		json_structure[var_name] = _jatum_serialize_value(d_value, seen_references)

	return json_structure

/**
 * Attempt to create a value from a JATUN JSON.
 *
 * * json - The JSON to deserialize.
 */
/world/proc/jatum_deserialize(json)
	if(!istext(json))
		CRASH("Non-text passed!")

	var/list/structure = json_decode(json)
	if(!structure)
		CRASH("Invalid JSON!")

	var/jatum_version = structure["jatum\\version"]
	if(isnull(jatum_version))
		CRASH("Not JATUM JSON!")

	if(jatum_version != JATUM_VERSION)
		CRASH("Incompatible JATUM_VERSION")

	try
		return _jatum_deserialize_value(structure["content"], list())
	catch(var/exception/e)
		CRASH(e)

/world/proc/_jatum_deserialize_value(list/structure, list/active_references)
	if(!structure)
		return null

	var/ref_id = structure["jatum\\id"]
	var/entry_type = structure["type"]
	switch(entry_type)
		if("jatum\\raw")
			return structure["value"]
		if("jatum\\path")
			var/string_path = structure["path"]
			var/path = text2path(string_path)
			if(!path)
				CRASH("Invalid path: [string_path]")
			return path
		if("jatum\\ref")
			var/result = active_references[ref_id]
			if(!result)
				CRASH("Missing reference ID [ref_id]!")
			return result
		if("/regex")
			var/name = structure["name"]
			var/flags = structure["flags"]
			if(flags)
				. = new /regex(name, flags)
			else
				. = new /regex(name)
		if("/list")
			var/list_contents = structure["contents"]
			. = list()
			for(var/entry in list_contents)
				var/key = entry["key"]
				var/l_value = entry["value"]
				if(key)
					.[_jatum_deserialize_value(key, active_references)] = _jatum_deserialize_value(l_value, active_references)
				else
					. += _jatum_deserialize_value(l_value, active_references)

		else
			// everything else is a /datum and instantiates via reflection
			var/list/jatum_arglist = structure["jatum\\new_arglist"]
			var/full_type = text2path(entry_type)
			if(!full_type)
				CRASH("Invalid type: [entry_type]")
			if(jatum_arglist)
				var/list/new_arglist = _jatum_deserialize_value(jatum_arglist, active_references)
				. = new full_type(arglist(new_arglist))
			else
				. = new full_type

			var/datum/D = .
			for(var/var_name in structure)
				if(var_name == "type"\
					|| var_name == "jatum\\id"\
					|| var_name == "jatum\\new_arglist")
					continue
				var/value = structure[var_name]
				D.vars[var_name] = _jatum_deserialize_value(value, active_references)

	active_references["[ref_id]"] = .
