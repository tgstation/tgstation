PROCESSING_SUBSYSTEM_DEF(dcs)
	name = "Datum Component System"
	flags = SS_NO_INIT
	wait = 1 SECONDS

	var/list/elements_by_type = list()

/datum/controller/subsystem/processing/dcs/Recover()
	comp_lookup = SSdcs.comp_lookup

/datum/controller/subsystem/processing/dcs/proc/GetElement(list/arguments, source_path)
	var/datum/element/eletype = arguments[1]
	var/element_id = eletype

	if(!ispath(eletype, /datum/element))
		CRASH("Attempted to instantiate [eletype] as a /datum/element")

	if(initial(eletype.element_flags) & ELEMENT_BESPOKE)
		element_id = GetIdFromArguments(arguments, source_path)

	. = elements_by_type[element_id]
	if(.)
		return
	. = elements_by_type[element_id] = new eletype

#define CACHED_ID_INFO_KEY_SEGMENTS 1
#define CACHED_ID_INFO_KEY_ID 2

#define CACHED_ID_INFO_HEURISTIC_BLOCKED 1

/****
	* Generates an id for bespoke elements when given the argument list
	* Generating the id here is a bit complex because we need to support named arguments
	* Named arguments can appear in any order and we need them to appear after ordered arguments
	* We assume that no one will pass in a named argument with a value of null
	**/
/datum/controller/subsystem/processing/dcs/proc/GetIdFromArguments(list/arguments, source_path)
	// We heuristically assume that most source paths will be generating the same element.
	// The code works even if this isn't true, but even with the cost of checking for confirmation,
	// this is still significantly faster, mostly because \ref[] is really slow.
	var/static/list/ids_per_type = list()

	var/datum/element/eletype = arguments[1]

	var/list/cached_id_info = ids_per_type[eletype]?[source_path]
	if (islist(cached_id_info))
		var/list/segments = cached_id_info[CACHED_ID_INFO_KEY_SEGMENTS]
		var/segments_length = length(segments)

		if (segments_length == length(arguments))
			var/all_valid = TRUE

			for (var/index in initial(eletype.id_arg_index) to segments_length)
				if (arguments[index] != segments[index])
					all_valid = FALSE
					ids_per_type[eletype][source_path] = CACHED_ID_INFO_HEURISTIC_BLOCKED
					break

			if (all_valid)
				return cached_id_info[CACHED_ID_INFO_KEY_ID]

	var/list/fullid = list("[eletype]")
	var/list/named_arguments = list()

	for(var/i in initial(eletype.id_arg_index) to length(arguments))
		var/key = arguments[i]

		if(istext(key))
			var/value = arguments[key]
			if (isnull(value))
				fullid += key
			else
				if (!istext(value) && !isnum(value))
					value = REF(value)
				named_arguments[key] = value

			continue

		if (isnum(key))
			fullid += "[key]"
		else
			fullid += REF(key)

	if(length(named_arguments))
		named_arguments = sortTim(named_arguments, /proc/cmp_text_asc)
		fullid += named_arguments

	var/id = list2params(fullid)

	if (isnull(cached_id_info))
		if (isnull(ids_per_type[eletype]))
			ids_per_type[eletype] = list((source_path) = list(arguments.Copy(), id))
		else
			ids_per_type[eletype][source_path] = list(arguments.Copy(), id)

	return id

#undef CACHED_ID_INFO_KEY_SEGMENTS
#undef CACHED_ID_INFO_KEY_ID
#undef CACHED_ID_INFO_HEURISTIC_BLOCKED
