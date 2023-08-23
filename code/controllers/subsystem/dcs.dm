PROCESSING_SUBSYSTEM_DEF(dcs)
	name = "Datum Component System"
	flags = SS_NO_INIT
	wait = 1 SECONDS

	var/list/elements_by_type = list()

	/**
	 * A nested assoc list of bespoke element types (keys) and superlists containing all lists used as arguments (values).
	 * Inside the superlists, lists that've been sorted alphabetically are keys, while the original unsorted lists are values.
	 *
	 * e.g. list(
	 *	/datum/element/first = list(list(A, B, C) = list(B, A, C), list(A, B) = list(A, B)),
	 *	/datum/element/second = list(list(B, C) = list(C, B), list(D) = list(D)),
	 * )
	 *
	 * Used by the dcs_check_list_arguments unit test.
	 */
	var/list/arguments_that_are_lists_by_element = list()
	/**
	 * An assoc list of list instances and their sorted counterparts.
	 *
	 * e.g. list(
	 *	list(B, A, C) = list(A, B, C),
	 *	list(C, B) = list(B, C),
	 * )
	 *
	 * Used to make sure each list instance is sorted no more than once, or the unit test won't work.
	 */
	var/list/sorted_arguments_that_are_lists = list()

/datum/controller/subsystem/processing/dcs/Recover()
	_listen_lookup = SSdcs._listen_lookup

/datum/controller/subsystem/processing/dcs/proc/GetElement(list/arguments, init_element = TRUE)
	var/datum/element/eletype = arguments[1]
	var/element_id = eletype

	if(!ispath(eletype, /datum/element))
		CRASH("Attempted to instantiate [eletype] as a /datum/element")

	if(initial(eletype.element_flags) & ELEMENT_BESPOKE)
		element_id = length(arguments) == 1 ? "[arguments[1]]" : GetIdFromArguments(arguments)

	. = elements_by_type[element_id]
	if(. || !init_element)
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
	var/list/fullid = list(eletype)
	var/list/named_arguments
	for(var/i in initial(eletype.argument_hash_start_idx) to length(arguments))
		var/key = arguments[i]

		if(istext(key))
			var/value = arguments[key]
			if (isnull(value))
				fullid += key
			else
				if (!istext(value) && !isnum(value))
					if(PERFORM_ALL_TESTS(dcs_check_list_arguments) && islist(value))
						add_to_arguments_that_are_lists(value, eletype)
					value = REF(value)

				if (!named_arguments)
					named_arguments = list()

				named_arguments[key] = value
			continue

		if (isnum(key))
			fullid += key
		else
			if(PERFORM_ALL_TESTS(dcs_check_list_arguments) && islist(key))
				add_to_arguments_that_are_lists(key, eletype)
			fullid += REF(key)

	if(named_arguments)
		named_arguments = sortTim(named_arguments, GLOBAL_PROC_REF(cmp_text_asc))
		fullid += named_arguments

	return list2params(fullid)

/**
 * Offloading the first half of the dcs_check_list_arguments here, which is populating the superlist
 * with sublists that will be later compared with each other by the dcs_check_list_arguments unit test.
 */
/datum/controller/subsystem/processing/dcs/proc/add_to_arguments_that_are_lists(list/argument, datum/element/element_type)
	if(initial(element_type.element_flags) & ELEMENT_NO_LIST_UNIT_TEST)
		return
	var/list/element_type_superlist = arguments_that_are_lists_by_element[element_type]
	if(!element_type_superlist)
		arguments_that_are_lists_by_element[element_type] = element_type_superlist = list()

	var/list/sorted_argument = argument
	if(!(initial(element_type.element_flags) & ELEMENT_DONT_SORT_LIST_ARGS))
		sorted_argument = sorted_arguments_that_are_lists[argument]
		if(!sorted_argument)
			sorted_arguments_that_are_lists[argument] = sorted_argument = sortTim(argument.Copy(), GLOBAL_PROC_REF(cmp_embed_text_asc))

	element_type_superlist[sorted_argument] = argument
