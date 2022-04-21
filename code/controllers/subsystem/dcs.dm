PROCESSING_SUBSYSTEM_DEF(dcs)
	name = "Datum Component System"
	flags = SS_NO_INIT
	wait = 1 SECONDS

	var/list/elements_by_type = list()

/datum/controller/subsystem/processing/dcs/Recover()
	comp_lookup = SSdcs.comp_lookup

/datum/controller/subsystem/processing/dcs/proc/GetElement(list/arguments)
	var/datum/element/eletype = arguments[1]
	var/element_id = eletype

	if(!ispath(eletype, /datum/element))
		CRASH("Attempted to instantiate [eletype] as a /datum/element")

	if(initial(eletype.element_flags) & ELEMENT_BESPOKE)
		element_id = GetIdFromArguments(arguments)

	. = elements_by_type[element_id]
	if(.)
		return
	. = elements_by_type[element_id] = new eletype

/****
	* Generates an id for bespoke elements when given the argument list
	* Generating the id here is a bit complex because we need to support named arguments
	* Named arguments can appear in any order and we need them to appear after ordered arguments
	* We assume that no one will pass in a named argument with a value of null
	**/
/datum/controller/subsystem/processing/dcs/proc/GetIdFromArguments(list/arguments)
	var/datum/element/eletype = arguments[1]
	var/list/fullid = list("[eletype]")
	var/list/named_arguments = list()
	for(var/i in initial(eletype.id_arg_index) to length(arguments))
		var/key = arguments[i]
		var/value
		if(istext(key))
			value = arguments[key]
		if(!(istext(key) || isnum(key)))
			key = REF(key)
		key = "[key]" // Key is stringified so numbers dont break things
		if(!isnull(value))
			if(!(istext(value) || isnum(value)))
				value = REF(value)
			named_arguments["[key]"] = value
		else
			fullid += "[key]"

	if(length(named_arguments))
		named_arguments = sort_list(named_arguments)
		fullid += named_arguments
	return list2params(fullid)
